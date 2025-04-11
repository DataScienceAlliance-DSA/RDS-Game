extends Node2D

@onready var player = get_tree().get_nodes_in_group("Player")[0]

@export var default_spawn : Vector2

func _ready():
	player.global_position = PS.spawning_at
	player.autonomous = false
	UI.start_scene_change(false, false, "")
	
	match(PS.village_state):
		1:
			if PS.spawning_at != Vector2(0.,0.): player.global_posiion = PS.spawning_at
			else: player.global_position = default_spawn
		2:
			if PS.spawning_at != Vector2(0.,0.): player.global_posiion = PS.spawning_at
			else: player.global_position = default_spawn
		3:
			player.global_position = Vector2(1629,-1839)

func _process(delta):
	print(player.global_position)
