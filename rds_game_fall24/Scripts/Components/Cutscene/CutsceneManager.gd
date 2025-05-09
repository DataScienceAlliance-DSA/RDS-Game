class_name CutsceneManager
extends Node

var actions : Array[Action] 	# Action array, to be performed in sequence when .action() is called

@onready var player : CharacterController = get_tree().get_nodes_in_group("Player")[0] as CharacterController

@onready var cutscene_active = false
@onready var skipping_cutscene = false

signal actions_complete # emitted after action group (parallel/series) is completed
signal lines_complete # emitted after monologue/dialogue is completed
signal wait_complete # emitted after wait is completed

var parallel_completion_holdout
signal parallel_completed

# UI REFERENCES
var monologue_ui
var dialogue_ui

func _init(actions):
	UI.set_active_cm(self)
	self.actions = actions
	monologue_ui = UI.get_node("Monologue")
	dialogue_ui = UI.get_node("Dialogue")

func set_actions(actions):
	self.actions = actions
	parallel_completion_holdout = false # stop all previous parallel motions?

func series_action():
	cutscene_active = true
	player.in_cutscene = true
	for action in actions:
		action.cue()
		if !skipping_cutscene: await action.action_completed
		else: action.skip_action()
	
	actions_complete.emit()

func parallel_action():
	cutscene_active = true
	player.in_cutscene = true
	for action in actions:
		action.cue()
	
	parallel_completion_holdout = true
	await self.parallel_completed
	
	actions_complete.emit()

func halt():
	for action in actions:
		action.halt()

func _process(delta):
	if (parallel_completion_holdout):
		if !skipping_cutscene:
			var all_actions_finished = true
			for action in actions:
				if (!action.action_finished): all_actions_finished = false
			parallel_completion_holdout = !all_actions_finished
			if all_actions_finished: parallel_completed.emit()
		else: 
			for action in actions:
				action.skip_action()
			parallel_completion_holdout = false
			parallel_completed.emit()

func skip_cutscene():
	skipping_cutscene = true
	for action in actions:
		action.skip_action()
	monologue_ui.close_3choice_dialogue()
	dialogue_ui.close_dialogue()
	
	actions_complete.emit()
	lines_complete.emit()
	wait_complete.emit()

func wait(timer):
	if !skipping_cutscene: 
		await get_tree().create_timer(timer).timeout
	wait_complete.emit()

func call_monologue(script):
	if skipping_cutscene: return
	monologue_ui.open_3choice_dialogue(script, null)
	await monologue_ui.monologue_complete
	
	lines_complete.emit()

func call_dialogue(script):
	if skipping_cutscene: return
	dialogue_ui.open_dialogue(script, null)
	await dialogue_ui.dialogue_complete
	
	lines_complete.emit()

# clear all actions, free their nodes
func cut():
	player.in_cutscene = false
	cutscene_active = false
	for action in actions:
		action.queue_free()
		actions.pop_front()
