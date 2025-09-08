class_name Sounds
extends Node

static var instance: Sounds
@export var button_ding: AudioStreamPlayer
@export var email_typing: AudioStreamPlayer

func _ready() -> void:
	instance = self

func play_button_ding() -> void:
	button_ding.play()

func play_email_typing() -> void:
	email_typing.play()

func stop_email_typing() -> void:
	email_typing.stop()
