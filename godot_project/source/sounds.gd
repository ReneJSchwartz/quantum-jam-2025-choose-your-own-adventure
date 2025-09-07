class_name Sounds
extends Node

static var instance: Sounds
@export var button_ding: AudioStreamPlayer

func _ready() -> void:
	instance = self

func play_button_ding() -> void:
	button_ding.play()
	
