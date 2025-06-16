extends Node2D

@onready var text = $CanvasLayer/MarginContainer
@onready var fade_color = $CanvasLayer2/ColorRect

@onready var fading_screen = false
@onready var fade_timer = 0.

func _ready():
	UI.start_scene_change(false, false, "")
	UI.set_tooltip("")

func _process(delta):
	if (!fading_screen):
		text.position.y -= delta * 30.
		
		if (text.position.y < -2854.):
			set_process(false)
			finish_credits()
	else:
		fade_timer = fade_timer + delta
		if (fade_timer < 3.):
			fade_color.color.a = fade_timer / 3.
		else:
			UI.start_scene_change(true, true, "res://Scenes/scene_selection.tscn")
			set_process(false)

func finish_credits():
	await get_tree().create_timer(5.0).timeout
	fading_screen = true
	set_process(true)
