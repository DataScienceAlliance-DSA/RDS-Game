# Cauldron_Room:
# literally just for cutscenes of the cauldron room
class_name Cauldron_Room
extends Node2D


func _ready():
	var dialogue_ui = UI.get_node("Dialogue")
	
	var player = get_node("Player")
	player.autonomous = true
	var actionA = Action.new(player, "LerpMove", Vector2(960,928), 200)
	
	var actions : Array[Action] = [actionA]
	for action in actions:
		add_child(action)
	
	var cm = CutsceneManager.new(actions)
	cm.parallel_action()
	
	await cm.cutscene_complete
	
	dialogue_ui.open_dialogue("res://Scripts/Dialogues/Cauldron/FoxIntro.json", null)
	await dialogue_ui.dialogue_complete
	# RE ENABLE THE PLAYER
	player.autonomous = false
