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
@onready var screen_blur = $ScreenBlur.material as ShaderMaterial
@onready var screen_blur_node = $ScreenBlur
@onready var exit_game_button = $PauseMenu/VBoxContainer/Panel2/MarginContainer/VBoxContainer/Control3/TextureButton

@onready var dialogue = $Dialogue
@onready var monologue = $Monologue

@onready var player_name_input = $PlayerNameInput

@onready var pause_menu = $PauseMenu

@onready var tooltip_active = false
@onready var pause_menu_active = false

@onready var tooltip_image = $InstructionsPanel2/Control2/TextureRect
@onready var tooltip_button = $InstructionsPanel/Control/TextureButton
@onready var tooltip_blur = $TooltipBlur
@onready var tooltip_button_panel = $InstructionsPanel
@onready var tooltip_instructions_panel = $InstructionsPanel2

var active_cutscene_manager : CutsceneManager # reference to the current scene's active CM

signal ui_change_complete

@onready var TOOLTIP_BUTTON_VISITED_PATH = load("res://Assets/1_Fairness/FairnessEnv/Help Button_Visited.png")
@onready var TOOLTIP_BUTTON_NORMAL_PATH = load("res://Assets/1_Fairness/FairnessEnv/Help Button_Active.png")

@onready var interaction_prompt_label = get_node("TutorialTexts/InteractionHelpLabel")

func ready():
	UI.set_tooltip("res://Assets/UI/tooltips/Fairness Mini Game_1.png")

func set_ui_color_mode(color : String):
	dialogue.text_color = "#311E1C" if color == "light" else "#FFFFFF"
	monologue.text_color = "#311E1C" if color == "light" else "#FFFFFF"
	dialogue.get_node("PlayerContainer/PositionControl/ScaleControl/IconCenter/TextureRect").texture = load("res://Assets/UI/V2Dialogue Box_Short_Light.png") if color == "light" else load("res://Assets/UI/V2Dialogue Box_Short_Dark.png") 
	dialogue.get_node("CharacterContainer/PositionControl/ScaleControl/IconCenter/TextBanner").texture = load("res://Assets/UI/V2Dialogue Box_Short_Light.png") if color == "light" else load("res://Assets/UI/V2Dialogue Box_Short_Dark.png") 
	monologue.get_node("TextContainer/PositionControl/ScaleControl/IconCenter/TextBanner").texture = load("res://Assets/UI/V2Dialogue Box_Long_Light.png") if color == "light" else load("res://Assets/UI/V2Dialogue Box_Long_Dark.png") 
	dialogue.get_node("PlayerContainer/PositionControl/ScaleControl/IconCenter/TextureRect/ArrowContainer/Arrow").texture = load("res://Assets/UI/Dialogue Arrow_Active_Light.png") if color == "light" else load("res://Assets/UI/Dialogue Arrow_Active_Dark.png")
	dialogue.get_node("CharacterContainer/PositionControl/ScaleControl/IconCenter/TextBanner/ArrowContainer/Arrow").texture = load("res://Assets/UI/Dialogue Arrow_Active_Light.png") if color == "light" else load("res://Assets/UI/Dialogue Arrow_Active_Dark.png")
	monologue.get_node("TextContainer/PositionControl/ScaleControl/IconCenter/TextBanner/ArrowContainer/Arrow").texture = load("res://Assets/UI/Dialogue Arrow_Active_Light.png") if color == "light" else load("res://Assets/UI/Dialogue Arrow_Active_Dark.png")

func _process(delta):
	if Global.show_interaction_help:
		interaction_prompt_label.visible = true
	else: 
		interaction_prompt_label.visible = false
		
		
	if (Input.is_action_just_released("menu")):
		pause_menu_active = !pause_menu_active
		if (pause_menu_active): 
			pause_menu_active = true
			pause_menu.visible = true
			screen_blur_node.visible = true
			pause_game()
		else: resume_button_pressed()
	
	# screen_blur.set_shader_parameter("lod", .75 if pause_menu_active else 0.)
	# screen_blur.set_shader_parameter("dim", .3 if pause_menu_active else 0.)
	
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
			screen_hide.z_index = 0 # reset screen_hide to its original priority for scene transitions
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
		screen_hide.z_index = -1 # allow other UI menus to overlap this fade screen
		
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
		# UI NODE + TREE PROCESS CLEANUP
		get_tree().change_scene_to_file(next_scene)
		pause_menu_active = false
		tooltip_active = false
		get_tree().paused = false
		pause_menu.visible = false
		screen_blur_node.visible = false
		screen_hide.visible = false
		dialogue.visible = false
		monologue.visible = false
		tooltip_image.visible = false
		tooltip_blur.visible = false
		player_name_input.visible = false
		
		dialogue.close_dialogue()
		monologue.close_3choice_dialogue()

func set_active_cm(active_cutscene_manager):
	self.active_cutscene_manager = active_cutscene_manager

func resume_button_pressed():
	pause_menu_active = false
	pause_menu.visible = false
	screen_blur_node.visible = false
	
	resume_game(true)

func exit_game_button_pressed():
	start_scene_change(true, true, "res://Scenes/scene_selection_redux.tscn")

func tooltip_button_pressed():
	tooltip_active = !tooltip_active
	if tooltip_active:
		tooltip_button.texture_normal = TOOLTIP_BUTTON_VISITED_PATH
		tooltip_button.modulate = Color(0.988,0.612,0.078, 1.)
		tooltip_image.visible = true
		tooltip_blur.visible = true
		pause_game()
	else:
		tooltip_button.texture_normal = TOOLTIP_BUTTON_NORMAL_PATH
		tooltip_button.modulate = Color(1.,1.,1., 1.)
		tooltip_image.visible = false
		tooltip_blur.visible = false
		resume_game(false)

func set_tooltip(image_path):
	if image_path == "":
		tooltip_button_panel.visible = false
		tooltip_instructions_panel.visible = false
	else:
		tooltip_button_panel.visible = true
		tooltip_instructions_panel.visible = true
		tooltip_image.texture = load(image_path)

func pause_game():
	get_tree().paused = true
	var player_group = get_tree().get_nodes_in_group("Player")
	if player_group: player_group[0].reset_player()

func resume_game(caller_is_pause_menu):
	if caller_is_pause_menu:
		if !tooltip_active: get_tree().paused = false
	else:
		if !pause_menu_active: get_tree().paused = false
