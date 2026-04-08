class_name QuantumGateManager
extends Node
const QuantumApiBridgeScript = preload("res://source/dialogue/quantum_api_bridge.gd")
const API_GATE_BY_TYPE = ["bit_flip", "phase_flip", "rotation"]
const GATE_SEQUENCE_BY_TYPE = ["X", "Z", "Y-ROT"]
const GATE_NAME_BY_TYPE = ["bit-flip", "phase-flip", "rotation"]
const SUCCESS_FRAGMENT_BY_TYPE = ["Memory shard: stable bit-flip alignment.", "Memory shard: phase coherence regained.", "Memory shard: rotational pattern stabilized."]
const FAILURE_FRAGMENT_BY_TYPE = ["Memory shard collapsed during bit-flip.", "Memory shard decohered after phase-flip.", "Memory shard split across timelines after rotation."]
signal quantum_gate_result(gate_sequence: String, success: bool, memory_fragment: String, quantum_data: Dictionary)
var gate_success_rate: float = 0.85
var applied_gates: Array = []
var story_state: Dictionary = {}
enum GateType { BIT_FLIP, PHASE_FLIP, ROTATION }
func _ready() -> void:
	QuantumApiBridgeScript.get_or_create(self)
func apply_quantum_gate(gate_type: int, dialogue_text: String) -> void:
	applied_gates.append(_get_gate_name(gate_type))
	_send_quantum_gate_request(dialogue_text, gate_type)
func _send_quantum_gate_request(text: String, gate_type: int) -> void:
	var rotation_angle_rad: Variant = null
	if gate_type == GateType.ROTATION:
		rotation_angle_rad = 0.5
	QuantumApiBridgeScript.run_gate(self, _to_api_gate_type(gate_type), _on_quantum_gate_response.bind(gate_type, text), rotation_angle_rad)
func _on_quantum_gate_response(request_success, payload, gate_type, text) -> void:
	var gate_sequence := _get_gate_sequence(gate_type)
	var success := false
	var status_code := int(payload.get("status_code", 0))
	if request_success:
		success = bool(payload.get("success", false))
	elif status_code != 400:
		success = randf() < gate_success_rate
	var fragment := _generate_memory_fragment(gate_type, success, text)
	var response_payload: Dictionary = {}
	if payload is Dictionary:
		response_payload = payload.duplicate()
	if status_code == 400:
		response_payload["validation_error"] = true
	quantum_gate_result.emit(gate_sequence, success, fragment, response_payload)
func _to_api_gate_type(gate_type: int) -> String:
	return API_GATE_BY_TYPE[clampi(gate_type, 0, API_GATE_BY_TYPE.size() - 1)]
func _generate_memory_fragment(gate_type: int, success: bool, _transformed_text: String) -> String:
	var index := clampi(gate_type, 0, SUCCESS_FRAGMENT_BY_TYPE.size() - 1)
	if success:
		return SUCCESS_FRAGMENT_BY_TYPE[index]
	return FAILURE_FRAGMENT_BY_TYPE[index]
func _get_gate_sequence(gate_type: int) -> String:
	return GATE_SEQUENCE_BY_TYPE[clampi(gate_type, 0, GATE_SEQUENCE_BY_TYPE.size() - 1)]
func _get_gate_name(gate_type: int) -> String:
	return GATE_NAME_BY_TYPE[clampi(gate_type, 0, GATE_NAME_BY_TYPE.size() - 1)]
func all_gates_applied() -> bool:
	return applied_gates.size() >= 3
func get_story_state() -> Dictionary:
	return {"applied_gates": applied_gates, "story_state": story_state}
func set_story_state(state: Dictionary) -> void:
	applied_gates = state.get("applied_gates", [])
	story_state = state.get("story_state", {})
