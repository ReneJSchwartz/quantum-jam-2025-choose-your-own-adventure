class_name QuantumGateManager
extends Node
## Manages quantum gate decisions and their story consequences
## Integrates with the quantum echo server's /quantum_gates endpoint

signal quantum_gate_result(gate_sequence: String, success: bool, memory_fragment: String, quantum_data: Dictionary)

var quantum_echo_service: QuantumEchoService
var gate_success_rate: float = 0.85  # 85% success rate as mentioned in GDD
var applied_gates: Array[String] = []  # Track which gates have been applied
var story_state: Dictionary = {}  # Track story state and outcomes

# Quantum gate types matching your story
enum GateType {
	BIT_FLIP,    # X gate - 2A) Apply a bit-flip gate first  
	PHASE_FLIP,  # Z gate - 2B) Start with a phase-flip gate
	ROTATION     # Y gate - 2C) Rotate the qubit superposition
}

func _ready():
	# Get reference to quantum echo service
	quantum_echo_service = get_node("../quantum_echo_service")
	if not quantum_echo_service:
		print("❌ QuantumGateManager: Could not find QuantumEchoService")

## Apply a quantum gate choice and get story consequences
func apply_quantum_gate(gate_type: GateType, dialogue_text: String) -> void:
	var gate_sequence = _get_gate_sequence(gate_type)
	var gate_name = _get_gate_name(gate_type)
	
	print("🌀 Applying quantum gate: ", gate_name, " (", gate_sequence, ")")
	
	# Add to applied gates list
	applied_gates.append(gate_name)
	
	# Send the dialogue text with quantum gate transformation to server
	if quantum_echo_service:
		_send_quantum_gate_request(dialogue_text, gate_sequence, gate_type)
	else:
		# Fallback if server unavailable
		_handle_local_gate_simulation(gate_type, dialogue_text)

## Send quantum gate request to server
func _send_quantum_gate_request(text: String, gate_sequence: String, gate_type: GateType) -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Store gate type for response handling
	http_request.set_meta("gate_type", gate_type)
	http_request.set_meta("original_text", text)
	
	http_request.request_completed.connect(_on_quantum_gate_response)
	
	# Prepare request data for quantum_gates endpoint
	var request_data = {
		"text": text,
		"gate_sequence": gate_sequence
	}
	
	var json_string = JSON.stringify(request_data)
	var headers = ["Content-Type: application/json"]
	
	print("🎯 Sending quantum gate request: ", gate_sequence)
	var error = http_request.request("http://108.175.12.95:8000/quantum_gates", headers, HTTPClient.METHOD_POST, json_string)
	
	if error != OK:
		print("❌ Failed to send quantum gate request: ", error)
		_handle_local_gate_simulation(gate_type, text)
		http_request.queue_free()

## Handle quantum gate response from server
func _on_quantum_gate_response(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var http_request = get_children().filter(func(child): return child is HTTPRequest)[0] as HTTPRequest
	var gate_type = http_request.get_meta("gate_type") as GateType
	var original_text = http_request.get_meta("original_text") as String
	
	http_request.queue_free()
	
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			var response_data = json.data
			print("✨ Quantum gate response received: ", response_data.get("gates_applied", []))
			
			var transformed_text = response_data.get("transformed", original_text)
			var superposition_avg = response_data.get("superposition_average", 0.5)
			var _quantum_states = response_data.get("quantum_states", [])
			
			# Determine success based on superposition strength and random factor
			var success = _determine_gate_success(superposition_avg)
			
			# Generate memory fragment based on gate type and success
			var memory_fragment = _generate_memory_fragment(gate_type, success, transformed_text)
			
			# Emit result for dialogue system
			quantum_gate_result.emit(_get_gate_sequence(gate_type), success, memory_fragment, response_data)
			return
	
	print("❌ Quantum gate server error, using fallback")
	_handle_local_gate_simulation(gate_type, original_text)

## Fallback local simulation if server unavailable
func _handle_local_gate_simulation(gate_type: GateType, text: String) -> void:
	var success = randf() < gate_success_rate
	var memory_fragment = _generate_memory_fragment(gate_type, success, text)
	var gate_sequence = _get_gate_sequence(gate_type)
	
	quantum_gate_result.emit(gate_sequence, success, memory_fragment, {})

## Determine if gate application was successful based on quantum data
func _determine_gate_success(superposition_average: float) -> bool:
	# Higher superposition = more quantum effects = higher success chance
	var quantum_bonus = superposition_average * 0.3
	var final_success_rate = gate_success_rate + quantum_bonus
	
	return randf() < final_success_rate

## Generate memory fragments based on gate type and outcome
func _generate_memory_fragment(gate_type: GateType, success: bool, _transformed_text: String) -> String:
	match gate_type:
		GateType.BIT_FLIP:
			if success:
				return """A transparent memory overlays the lab—scientists running similar tests.
				
Somewhere beneath the surface, faint voices murmur, their messages lost to time but not entirely extinguished. This memory beckons you to listen closely — to gather shards of forgotten knowledge, piecing together a past only partially remembered.

But it fades before you can learn anything.

Theo: "It's holding stable." """
			else:
				return """The light vanishes in a blink as the superposition collapses.
				
But not before a memory—a flash of this same lab superimposed on this lab appears.
Panicked scientists turn to run.
Before all is swallowed in a blink of light.

Kaela: "What was that?"
Ava: "Quantum decoherence"
Kaela: "No, before that, like it was showing us something that had happened before. A quantum memory, past and present converging."
Theo: "Not just that, we've got some anomalies here…"
Kaela: "The light, it's growing—"
A blink of light swallows everything."""
				
		GateType.PHASE_FLIP:
			if success:
				return """The light dims and warps. Shadows gather, and the memory becomes fragmentary—blurred shapes shift in and out of focus, voices murmur softly but indistinctly, like being half-remembered in a dream.

Faint echoes of disquiet stir the air—whispers of failures, lost experiments, and fading hopes.
A sense of melancholy seeps deep—a silent testament to the quantum echoes trapped in limbo, lost and waiting for remembrance. The boundary between memory and oblivion blurs here, unveiling the fragile nature of what once was and what might have been.

Kaela: "They… were here, once."
"Dreams and despair intertwined in fragile quantum webs."
The light and the voices fade.

Theo: "It's holding stable. Choose the next gate carefully to avoid collapse." """
			else:
				return """The phase flip destabilizes violently. Reality fractures around you.
				
The memory becomes a nightmare—twisted echoes of pain and loss. You see the moment everything went wrong in the previous experiment, but the quantum interference makes it impossible to understand what caused the disaster.

The light flickers erratically, threatening to collapse entirely."""
				
		GateType.ROTATION:
			if success:
				return """The chamber fills with a radiant glow, shadows lifting to reveal the sharp outlines of a bustling research floor.
				
Scientists catalog data with nervous excitement; Kaela stands before a massive console, her face illuminated by cascading holograms of quantum patterns.
This memory captures the very moment the team surpassed a monumental barrier — the quantum echoes stabilizing for the first time, a symphony of light and hope woven into every pulse.

You sense not just a technical achievement, but a profound awakening — the birth of a new era where memory and reality blur, and possibilities expand beyond the imaginable.

Kaela's Voice: "We stood on the edge of the unknown, hearts pounding with anticipation and fear. Each signal from the quantum echoes was a promise whispered across time and space—proof that our understanding was just beginning." """
			else:
				return """The rotation creates dangerous interference patterns. Multiple timeline echoes overlap chaotically.
				
You glimpse fragments of both triumph and disaster—parallel worlds where the experiment succeeded brilliantly and others where it destroyed everything. The quantum superposition refuses to collapse into a single clear memory, leaving you with haunting questions about which future you're helping to create."""
				
	return "Unknown quantum gate result"

## Convert gate type to server gate sequence
func _get_gate_sequence(gate_type: GateType) -> String:
	match gate_type:
		GateType.BIT_FLIP:
			return "X"      # Bit-flip gate
		GateType.PHASE_FLIP:
			return "Z"      # Phase-flip gate  
		GateType.ROTATION:
			return "Y-ROT"  # Y rotation gate
		_:
			return "H"      # Default Hadamard

## Get human-readable gate name
func _get_gate_name(gate_type: GateType) -> String:
	match gate_type:
		GateType.BIT_FLIP:
			return "bit-flip"
		GateType.PHASE_FLIP:
			return "phase-flip"
		GateType.ROTATION:
			return "rotation"
		_:
			return "unknown"

## Check if all three gates have been applied (for story progression)
func all_gates_applied() -> bool:
	return applied_gates.size() >= 3

## Get story state for save/load
func get_story_state() -> Dictionary:
	return {
		"applied_gates": applied_gates,
		"story_state": story_state
	}

## Load story state from save
func set_story_state(state: Dictionary) -> void:
	applied_gates = state.get("applied_gates", [])
	story_state = state.get("story_state", {})
