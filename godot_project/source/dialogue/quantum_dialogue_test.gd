extends Node
## Test script for gate-related Quantum API smoke checks.

const QuantumApiBridgeScript = preload("res://source/dialogue/quantum_api_bridge.gd")

signal gate_call_completed(call_success: bool, call_payload: Dictionary)

func _ready():
	print("🧪 Testing Quantum API gate integration through addon bridge")
	await test_quantum_gates()

func test_quantum_gates() -> void:
	await _test_gate("bit_flip")
	await _test_gate("phase_flip")
	await _test_gate("rotation", 0.5)
	await _test_rotation_validation_error()

func _test_gate(gate_type: String, rotation_angle_rad: Variant = null) -> void:
	var result := await _await_gate(gate_type, rotation_angle_rad)
	var request_success := bool(result["request_success"])
	var payload := result["payload"] as Dictionary

	if request_success:
		print("✅ ", gate_type, " call succeeded")
		print("   measurement: ", payload.get("measurement", "n/a"))
		print("   superposition_strength: ", payload.get("superposition_strength", "n/a"))
		print("   success: ", payload.get("success", false))
		return

	print("❌ ", gate_type, " call failed: ", payload)

func _test_rotation_validation_error() -> void:
	var result := await _await_gate("rotation")
	var request_success := bool(result["request_success"])
	var payload := result["payload"] as Dictionary

	if request_success:
		print("❌ Expected rotation validation failure but got success payload: ", payload)
		return

	var status_code := int(payload.get("status_code", 0))
	var message := str(payload.get("message", ""))
	if status_code == 400 and !message.is_empty():
		print("✅ Rotation validation failure returned clearly: ", message)
	else:
		print("⚠️ Rotation without angle failed, but error details were unclear: ", payload)

func _await_gate(gate_type: String, rotation_angle_rad: Variant = null) -> Dictionary:
	QuantumApiBridgeScript.run_gate(
		self,
		gate_type,
		Callable(self, "_on_gate_call_complete"),
		rotation_angle_rad
	)

	var result: Array = await gate_call_completed
	return {
		"request_success": bool(result[0]),
		"payload": result[1] as Dictionary,
	}

func _on_gate_call_complete(call_success: bool, call_payload: Dictionary) -> void:
	gate_call_completed.emit(call_success, call_payload)
