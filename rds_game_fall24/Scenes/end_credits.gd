extends Node2D

@onready var text = $CanvasLayer/MarginContainer

func _ready():
	UI.start_scene_change(false, false, "")
	UI.set_tooltip("")

func _process(delta):
	text.position.y -= delta * 30.
	
	if (text.position.y < -1874.): 
		UI.start_scene_change(true, true, "res://Scenes/scene_selection.tscn")
		set_process(false)
