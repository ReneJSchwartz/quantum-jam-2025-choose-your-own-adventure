class_name QuantumApiClient
extends Node

const DEFAULT_BASE_URL := "https://davidjgrimsley.com/public-facing/api/quantum/v1"
const DIRECT_API_KEY := ""
const SETTINGS_BASE_URL := "quantum_api/base_url"
const SETTINGS_BACKEND_PROXY_MODE := "quantum_api/backend_proxy_mode"
const SETTINGS_DIRECT_API_KEY := "quantum_api/direct_api_key"
const DEFAULT_BACKEND_PROXY_MODE := true

var base_url: String = DEFAULT_BASE_URL
var api_key: String = DIRECT_API_KEY
var backend_proxy_mode: bool = DIRECT_API_KEY.is_empty()

func _init(custom_base_url: String = DEFAULT_BASE_URL, custom_api_key: String = DIRECT_API_KEY, use_backend_proxy: bool = DIRECT_API_KEY.is_empty()) -> void:
	base_url = _normalize_base_url(custom_base_url)
	api_key = custom_api_key.strip_edges()
	backend_proxy_mode = use_backend_proxy

func set_base_url(url: String) -> void:
	base_url = _normalize_base_url(url)

func set_api_key(key: String) -> void:
	api_key = key.strip_edges()

func set_backend_proxy_mode(enabled: bool) -> void:
	backend_proxy_mode = enabled

func apply_project_settings() -> void:
	var configured_base_url := str(ProjectSettings.get_setting(SETTINGS_BASE_URL, DEFAULT_BASE_URL)).strip_edges()
	if configured_base_url.is_empty():
		configured_base_url = DEFAULT_BASE_URL

	set_base_url(configured_base_url)
	set_backend_proxy_mode(
		_variant_to_bool(
			ProjectSettings.get_setting(SETTINGS_BACKEND_PROXY_MODE, DEFAULT_BACKEND_PROXY_MODE),
			DEFAULT_BACKEND_PROXY_MODE
		)
	)
	set_api_key(str(ProjectSettings.get_setting(SETTINGS_DIRECT_API_KEY, DIRECT_API_KEY)).strip_edges())

func get_default_base_url() -> String:
	return DEFAULT_BASE_URL

func get_config_snapshot() -> Dictionary:
	return {
		"base_url": base_url,
		"backend_proxy_mode": backend_proxy_mode,
		"api_key_present": !api_key.is_empty(),
	}

func health_check(callback: Callable) -> void:
	_request_json("/health", HTTPClient.METHOD_GET, null, callback, false)

func transform_text(text: String, callback: Callable, fallback_text: String = "") -> void:
	var wrapped_callback := func(success: bool, payload: Dictionary) -> void:
		if success:
			callback.call(true, payload)
			return

		var fallback_payload: Dictionary = payload.duplicate(true)
		fallback_payload["original"] = text
		fallback_payload["transformed"] = fallback_text if !fallback_text.is_empty() else text
		if !fallback_payload.has("message"):
			fallback_payload["message"] = "Text transform failed"
		if !fallback_payload.has("status_code"):
			fallback_payload["status_code"] = 0
		callback.call(false, fallback_payload)

	_request_json(
		"/text/transform",
		HTTPClient.METHOD_POST,
		{"text": text},
		wrapped_callback,
		true
	)

func run_gate(gate_type: String, callback: Callable, rotation_angle_rad: Variant = null) -> void:
	var payload: Dictionary = {
		"gate_type": gate_type,
	}
	if rotation_angle_rad != null:
		payload["rotation_angle_rad"] = rotation_angle_rad

	_request_json("/gates/run", HTTPClient.METHOD_POST, payload, callback, true)

func _request_json(
	endpoint_path: String,
	method: int,
	payload: Variant,
	callback: Callable,
	requires_api_key: bool,
) -> void:
	var request_url: String = base_url + endpoint_path
	var method_name: String = _http_method_to_string(method)

	if requires_api_key and !backend_proxy_mode and api_key.is_empty():
		callback.call(
			false,
			{
				"error": "missing_api_key",
				"message": "Direct API-key mode is enabled, but no Quantum API key is configured.",
				"status_code": 0,
				"request_url": request_url,
				"endpoint_path": endpoint_path,
				"method": method_name,
				"backend_proxy_mode": backend_proxy_mode,
				"api_key_present": !api_key.is_empty(),
			},
		)
		return

	var http_request := HTTPRequest.new()
	add_child(http_request)

	http_request.request_completed.connect(
		func(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
			var parsed = _parse_response(result, response_code, body, request_url, endpoint_path, method_name)
			http_request.queue_free()
			callback.call(parsed["success"], parsed["payload"])
	)

	var body_string := ""
	var headers := _build_headers(requires_api_key, payload != null)
	if payload != null:
		body_string = JSON.stringify(payload)

	var error := http_request.request(request_url, headers, method, body_string)
	if error != OK:
		http_request.queue_free()
		callback.call(
			false,
			{
				"error": "request_start_failed",
				"message": "Failed to start HTTP request: " + error_string(error),
				"status_code": 0,
				"result": error,
				"result_text": error_string(error),
				"request_url": request_url,
				"endpoint_path": endpoint_path,
				"method": method_name,
				"backend_proxy_mode": backend_proxy_mode,
				"api_key_present": !api_key.is_empty(),
			},
		)

func _build_headers(requires_api_key: bool, include_json_content_type: bool) -> PackedStringArray:
	var headers: PackedStringArray = []
	if include_json_content_type:
		headers.append("Content-Type: application/json")
	if requires_api_key and !api_key.is_empty():
		headers.append("X-API-Key: " + api_key)
	return headers

func _parse_response(result: int, response_code: int, body: PackedByteArray, request_url: String, endpoint_path: String, method_name: String) -> Dictionary:
	var response_text := body.get_string_from_utf8()
	var payload: Dictionary = {}

	if !response_text.is_empty():
		var json := JSON.new()
		if json.parse(response_text) == OK and json.data is Dictionary:
			payload = json.data

	if result != HTTPRequest.RESULT_SUCCESS:
		if payload.is_empty():
			payload = {
				"error": "transport_error",
				"message": "HTTP transport failed: " + _http_request_result_to_message(result),
			}
		elif !payload.has("message"):
			payload["message"] = "HTTP transport failed: " + _http_request_result_to_message(result)

		payload["result"] = result
		payload["result_text"] = _http_request_result_to_message(result)
		payload["status_code"] = response_code
		payload["request_url"] = request_url
		payload["endpoint_path"] = endpoint_path
		payload["method"] = method_name
		payload["backend_proxy_mode"] = backend_proxy_mode
		payload["api_key_present"] = !api_key.is_empty()
		if !response_text.is_empty():
			payload["response_text"] = response_text.substr(0, min(response_text.length(), 512))
		return {"success": false, "payload": payload}

	if response_code >= 200 and response_code < 300:
		return {"success": true, "payload": payload}

	var default_message := response_text if !response_text.is_empty() else "Quantum API request failed"
	if response_code == 401:
		default_message = "Unauthorized (401). Configure quantum_api/direct_api_key or use a backend proxy endpoint that injects authentication."

	if payload.is_empty():
		payload = {
			"error": "http_error",
			"message": default_message,
		}
	elif !payload.has("message"):
		payload["message"] = default_message

	if response_code == 401:
		payload["error"] = "unauthorized"
		payload["auth_hint"] = "Set [quantum_api] direct_api_key and ensure the endpoint accepts your auth mode."

	payload["result"] = result
	payload["result_text"] = _http_request_result_to_message(result)
	payload["status_code"] = response_code
	payload["request_url"] = request_url
	payload["endpoint_path"] = endpoint_path
	payload["method"] = method_name
	payload["backend_proxy_mode"] = backend_proxy_mode
	payload["api_key_present"] = !api_key.is_empty()
	if !response_text.is_empty():
		payload["response_text"] = response_text.substr(0, min(response_text.length(), 512))
	return {"success": false, "payload": payload}

func _normalize_base_url(url: String) -> String:
	var normalized := url.strip_edges().trim_suffix("/")
	if normalized.is_empty():
		return DEFAULT_BASE_URL
	if normalized.ends_with("/v1"):
		return normalized
	return normalized + "/v1"

func _variant_to_bool(value: Variant, fallback: bool) -> bool:
	if value is bool:
		return value
	if value is int:
		return value != 0
	if value is String:
		var normalized: String = str(value).strip_edges().to_lower()
		if normalized == "1" or normalized == "true" or normalized == "yes" or normalized == "on":
			return true
		if normalized == "0" or normalized == "false" or normalized == "no" or normalized == "off":
			return false
	return fallback

func _http_method_to_string(method: int) -> String:
	match method:
		HTTPClient.METHOD_GET:
			return "GET"
		HTTPClient.METHOD_POST:
			return "POST"
		HTTPClient.METHOD_PUT:
			return "PUT"
		HTTPClient.METHOD_DELETE:
			return "DELETE"
		HTTPClient.METHOD_PATCH:
			return "PATCH"
		_:
			return "METHOD_" + str(method)

func _http_request_result_to_message(result: int) -> String:
	match result:
		HTTPRequest.RESULT_SUCCESS:
			return "SUCCESS"
		HTTPRequest.RESULT_CHUNKED_BODY_SIZE_MISMATCH:
			return "CHUNKED_BODY_SIZE_MISMATCH"
		HTTPRequest.RESULT_CANT_CONNECT:
			return "CANT_CONNECT"
		HTTPRequest.RESULT_CANT_RESOLVE:
			return "CANT_RESOLVE"
		HTTPRequest.RESULT_CONNECTION_ERROR:
			return "CONNECTION_ERROR"
		HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
			return "TLS_HANDSHAKE_ERROR"
		HTTPRequest.RESULT_NO_RESPONSE:
			return "NO_RESPONSE"
		HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED:
			return "BODY_SIZE_LIMIT_EXCEEDED"
		HTTPRequest.RESULT_BODY_DECOMPRESS_FAILED:
			return "BODY_DECOMPRESS_FAILED"
		HTTPRequest.RESULT_REQUEST_FAILED:
			return "REQUEST_FAILED"
		HTTPRequest.RESULT_DOWNLOAD_FILE_CANT_OPEN:
			return "DOWNLOAD_FILE_CANT_OPEN"
		HTTPRequest.RESULT_DOWNLOAD_FILE_WRITE_ERROR:
			return "DOWNLOAD_FILE_WRITE_ERROR"
		HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED:
			return "REDIRECT_LIMIT_REACHED"
		HTTPRequest.RESULT_TIMEOUT:
			return "TIMEOUT"
		_:
			return "RESULT_" + str(result)
