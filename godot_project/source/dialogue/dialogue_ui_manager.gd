class_name DialogueUiManager
extends Node
## Controls Dialogue UI (speaker name, dialogue text, showing and hiding the 
## dialogue UI, changing talker picture (when implemented), etc.

const QuantumApiBridgeScript = preload("res://source/dialogue/quantum_api_bridge.gd")

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
static var instance: DialogueUiManager
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
## Runtime Quantum API transport is centralized through QuantumApiBridge.
var quantum_api_bridge: Node


func _ready():
	#test_populate_player_options_with_mock_data = false
	#test_show_overlay = false
	#test_write_mock_message = false
	instance = self
	print("[DialogueUI] Ready. node=", get_path())
	quantum_api_bridge = QuantumApiBridgeScript.get_or_create(self)
	print("[DialogueUI] Quantum bridge ready=", quantum_api_bridge != null)
	
	ui_container.visible = false
	print("[DialogueUI] UI container hidden on ready. options_count=", dialogue_options.size())
	
	# Default text speed, remove when options script sets this. 
	set_text_speed(TextSpeedOption.NORMAL)
	text_area.scroll_following = false
	text_area.scroll_to_line(0)
	
	for i in range(len(dialogue_options)):
		var button_index := i
		dialogue_options[i].pressed.connect(func(): _on_user_choice_button_pressed(button_index))
		dialogue_options[i].pressed.connect(func(): hide_player_options())
	
	button_callbacks.append_array([func(): pass, func(): pass, func(): pass, func(): pass])

func show_dialogue_overlay() -> void:
	print("[DialogueUI] show_dialogue_overlay")
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
	print("[DialogueUI] hide_dialogue_overlay")
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
	print("[DialogueUI] Player selected option index=", button_index)
	var _callback_result: Variant = await button_callbacks[button_index].call()
	if next_dialogue_callback.is_null():
		print("[DialogueUI] WARNING: next_dialogue_callback is null after option press")
		return
	next_dialogue_callback.call()

## Temporary write text refactor step.
func show_text(content: DialogueContent):
	print("[DialogueUI] show_text | speaker=", content.speaker_name, " text_len=", content.dialogue_text.length())
	write_text(content.dialogue_text, content.speaker_name, content.speaker_image)
	pass

## Main method of the class that writes text to a dialogue text box and shows
## other info to the player as well. Showing player selectable options is done
## in show_player_options() however. Now enhanced with quantum echo processing!
func write_text(bbcode_text: String, talker: String, _speaker_image: String):
	print("[DialogueUI] write_text | speaker=", talker, " source_text_len=", bbcode_text.length())
	# reset variables
	text_speed_multiplier = 1
	current_typewriter_audio_index = 0
	text_area.visible_characters = 0
	text_area.scroll_to_line(0)
	
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

## Uses the shared addon bridge for text transform.
func _process_text_with_quantum_server(text: String):
	print("[QuantumUI] Processing text with shared Quantum API bridge...")
	QuantumApiBridgeScript.transform_text(
		self,
		text,
		Callable(self, "_on_quantum_text_processed").bind(text),
		text
	)

func _on_quantum_text_processed(request_success: bool, payload: Dictionary, fallback_text: String) -> void:
	var processed_text := str(payload.get("transformed", fallback_text))
	if request_success:
		print("[QuantumUI] transform_text success | sample=", processed_text.substr(0, 80))
	else:
		print(
			"[QuantumUI] transform_text FAILED | status=", int(payload.get("status_code", 0)),
			" error=", str(payload.get("error", "unknown")),
			" result=", str(payload.get("result_text", payload.get("result", "n/a"))),
			" message=", str(payload.get("message", "no message")),
			" url=", str(payload.get("request_url", "n/a")),
			" api_key_present=", bool(payload.get("api_key_present", false)),
			" backend_proxy_mode=", bool(payload.get("backend_proxy_mode", true))
		)
		if processed_text == fallback_text:
			print("[QuantumUI] Using fallback text because transform failed.")
	_display_processed_text(processed_text)

## Display the final processed text with typewriter animation
func _display_processed_text(processed_text: String):
	print("[QuantumUI] ✨ Displaying processed text: %s" % processed_text.substr(0, 80))
	text_area.text = processed_text
	text_area.visible_characters = 0
	text_area.scroll_to_line(0)
	
	# Start typewriter animation
	_animate_typewriter_effect()

## 🎭 TYPEWRITER ANIMATION
func _animate_typewriter_effect():
	var total_characters: int = text_area.get_total_character_count()
	if total_characters < 1:
		total_characters = 1
	# Prevent very long entries from taking 60-90s to reveal.
	var max_reveal_duration_seconds: float = 8.0
	var chars_per_second_from_length: float = float(total_characters) / max_reveal_duration_seconds
	var effective_chars_per_second: float = text_speed
	if chars_per_second_from_length > effective_chars_per_second:
		effective_chars_per_second = chars_per_second_from_length
	var length_adjusted_text_speed: float = effective_chars_per_second / float(total_characters)
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
