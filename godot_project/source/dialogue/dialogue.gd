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
	
##All three options need to be done to proceed

var completed_bit_flip: bool
var completed_phase_flip: bool
var completed_rotation: bool

func processor():
	add_text("""Theo (Engineer): “Kaela, timing is critical here. Feed the qubits gently into the processor. Each quantum gate you apply must be precise — one wrong flip could collapse the entire superposition. The echoes are fragile but hold the key to forgotten memories.”

Kaela: “And what happens if I fail?”

Theo: “... Don’t.”""")
  
	add_option("Apply a bit-flip gate first.", func(): 
		completed_bit_flip = true
		processor_bit_flip())
	add_option("Start with a phase-flip gate.", func():
		completed_phase_flip = true
		processor_phase_flip()) 
	add_option("Rotate the qubit superposition to reveal hidden states", func():
		completed_rotation = true
		processor_rotate())
	queue_added_options()
	
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

	if completed_bit_flip and completed_phase_flip and completed_rotation:
		processor_complete()
	else:
		if completed_phase_flip == false:
			add_option("Phase-flip gate.", func():
				completed_phase_flip = true
				processor_phase_flip())
		if completed_rotation == false:
			add_option("Rotate the qubit superposition to reveal hidden states.", func():
				completed_rotation = true
				processor_rotate())
		queue_added_options()
	
func processor_bit_flip_fail():
	add_text("""It fails and the light vanishes in a blink as the superposition collapses.
But not before a memory, a flash of this same lab superimposed on this lab appears.
	Panicked scientists turn to run.
Before all is swallowed in a blink of light.
-
Kaela: What was that?
Ava: Quantum decoherence
Kaela: No, before that, like it was showing us something that had happened before. A quantum memory, past and present converging.
Theo: Not just that, we’ve got some anomalies here…
Kaele: The light, it’s growing-
A blink of light swallows everything.

THE END.""")
##ends the game
	
func processor_phase_flip(): 
	add_text("""The echo’s glow shifts hues as the phase flips. You sense a whisper of a memory trying to surface.
AI Ava: Phase adjustments detected. Memory fragment integrity increased."
""")

func processor_phase_flip_pass():
	add_text("""Theo: The second gate is up.

The light dims and warps. Shadows gather, and the memory becomes fragmentary—blurred shapes shift in and out of focus, voices murmur softly but indistinctly, like being half-remembered in a dream. 

Faint echoes of disquiet stir the air—whispers of failures, lost experiments, and fading hopes.
A sense of melancholy seeps deep—a silent testament to the quantum echoes trapped in limbo, lost and waiting for remembrance. The boundary between memory and oblivion blurs here, unveiling the fragile nature of what once was and what might have been.
Kaela: "They… were here, once.”
“Dreams and despair intertwined in fragile quantum webs.”
The Light and the voices fade.
	
Theo: It’s holding stable. Choose the next gate carefully to avoid collapse.""")
##This can only succeed, because fail is not found in story text

func processor_rotate():
	add_text("""As you rotate the superposition, complex interference patterns emerge, revealing multiple potential memories branching within the echo.
Kaela (awed): "So many possibilities... which reality do I choose to remember?""")
	
	add_option("Brightest memory path.", brightest_memory_path)
	add_option("Faint echoes.", explore_faint_echoes)
	queue_added_options()
	
func brightest_memory_path():
	add_text("""The chamber fills with a radiant glow, shadows lifting to reveal the sharp outlines of a bustling research floor. 
Scientists catalog data with nervous excitement; Kaela stands before a massive console, her face illuminated by cascading holograms of quantum patterns. 
This memory captures the very moment the team surpassed a monumental barrier — the quantum echoes stabilizing for the first time, a symphony of light and hope woven into every pulse.
You sense not just a technical achievement, but a profound awakening — the birth of a new era where memory and reality blur, and possibilities expand beyond the imaginable.
Dialogue (Kaela’s Voice):
“We stood on the edge of the unknown, hearts pounding with anticipation and fear. 
Each signal from the quantum echoes was a promise whispered across time and space—proof that our understanding was just beginning. 
This moment was our beacon, the light piercing the darkness. It taught me that even in uncertainty, resolve and belief create miracles.”

The memory from the flare fades.""")

	if completed_bit_flip and completed_phase_flip and completed_rotation:
		processor_complete()
	else:
		if completed_phase_flip == false:
			add_option("Phase-flip gate.", func():
				completed_phase_flip = true
				processor_phase_flip())
		if completed_bit_flip == false:
			add_option("Apply a bit-flip gate.", func():
				completed_bit_flip = true
				processor_bit_flip())
		queue_added_options()

func explore_faint_echoes():
	add_text("""You're drawn into a prism of possibilities—the memory fractures into two divergent
timelines, each pulsing with life and consequence.
In one, the project flourishes beyond all expectations. New cures, quantum communication, and technologies blossom rapidly, illuminating the world with unprecedented advancements. The energy is vibrant, full of hope and renewal, where Kaela and her cohorts stand triumphant, celebrated as pioneers of a new age.
Yet, the other timeline is draped in darkness. Catastrophe follows unchecked ambition. Quantum experiments spiral out of control, rending spacetime itself. Cities fall into chaos, memories become fragmented and lost, and despair taints every human connection. Here, Kaela’s gamble with quantum echoes ends in ruin.
The quantum reality bends before you—a choice crystallizes. Which timeline will you preserve? The world of radiant hope or the one scarred by quantum chaos? The echoes do not judge; they await your hand to collapse the infinite possibilities into one enduring reality.
Dialogue (Echo Whisper, overlapping voices):
“Two paths diverged in the quantum cloud, each bearing the weight of all we dared and feared.”
“One blooms with light—the promise of what might be, if we hold fast to courage and wisdom.”
“The other darkens, a warning etched in shattered echoes—of power unchecked and lines crossed.”
“Your choice will echo across time, shaping the future’s fragile fabric. Choose well, for you are the weaver of worlds.”

Kaela (reflective):
So much hangs in the balance...
Our dreams, our fears... trapped in quantum shadows.
But this is more than a choice — it is the destiny we forge.
I must decide which world the echoes will sing… and which will fade into silence.""")

	if completed_bit_flip and completed_phase_flip and completed_rotation:
		processor_complete()
	else:
		if completed_phase_flip == false:
			add_option("Phase-flip gate.", func():
				completed_phase_flip = true
				processor_phase_flip())
		if completed_bit_flip == false:
			add_option("Apply a bit-flip gate.", func():
				completed_bit_flip = true
				processor_bit_flip())
		queue_added_options()

func processor_complete():
	add_text("""The light flickers and pulses but settles.

Theo: “It’s stable! You did it!”
Kaela: Let’s see what we’ve unlocked.

Reality splinters before you— the memory of the laboratory overlapping here and now.

The scientists mill about the lab, the bright quantum light in the memory, looks stable.
A mirror image of the light you’ve managed to stabilize.

Out of the corner of your eye you see a scientist pocket a USB.
They sneak out when none of the phantom scientists are watching.
Only moments later NovaCore guards enter the lab.

But their orders are silent, drowned out by the murmuring voices.
But they drag one of the scientists out, struggling.

Panic sets in and the Higgs echo destabilizes under observation.

The memory light flickers and flares. Your own light flares in response. An echo.

What you see unfolding is chaos. 
Panicked scientists turn to run as the light glows brighter.
Others are hunched over their desks typing furiously.

Before all is swallowed in a bright flare of light.


The lab is left empty, the light and memory fading.
-
Kaela: What just happened?
Ava: “Memory chamber unlocked.”

A new stable memory forms. 

The memory chamber resonates around you.

The memory pulses with a cascade of elegant quantum algorithms and blueprints—fractal in complexity, shimmering like a living code. 
As the quantum echo memory stabilizes, the walls around you dissolve into shifting streams of light and shadow. 
a whisper forms into a voice — not just data, but a sentient consciousness trapped within the echoes.
The image of Dr. Mira Selwyn flickers before you, her eyes haunted, her voice trembling with urgency.
Dialogue (Mira’s Voice):
 "I… remember the silence that followed the catastrophe. The project was our beacon, our hope. Yet… beneath that light, betrayal festered like a shadow. I was there, Kaela. I saw the sabotage, felt the fracture in our reality. You must finish what was started, untangle the web of lies woven in dark corridors. I sacrificed everything to preserve these memories — you must not let them be lost again."
(soft echoing) "Trust the echoes, even when they falter. Find the truth… before it fades forever."
	The light and the memory fade.""")
	
func quantum_memory():
	add_text("""AI Assistant Ava: 
“Echo signals from a forgotten past are reconstructing… Can you feel it, Kaela? The quantum whispers of those lost, waiting for you to listen.”

Kaela: “NovaCore didn’t tell me they had almost succeeded before this - that they’d lost so many people.”

Theo: 
“Unlocking and harnessing Echo-tech is a priority. 
You saw one of the scientists stole our data, it was the only record left of the experiment after the accident. And now it’s in the hands of our rivals.
But if we can apply our own obfuscation on the quantum memories we unlock here…
We could rewrite it and make it like it never happened.Keep Echo-Tech our”

Ava: “Can you hear them?”

Kaela: “That’s what quantum presence is. Their memories are lost, like ghosts trapped between realities. And you want to rewrite memory, so none of those scientists existed?”

Theo frowns and shakes his head.
Theo: “Echo-tech belongs to NovaCore - they belong to NovaCore. We can keep them stable and safe and learn from the echoes. Without us, they will be lost.”

Alarms flare and red light flashes across the lab.


“WARNING. SECURITY BREACH. WARN-”

The warning is cut off, the lights flicker back to normal.

And the heavy security doors slide open.""")

func dilemma():
	
	
	pass
	
