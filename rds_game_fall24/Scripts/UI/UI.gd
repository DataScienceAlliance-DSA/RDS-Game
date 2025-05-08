extends CanvasLayer

@onready var screen_hide = get_node("ScreenHide")
@onready var screen_hide_canvas = get_node("ScreenHide") as CanvasItem

@onready var skip_cutscene = get_node("DebugStuff/SkipCutsceneCTRL/ProgressBar")

@onready var scene_hide_timer = 0.0
@onready var scene_change_active = false
@onready var screen_fade_active = false
@onready var scene_change_switching = false
var screen_fade_closing

var next_scene : String # string to next scene

@onready var scene_hide_max = 1.0	# time it takes for screen to hide before scene_changes

@onready var screen_hide_start = Vector2(1366, 0)
@onready var screen_hide_finish = Vector2(1366, 768)
@onready var screen_hide_goal = Vector2(1366, 0)
@onready var screen_hide_begin = Vector2(1366, 0)
var screen_fade_goal
var current_screen_fade_val

var active_cutscene_manager : CutsceneManager # reference to the current scene's active CM

signal ui_change_complete

func _ready():
	screen_hide.visible = false

func _process(delta):
	# print(scene_hide_timer)
	if (scene_hide_timer < scene_hide_max) and (scene_change_active):
		screen_hide.size = screen_hide_begin.lerp(screen_hide_goal, (((scene_hide_timer - scene_hide_max) ** 3.0) / (scene_hide_max ** 3.0)) + 1.0) 
		scene_hide_timer += delta
	elif (scene_change_active):
		if (scene_change_switching): enter_next_scene()
		scene_change_active = false
		scene_change_switching = false
	
	if (scene_hide_timer < scene_hide_max) and (screen_fade_active):
		current_screen_fade_val = lerpf(current_screen_fade_val, screen_fade_goal, delta * 3.)
		screen_hide_canvas.modulate = Color(1.,1.,1.,current_screen_fade_val)
		scene_hide_timer += delta
	elif (screen_fade_active):
		screen_fade_active = false
		if (!screen_fade_closing):
			screen_hide.size = Vector2(DisplayServer.window_get_size().x, 0.)
			screen_hide.visible = false
		ui_change_complete.emit()
	
	if (active_cutscene_manager != null):
		if (active_cutscene_manager.cutscene_active):
			if (Input.is_action_pressed("skip_cutscene")):
				skip_cutscene.value = min(1., skip_cutscene.value + delta)
			else:
				skip_cutscene.value = max(0., skip_cutscene.value - delta)
			
			if (skip_cutscene.value == 0.):
				skip_cutscene.visible = false
			elif (skip_cutscene.value == 1.):
				skip_cutscene.visible = false
				active_cutscene_manager.skip_cutscene()
			else:
				skip_cutscene.visible = true

func start_scene_change(close, switch, scene): 
	screen_hide.visible = true
	screen_hide.modulate = Color(1.,1.,1.,1.)
	
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
		screen_fade_active = true
		current_screen_fade_val = 0.
		screen_hide.modulate = Color(1.,1.,1.,current_screen_fade_val)
		screen_hide.size = DisplayServer.window_get_size()
		screen_hide.visible = true
		screen_fade_closing = true
		screen_fade_goal = 1.0
	else:
		screen_fade_active = true
		current_screen_fade_val = 1.
		screen_fade_closing = false
		screen_fade_goal = 0.0
	
	scene_hide_timer = 0.0

func enter_next_scene():
	if (next_scene):
		get_tree().change_scene_to_file(next_scene)

func set_active_cm(active_cutscene_manager):
	self.active_cutscene_manager = active_cutscene_manager
