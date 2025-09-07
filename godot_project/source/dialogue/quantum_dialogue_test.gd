extends Node
## Test script to verify quantum gate integration

func _ready():
	print("🧪 Testing Quantum Gate Integration")
	test_quantum_gates()

func test_quantum_gates():
	# Test quantum gate endpoint with different gate sequences
	test_gate("H-X", "Hello quantum world!")
	test_gate("X-Z", "The burst vanishes into memory")
	test_gate("Y-ROT", "I remember the quantum echo")

func test_gate(gate_sequence: String, text: String):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	http_request.request_completed.connect(_on_gate_response)
	
	var request_data = {
		"text": text,
		"gate_sequence": gate_sequence
	}
	
	var json_string = JSON.stringify(request_data)
	var headers = ["Content-Type: application/json"]
	
	print("🎯 Testing gate sequence: ", gate_sequence, " with text: ", text)
	http_request.request("https://108.175.12.95:8000/quantum_gates", headers, HTTPClient.METHOD_POST, json_string)

func _on_gate_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			var response_data = json.data
			print("✨ Gate result: ", response_data.get("transformed", ""))
			print("📊 Superposition average: ", response_data.get("superposition_average", 0))
			print("🔬 Gates applied: ", response_data.get("gates_applied", []))
		else:
			print("❌ Failed to parse response")
	else:
		print("❌ Server error: ", response_code)
