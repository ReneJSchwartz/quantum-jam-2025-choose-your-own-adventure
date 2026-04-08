extends Node

@export var first_selected_element: Control
@export var main_menu_container: Control
@export var read_mail_button: Button
@export var game_name: RichTextLabel

func _ready():
	print("[MainMenu] Ready. node=", get_path())
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
	print("[MainMenu] _on_b_new_game_pressed")
	var signal_bus_path: String = "<null>"
	if SignalBus.instance != null:
		signal_bus_path = str(SignalBus.instance.get_path())

	var game_graphics_path: String = "<null>"
	if GameGraphics.instance != null:
		game_graphics_path = str(GameGraphics.instance.get_path())

	print("[MainMenu] SignalBus.instance path: ", signal_bus_path)
	print("[MainMenu] GameGraphics.instance path: ", game_graphics_path)
	main_menu_container.visible = false

	if SignalBus.instance != null:
		SignalBus.instance.pub("game_started")
	else:
		print("[MainMenu] ERROR: SignalBus.instance is null, game_started not published")

	if GameGraphics.instance != null:
		GameGraphics.instance.show_text_box()
	else:
		print("[MainMenu] ERROR: GameGraphics.instance is null, text box cannot be shown")
	# todo start game
