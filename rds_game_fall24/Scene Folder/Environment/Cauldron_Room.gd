# Cauldron_Room:
# literally just for cutscenes of the cauldron room
class_name Cauldron_Room
extends Node2D

@onready var player = get_node("Player")
@onready var dialogue_ui = UI.get_node("Dialogue")

@export var default_spawn : Vector2

func _ready():
	match(PS.cauldron_state):
		0:
			player.autonomous = true
			get_tree().get_nodes_in_group("Fox")[0].following_player = false
			
			var actionA = Action.new(player, "LerpMove", Vector2(960,928), 200)
			var actionB = Action.new(player, "LerpMove", Vector2(961,928), 200)
			
			var actions : Array[Action] = [actionA, actionB]
			for action in actions:
				add_child(action)
			
			var cm = CutsceneManager.new(actions)
			
			UI.start_scene_change(false, false, "")
			cm.series_action()
			
			await cm.actions_complete
			
			cm.cut()
			
			# required dialogue
			dialogue_ui.open_dialogue("res://Scripts/Dialogues/Cauldron/FoxIntro.json", null)
			await dialogue_ui.dialogue_complete
			
			# RE ENABLE THE PLAYER
			player.autonomous = false
		1:
			if PS.spawning_at != Vector2(0.,0.): player.global_position = PS.spawning_at
			else: player.global_position = default_spawn
			
			get_node("Cauldron/CauldronArea").interactions = 2
			
			player.autonomous = false
			get_tree().get_nodes_in_group("Fox")[0].following_player = true
			UI.start_scene_change(false, false, "")
