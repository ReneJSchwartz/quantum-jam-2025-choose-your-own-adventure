class_name QuantumEchoService
extends Node
## 🌟 QUANTUM TEXT TRANSFORMATION SERVICE 🌟
##
## Service for connecting to the Quantum Echo Server to transform dialogue text
## with real quantum computing effects using qiskit and IBM's quantum simulators.
##
## 🔬 QUANTUM SCIENCE FOUNDATION:
## - Uses qiskit 2.1.2 with AerSimulator for quantum circuit simulation
## - Applies real quantum gates (H, X, Y, Z) to create text transformations
## - Measurement outcomes from quantum circuits determine text modifications
## - Quantum superposition and entanglement effects influence story outcomes
##
## 🎮 GAME INTEGRATION:
## - Automatically called by DialogueUiManager based on content analysis
## - Memory-related text uses quantum memory fragmentation
## - AI dialogue uses quantum caps transformation  
## - Quantum terminology triggers ghost effects
## - Default content gets scramble transformation
##
## 📡 SERVER ARCHITECTURE:
## - Flask server running at 108.175.12.95:8000 (configured for VPS deployment)
## - Async HTTP requests with fallback to original text on errors
## - JSON API with comprehensive error handling and logging
## - Health check endpoint for server status monitoring
##
## 🚀 USAGE EXAMPLES:
##   # Basic quantum echo transformation
##   quantum_echo_service.process_quantum_echo(
##     "Hello quantum world!", 
##     EchoType.SCRAMBLE, 
##     my_callback_function,
##     "fallback text"
##   )
##
##   # Advanced quantum memory processing  
##   quantum_echo_service.process_quantum_memory(
##     "I remember the quantum experiments...",
##     QuantumMemoryType.FRAGMENTED,
##     0.8,  # intensity 0.0-1.0
##     my_callback_function,
##     "original text"
##   )
##

## 🌐 QUANTUM ECHO SERVER CONFIGURATION
## The base URL of your quantum echo server
## 
## Current Setup: VPS deployment at 108.175.12.95:8000
## Local Development: Change to "https://108.175.12.95:8000" for local testing
## 
## Server Requirements:
## - Flask application with qiskit integration
## - Python 3.11+ recommended (3.13 compatible)  
## - qiskit==2.1.2, qiskit-aer==0.17.1
## - CORS enabled for cross-origin requests
## 
const SERVER_URL = "https://108.175.12.95:8000"

## 🎭 QUANTUM ECHO TYPES - Text Transformation Categories
## Available echo types from the server - each uses different quantum circuits
##
## Implementation Details:
## - SCRAMBLE: Uses Hadamard gates + measurement to randomly scramble characters
## - CASE_FLIP: Applies X gates in superposition to flip character cases  
## - GHOST: Creates interferene patterns with Y gates for spectral text effects
## - QUANTUM_CAPS: Uses Z-rotation gates to create quantum-based capitalization
## - ORIGINAL: Quantum bypass - returns text unmodified (classical fallback)
##
enum EchoType { SCRAMBLE, CASE_FLIP, GHOST, QUANTUM_CAPS, ORIGINAL }

## 🧠 QUANTUM MEMORY TYPES - Advanced Storytelling Effects  
## Available quantum memory types for advanced storytelling
##
## Quantum Memory Science:
## - FRAGMENTED: Simulates quantum decoherence in memory storage
## - ENTANGLED: Creates quantum entanglement between text segments
## - SUPERPOSITION: Text exists in multiple states until "observed" by player
##
## Game Narrative Applications:
## - Memory flashbacks with fragmentation effects
## - Character connections through entangled dialogue
## - Multiple reality states collapsed by player choice
##
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

## 🎯 COMPREHENSIVE QUANTUM TEXT PROCESSING METHOD  
## NEW: Process ALL quantum-eligible words with appropriate effects
##
## This method uses the QuantumWordDictionary to identify words and apply
## the most appropriate quantum transformation for each word category.
## Processes ~70% of words with multiple simultaneous quantum effects.
##
## Parameters:
## - text: Full input text
## - callback: Function called with comprehensively processed text
##
## Processing Logic:
## - MEMORY words → CASE_FLIP effects (fragmented memory)
## - QUANTUM words → GHOST effects (spectral phenomena)  
## - TECH words → QUANTUM_CAPS effects (technological emphasis)
## - EMOTIONAL words → SCRAMBLE effects (tension/uncertainty)
## - COMMON words → Mixed effects (general quantum uncertainty)
##
## Example: "I remember the quantum experiments" 
##          → "I ReMeMbEr the qu∆ntum ExPeRiMeNtS" (multiple effects applied)
##
## 🚀 SERVER-SIDE COMPREHENSIVE QUANTUM PROCESSING
## NEW: Process entire text on server with single request instead of 30+ individual calls
##
## This method sends the full text to the quantum server's new /quantum_comprehensive_text
## endpoint which processes ~70% of words with appropriate quantum effects in a single batch.
##
## Performance Benefits:
## - 1 HTTP request instead of 30+ individual requests
## - Server-side dictionary lookups (faster)
## - No network timeouts from multiple requests
## - Batch quantum transformations
## - ~70% word coverage maintained
##
## Parameters:
## - text: Full input text to process
## - callback: Function called with comprehensively processed text
##
func process_comprehensive_quantum_text(text: String, callback: Callable) -> void:
	print("🚀 Starting SERVER-SIDE comprehensive quantum processing")
	print("📊 Processing text: ", text.substr(0, 50))
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var json_data = {
		"text": text
	}
	
	var json_string = JSON.stringify(json_data)
	var headers = ["Content-Type: application/json"]
	
	# Single request to process entire text on server
	http_request.request_completed.connect(_on_comprehensive_server_response.bind(callback, http_request, text))
	http_request.request(SERVER_URL + "/quantum_comprehensive_text", headers, HTTPClient.METHOD_POST, json_string)
	
	print("📡 Single batch request sent (replaces 30+ individual requests)")

## Handle server response from comprehensive processing endpoint
func _on_comprehensive_server_response(callback: Callable, http_request: HTTPRequest, original_text: String, _result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	print("🎯 Comprehensive server response received: ", response_code)
	
	if response_code == 200:
		var response_text = body.get_string_from_utf8()
		var json = JSON.new()
		var parse_result = json.parse(response_text)
		
		if parse_result == OK:
			var data = json.data
			var transformed_text = data.get("transformed", "")
			var stats = data.get("stats", {})
			var performance = data.get("performance", {})
			
			print("✨ Comprehensive quantum processing complete!")
			print("📊 Coverage: %d/%d words (%.1f%%)" % [stats.get("quantum_words", 0), stats.get("total_words", 0), stats.get("coverage_percent", 0)])
			print("🎭 Effects applied: ", stats.get("effects_applied", {}))
			print("⚡ Performance: ", performance.get("efficiency_gain", "Single batch request"))
			
			callback.call(transformed_text)
		else:
			print("❌ Failed to parse comprehensive server response")
			callback.call(original_text)  # Fallback to original
	else:
		print("❌ Comprehensive server error: ", response_code)
		callback.call(original_text)  # Fallback to original
	
	http_request.queue_free()

## 🔄 LEGACY COMPATIBILITY METHOD
## Backward compatibility for old selective processing calls
## Redirects to the new comprehensive processing system
func process_selective_quantum_words(text: String, _target_words: Array[String], _echo_type: EchoType, callback: Callable) -> void:
	print("⚠️  Legacy method called - redirecting to comprehensive processing")
	process_comprehensive_quantum_text(text, callback)

## Helper function to replace words while preserving case context
func _replace_word_case_insensitive(text: String, old_word: String, new_word: String) -> String:
	var result = text
	var search_pos = 0
	
	while true:
		var pos = result.to_lower().find(old_word.to_lower(), search_pos)
		if pos == -1:
			break
		
		# Check if it's a whole word (not part of another word)
		var is_word_boundary = true
		if pos > 0 and result[pos - 1].is_valid_identifier():
			is_word_boundary = false
		if pos + old_word.length() < result.length() and result[pos + old_word.length()].is_valid_identifier():
			is_word_boundary = false
		
		if is_word_boundary:
			result = result.substr(0, pos) + new_word + result.substr(pos + old_word.length())
			search_pos = pos + new_word.length()
		else:
			search_pos = pos + 1
	
	return result

## 🎯 MAIN QUANTUM TEXT PROCESSING METHOD
## Process text through quantum echo server
## Returns the transformed text via callback when complete
##
## API Endpoint: POST /quantum_echo
## Request Format: {"text": string, "echo_type": string}  
## Response Format: {"echo": string, "quantum_state": dict, "measurement_result": list}
##
## Parameters:
## - text: Input text to transform
## - echo_type: Quantum transformation type (see EchoType enum)
## - callback: Function called with transformed text result  
## - fallback_text: Text to use if quantum server fails (defaults to original)
##
## Quantum Processing Flow:
## 1. Create quantum circuit based on echo_type
## 2. Apply quantum gates (H, X, Y, Z) to qubits  
## 3. Measure quantum state to get random values
## 4. Use measurement results to transform text
## 5. Return quantum-processed text via callback
##
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

## 🧬 ADVANCED QUANTUM MEMORY PROCESSING METHOD
## NEW: Process text using quantum memory effects for storytelling
##
## API Endpoint: POST /quantum_memory
## Request Format: {"text": string, "memory_type": string, "intensity": float}
## Response Format: {"memory_echo": string, "memory_state": string, "quantum_coherence": float}
##
## Parameters:
## - text: Input text for memory processing
## - memory_type: Type of quantum memory effect (see QuantumMemoryType enum)  
## - intensity: Effect strength 0.0-1.0 (higher = more pronounced effects)
## - callback: Function called with processed text result
## - fallback_text: Text to use if quantum server fails
##
## Quantum Memory Science:
## - Uses quantum circuit with entanglement gates for memory correlation
## - Applies controlled gates based on text content analysis
## - Measures quantum state to determine memory fragmentation patterns
## - Intensity parameter controls decoherence simulation strength
##
## Storytelling Applications:
## - intensity 0.1-0.3: Subtle memory uncertainty
## - intensity 0.4-0.6: Noticeable memory distortion  
## - intensity 0.7-1.0: Dramatic memory fragmentation
##
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

## 🏥 QUANTUM SERVER HEALTH MONITORING
## Convenience method to test server connectivity
##
## API Endpoint: GET /health  
## Response Format: {"status": "healthy", "qiskit_available": bool, "server_info": dict}
##
## Health Check Includes:
## - Server connectivity status
## - Qiskit library availability
## - Quantum simulator accessibility  
## - API endpoint functionality
## - Version compatibility information
##
## Parameters:
## - callback: Called with (success: bool, message: string)
##
## Usage for Debugging:
##   quantum_echo_service.test_server_health(func(healthy, msg):
##     if healthy: print("✅ Quantum server ready!")
##     else: print("❌ Server issue: ", msg)
##   )
##
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
				print("[QuantumEchoService] ✅ Quantum server health check PASSED!")
				print("[QuantumEchoService] Server info:", response_data)
				print("🔬 Qiskit available: ", response_data.get("qiskit_available", false))
				callback.call(true, "Server healthy")
				return
	print("[QuantumEchoService] ❌ Quantum server health check FAILED!")
	callback.call(false, "Health check failed")
