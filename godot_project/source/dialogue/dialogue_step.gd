class_name DialogueStep
extends Node
## Choose either options or content and dialogue will feed that in.

var isOptions: bool = false
var options: Array[DialogueOption] = []
var content: DialogueContent = DialogueContent.new()

static func create(isOptions: bool, options: Array[DialogueOption] = [], content: DialogueContent = null) -> DialogueStep:
	var instance = DialogueStep.new()
	instance.isOptions = isOptions
	instance.options = options
	instance.content = content
	return instance
