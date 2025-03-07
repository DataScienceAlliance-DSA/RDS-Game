class_name CutsceneManager
extends Node

var actions : Array[Action] 	# Action array, to be performed in sequence when .action() is called

@onready var player : CharacterController = get_tree().get_nodes_in_group("Player")[0] as CharacterController

@onready var cutscene_active = false
@onready var skipping_cutscene = false
signal cutscene_complete

# UI REFERENCES
@onready var monologue_ui = UI.get_node("Monologue")

func _init(actions):
	UI.set_active_cm(self)
	self.actions = actions

func series_action():
	cutscene_active = true
	for action in actions:
		await action.cue() if !skipping_cutscene else action.cue()
	
	cutscene_complete.emit()

func parallel_action():
	cutscene_active = true
	for action in actions:
		action.cue()
	
	for action in actions:
		await action.action_completed if !skipping_cutscene else action.action_completed
	
	cutscene_complete.emit()

func skip_cutscene():
	skipping_cutscene = true
	for action in actions:
		action.skip_action()
	monologue_ui.close_3choice_dialogue()

func wait(timer):
	if !skipping_cutscene: await get_tree().create_timer(timer).timeout

func call_monologue(script):
	if skipping_cutscene: return
	monologue_ui.open_3choice_dialogue(script, null)
	await monologue_ui.monologue_complete

# clear all actions, free their nodes
func cut():
	cutscene_active = false
	for action in actions:
		action.queue_free()
		actions.pop_front()
