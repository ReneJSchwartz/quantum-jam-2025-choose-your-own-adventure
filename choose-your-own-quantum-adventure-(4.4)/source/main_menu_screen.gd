extends Node

@export var first_selected_element: Control
@export var main_menu_container: Control
@export var read_mail_button: Button
@export var game_name: RichTextLabel

func _ready():
	game_name.visible = false
	get_tree().create_timer(1).timeout.connect(func():
		game_name.visible = true)
	
	read_mail_button.visible = false
	get_tree().create_timer(2).timeout.connect(func():
		read_mail_button.visible = true
		select_first_element())

func select_first_element() -> void:
	first_selected_element.grab_focus()

func _on_b_quit_game_pressed() -> void:
	# does not work on web, do not use at all
	get_tree().quit()

func _on_b_new_game_pressed() -> void:
	print("_on_b_new_game_pressed")
	main_menu_container.visible = false
	SignalBus.instance.pub("game_started")
	GameGraphics.instance.show_text_box()
	# todo start game
