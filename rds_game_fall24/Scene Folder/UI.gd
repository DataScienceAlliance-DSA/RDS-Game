extends CanvasLayer

@onready var screen_hide = get_node("ScreenHide")
@onready var scene_hide_timer = 0.0
@onready var scene_change_active = false
@onready var scene_change_switching = false

@onready var scene_hide_max = 1.0	# time it takes for screen to hide before scene_changes

@onready var screen_hide_start = Vector2(1366, 0)
@onready var screen_hide_finish = Vector2(1366, 768)
@onready var screen_hide_goal = Vector2(1366, 0)
@onready var screen_hide_begin = Vector2(1366, 0)

func _ready():
	screen_hide.visible = false

func _process(delta):
	# print(scene_hide_timer)
	if (scene_hide_timer < scene_hide_max) and (scene_change_active):
		screen_hide.size = screen_hide_begin.lerp(screen_hide_goal, (((scene_hide_timer - scene_hide_max) ** 3.0) / (scene_hide_max ** 3.0)) + 1.0) 
		scene_hide_timer += delta
	elif (scene_change_active) and (scene_change_switching):
		enter_next_scene()

func start_scene_change(close, switch): 
	screen_hide.visible = true
	
	if (close == true):
		screen_hide_begin.y = screen_hide_start.y
		screen_hide_goal.y = screen_hide_finish.y
	else:
		screen_hide_begin.y = screen_hide_finish.y
		screen_hide_goal.y = screen_hide_start.y
	
	scene_hide_timer = 0.0
	scene_change_active = true
	scene_change_switching = switch

func enter_next_scene():
	get_tree().change_scene_to_file("res://Scene Folder/Minigames/Cannonball_Game/GameManager/Cannonball_Game.tscn")
