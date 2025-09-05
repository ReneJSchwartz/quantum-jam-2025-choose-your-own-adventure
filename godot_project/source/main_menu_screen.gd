extends Node

@export var first_selected_element: Control
@export var main_menu_container: Control

func _on_time_to_select_first_element() -> void:
	first_selected_element.grab_focus()

func _on_b_quit_game_pressed() -> void:
	# does not work on web, do not use at all
	get_tree().quit()

func _on_b_new_game_pressed() -> void:
	main_menu_container.visible = false
	# todo start game
