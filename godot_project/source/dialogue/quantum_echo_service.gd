class_name QuantumEchoService
extends Node
## Service for connecting to the Quantum Echo Server to transform dialogue text
## with quantum effects like scrambling, case reversal, and other echo types.

## The base URL of your quantum echo server
const SERVER_URL = "http://108.175.12.95:8000"

## Available echo types from the server
enum EchoType { SCRAMBLE, CASE_FLIP, GHOST, QUANTUM_CAPS, ORIGINAL }

## Available quantum memory types for advanced storytelling
enum QuantumMemoryType { FRAGMENTED, ENTANGLED, SUPERPOSITION }

## Convert enum to server string
static func echo_type_to_string(echo_type: EchoType) -> String:
	match echo_type:
		EchoType.SCRAMBLE:
			return "scramble"
		EchoType.CASE_FLIP:
			return "case_flip" 
		EchoType.GHOST:
			return "ghost"
		EchoType.QUANTUM_CAPS:
			return "quantum_caps"
		EchoType.ORIGINAL:
			return "original"
		_:
			return "scramble"

## Convert quantum memory enum to server string
static func memory_type_to_string(memory_type: QuantumMemoryType) -> String:
	match memory_type:
		QuantumMemoryType.FRAGMENTED:
			return "fragmented"
		QuantumMemoryType.ENTANGLED:
			return "entangled"
		QuantumMemoryType.SUPERPOSITION:
			return "superposition"
		_:
			return "fragmented"

## Singleton instance
static var instance: QuantumEchoService

func _ready():
	instance = self

## Process text through quantum echo server
## Returns the transformed text via callback when complete
func process_quantum_echo(text: String, echo_type: EchoType, callback: Callable, fallback_text: String = "") -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Store the callback and fallback for use in the response handler
	http_request.set_meta("callback", callback)
	http_request.set_meta("fallback_text", fallback_text if !fallback_text.is_empty() else text)
	
	# Configure request - use a lambda to handle the response
	http_request.request_completed.connect(func(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
		_on_quantum_echo_response(http_request, result, response_code, _headers, body)
	)
	
	# Prepare request data
	var request_data = {
		"text": text,
		"echo_type": echo_type_to_string(echo_type)
	}
	
	var json_string = JSON.stringify(request_data)
	var headers = ["Content-Type: application/json"]
	
	print("🌀 Sending quantum echo request: ", echo_type_to_string(echo_type), " for text: ", text.substr(0, 50), "...")
	
	# Make the request
	var error = http_request.request(SERVER_URL + "/quantum_echo", headers, HTTPClient.METHOD_POST, json_string)
	
	if error != OK:
		print("❌ Failed to make quantum echo request: ", error)
		# Fall back to original text
		callback.call(fallback_text if !fallback_text.is_empty() else text)
		http_request.queue_free()

## Handle the response from quantum echo server
func _on_quantum_echo_response(http_request: HTTPRequest, _result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	# Get the stored callback and fallback text
	var callback = http_request.get_meta("callback") as Callable
	var fallback_text = http_request.get_meta("fallback_text") as String
	
	# Clean up the request node
	http_request.queue_free()
	
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			var response_data = json.data
			if response_data.has("echo"):
				var quantum_text = response_data["echo"]
				print("✨ Quantum echo received: ", quantum_text.substr(0, 100), "...")
				callback.call(quantum_text)
				return
			else:
				print("❌ Invalid response format from quantum server - missing 'echo' field")
				print("Response data: ", response_data)
	else:
		print("❌ Quantum echo server error. Response code: ", response_code)
	
	# Fallback to original text on any error
	print("🔄 Using fallback text")
	callback.call(fallback_text)

## NEW: Process text using quantum memory effects for storytelling
func process_quantum_memory(text: String, memory_type: QuantumMemoryType, intensity: float, callback: Callable, fallback_text: String = "") -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Store the callback and fallback for use in the response handler
	http_request.set_meta("callback", callback)
	http_request.set_meta("fallback_text", fallback_text if !fallback_text.is_empty() else text)
	
	# Configure request - use a lambda to handle the response
	http_request.request_completed.connect(func(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
		_on_quantum_memory_response(http_request, result, response_code, _headers, body)
	)
	
	# Prepare request data
	var request_data = {
		"text": text,
		"memory_type": memory_type_to_string(memory_type),
		"intensity": intensity
	}
	
	var json_string = JSON.stringify(request_data)
	var headers = ["Content-Type: application/json"]
	
	print("🧠 Sending quantum memory request: ", memory_type_to_string(memory_type), " intensity: ", intensity, " for text: ", text.substr(0, 50), "...")
	
	# Make the request
	var error = http_request.request(SERVER_URL + "/quantum_memory", headers, HTTPClient.METHOD_POST, json_string)
	
	if error != OK:
		print("❌ Failed to make quantum memory request: ", error)
		# Fall back to original text
		callback.call(fallback_text if !fallback_text.is_empty() else text)
		http_request.queue_free()

## Handle the response from quantum memory endpoint
func _on_quantum_memory_response(http_request: HTTPRequest, _result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	# Get the stored callback and fallback text
	var callback = http_request.get_meta("callback") as Callable
	var fallback_text = http_request.get_meta("fallback_text") as String
	
	# Clean up the request node
	http_request.queue_free()
	
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			var response_data = json.data
			if response_data.has("memory_echo"):
				var quantum_memory_text = response_data["memory_echo"]
				print("🧠✨ Quantum memory received: ", quantum_memory_text.substr(0, 100), "...")
				print("Memory state: ", response_data.get("memory_state", "unknown"))
				print("Quantum coherence: ", response_data.get("quantum_coherence", 0.0))
				callback.call(quantum_memory_text)
				return
			else:
				print("❌ Invalid response format from quantum memory - missing 'memory_echo' field")
				print("Response data: ", response_data)
	else:
		print("❌ Quantum memory server error. Response code: ", response_code)
	
	# Fallback to original text on any error
	print("🔄 Using fallback text for quantum memory")
	callback.call(fallback_text)

## Convenience method to test server connectivity
func test_server_health(callback: Callable) -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Store the callback for use in the response handler
	http_request.set_meta("callback", callback)
	
	http_request.request_completed.connect(func(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
		_on_health_response(http_request, result, response_code, _headers, body)
	)
	
	print("🏥 Testing quantum server health...")
	var error = http_request.request(SERVER_URL + "/health")
	
	if error != OK:
		print("❌ Failed to make health check request: ", error)
		callback.call(false, "Request failed")
		http_request.queue_free()

## Handle health check response
func _on_health_response(http_request: HTTPRequest, _result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	# Get the stored callback
	var callback = http_request.get_meta("callback") as Callable
	
	# Clean up the request node
	http_request.queue_free()
	
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			var response_data = json.data
			if response_data.has("status") and response_data["status"] == "healthy":
				print("✅ Quantum server is healthy!")
				print("🔬 Qiskit available: ", response_data.get("qiskit_available", false))
				callback.call(true, "Server healthy")
				return
	
	print("❌ Quantum server health check failed")
	callback.call(false, "Health check failed")
