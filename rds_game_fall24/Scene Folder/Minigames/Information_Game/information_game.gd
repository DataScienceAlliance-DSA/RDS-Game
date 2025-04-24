extends Node2D

var cm : CutsceneManager

@onready var panel = $InformationPanel

func _ready():
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

func _process(delta):
	panel.stage_condition_check()
