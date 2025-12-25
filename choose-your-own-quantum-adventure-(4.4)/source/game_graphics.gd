class_name GameGraphics
extends Control

@export var grid: TextureRect
@export var novacore_text: TextureRect
@export var line_graph: TextureRect
@export var bar_graph: TextureRect
@export var qubit: TextureRect
@export var text_box_bg: TextureRect
@export var ava: TextureRect
@export var ava_volume: TextureRect
@export var light: TextureRect

static var instance: GameGraphics

func _ready() -> void:
	instance = self
	#SignalBus.instance.sub("game_started", func (data): show_text_box())
	_hide_all()

func _hide_all():
	line_graph.visible = false
	bar_graph.visible = false
	qubit.visible = false
	text_box_bg.visible = false
	ava.visible = false
	ava_volume.visible = false

func show_text_box():
	print("show_text_box")
	text_box_bg.visible = true

func show_widgets_at_right():
	qubit.visible = true
	line_graph.visible = true
	bar_graph.visible = true

func show_ava():
	ava.visible = true

func hide_ava():
	ava.visible = false

func ava_start_talking():
	ava_volume.visible = true

func ava_stop_talking():
	ava_volume.visible = false
