class_name DialogueContent
extends RefCounted
## Wraps the data the dialogue box needs for showing text.

var dialogue_text: String = ""
var speaker_name: String = ""
var speaker_image: String = ""

static func create(p_dialogue_text: String, p_speaker_name: String = "", p_speaker_image: String = "") -> DialogueContent:
	var instance = DialogueContent.new()
	instance.dialogue_text = p_dialogue_text
	instance.speaker_name = p_speaker_name
	instance.speaker_image = p_speaker_image
	return instance
