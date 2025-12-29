extends Node
## Test script to verify quantum echo integration in Godot
## Run this in your game to test if the quantum system works

func _ready():
	print("🧪 Testing Quantum Echo Integration...")
	test_quantum_echo_service()

func test_quantum_echo_service():
	# Create an instance of the quantum echo service
	var quantum_service = preload("res://source/dialogue/quantum_echo_service.gd").new()
	add_child(quantum_service)
	
	# Test server health first
	print("🏥 Testing server health...")
	quantum_service.test_server_health(on_health_result)
	
	# Wait a moment then test quantum echo
	await get_tree().create_timer(2.0).timeout
	print("🌀 Testing quantum echo...")
	quantum_service.process_quantum_echo(
		"Hello quantum world!",
		quantum_service.EchoType.SCRAMBLE,
		on_quantum_result,
		"Hello quantum world! [FALLBACK]"
	)

func on_health_result(is_healthy: bool, message: String):
	if is_healthy:
		print("✅ Server Health: ", message)
	else:
		print("❌ Server Health: ", message)

func on_quantum_result(result_text: String):
	print("✨ Quantum Echo Result: ", result_text)
	print("🎉 Quantum integration test complete!")
