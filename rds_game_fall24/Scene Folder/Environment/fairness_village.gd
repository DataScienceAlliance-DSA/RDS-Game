extends Node2D

@onready var player = get_tree().get_nodes_in_group("Player")[0]

func _ready():
	player.autonomous = false
	UI.start_scene_change(false, false, "")
