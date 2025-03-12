extends Node2D

@onready var player = get_tree().get_nodes_in_group("Player")[0]

func _ready():
	player.global_position = PS.spawning_at
	player.autonomous = false
	UI.start_scene_change(false, false, "")

func _process(delta):
	print(player.global_position)
