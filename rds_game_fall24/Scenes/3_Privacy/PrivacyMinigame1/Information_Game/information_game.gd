extends Node2D

var cm : CutsceneManager

@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var panel = $InformationPanel

@onready var sea_tile_map = load("res://Scenes/2_Transparency/TransparencyMinigame2/transparency_sea_tile_map.tscn")
@onready var siren_sea = $SirenTileMap

var sea_cutscene : bool
var current_sea
var new_sea
@onready var trigger_new_sea = true

@onready var stopping_cutscene : bool = false
@onready var stopping_cutscene_time : float = 0
var saved_current_sea_position : Vector2
var saved_new_sea_position : Vector2

signal stopping_sea_done

func _ready():
	UI.set_tooltip("")
	UI.start_scene_change(false, true, "")
	
	sea_cutscene = true
	player.autonomous = true
	current_sea = sea_tile_map.instantiate()
	add_child(current_sea)
	
	var actionA = Action.new(player, "LerpMove", Vector2(319, 512), 200)
	var actionB = Action.new(player, "LerpMove", Vector2(320, 512), 200)
	
	var actions : Array[Action] = [actionA, actionB]
	for action in actions:
		add_child(action)
	
	cm = CutsceneManager.new(actions)
	add_child(cm)
	
	cm.series_action()
	await cm.actions_complete
	
	cm.call_dialogue("res://Resources/Texts/Dialogues/3_Privacy/PrivacyMinigame1/SirenIntro1.json")
	await cm.lines_complete
	
	saved_current_sea_position = current_sea.position
	if new_sea: saved_new_sea_position = new_sea.position
	stopping_cutscene = true
	sea_cutscene = false

func _process(delta):
	if sea_cutscene:
		print(current_sea.position)
		current_sea.position.x = current_sea.position.x - delta * 150.
		if current_sea.position.x < -5632:
			if trigger_new_sea:
				new_sea = sea_tile_map.instantiate()
				add_child(new_sea)
				new_sea.position = Vector2(1536, 0)
				trigger_new_sea = false
			new_sea.position.x = new_sea.position.x - delta * 150.
			if current_sea.position.x < -7168:
				current_sea.queue_free()
				current_sea = new_sea
				trigger_new_sea = true
	elif stopping_cutscene:
		stopping_cutscene_time = stopping_cutscene_time + delta
		if stopping_cutscene_time >= 8: 
			stopping_cutscene = false
			initiate_rest_of_cutscene()
		
		var vec = Vector2(interp(0, -556, stopping_cutscene_time / 4., "linear"), 0) if (stopping_cutscene_time < 4) else Vector2(interp(-556, -640, (stopping_cutscene_time - 4) / 4., "easeOutExpo"), 0)
		siren_sea.position = vec + Vector2(-896, 1023)
		current_sea.position = saved_current_sea_position + vec
		if new_sea: new_sea.position = saved_new_sea_position + vec
	
	panel.stage_condition_check()

func initiate_rest_of_cutscene():
	
	cm.call_monologue("res://Resources/Texts/Monologues/3_Privacy/PrivacyMinigame1/SirenIntro2.json")
	await cm.lines_complete
	cm.call_dialogue("res://Resources/Texts/Dialogues/3_Privacy/PrivacyMinigame1/SirenIntro3.json")
	await cm.lines_complete
	cm.call_dialogue("res://Resources/Texts/Dialogues/3_Privacy/PrivacyMinigame1/SirenIntro4.json")
	await cm.lines_complete
	
	panel.open_ui()
	await panel.ui_opened
	
	cm.call_monologue("res://Resources/Texts/Monologues/3_Privacy/PrivacyMinigame1/PIIGameIntro.json")
	await cm.lines_complete
	
	UI.set_tooltip("res://Assets/UI/tooltips/Privacy Mini Game_1_Part 1.png")
	
	panel.next_stage()
	await panel.single_element_opened
	await panel.stage_condition_passed
	panel.close_page_element()
	await panel.single_element_closed
	
	panel.next_stage()
	await panel.single_element_opened
	await panel.stage_condition_passed
	panel.close_page_element()
	await panel.single_element_closed
	
	panel.next_stage()
	await panel.single_element_opened
	await panel.stage_condition_passed
	panel.close_page_element()
	await panel.single_element_closed
	
	cm.call_monologue("res://Resources/Texts/Monologues/3_Privacy/PrivacyMinigame1/EncryptionGameIntro.json")
	await cm.lines_complete
	
	panel.next_stage()
	await panel.single_element_opened
	await panel.stage_condition_passed
	panel.close_page_element()
	await panel.single_element_closed
	
	panel.next_stage()
	await panel.single_element_opened
	await panel.stage_condition_passed
	panel.close_page_element()
	await panel.single_element_closed
	
	panel.next_stage()
	await panel.single_element_opened
	await panel.stage_condition_passed
	panel.close_page_element()
	await panel.single_element_closed
	
	cm.call_monologue("res://Resources/Texts/Monologues/3_Privacy/PrivacyMinigame1/MemoryGameIntro.json")
	await cm.lines_complete
	
	panel.next_stage()
	await panel.single_element_opened
	await panel.stage_condition_passed
	panel.close_page_element()
	await panel.single_element_closed
	
	panel.next_stage()
	await panel.single_element_opened
	await panel.stage_condition_passed
	panel.close_page_element()
	await panel.single_element_closed
	
	panel.next_stage()
	await panel.single_element_opened
	await panel.stage_condition_passed
	panel.close_page_element()
	await panel.single_element_closed
	
	panel.close_ui()
	await panel.ui_closed
	
	cm.call_monologue("res://Resources/Texts/Monologues/3_Privacy/PrivacyMinigame1/SirenCompleted.json")
	await cm.lines_complete
	
	cm.call_monologue("res://Resources/Texts/Monologues/3_Privacy/PrivacyMinigame1/FoxPostInformationGame.json")
	await cm.lines_complete
	
	UI.start_scene_change(true, false, "")

func interp(start, finish, delta, easing):
	match(easing):
		"linear":
			return start + (finish - start) * (delta)
		"easeOutExpo":
			return start + (finish - start) * (1. - pow(2., -10. * delta))
		"easeInExpo":
			return start + (finish - start) * (pow(2., 10. * delta - 10.))
