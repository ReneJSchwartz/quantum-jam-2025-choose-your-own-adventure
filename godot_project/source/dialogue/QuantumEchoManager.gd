# QuantumEchoManager.gd
# Add this script to a Node in your Godot scene to handle quantum echo requests

extends Node
class_name QuantumEchoManager

signal quantum_echo_received(original_text: String, echo_text: String, echo_type: String)
signal quantum_echo_error(error_message: String)

var http_request: HTTPRequest
var server_url: String = "http://108.175.12.95:8000"  # Change this to your VPS URL

# Available echo types
enum EchoType {
    SCRAMBLE,    # Quantum scrambling with special characters
    REVERSE,     # Quantum case reversal  
    GHOST,       # Ghostly superscript transformation
    QUANTUM_CAPS # Quantum-influenced capitalization
}

func _ready():
    # Create HTTP request node
    http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.request_completed.connect(_on_request_completed)
    
    # Test server connection on startup
    test_server_connection()

func set_server_url(url: String):
    """Set the quantum echo server URL (e.g., for production VPS)"""
    server_url = url
    print("Quantum Echo Server URL set to: ", server_url)

func test_server_connection():
    """Test if the quantum echo server is available"""
    var headers = ["Content-Type: application/json"]
    http_request.request(server_url + "/health", headers, HTTPClient.METHOD_GET)

func get_quantum_echo(dialogue_text: String, echo_type: EchoType = EchoType.SCRAMBLE):
    """
    Request a quantum echo transformation of the dialogue text
    
    Args:
        dialogue_text: The original dialogue text to transform
        echo_type: The type of quantum transformation to apply
    """
    if dialogue_text.is_empty():
        quantum_echo_error.emit("Cannot process empty text")
        return
    
    var echo_type_string = _echo_type_to_string(echo_type)
    var headers = ["Content-Type: application/json"]
    var json_data = {
        "text": dialogue_text,
        "echo_type": echo_type_string
    }
    var json_string = JSON.stringify(json_data)
    
    print("Requesting quantum echo for: ", dialogue_text)
    http_request.request(server_url + "/quantum_echo", headers, HTTPClient.METHOD_POST, json_string)

func _echo_type_to_string(echo_type: EchoType) -> String:
    """Convert EchoType enum to string"""
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

func _on_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
    """Handle HTTP request completion"""
    var body_string = body.get_string_from_utf8()
    
    if response_code == 200:
        var json = JSON.new()
        var parse_result = json.parse(body_string)
        
        if parse_result == OK:
            var response_data = json.data
            
            # Check if this was a health check
            if response_data.has("status"):
                if response_data.status == "healthy":
                    print("✓ Quantum Echo Server is healthy and ready")
                else:
                    print("⚠ Quantum Echo Server health check failed")
                return
            
            # Handle quantum echo response
            if response_data.has("echo"):
                var original = response_data.get("original", "")
                var echo = response_data.get("echo", "")
                var echo_type = response_data.get("echo_type", "")
                
                print("Quantum echo received:")
                print("  Original: ", original)
                print("  Echo: ", echo)
                print("  Type: ", echo_type)
                
                quantum_echo_received.emit(original, echo, echo_type)
            else:
                quantum_echo_error.emit("Invalid response format")
        else:
            quantum_echo_error.emit("Failed to parse JSON response")
    else:
        print("Quantum Echo Server error: ", response_code)
        quantum_echo_error.emit("Server responded with error: " + str(response_code))

# Example usage functions
func create_quantum_dialogue_effect(original_text: String, echo_text: String):
    """
    Example function showing how you might use quantum echoes in your dialogue system
    """
    print("=== QUANTUM DIALOGUE EFFECT ===")
    print("Character: \"", original_text, "\"")
    print("Quantum Echo: \"", echo_text, "\"")
    print("===============================")
    
    # You could:
    # - Display the echo text with different styling
    # - Play it as a "whisper" or "echo" effect
    # - Use it for mysterious/supernatural dialogue
    # - Show it as thoughts or subconscious responses

func demonstrate_all_echo_types(text: String):
    """Demonstrate all available echo types with the given text"""
    print("Demonstrating all quantum echo types with: ", text)
    
    # Request each echo type
    get_quantum_echo(text, EchoType.SCRAMBLE)
    await quantum_echo_received
    
    get_quantum_echo(text, EchoType.REVERSE)
    await quantum_echo_received
    
    get_quantum_echo(text, EchoType.GHOST)
    await quantum_echo_received
    
    get_quantum_echo(text, EchoType.QUANTUM_CAPS)
    await quantum_echo_received
