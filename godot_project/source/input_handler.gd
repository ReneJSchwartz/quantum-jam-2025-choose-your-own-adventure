extends Node

# input handling for ui game events
func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		if Dialogue.dialogue_running:
			DialogueUiManager.instance.on_skip_text()
	
	# menu testing
	if event is InputEventKey:
		if event.pressed and event.keycode == 49 and event.echo == false: # 1
			# debug thing 1
			pass
		if event.pressed and event.keycode == 50 and event.echo == false: # 1
			# debug thing 2
			pass
		if event.pressed and event.keycode == 51 and event.echo == false: # 1
			# debug thing 3
			pass
		if event.pressed and event.keycode == 52 and event.echo == false: # 1
			# debug thing 4
			pass
