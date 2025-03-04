extends CanvasLayer

@onready var screen_hide = get_node("ScreenHide")
@onready var scene_hide_timer = 0.0
@onready var scene_change_active = false
@onready var screen_fade_active = false
@onready var scene_change_switching = false
var screen_fade_closing

var next_scene : String 			# string to next scene

@onready var scene_hide_max = 1.0	# time it takes for screen to hide before scene_changes

@onready var screen_hide_start = Vector2(1366, 0)
@onready var screen_hide_finish = Vector2(1366, 768)
@onready var screen_hide_goal = Vector2(1366, 0)
@onready var screen_hide_begin = Vector2(1366, 0)
var screen_fade_goal
var current_screen_fade_val

signal ui_change_complete

func _ready():
	screen_hide.visible = false

func _process(delta):
	# print(scene_hide_timer)
	if (scene_hide_timer < scene_hide_max) and (scene_change_active):
		screen_hide.size = screen_hide_begin.lerp(screen_hide_goal, (((scene_hide_timer - scene_hide_max) ** 3.0) / (scene_hide_max ** 3.0)) + 1.0) 
		scene_hide_timer += delta
	elif (scene_change_active) and (scene_change_switching):
		enter_next_scene()
	
	if (scene_hide_timer < scene_hide_max) and (screen_fade_active):
		current_screen_fade_val = lerpf(current_screen_fade_val, screen_fade_goal, delta * 3.)
		screen_hide.modulate = Vector4(1.,1.,1.,current_screen_fade_val)
		scene_hide_timer += delta
	elif (screen_fade_active):
		screen_fade_active = false
		if (!screen_fade_closing):
			screen_hide.visible = false
		ui_change_complete.emit()

func start_scene_change(close, switch, scene): 
	screen_hide.visible = true
	
	next_scene = scene
	
	if (close == true):
		screen_hide_begin.y = screen_hide_start.y
		screen_hide_goal.y = screen_hide_finish.y
	else:
		screen_hide_begin.y = screen_hide_finish.y
		screen_hide_goal.y = screen_hide_start.y
	
	scene_hide_timer = 0.0
	scene_change_active = true
	scene_change_switching = switch

func fade(close):
	if (close):
		current_screen_fade_val = 0.
		screen_hide.modulate = Vector4(1.,1.,1.,current_screen_fade_val)
		screen_hide.visible = true
		screen_fade_closing = true
		screen_fade_goal = 1.0
	else:
		current_screen_fade_val = 1.
		screen_fade_closing = false
		screen_fade_goal = 0.0
	
	scene_hide_timer = 0.0

func enter_next_scene():
	get_tree().change_scene_to_file(next_scene)
