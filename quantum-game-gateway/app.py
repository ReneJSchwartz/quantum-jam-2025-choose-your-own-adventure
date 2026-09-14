"""Narrow server-side gateway for the public Echoes of Light game only."""

from __future__ import annotations

import os
from typing import Any

import requests
from flask import Flask, Response, jsonify, request
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from werkzeug.exceptions import RequestEntityTooLarge
from werkzeug.middleware.proxy_fix import ProxyFix

DEFAULT_ALLOWED_ORIGINS = (
    "https://davidjgrimsley.com",
    "https://www.davidjgrimsley.com",
)
MAX_TEXT_LENGTH = 2_000
MAX_BODY_BYTES = 16 * 1024


def _origins(value: str | None) -> set[str]:
    raw = value or ",".join(DEFAULT_ALLOWED_ORIGINS)
    return {origin.strip().rstrip("/") for origin in raw.split(",") if origin.strip()}


def _error(code: str, message: str, status_code: int) -> tuple[Response, int]:
    return jsonify({"error": code, "message": message, "status_code": status_code}), status_code


def create_app(overrides: dict[str, Any] | None = None) -> Flask:
    app = Flask(__name__)
    app.config.from_mapping(
        QUANTUM_GAME_API_KEY=os.environ.get("QUANTUM_GAME_API_KEY", ""),
        QUANTUM_GAME_UPSTREAM_BASE=os.environ.get("QUANTUM_GAME_UPSTREAM_BASE", "http://127.0.0.1:8000/v1"),
        QUANTUM_GAME_ALLOWED_ORIGINS=_origins(os.environ.get("QUANTUM_GAME_ALLOWED_ORIGINS")),
        QUANTUM_GAME_UPSTREAM_TIMEOUT_SECONDS=float(os.environ.get("QUANTUM_GAME_UPSTREAM_TIMEOUT_SECONDS", "10")),
        RATELIMIT_STORAGE_URI=os.environ.get("REDIS_URL", "redis://127.0.0.1:6379/1"),
        MAX_CONTENT_LENGTH=MAX_BODY_BYTES,
    )
    if overrides:
        app.config.update(overrides)
    app.config["QUANTUM_GAME_UPSTREAM_BASE"] = str(app.config["QUANTUM_GAME_UPSTREAM_BASE"]).rstrip("/")
    app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1)

    limiter = Limiter(
        key_func=get_remote_address,
        app=app,
        storage_uri=app.config["RATELIMIT_STORAGE_URI"],
        default_limits=["120 per minute"],
    )

    @app.after_request
    def add_security_headers(response: Response) -> Response:
        origin = request.headers.get("Origin", "").rstrip("/")
        if origin and origin in app.config["QUANTUM_GAME_ALLOWED_ORIGINS"]:
            response.headers["Access-Control-Allow-Origin"] = origin
            response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
            response.headers["Access-Control-Allow-Headers"] = "Content-Type"
            response.headers["Vary"] = "Origin"
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["Cache-Control"] = "no-store"
        return response

    @app.errorhandler(RequestEntityTooLarge)
    def payload_too_large(_error_value: RequestEntityTooLarge) -> tuple[Response, int]:
        return _error("payload_too_large", "Request payload exceeds the game gateway limit.", 413)

    @app.errorhandler(429)
    def rate_limited(_error_value: Exception) -> tuple[Response, int]:
        return _error("rate_limited", "Too many game requests. Please retry shortly.", 429)

    def options() -> tuple[Response, int]:
        return "", 204

    def json_body() -> tuple[dict[str, Any] | None, tuple[Response, int] | None]:
        if not request.is_json:
            return None, _error("invalid_json", "A JSON request body is required.", 415)
        body = request.get_json(silent=True)
        if not isinstance(body, dict):
            return None, _error("invalid_json", "A JSON object is required.", 400)
        return body, None

    def forward(method: str, path: str, body: dict[str, Any] | None = None, protected: bool = False) -> tuple[Response, int] | Response:
        headers = {"Accept": "application/json"}
        if protected:
            api_key = str(app.config["QUANTUM_GAME_API_KEY"]).strip()
            if not api_key:
                app.logger.error("Echoes gateway is missing its dedicated upstream API key")
                return _error("gateway_misconfigured", "Game service is temporarily unavailable.", 503)
            headers["X-API-Key"] = api_key
        client_ip = request.remote_addr
        if client_ip:
            headers["X-Forwarded-For"] = client_ip
        headers["X-Forwarded-Proto"] = request.scheme
        try:
            upstream = requests.request(
                method,
                app.config["QUANTUM_GAME_UPSTREAM_BASE"] + path,
                json=body,
                headers=headers,
                timeout=(2.0, float(app.config["QUANTUM_GAME_UPSTREAM_TIMEOUT_SECONDS"])),
            )
        except requests.Timeout:
            return _error("gateway_timeout", "Quantum game service timed out.", 504)
        except requests.RequestException:
            return _error("gateway_unavailable", "Quantum game service is unavailable.", 502)

        if not 200 <= upstream.status_code < 300:
            return _error("upstream_error", "Quantum game service request failed.", upstream.status_code)
        try:
            payload = upstream.json()
        except ValueError:
            return _error("upstream_invalid_response", "Quantum game service returned an invalid response.", 502)
        if not isinstance(payload, dict):
            return _error("upstream_invalid_response", "Quantum game service returned an invalid response.", 502)
        return jsonify(payload), upstream.status_code

    @app.route("/v1/health", methods=["GET", "OPTIONS"])
    @limiter.limit("30 per minute")
    def health() -> tuple[Response, int] | Response:
        if request.method == "OPTIONS":
            return options()
        return forward("GET", "/health")

    @app.route("/v1/gates/run", methods=["POST", "OPTIONS"])
    @limiter.limit("30 per minute")
    def run_gate() -> tuple[Response, int] | Response:
        if request.method == "OPTIONS":
            return options()
        body, problem = json_body()
        if problem:
            return problem
        gate_type = body.get("gate_type")
        if gate_type not in {"bit_flip", "phase_flip", "rotation"}:
            return _error("invalid_gate", "gate_type must be bit_flip, phase_flip, or rotation.", 400)
        allowed: dict[str, Any] = {"gate_type": gate_type}
        if "rotation_angle_rad" in body:
            angle = body["rotation_angle_rad"]
            if isinstance(angle, bool) or not isinstance(angle, (int, float)):
                return _error("invalid_rotation_angle", "rotation_angle_rad must be numeric.", 400)
            allowed["rotation_angle_rad"] = angle
        return forward("POST", "/gates/run", allowed, protected=True)

    @app.route("/v1/text/transform", methods=["POST", "OPTIONS"])
    @limiter.limit("60 per minute")
    def transform_text() -> tuple[Response, int] | Response:
        if request.method == "OPTIONS":
            return options()
        body, problem = json_body()
        if problem:
            return problem
        text = body.get("text")
        if not isinstance(text, str) or not text.strip():
            return _error("invalid_text", "text must be a non-empty string.", 400)
        if len(text) > MAX_TEXT_LENGTH:
            return _error("text_too_long", "text exceeds the game gateway limit.", 413)
        return forward("POST", "/text/transform", {"text": text}, protected=True)

    return app


app = create_app()


if __name__ == "__main__":
    # Deployment is via systemd + gunicorn. This is local development only.
    app.run(host="127.0.0.1", port=8101, debug=False)
