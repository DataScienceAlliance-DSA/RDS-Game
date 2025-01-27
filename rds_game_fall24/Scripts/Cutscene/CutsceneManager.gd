class_name CutsceneManager
extends Node

var actions : Array[Action] 	# Action array, to be performed in sequence when .action() is called

@onready var player : CharacterController = get_tree().get_nodes_in_group("Player")[0] as CharacterController

signal cutscene_complete


func _init(actions):
	self.actions = actions

func series_action():
	for action in actions:
		await action.cue()
	
	cutscene_complete.emit()

func parallel_action():
	for action in actions:
		action.cue()
	
	for action in actions:
		await action.action_completed
	
	cutscene_complete.emit()

# clear all actions, free their nodes
func clear():
	for action in actions:
		action.queue_free()
		actions.pop_front()
