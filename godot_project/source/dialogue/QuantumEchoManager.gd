extends Node
class_name QuantumEchoManager

const QuantumApiBridgeScript = preload("res://source/dialogue/quantum_api_bridge.gd")

signal quantum_echo_received(original_text: String, echo_text: String, echo_type: String)
signal quantum_echo_error(error_message: String)

var server_url: String = ""

enum EchoType {
    SCRAMBLE,
    REVERSE,
    GHOST,
    QUANTUM_CAPS
}

func _ready():
    QuantumApiBridgeScript.get_or_create(self)
    test_server_connection()

func set_server_url(url: String):
    server_url = url.strip_edges()
    ProjectSettings.set_setting(QuantumApiBridgeScript.SETTINGS_BASE_URL, server_url)
    var bridge = QuantumApiBridgeScript.get_or_create(self)
    if bridge != null:
        bridge.refresh_config()
    print("Quantum API base URL set to: ", server_url)

func set_backend_proxy_mode(enabled: bool) -> void:
    ProjectSettings.set_setting(QuantumApiBridgeScript.SETTINGS_BACKEND_PROXY_MODE, enabled)
    var bridge = QuantumApiBridgeScript.get_or_create(self)
    if bridge != null:
        bridge.refresh_config()

func set_direct_api_key(key: String) -> void:
    ProjectSettings.set_setting(QuantumApiBridgeScript.SETTINGS_DIRECT_API_KEY, key.strip_edges())
    var bridge = QuantumApiBridgeScript.get_or_create(self)
    if bridge != null:
        bridge.refresh_config()

func test_server_connection():
    QuantumApiBridgeScript.health_check(self, Callable(self, "_on_health_check_response"))

func get_quantum_echo(dialogue_text: String, echo_type: EchoType = EchoType.SCRAMBLE):
    if dialogue_text.is_empty():
        quantum_echo_error.emit("Cannot process empty text")
        return

    var echo_type_string = _echo_type_to_string(echo_type)
    QuantumApiBridgeScript.transform_text(
        self,
        dialogue_text,
        Callable(self, "_on_quantum_transform_response").bind(dialogue_text, echo_type_string),
        dialogue_text
    )

func _on_health_check_response(request_success: bool, payload: Dictionary) -> void:
    if request_success:
        print("Quantum API health check passed")
        return
    quantum_echo_error.emit("Health check failed: " + str(payload.get("message", "Unknown error")))

func _on_quantum_transform_response(request_success: bool, payload: Dictionary, dialogue_text: String, echo_type_string: String) -> void:
    var original := str(payload.get("original", dialogue_text))
    var echo := str(payload.get("transformed", dialogue_text))

    if request_success:
        quantum_echo_received.emit(original, echo, echo_type_string)
        return

    quantum_echo_error.emit(str(payload.get("message", "Failed to transform text")))
    quantum_echo_received.emit(original, echo, echo_type_string)

func _echo_type_to_string(echo_type: EchoType) -> String:
    match echo_type:
        EchoType.SCRAMBLE:
            return "scramble"
        EchoType.REVERSE:
            return "reverse"
        EchoType.GHOST:
            return "ghost"
        EchoType.QUANTUM_CAPS:
            return "quantum_caps"
        _:
            return "scramble"

func create_quantum_dialogue_effect(original_text: String, echo_text: String):
    print("=== QUANTUM DIALOGUE EFFECT ===")
    print("Character: \"", original_text, "\"")
    print("Quantum Echo: \"", echo_text, "\"")
    print("===============================")

func demonstrate_all_echo_types(text: String):
    print("Demonstrating all quantum echo types with: ", text)

    get_quantum_echo(text, EchoType.SCRAMBLE)
    await quantum_echo_received

    get_quantum_echo(text, EchoType.REVERSE)
    await quantum_echo_received

    get_quantum_echo(text, EchoType.GHOST)
    await quantum_echo_received

    get_quantum_echo(text, EchoType.QUANTUM_CAPS)
    await quantum_echo_received
