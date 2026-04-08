class_name QuantumEchoService
extends Node

## Compatibility adapter that keeps legacy method signatures while routing
## all Quantum API traffic through the shared addon bridge.

const QuantumApiBridgeScript = preload("res://source/dialogue/quantum_api_bridge.gd")

enum EchoType { SCRAMBLE, CASE_FLIP, GHOST, QUANTUM_CAPS, ORIGINAL }
enum QuantumMemoryType { FRAGMENTED, ENTANGLED, SUPERPOSITION }

static var instance: QuantumEchoService

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

func _ready() -> void:
	instance = self
	QuantumApiBridgeScript.get_or_create(self)

func process_comprehensive_quantum_text(text: String, callback: Callable) -> void:
	_request_transform_with_fallback(text, callback, text)

func process_selective_quantum_words(text: String, _target_words: Array[String], _echo_type: EchoType, callback: Callable) -> void:
	process_comprehensive_quantum_text(text, callback)

func process_quantum_echo(text: String, _echo_type: EchoType, callback: Callable, fallback_text: String = "") -> void:
	var fallback := fallback_text if !fallback_text.is_empty() else text
	_request_transform_with_fallback(text, callback, fallback)

func process_quantum_memory(text: String, _memory_type: QuantumMemoryType, _intensity: float, callback: Callable, fallback_text: String = "") -> void:
	var fallback := fallback_text if !fallback_text.is_empty() else text
	_request_transform_with_fallback(text, callback, fallback)

func _request_transform_with_fallback(text: String, callback: Callable, fallback: String) -> void:
	QuantumApiBridgeScript.transform_text(self, text, _on_transform_response.bind(callback, fallback), fallback)

func _on_transform_response(_request_success: bool, payload: Dictionary, callback: Callable, fallback: String) -> void:
	callback.call(str(payload.get("transformed", fallback)))

func test_server_health(callback: Callable) -> void:
	QuantumApiBridgeScript.health_check(self, _on_health_check_response.bind(callback))

func _on_health_check_response(request_success: bool, payload: Dictionary, callback: Callable) -> void:
	if request_success:
		callback.call(true, "Server healthy")
		return
	callback.call(false, str(payload.get("message", "Health check failed")))
