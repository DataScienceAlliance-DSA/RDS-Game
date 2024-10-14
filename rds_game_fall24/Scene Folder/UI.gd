extends CanvasLayer

@onready var screen_hide = get_node("ScreenHide")
@onready var scene_hide_timer = 0.0
@onready var scene_change_active = false

@onready var scene_hide_max = 1.0	# time it takes for screen to hide before scene_changes

@onready var screen_hide_start = Vector2(1366, 0)
@onready var screen_hide_finish = Vector2(1366, 768)

func _ready():
	screen_hide.visible = false

func _process(delta):
	if (scene_hide_timer < scene_hide_max) and (scene_change_active):
		screen_hide.size = screen_hide_start.lerp(screen_hide_finish, (((scene_hide_timer - scene_hide_max) ** 3.0) / (scene_hide_max ** 3.0)) + 1.0) 
		print(screen_hide.size)
		scene_hide_timer += delta
	elif (scene_change_active):
		enter_next_scene()

func start_scene_change(): 
	screen_hide.visible = true
	screen_hide.size.y = 0
	scene_hide_timer = 0.0
	scene_change_active = true
	print("here")

func enter_next_scene():
	get_tree().change_scene_to_file("res://Scene Folder/Minigames/Cannonball_Game/GameManager/Cannonball_Game.tscn")
