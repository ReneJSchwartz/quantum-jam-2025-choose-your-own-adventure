from __future__ import annotations

from pathlib import Path
from typing import Any
import sys

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import app as gateway


class FakeResponse:
    def __init__(self, status_code: int = 200, payload: dict[str, Any] | None = None) -> None:
        self.status_code = status_code
        self._payload = payload if payload is not None else {"ok": True}

    def json(self) -> dict[str, Any]:
        return self._payload


@pytest.fixture()
def client(monkeypatch: pytest.MonkeyPatch):
    calls: list[dict[str, Any]] = []

    def fake_request(method: str, url: str, **kwargs: Any) -> FakeResponse:
        calls.append({"method": method, "url": url, **kwargs})
        return FakeResponse(payload={"ok": True, "url": url})

    monkeypatch.setattr(gateway.requests, "request", fake_request)
    app = gateway.create_app(
        {
            "TESTING": True,
            "QUANTUM_GAME_API_KEY": "test-only-upstream-key",
            "QUANTUM_GAME_ALLOWED_ORIGINS": {"https://davidjgrimsley.com"},
            "RATELIMIT_STORAGE_URI": "memory://",
        }
    )
    return app.test_client(), calls


def test_gateway_allows_only_game_routes_and_hides_key_from_client(client) -> None:
    test_client, calls = client
    response = test_client.post(
        "/v1/gates/run",
        json={"gate_type": "bit_flip", "unexpected": "discarded"},
        headers={"Origin": "https://davidjgrimsley.com", "X-API-Key": "player-key"},
    )

    assert response.status_code == 200
    assert response.headers["Access-Control-Allow-Origin"] == "https://davidjgrimsley.com"
    assert calls[0]["url"].endswith("/v1/gates/run")
    assert calls[0]["headers"]["X-API-Key"] == "test-only-upstream-key"
    assert calls[0]["json"] == {"gate_type": "bit_flip"}
    assert test_client.post("/v1/jobs/circuits", json={}).status_code == 404
    assert test_client.post("/v1/transpile", json={}).status_code == 404


def test_gateway_validates_payloads_and_sanitizes_upstream_errors(client, monkeypatch: pytest.MonkeyPatch) -> None:
    test_client, _calls = client
    assert test_client.post("/v1/text/transform", json={"text": "x" * 2001}).status_code == 413
    assert test_client.post("/v1/gates/run", json={"gate_type": "not-a-gate"}).status_code == 400

    monkeypatch.setattr(gateway.requests, "request", lambda *_args, **_kwargs: FakeResponse(500, {"secret": "never expose"}))
    response = test_client.post("/v1/text/transform", json={"text": "hello"})
    assert response.status_code == 500
    assert response.get_json() == {
        "error": "upstream_error",
        "message": "Quantum game service request failed.",
        "status_code": 500,
    }


def test_gateway_cors_is_explicit_and_preflight_has_no_upstream_call(client) -> None:
    test_client, calls = client
    response = test_client.options("/v1/text/transform", headers={"Origin": "https://davidjgrimsley.com"})
    assert response.status_code == 204
    assert response.headers["Access-Control-Allow-Origin"] == "https://davidjgrimsley.com"
    assert calls == []
    rejected_origin = test_client.get("/v1/health", headers={"Origin": "https://example.invalid"})
    assert "Access-Control-Allow-Origin" not in rejected_origin.headers
