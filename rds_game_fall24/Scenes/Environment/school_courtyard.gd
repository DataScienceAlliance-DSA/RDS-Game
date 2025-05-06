extends Node2D

@onready var fox = get_node("Fox")
@onready var player = get_tree().get_nodes_in_group("Player")[0]

# Called when the node enters the scene tree for the first time.
func _ready():
	if (PS.spawning_at != Vector2(0,0)): player.global_position = PS.spawning_at
	else: player.global_position = Vector2(72, 449)
	UI.start_scene_change(false, false, "")
	fox.following_player = true
