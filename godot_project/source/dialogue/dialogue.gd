class_name Dialogue
extends Node
## Can be used to trigger a dialogue sequence and design the dialogue
## in editor. Can also be filled programmatically if wanted.

## Index that keeps track of when the dialogue is finished.
var current_dialogue_step = 0
## Dialogue running.
static var dialogue_running: bool = false
## Stores the used dialogue.
var steps: Array[DialogueStep] = []
static var instance: Dialogue


func _ready() -> void:
	instance = self
	# testing non-interactive demo
	#add_text("text sample <b>bold</b>", "speaker name", "not used yet")
	#add_text("second page", "speaker name 2", "_")
	# option can add dynamic continuation to dialogue with add_texts and add_options
	#add_options([DialogueOption.create("doStuff", func(): print("do stuff callback"))])
	#start_dialogue()
	pass

## Helper method for adding dialogue. 
func add_text(text, name, image):
	steps.append(DialogueStep.create(false, [], DialogueContent.create(text, name, image)))

## Helper method for adding dialogue player options. 
func add_options(opt: Array[DialogueOption]):
	steps.append(DialogueStep.create(true, opt))

func start_dialogue():
	current_dialogue_step = 0
	dialogue_running = true
	DialogueUiManager.instance.show_dialogue_overlay()
	DialogueUiManager.instance.next_dialogue_callback = continue_dialogue
	await get_tree().process_frame
	continue_dialogue()


## Called by DialogueUiManager after first step. Either supplies the next step or ends the
## dialogue.
func continue_dialogue():
	if len(steps) <= current_dialogue_step:
		DialogueUiManager.instance.hide_dialogue_overlay()
		dialogue_running = false
		steps = []
		return
	
	var step = steps[current_dialogue_step]
	if step.isOptions:
		DialogueUiManager.instance.show_player_options(step.options)
	else:
		DialogueUiManager.instance.show_text(step.content)
	
	current_dialogue_step += 1
