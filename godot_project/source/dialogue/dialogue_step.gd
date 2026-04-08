class_name DialogueStep
extends RefCounted
## Choose either options or content and dialogue will feed that in.

var isOptions: bool = false
var options: Array[DialogueOption] = []
var content: DialogueContent = DialogueContent.new()

static func create(p_is_options: bool, p_options: Array[DialogueOption] = [], p_content: DialogueContent = null) -> DialogueStep:
	var instance = DialogueStep.new()
	instance.isOptions = p_is_options
	instance.options = p_options
	instance.content = p_content
	return instance
