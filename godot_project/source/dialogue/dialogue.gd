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
## Stores temporary options that can be fed to add_options()
var temp_options: Array[DialogueOption]
var on_dialogue_end_callback: Callable = func(): pass
## Delay hiding dialogue by this amount. 
var hide_dialogue_delay: float = 0
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

# adds to temp options, needs confirming with add_built_options_step()
func add_option(text: String, action: Callable):
	temp_options.append(DialogueOption.create(text, action))

# allows building options in steps using add_option()
func queue_added_options():
	steps.append(DialogueStep.create(true, temp_options))
	temp_options = []

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
		on_dialogue_end_callback.call()
		on_dialogue_end_callback = func(): pass
		get_tree().create_timer(hide_dialogue_delay).timeout.connect(
			DialogueUiManager.instance.hide_dialogue_overlay)
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
	opts.append(DialogueOption.create(
		"Check your readings", 
		func(): passage_a()))
	opts.append(DialogueOption.create("Close your eyes", func(): pass))
	opts.append(DialogueOption.create("I think it's time for a coffee break...", func(): pass))
	add_options(opts)
	start_dialogue()

func passage_a():
	add_text("The burst of light... it seems to be a quantum signature. 
Data trapper in an alternate quantum state, here on second... gone the next. Lost.

But maybe...")

	add_option("I should try to restest and get it to reappear", 
		func(): passage_a_1())
	add_option("I should be careful and run some tests",
		func(): passage_a_2_test())
	queue_added_options()

func passage_a_1(): # a 1 reappear
	add_text("Wow, I made it reappear! 
The burst is brighter than before, lasting longer.
But when it fades it leaves behind an afterimage in its wake.
The air seems to quiver where it floated.

It looks like the after image of a previous experiment.
Like this has been done before.")
	
	var opts: Array[DialogueOption] = []
	opts.append(DialogueOption.create(
		"Keep going and try again", 
		func(): passage_a_1()))
	opts.append(DialogueOption.create(
		"I should be careful and run some tests",
		func(): passage_a_2_test( )))
	
	add_options(opts)
	
# when at 3 continue a passage non test side. at 1 because we just continued
var keep_going_amt = 1
func passage_a_1_continue(): # keep going and try again
	add_text("Keep testing.

The light burns brighter and longer.
And I can see the experiment and the scientist...

But something seems to be going wrong.")

	var opts: Array[DialogueOption] = []
	opts.append(DialogueOption.create(
		"Keep going, I need to find out what happens", 
		func():
			keep_going_amt += 1
			if keep_going_amt >= 3:
				passage_a_1_triple_continue()
			else:
				passage_a_1_continue())) # recursion until 3 keep goings
	opts.append(DialogueOption.create(
		"I should be careful and run some tests",
		func(): 
			passage_a_2_test()))
	add_options(opts)

func passage_a_1_triple_continue():
	
	pass


func passage_a_2_test():
	
	pass
