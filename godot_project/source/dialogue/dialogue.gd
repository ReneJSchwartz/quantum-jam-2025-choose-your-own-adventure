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

func _init():
	SignalBus.sub("game_started", func(data): beginning())

func _ready() -> void:
	instance = self
	# testing non-interactive demo
	#add_text("text sample <b>bold</b>", "speaker name", "not used yet")
	#add_text("second page", "speaker name 2", "_")
	# option can add dynamic continuation to dialogue with add_texts and add_options
	#add_options([DialogueOption.create("doStuff", func(): print("do stuff callback"))])
	#start_dialogue()

## Helper method for adding dialogue. 
func add_text(text, name = "", image = ""):
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

# Game specific dialogue.
func beginning():
	add_text("The laboratory is stark - clean surfaces and white walls.")
	add_text("
	Before you sits your half finished experiment in quantum computing.")
	add_text("
	A bright burst of light flares across your eyes.")
	add_text("
	And before you can blink it's gone, it's after effects glowing at the edges of your sight.")
	var opts: Array[DialogueOption] = []
	opts.append(DialogueOption.create("Check your readings", func(): pass))
	opts.append(DialogueOption.create("Close your eyes", func(): pass))
	opts.append(DialogueOption.create("I think it's time for a coffee break...", func(): pass))
	add_options(opts)
	start_dialogue()

func passage_a():
	pass
