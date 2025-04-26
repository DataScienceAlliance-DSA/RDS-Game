extends Node2D

var cm : CutsceneManager

@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var panel = $InformationPanel

@onready var sea_tile_map = load("res://Scene Folder/Environment/transparency_sea_tile_map.tscn")

func _ready():
	UI.start_scene_change(false, true, "")
	
	player.autonomous = true
	
	var actionA = Action.new(player, "LerpMove", Vector2(319, 512), 200)
	var actionB = Action.new(player, "LerpMove", Vector2(320, 512), 200)
	
	var actions : Array[Action] = [actionA, actionB]
	for action in actions:
		add_child(action)
	
	cm = CutsceneManager.new(actions)
	add_child(cm)
	
	cm.series_action()
	await cm.actions_complete
	
	cm.call_dialogue("res://Scripts/Dialogues/Information/SirenIntro1.json")
	await cm.lines_complete
	cm.call_monologue("res://Scripts/Monologues/Information/SirenIntro2.json")
	await cm.lines_complete
	cm.call_dialogue("res://Scripts/Dialogues/Information/SirenIntro3.json")
	await cm.lines_complete
	cm.call_dialogue("res://Scripts/Dialogues/Information/SirenIntro4.json")
	await cm.lines_complete
	
	panel.open_ui()
	await panel.ui_opened
	
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

func _process(delta):
	panel.stage_condition_check()
