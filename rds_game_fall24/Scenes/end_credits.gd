extends Node2D

@onready var text = $CanvasLayer/MarginContainer
@onready var fade_color = $CanvasLayer2/ColorRect

@onready var fading_screen = false
@onready var fade_timer = 0.

@onready var credits_speed = 30.

@onready var credits_icon = $CanvasLayer/MarginContainer2/Control/CreditsIcon
@onready var credits_icon_timer = 0.

# CONSTANTS FOR FFW ICON INTERPOLATION
const n1 = 7.5625
const d1 = 2.75

func _ready():
	UI.start_scene_change(false, false, "")
	UI.set_tooltip("")

func _process(delta):
	if (Input.is_anything_pressed() and !Input.is_action_pressed("menu")):
		credits_speed = 300.
		credits_icon_timer = credits_icon_timer + delta
		credits_icon.visible = true
		
		credits_icon_timer = fmod(credits_icon_timer, 1.5)
		var shift
		if (credits_icon_timer < .75):
			var x = credits_icon_timer / .75
			if (x < 1 / d1): 
				shift = n1 * x * x;
			elif (x < 2 / d1): 
				x -= 1.5 / d1
				shift = n1 * x * x + 0.75;
			elif (x < 2.5 / d1): 
				x -= 2.25 / d1
				shift = n1 * x * x + 0.9375;
			else: 
				x -= 2.625 / d1
				shift = n1 * x * x + 0.984375;
		else:
			var x = (credits_icon_timer - .75) / .75
			shift = pow(1. - x, 4.);
		
		credits_icon.position = Vector2(-shift * 25., 0.)
	else:
		credits_speed = 30.
		credits_icon_timer = 0.
		credits_icon.visible = false
		
		credits_icon.position = Vector2(0.,0.)
	
	if (!fading_screen):
		text.position.y -= delta * credits_speed
		
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
	credits_icon.visible = false
	await get_tree().create_timer(5.0).timeout
	fading_screen = true
	set_process(true)
