extends Node2D

@onready var fox = get_node("Fox")

# Called when the node enters the scene tree for the first time.
func _ready():
	UI.start_scene_change(false, false, "")
	fox.following_player = true
