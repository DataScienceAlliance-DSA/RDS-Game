extends Node2D

@onready var scene_container = $CanvasLayer/GridContainer
@onready var target_scene_container_pos = Vector2(100, 64)
var target_button
@onready var target_button_just_clicked = false

@onready var game_title = $CanvasLayer/MarginContainer2/VBoxContainer/Panel/RichTextLabel
@onready var title_margin_container = $CanvasLayer/MarginContainer
@onready var desc_margin_container = $CanvasLayer/MarginContainer2
@onready var target_title_container_margin = Vector2(450,450)
@onready var target_desc_container_margin = Vector2(-650,1366)
@onready var current_title_container_margin = Vector2(450,450)
@onready var current_desc_container_margin = Vector2(-650,1366)

func _ready():
	UI.start_scene_change(false, false, "")
	
	for button in scene_container.get_children():
		button.pressed.connect(register_button_press.bind(button))

func _process(delta):
	## SCENE CONTAINER VISUAL ANIMATION
	if !target_button_just_clicked:
		if Input.is_action_just_released("scroll_down"):
			target_scene_container_pos.x -= 128.
			target_button = null
			target_title_container_margin = Vector2(450,450)
			target_desc_container_margin = Vector2(-650,1366)
		elif Input.is_action_just_released("scroll_up"):
			target_scene_container_pos.x += 128.
			target_button = null
			target_title_container_margin = Vector2(450,450)
			target_desc_container_margin = Vector2(-650,1366)
	else:
		target_scene_container_pos.x = 100. - target_button.position.x
		target_button_just_clicked = false
	target_scene_container_pos.x = max(min(100., target_scene_container_pos.x), -5472.)
	
	scene_container.position = scene_container.position.lerp(target_scene_container_pos, 5. * delta)
	current_title_container_margin = current_title_container_margin.lerp(target_title_container_margin, 5. * delta)
	current_desc_container_margin = current_desc_container_margin.lerp(target_desc_container_margin, 5. * delta)
	
	title_margin_container.add_theme_constant_override("margin_left", current_title_container_margin.x)
	title_margin_container.add_theme_constant_override("margin_right", current_title_container_margin.y)
	desc_margin_container.add_theme_constant_override("margin_left", current_desc_container_margin.x)
	desc_margin_container.add_theme_constant_override("margin_right", current_desc_container_margin.y)

func register_button_press(button):
	target_button = button
	target_button_just_clicked = true
	
	target_title_container_margin = Vector2(800,100)
	target_desc_container_margin = Vector2(100,616)
	
	game_title.text = "[color=EAEDFA][center]\n[b]"+str(button.editor_description)+"[/b]"

func play_scene_button_pressed():
	if target_button:
		var index = target_button.name.substr(target_button.name.length() - 2, 2) as int
		match index:
			1:
				UI.start_scene_change(true, true, "res://Scenes/0_Tutorial/Tutorial_VeracityEnv/Intro_Room.tscn")
			2:
				UI.start_scene_change(true, true, "res://Scenes/0_Tutorial/TutorialMinigame1/Cannonball_Game.tscn")
			3:
				UI.start_scene_change(true, true, "res://Scenes/0_Tutorial/TutorialMinigame2/GameManager/Mixing_Game.tscn")
			4:
				UI.start_scene_change(true, true, "res://Scenes/1_Fairness/FairnessEnv/fairness_village.tscn")
			5:
				UI.start_scene_change(true, true, "res://Scenes/1_Fairness/FairnessMinigame1/GameManager/fairness_minigame_1.tscn")
			6:
				UI.start_scene_change(true, true, "res://Scenes/1_Fairness/FairnessMinigame2/GameManager/fairness_minigame_2.tscn")
			7:
				print("TRANSPARENCY PILLAR IS WIP")
			8:
				UI.start_scene_change(true, true, "res://Scenes/2_Transparency/TransparencyMinigame1/Cargo_Game.tscn")
			9:
				UI.start_scene_change(true, true, "res://Scenes/2_Transparency/TransparencyMinigame2/transparency_game_2.tscn")
			10:
				print("PRIVACY PILLAR IS WIP")
			11:
				UI.start_scene_change(true, true, "res://Scenes/3_Privacy/PrivacyMinigame1/Information_Game/information_game.tscn")
			12:
				print("SECURITY GAME IS WIP")
			13:
				print("VERACITY PILLAR IS WIP")
			14:
				print("MAP GAME IS WIP")
			15:
				UI.start_scene_change(true, true, "res://Scenes/4_Veracity/VeracityMinigame2/VeracityMinigame2.tscn")
			16:
				print("FINALE IS WIP")
			17:
				UI.start_scene_change(true, true, "res://Scenes/5_Finale/FinaleMinigame1/FinaleMinigame1.tscn")
			18:
				print("MEMORY GAME IS WIP")
