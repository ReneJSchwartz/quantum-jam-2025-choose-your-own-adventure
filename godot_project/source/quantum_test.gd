extends Node
## Smoke tests for shared Quantum API bridge behavior.

const QuantumApiBridgeScript = preload("res://source/dialogue/quantum_api_bridge.gd")
const REGRESSION_ARGUMENT := "--quantum-regression"
const TEST_BASE_URL_ENV := "QUANTUM_API_TEST_BASE_URL"

var _pending_health_done := false
var _pending_health_success := false
var _pending_health_payload: Dictionary = {}

var _pending_transform_done := false
var _pending_transform_success := false
var _pending_transform_payload: Dictionary = {}
var _pending_gate_done := false
var _pending_gate_success := false
var _pending_gate_payload: Dictionary = {}
var _regression_failed := false

func _ready():
	var test_base_url := OS.get_environment(TEST_BASE_URL_ENV).strip_edges()
	if !test_base_url.is_empty():
		ProjectSettings.set_setting(QuantumApiBridgeScript.SETTINGS_BASE_URL, test_base_url)
		print("[QuantumTest] Using fixture base URL from ", TEST_BASE_URL_ENV)
	print("🧪 Testing Quantum API bridge integration...")
	await test_quantum_api_bridge()
	if REGRESSION_ARGUMENT in OS.get_cmdline_user_args():
		get_tree().quit(1 if _regression_failed else 0)

func test_quantum_api_bridge() -> void:
	await _test_health_check()
	await _test_transform_text()
	await _test_gate()
	await _test_api_down_fallback()
	print("🎉 Quantum bridge smoke test complete")

func _test_health_check() -> void:
	var result := await _await_health_check()
	if bool(result["request_success"]):
		print("✅ Health check succeeded")
	else:
		_regression_failed = true
		print("❌ Health check failed: ", result["payload"])

func _test_transform_text() -> void:
	var source_text := "memory signal and quantum circuit"
	var fallback_text := source_text + " [fallback]"
	var result := await _await_transform(source_text, fallback_text)
	var payload := result["payload"] as Dictionary
	var transformed := str(payload.get("transformed", ""))

	if transformed.is_empty():
		_regression_failed = true
		print("❌ Transform returned empty payload: ", payload)
		return

	print("✅ transform_text returned transformed content")
	print("   transformed: ", transformed)
	print("   category_counts: ", payload.get("category_counts", {}))

func _test_gate() -> void:
	var result := await _await_gate("bit_flip")
	if bool(result["request_success"]):
		print("✅ gate execution succeeded")
		return
	_regression_failed = true
	print("❌ Gate execution failed: ", result["payload"])

func _test_api_down_fallback() -> void:
	var bridge = QuantumApiBridgeScript.get_or_create(self)
	if bridge == null:
		_regression_failed = true
		print("❌ Bridge unavailable for fallback test")
		return

	var had_setting := ProjectSettings.has_setting(QuantumApiBridgeScript.SETTINGS_BASE_URL)
	var original_base_url := str(ProjectSettings.get_setting(QuantumApiBridgeScript.SETTINGS_BASE_URL, QuantumApiBridgeScript.DEFAULT_BASE_URL))

	ProjectSettings.set_setting(QuantumApiBridgeScript.SETTINGS_BASE_URL, "http://127.0.0.1:65535/public-facing/api/quantum")
	bridge.refresh_config()

	var fallback_text := "fallback survives outage"
	var result := await _await_transform("this request should fail", fallback_text)
	var payload := result["payload"] as Dictionary
	var transformed := str(payload.get("transformed", ""))

	if !had_setting:
		ProjectSettings.set_setting(QuantumApiBridgeScript.SETTINGS_BASE_URL, QuantumApiBridgeScript.DEFAULT_BASE_URL)
	else:
		ProjectSettings.set_setting(QuantumApiBridgeScript.SETTINGS_BASE_URL, original_base_url)
	bridge.refresh_config()

	if transformed == fallback_text and !bool(result["request_success"]):
		print("✅ API-down fallback returned without freezing")
	else:
		_regression_failed = true
		print("❌ API-down fallback behavior unexpected: ", result)

func _await_health_check() -> Dictionary:
	_pending_health_done = false
	_pending_health_success = false
	_pending_health_payload = {}

	QuantumApiBridgeScript.health_check(self, Callable(self, "_on_health_check_complete"))

	while !_pending_health_done:
		await get_tree().process_frame

	return {
		"request_success": _pending_health_success,
		"payload": _pending_health_payload,
	}

func _await_transform(text: String, fallback_text: String) -> Dictionary:
	_pending_transform_done = false
	_pending_transform_success = false
	_pending_transform_payload = {}

	QuantumApiBridgeScript.transform_text(
		self,
		text,
		Callable(self, "_on_transform_complete"),
		fallback_text
	)

	while !_pending_transform_done:
		await get_tree().process_frame

	return {
		"request_success": _pending_transform_success,
		"payload": _pending_transform_payload,
	}

func _await_gate(gate_type: String) -> Dictionary:
	_pending_gate_done = false
	_pending_gate_success = false
	_pending_gate_payload = {}

	QuantumApiBridgeScript.run_gate(self, gate_type, Callable(self, "_on_gate_complete"))

	while !_pending_gate_done:
		await get_tree().process_frame

	return {
		"request_success": _pending_gate_success,
		"payload": _pending_gate_payload,
	}

func _on_health_check_complete(call_success: bool, call_payload: Dictionary) -> void:
	_pending_health_success = call_success
	_pending_health_payload = call_payload
	_pending_health_done = true

func _on_transform_complete(call_success: bool, call_payload: Dictionary) -> void:
	_pending_transform_success = call_success
	_pending_transform_payload = call_payload
	_pending_transform_done = true

func _on_gate_complete(call_success: bool, call_payload: Dictionary) -> void:
	_pending_gate_success = call_success
	_pending_gate_payload = call_payload
	_pending_gate_done = true
