extends Node2D

var drop_spots
@onready var preview = get_node("Control/OrbPlacement/VBoxContainer/HBoxContainer/MarginContainer2/TextureRect") as TextureRect
@onready var goal = get_node("Control/OrbPlacement/VBoxContainer/HBoxContainer/MarginContainer/TextureRect") as TextureRect
var orb_slot	# array of the orbs occupying dropspots

@onready var stage : int = 0		# stage that player is at out of 3
# stage 0 automatically moves to 1 afterwards

func _ready():
	UI.start_scene_change(false, false, "")
	UI.get_node("Monologue").open_3choice_dialogue("res://Scripts/Monologues/Mixing/MixingIntro.json", null)
	drop_spots = get_tree().get_nodes_in_group('DropSpotGroup')
	next_stage()

func next_stage():
	stage = stage + 1
	match(stage):
		1:
			goal.texture = load("res://assets/Mixing_Game/smoke assets/redviolet.png")
		2:
			goal.texture = load("res://assets/Mixing_Game/smoke assets/greenyellow.png")
		3:
			goal.texture = load("res://assets/Mixing_Game/smoke assets/tealblue.png")

func _process(delta):
	orb_slot = []
	var drop_int = 0
	for drop_spot in drop_spots:
		if (drop_spot.get_overlapping_areas()):
			orb_slot.append(drop_spot.get_overlapping_areas()[0].get_parent().name)
		drop_int = drop_int + 1
	if (orb_slot.size() == 2):
		var possible_name1 = orb_slot[0] + orb_slot[1]
		var possible_name2 = orb_slot[1] + orb_slot[0]
		var possible_texture1
		var possible_texture2
		if (ResourceLoader.exists("res://assets/Mixing_Game/smoke assets/"+possible_name1+".png")):
			preview.texture = load("res://assets/Mixing_Game/smoke assets/"+possible_name1+".png")
		elif (ResourceLoader.exists("res://assets/Mixing_Game/smoke assets/"+possible_name2+".png")):
			preview.texture = load("res://assets/Mixing_Game/smoke assets/"+possible_name2+".png")
		else:
			preview.texture = load("res://assets/Mixing_Game/smoke assets/blank.tres")
	else:
		preview.texture = load("res://assets/Mixing_Game/smoke assets/blank.tres")

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
