class_name DialogueOption
extends RefCounted
## Class for dialogue options that the player can choose. Dialogue options show 
## above the dialogue panel(?) and one can be chosen. This wraps the data they 
## need to be able to be dynamically spawned.

var text: String
var activation_callback: Callable

static func create(p_text: String, p_activation_callback: Callable) -> DialogueOption:
	var instance = DialogueOption.new()
	instance.text = p_text
	instance.activation_callback = p_activation_callback
	return instance
