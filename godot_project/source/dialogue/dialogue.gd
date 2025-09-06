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
	# Find SignalBus in the scene tree when ready
	pass

func _ready() -> void:
	instance = self
	# Connect to game_started signal once SignalBus is available
	call_deferred("_connect_signal_bus")
	
func _connect_signal_bus():
	var signal_bus = get_node("/root/GameTree/Scripts/SignalBus")
	if signal_bus:
		signal_bus.sub("game_started", func(_data): beginning())
	else:
		print("Warning: SignalBus not found!")
	
	# testing non-interactive demo
	#add_text("text sample <b>bold</b>", "speaker name", "not used yet")
	#add_text("second page", "speaker name 2", "_")
	# option can add dynamic continuation to dialogue with add_texts and add_options
	#add_options([DialogueOption.create("doStuff", func(): print("do stuff callback"))])
	#start_dialogue()

## Helper method for adding dialogue. 
func add_text(text, speaker_name = "", image = ""):
	steps.append(DialogueStep.create(false, [], DialogueContent.create(text, speaker_name, image)))

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
	# todo you got mail sound
	add_text("""NovaCore
Quantum Gate Operation

Attention: Dr. Kaela

With the recent discovery of the unusual quantum effect called the "Higgs Echo", you have been recruited to study and harness this quantum echo.

As a leading physicist in your field, we except your experimentation with quantum superconductors to recapture and demonstrate the burst of brilliant light that mysteriously vanishes – the echo.

NovaCore envisions using the control of these echoes to unlock lost knowledge, resurrect moments from the past and potentially communicate across alternate timelines. This Echo-tech has the potential to change the face of the world.

We expect an accelerated timeline with your work, however manipulating echoes is perilous. Reviving the vanished light requires precise timing and interference of quantum pulses, risking unpredictable quantum feedback and fractures in reality. You have been chosen for this skill.

There have been security breaches in the recent days since the discovery. NovaCore reminds you of the NDA you have signed and stress the consequences of any contact with those outside the lab.

You have been assigned Engineer Theo and AI Assistant Ava to assist.

Any delay may lead to the technology falling into the wrong hands.

Kaela - you must master quantum echo technology.""")
	
	# todo insert scene swap
	discovery()
	
	start_dialogue()


func discovery():
	add_text("""That was three days ago and you, Theo and Ava have been locked away behind heavy security doors in the secure lab working hard.

NovaCore are breathing down the back of your neck.

But today —  you have finally managed to recreate the original experiment.

You stand before the quantum echo lab console, the vanished burst of light now flickering faintly on the screen.

It fades slowly, leaving the lab dim and silent in the afterglow.

Kaela:
“This burst... it’s not just light fading away.”

“It’s a quantum trace — a hidden echo waiting to be pulled back from nothingness.”

“If I can capture and feed this into the Echo Processor, maybe we can uncover what vanished with it?”

Theo arrives at the lab, tension etched on his face. “We need to do this right. What do you choose?”""")

	add_option("Attempt to capture the burst carefully.", func(): discovery_a_capture())
	add_option("Run a full diagnostic on the Echo Processor first.", func(): discovery_b_diagnostics())
	add_option("Consult with Theo before proceeding.", func(): discovery_c_consult())
	queue_added_options()

func discovery_a_capture():
	add_text("""Your hands steady, you initiate the capture protocol. The burst pulses—then disappears. Your instruments register a faint echo signal.
Kaela (thinking): "It’s fragile—this quantum presence is like a ghost trapped between realities."
Ava: “The data here is not strong enough to be read. I suggest feeding captured signal into the Echo Processor.”
""")

	add_option("Proceed to feed the captured signal into the Echo Processor.", processor)
	queue_added_options()
	

func discovery_b_diagnostics():
	add_text("""You decide caution is best and run diagnostics. Unexpectedly, a critical error warning flashes.
Theo: "Kaela, the system’s unstable! We could crash the entire quantum circuit if we proceed without fixing it."
""")
	add_option("Fix the error immediately", discovery_b_diagnostics_fix)
	add_option("Take a risk and capture anyway", discovery_a_capture)
	queue_added_options()
	
func discovery_b_diagnostics_fix():
	
	add_text("""Kaela: “Ava, run a workaround while we fix this.”""")
	
	add_text("""It looks like someone has tried to hack the system, but you caught it in time.
	Theo (comms): “I think we’re ready.”""")
	
	add_option("Proceed to feed the captured signal into the Echo Processor.", processor)
	queue_added_options()	

func discovery_c_consult():
	add_text("""Theo: "These echoes aren’t just data. They’re unstable quantum memories. How we handle them could rewrite what reality remembers."
Kaela: “How do we find out more about them?”
Theo: “We should run a diagnostic. Capturing them directly without more information could make them unpredictable."
""")

	add_option("Listen to Theo’s advice and run diagnostics", discovery_b_diagnostics_fix)
	add_option("Insist on capturing immediately", discovery_a_capture)
	queue_added_options()
	
func processor():
	add_text("""Theo (Engineer): “Kaela, timing is critical here. Feed the qubits gently into the processor. Each quantum gate you apply must be precise — one wrong flip could collapse the entire superposition. The echoes are fragile but hold the key to forgotten memories.”

Kaela: “And what happens if I fail?”

Theo: “... Don’t.”""")

	if randi() % 2 == 0:
		
		pass
	else:
		processor_bit_flip
		pass  
	add_option("Apply a bit-flip gate first.", processor_bit_flip)
	
	pass
	
func processor_bit_flip():
	add_text("""You apply the bit-flip gate. The echo pulses brighter but wavers unpredictably.
Kaela: "The echoes react... I hope this reveals more than it conceals."
Apply gates to stabilize the echo""")

	if randi() % 2 == 0:
		processor_bit_flip_pass()
	else:
		processor_bit_flip_fail()
		
func processor_bit_flip_pass():
	add_text("""Bit-flip - Pass
The flip succeeds and the bit-flip gate is applied.
A transparent memory, this very lab, scientists running similar tests.
	Kaela: A quantum memory, past and present converging.

Somewhere beneath the surface, faint voices murmur, their messages lost to time but not entirely extinguished. This memory beckons you to listen closely — to gather shards of forgotten knowledge, piecing together a past only partially remembered.
But it fades before you can learn anything.

Theo: It’s holding stable.""")

	add_option("Phase-flip gate.", processor_phase_flip)
	
func processor_bit_flip_fail():
	pass
	
func processor_phase_flip(): 
	pass
