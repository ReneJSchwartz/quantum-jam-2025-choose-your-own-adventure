class_name DialogueUiManager
extends Node
## Controls Dialogue UI (speaker name, dialogue text, showing and hiding the 
## dialogue UI, changing talker picture (when implemented), etc.

## Corresponds to settings menu speeds.
enum TextSpeedOption { SLOW, NORMAL, FAST }
## Get from options.
var text_speed: float = 0
## For deciding whether to play a typewriter sound.
var previous_shown_letters_amount: int = 0
## For looping the play_sound_pattern with a random typewriter_sound.
var current_typewriter_audio_index: int = 0
## How much the text speed such be multiplied with. Default 1. See also 
## dialogue_skip_speed_multiplier.
var text_speed_multiplier: float = 1.0
## For assigning dynamic callbacks to button pressed signal. That can be added
## as many times as needed.
var button_callbacks: Array[Callable] = []
# Tweening
## Used to tween the container to normal position from this position when shown.
var container_down_y_position_that_does_not_hide_player_options: float = 85
## Used to tween the container from this position when it is shown.
var container_down_y_position_that_hides_player_options: float = 180
## How long showing or hiding the dialogue overlay should take. Bear in mind 
## this travels greater distance (currently).
var hide_tween_duration = 0.53
## How long showing or hiding the dialogue overlay should take.
var show_tween_duration = 0.32
## Access pattern to the script.
static var instance: DialogueUiManager = self
## What code call to get the next dialogue. This is usually Dialogue script's
## continue_dialogue().
var next_dialogue_callback: Callable
@export_group("Dialogue Settings")
## 1 means a randomized sound when new letter appears and 0 is no sound.
## This audio pattern loops through the message.
@export var play_sound_pattern: String = "1010"
## Should the text jump straight to end when skipping text or just speed up 2x.
@export var on_skip_dialogue_jump_instantly_to_end: bool = true
## If text proceeds faster on skip, new speed should be old speed * multiplier.
## Not applicable if on skip jump straight to end enabled. 
@export var dialogue_skip_speed_multiplier: float = 2.0
## Can be used to set how fast text proceeds.
@export var text_speeds_slow_normal_fast: Array[float]
@export var delay_before_writing_speaker_name: float = 0
## How much time should pass between having speaker name completed and starting
## to type message box letters to screen.
@export var delay_after_speaker_name: float = 0.2
@export_group("Testing Functions")
## Brings overlay into view.
@export var test_show_overlay: bool
## Hides overlay from view.
@export var test_hide_overlay: bool
# Flip the bool on to run the function.
#@export var test_populate_player_options_with_mock_data: bool = false
### Flip the bool on to run the function.
#@export var test_write_mock_message: bool = false
### Flip the bool on to run the function.
#@export var test_write_mock_message_short: bool = false
@export_group("Component References")
## For position tweening
@export var ui_container: Control
## This is the text the player sees.
@export var text_area: RichTextLabel
## In the name field at left side of screen above the main dialogue box.
@export var speaker_name: RichTextLabel
## Image of the talker in right side of the dialogue box.
@export var talker_image: TextureRect
## Options the player can select (option's topmost node), these are dynamically
## populated.
@export var dialogue_options: Array[Button]
## Reference to the quantum echo service for text transformation  
## 🌟 QUANTUM TEXT API: This connects to the Flask quantum echo server at 108.175.12.95:8000
## 
## Available API Endpoints:
## - /quantum_echo: Transform text with various echo effects (scramble, case_flip, ghost, quantum_caps)
## - /quantum_memory: Process text with memory-based quantum transformations (fragmented, entangled, superposition)
## - /health: Check server status and qiskit availability
##
## Echo Types Available:
## - SCRAMBLE: Randomly scrambles characters using quantum measurement  
## - CASE_FLIP: Flips case using quantum superposition collapse
## - GHOST: Creates ghostly text effects with quantum interference
## - QUANTUM_CAPS: Applies quantum-based capitalization patterns
## - ORIGINAL: Returns unmodified text (quantum bypass)
##
## Memory Types for Advanced Storytelling:
## - FRAGMENTED: Simulates fragmented memory states (intensity controls fragmentation)
## - ENTANGLED: Creates text entanglement effects between phrases
## - SUPERPOSITION: Text exists in quantum superposition until observed
##
## Usage Pattern:
##   quantum_echo_service.process_quantum_echo(text, EchoType.SCRAMBLE, callback, fallback)
##   quantum_echo_service.process_quantum_memory(text, MemoryType.FRAGMENTED, intensity, callback, fallback)
##
var quantum_echo_service: Node


func _ready():
	#test_populate_player_options_with_mock_data = false
	#test_show_overlay = false
	#test_write_mock_message = false
	instance = self
	
	ui_container.visible = false
	
	# Note: No longer using quantum_echo_service - direct Flask server communication
	
	# Default text speed, remove when options script sets this. 
	set_text_speed(TextSpeedOption.NORMAL)
	
	for i in len(dialogue_options):
		dialogue_options[i].pressed.connect(func(): _on_user_choice_button_pressed(i))
		dialogue_options[i].pressed.connect(func(): hide_player_options())
	
	button_callbacks.append_array([func(): pass, func(): pass, func(): pass, func(): pass])

func show_dialogue_overlay() -> void:
	print(show_dialogue_overlay.get_method().get_basename())
	ui_container.visible = true
	hide_player_options()
	text_area.text = " "
	text_area.visible_characters = 0
	speaker_name.text = ""
	ui_container.position = Vector2(0, container_down_y_position_that_does_not_hide_player_options)
	var tween = get_tree().create_tween()
	tween.tween_property(
		ui_container, 
		"position", 
		Vector2(0, 0), 
		show_tween_duration)

func hide_dialogue_overlay(_instantly: bool = false) -> void:
	print(hide_dialogue_overlay.get_method().get_basename())
	#ui_container.visible = false
	#if instantly:
		#ui_container.position = Vector2(0, container_down_y_position_that_hides_player_options)
		#return
	#
	#var tween = get_tree().create_tween()
	#tween.tween_property(
		#ui_container, 
		#"position", 
		#Vector2(0, container_down_y_position_that_hides_player_options), 
		#hide_tween_duration)

## Handles runtime testing functions.
func _process(_delta: float):
	if test_show_overlay:
		show_dialogue_overlay()
		test_show_overlay = false
	elif test_hide_overlay:
		hide_dialogue_overlay()
		test_hide_overlay = false
	
	# message api was changed
	#return
	#if test_populate_player_options_with_mock_data:
		#var opt1: DialogueOption = DialogueOption.new()
		#opt1.text = "OptionDemo"
		#opt1.activation_callback = func(): print("DialogueOptionDemo callback")
		#show_player_options([opt1])
		#test_populate_player_options_with_mock_data = false
	#elif test_write_mock_message:
		#show_dialogue_overlay()
		#await get_tree().process_frame
		#write_text("If recursive is false, only this node's direct children are checked.", "Jane Doe", "jane_doe_happy")
		#test_write_mock_message = false
	#elif test_write_mock_message_short:
		#write_text("Apple", "Tybalt", "jane_doe_happy")
		#test_write_mock_message_short = false

## Dynamic button callbacks, the button does not save the callback 
## as that is hard with reusing buttons but instead this class stores 
## button callbacks and calls them through this method.
func _on_user_choice_button_pressed(button_index: int):
	button_callbacks[button_index].call()
	next_dialogue_callback.call()

## Temporary write text refactor step.
func show_text(content: DialogueContent):
	write_text(content.dialogue_text, content.speaker_name, content.speaker_image)
	pass

## Main method of the class that writes text to a dialogue text box and shows
## other info to the player as well. Showing player selectable options is done
## in show_player_options() however. Now enhanced with quantum echo processing!
func write_text(bbcode_text: String, talker: String, _speaker_image: String):
	# reset variables
	text_speed_multiplier = 1
	current_typewriter_audio_index = 0
	text_area.visible_characters = 0
	
	# set speaker name first (no quantum processing for names)
	speaker_name.text = talker
	speaker_name.visible_characters = 0
	
	# Show "Processing quantum echo..." while we wait for the server
	text_area.text = "⟨ Processing quantum echo... ⟩"
	
	var length_adjusted_speaker_name_text_speed = text_speed / speaker_name.get_total_character_count()
	
	if delay_before_writing_speaker_name > 0:
		await get_tree().create_timer(delay_before_writing_speaker_name).timeout
	
	while speaker_name.visible_ratio < 1:
		speaker_name.visible_ratio += length_adjusted_speaker_name_text_speed * get_process_delta_time() * text_speed_multiplier
		await get_tree().process_frame
		
	if delay_after_speaker_name > 0:
		await get_tree().create_timer(delay_after_speaker_name).timeout
	
	# 🌟 NEW: Direct quantum server processing (simplified!)
	_process_text_with_quantum_server(bbcode_text)

## 🌟 SIMPLIFIED QUANTUM TEXT PROCESSING
## Directly calls the Flask server's /quantum_text endpoint for comprehensive processing
func _process_text_with_quantum_server(text: String):
	print("[QuantumUI] Processing text with quantum server...")
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Store original text in the HTTPRequest node for later retrieval
	http_request.set_meta("original_text", text)
	
	# Create request data
	var json_data = {
		"text": text
	}
	
	var json_string = JSON.stringify(json_data)
	var headers = ["Content-Type: application/json"]
	
	# Connect response handler - signal parameters come first, then bound parameters
	http_request.request_completed.connect(_on_quantum_server_response)
	
	# Send request to Flask server (production server)
	var server_url = "https://108.175.12.95:8000/quantum_text"
	print("[QuantumUI] Sending request to: %s" % server_url)
	http_request.request(server_url, headers, HTTPClient.METHOD_POST, json_string)

## Handle quantum server response
## Signal signature: request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray)
func _on_quantum_server_response(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	# Get the HTTPRequest node that sent the signal
	var http_request = get_tree().get_nodes_in_group("http_requests")[0] if get_tree().get_nodes_in_group("http_requests").size() > 0 else null
	
	# If we can't find the request node, look through children
	if not http_request:
		for child in get_children():
			if child is HTTPRequest:
				http_request = child
				break
	
	var original_text = ""
	if http_request and http_request.has_meta("original_text"):
		original_text = http_request.get_meta("original_text")
		# Clean up HTTP request node
		http_request.queue_free()
	
	var processed_text = original_text  # Fallback to original
	
	if response_code == 200:
		var response_text = body.get_string_from_utf8()
		print("[QuantumUI] Quantum server response: %s" % response_text.substr(0, 100))
		
		var json = JSON.new()
		var parse_result = json.parse(response_text)
		
		if parse_result == OK:
			var response_data = json.data
			if response_data.has("transformed"):
				processed_text = response_data["transformed"]
				var coverage = response_data.get("coverage_percent", 0)
				print("[QuantumUI] ✨ Quantum processing complete! Coverage: %s%%" % coverage)
			else:
				print("[QuantumUI] ⚠️ No 'transformed' field in response")
		else:
			print("[QuantumUI] ⚠️ Failed to parse JSON response")
	else:
		print("[QuantumUI] ⚠️ Quantum server error: %s - using original text" % response_code)
	
	# Display the processed text
	_display_processed_text(processed_text)
	# Display the processed text with typewriter animation
	_display_processed_text(processed_text)

## Display the final processed text with typewriter animation
func _display_processed_text(processed_text: String):
	print("[QuantumUI] ✨ Displaying processed text: %s" % processed_text.substr(0, 80))
	text_area.text = processed_text
	text_area.visible_characters = 0
	
	# Start typewriter animation
	_animate_typewriter_effect()

## 🎭 TYPEWRITER ANIMATION
func _animate_typewriter_effect():
	var length_adjusted_text_speed = text_speed / text_area.get_total_character_count()
	while !is_text_finished():
		text_area.visible_ratio += length_adjusted_text_speed * get_process_delta_time() * text_speed_multiplier
		if text_area.visible_characters != previous_shown_letters_amount:
			previous_shown_letters_amount += 1
			# Optionally play sound for each letter
			if play_sound_pattern[previous_shown_letters_amount % len(play_sound_pattern)] == "0":
				pass
		await get_tree().process_frame

## Populates selectable options for the player.
func show_player_options(options: Array[DialogueOption]) -> void:
	hide_player_options()
	
	for i in range(len(options)) :
		dialogue_options[i].visible = true
		dialogue_options[i].text = options[i].text
		button_callbacks[i] = options[i].activation_callback
	
	dialogue_options[0].grab_focus()

func hide_player_options() -> void:
	for b in dialogue_options:
		b.visible = false


func is_text_finished() -> bool: return text_area.visible_ratio == 1


## Called by input handling.
func on_skip_text() -> void:
	print("on_skip_text")
	if (text_area.visible_ratio < 1):
		if on_skip_dialogue_jump_instantly_to_end:
			text_area.visible_ratio = 1
			speaker_name.visible_ratio = 1
		else:
			text_speed_multiplier = dialogue_skip_speed_multiplier
	elif Dialogue.dialogue_running and !dialogue_options[0].visible:
		next_dialogue_callback.call()


## Sets text speed based on user chosen TextSpeedOption (slow, normal, fast).
func set_text_speed(speed: TextSpeedOption) -> void:
	text_speed = text_speeds_slow_normal_fast[speed]
