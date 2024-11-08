extends Node2D

var drop_spots
@onready var preview = get_node("Control/OrbPlacement/VBoxContainer/HBoxContainer/MarginContainer2/TextureRect/RichTextLabel") as RichTextLabel
var orb_slot	# array of the orbs occupying dropspots

func _ready():
	UI.start_scene_change(false, false)
	UI.get_node("Monologue").open_3choice_dialogue("res://Scripts/Monologues/Mixing/MixingIntro.json", null)
	drop_spots = get_tree().get_nodes_in_group('DropSpotGroup')

func _process(delta):
	preview.text = ""
	orb_slot = []
	var drop_int = 0
	for drop_spot in drop_spots:
		if (drop_spot.get_overlapping_areas()):
			preview.text += drop_spot.get_overlapping_areas()[0].get_parent().name
			orb_slot.append(drop_spot.get_overlapping_areas()[0].get_parent().name)
		drop_int = drop_int + 1

func mix():
	if (orb_slot.size() == 2):
		get_node("Control").visible = false
		print("Now mixing... " + str(orb_slot[0]) + " and " + str(orb_slot[1]))
		
		match(orb_slot[1]):
			"violet":
				get_node("LeftOrb/Sprite2D").texture = load("res://assets/Cauldron_Room/Orbs Assets/orb 1.PNG")
			"red":
				get_node("LeftOrb/Sprite2D").texture = load("res://assets/Cauldron_Room/Orbs Assets/orb 2.PNG")
			"teal":
				get_node("LeftOrb/Sprite2D").texture = load("res://assets/Cauldron_Room/Orbs Assets/orb 3.PNG")
			"yellow":
				get_node("LeftOrb/Sprite2D").texture = load("res://assets/Cauldron_Room/Orbs Assets/orb 4.PNG")
			"blue":
				get_node("LeftOrb/Sprite2D").texture = load("res://assets/Cauldron_Room/Orbs Assets/orb 5.PNG")
			"green":
				get_node("LeftOrb/Sprite2D").texture = load("res://assets/Cauldron_Room/Orbs Assets/orb 6.PNG")
		
		match(orb_slot[0]):
			"violet":
				get_node("RightOrb/Sprite2D").texture = load("res://assets/Cauldron_Room/Orbs Assets/orb 1.PNG")
			"red":
				get_node("RightOrb/Sprite2D").texture = load("res://assets/Cauldron_Room/Orbs Assets/orb 2.PNG")
			"teal":
				get_node("RightOrb/Sprite2D").texture = load("res://assets/Cauldron_Room/Orbs Assets/orb 3.PNG")
			"yellow":
				get_node("RightOrb/Sprite2D").texture = load("res://assets/Cauldron_Room/Orbs Assets/orb 4.PNG")
			"blue":
				get_node("RightOrb/Sprite2D").texture = load("res://assets/Cauldron_Room/Orbs Assets/orb 5.PNG")
			"green":
				get_node("RightOrb/Sprite2D").texture = load("res://assets/Cauldron_Room/Orbs Assets/orb 6.PNG")
