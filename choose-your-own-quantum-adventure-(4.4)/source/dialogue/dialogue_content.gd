class_name DialogueContent
extends Node
## Wraps the data the dialogue box needs for showing text.

var dialogue_text: String = ""
var speaker_name: String = ""
var speaker_image: String = ""

static func create(dialogue_text: String, speaker_name: String = "", speaker_image: String = "") -> DialogueContent:
	var instance = DialogueContent.new()
	instance.dialogue_text = dialogue_text
	instance.speaker_name = speaker_name
	instance.speaker_image = dialogue_text
	return instance
