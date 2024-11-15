extends Node2D

var drop_spots
@onready var preview = get_node("Control/OrbPlacement/VBoxContainer/HBoxContainer/MarginContainer2/TextureRect") as TextureRect
@onready var goal = get_node("Control/OrbPlacement/VBoxContainer/HBoxContainer/MarginContainer/TextureRect") as TextureRect
var orb_slot	# array of the orbs occupying dropspots

@onready var cauldron_area = get_node("Cauldron/CauldronArea") as Area2D
@onready var cauldron_triggerable : bool = false 	# bool to allow process to consider setting cauldron animations

@onready var stage : int = 0		# stage that player is at out of 3
var goal_name : String				# current stage's pair of orb goal name
# stage 0 automatically moves to 1 afterwards

@onready var orb_pos1 : Vector2 = Vector2(636, 72)	# starting position of first orb when dropped
@onready var orb_pos2 : Vector2 = Vector2(731, 72)	# ^ but 2

@onready var orb_container = get_node("Control/MarginContainer") as Control # container for orbs, do move this
@onready var orb_holder = get_node("Control/MarginContainer/HBoxContainer") as Control	# placement for orbs, DONT MOVE THIS
@onready var spot_holder = get_node("Control/OrbPlacement") as Control	# placement for spots
@onready var mix_button = get_node("Control/Button") as Control
@onready var bg_blur_mat = get_node("Control/Blur").material as Material
@onready var orb_container_target_pos = orb_container.position
@onready var spot_container_target_pos = spot_holder.position
@onready var mix_button_target_pos = mix_button.position
@onready var bg_blur_prop = 1.0
@onready var blur_target_alpha = 1.0
@onready var mixing_ui_change_speed = 5.0
var reopening

func _ready():
	UI.start_scene_change(false, false, "")
	UI.get_node("Monologue").open_3choice_dialogue("res://Scripts/Monologues/Mixing/MixingIntro.json", null)
	drop_spots = get_tree().get_nodes_in_group('DropSpotGroup')
	next_stage(true, true)

func next_stage(success : bool, readying : bool):
	var cauldron_player = get_node("Cauldron/AnimationPlayer")
	stage = stage + 1 if success else stage
	match(stage):
		1:
			goal.texture = load("res://assets/Mixing_Game/smoke assets/redviolet.png")
			goal_name = "redviolet"
			print("goal is " + goal_name)
		2:
			goal.texture = load("res://assets/Mixing_Game/smoke assets/greenyellow.png")
			goal_name = "greenyellow"
			var orbs = get_tree().get_nodes_in_group("MixingOrbs")
			for orb in orbs:
				if (orb.name == 'red') or (orb.name == 'violet'):
					orb.queue_free()
			UI.get_node("Monologue").open_3choice_dialogue("res://Scripts/Monologues/goodmix1.json", null)
		3:
			goal.texture = load("res://assets/Mixing_Game/smoke assets/tealblue.png")
			goal_name = "tealblue"
			var orbs = get_tree().get_nodes_in_group("MixingOrbs")
			for orb in orbs:
				if (orb.name == 'green') or (orb.name == 'yellow'):
					orb.queue_free()
			UI.get_node("Monologue").open_3choice_dialogue("res://Scripts/Monologues/goodmix2.json", null)
		4:
			goal.texture = load("res://assets/Mixing_Game/smoke assets/blank.tres")
			var orbs = get_tree().get_nodes_in_group("MixingOrbs")
			for orb in orbs:
				if (orb.name == 'teal') or (orb.name == 'blue'):
					orb.queue_free()
			UI.get_node("Monologue").open_3choice_dialogue("res://Scripts/Monologues/goodmix3.json", null)
	if not readying:
		await UI.get_node("Monologue").closed_signal
		set_mixing_ui_visibility(true)
		cauldron_player.current_animation = "none"

func _process(delta):
	# ui lerps position when mixing scene opens and closes:
	orb_container.position = orb_container.position.lerp(orb_container_target_pos, delta * mixing_ui_change_speed)
	spot_holder.position = spot_holder.position.lerp(spot_container_target_pos, delta * mixing_ui_change_speed)
	mix_button.position = mix_button.position.lerp(mix_button_target_pos, delta * mixing_ui_change_speed)
	var orbs = get_tree().get_nodes_in_group("MixingOrbs")
	for orb in orbs:
		orb.modulate.a = lerpf(orb.modulate.a, 1.0, delta * mixing_ui_change_speed)
	bg_blur_prop = lerpf(bg_blur_prop, blur_target_alpha, delta * mixing_ui_change_speed)
	bg_blur_mat.set_shader_parameter("lod", 1.5 * bg_blur_prop)
	bg_blur_mat.set_shader_parameter("dim", 0.15 * bg_blur_prop)
	
	print(bg_blur_mat.get_shader_parameter("LOD"))
	print(bg_blur_mat.get_shader_parameter("Dim"))
	
	if ((orb_container.position.x > orb_container_target_pos.x - 25.0) and reopening):
		var spots = get_tree().get_nodes_in_group("DropSpots")
		for orb in orbs:
			orb.visible = true
			orb.modulate.a = 0.0
			orb.reparent(get_node("Control"))
		for spot in spots:
			spot.reparent(get_node("Control"))
		reopening = false
	
	# check for drop spot's areas colliding with dragged UI orbs
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
	
	# check for cauldron's area colliding with spawned RIGIDBODY orbs and play respective animation
	#if (cauldron_triggerable):
	#	cauldron_triggerable = false
	#	print("work")
	#	run_this()

func run_this():
	# await get_tree().create_timer(1.0).timeout
	var possible_name1 = orb_slot[0] + orb_slot[1]
	var possible_name2 = orb_slot[1] + orb_slot[0]
	cauldron_triggerable = false
	if (possible_name1 == goal_name) or (possible_name2 == goal_name):
		set_cauldron_animation("goal_name")
	else:
		set_cauldron_animation("bad")

func set_cauldron_animation(anim_name):
	var cauldron_player = get_node("Cauldron/AnimationPlayer")
	match (anim_name):
		"goal_name":
			match (stage):
				1:
					cauldron_player.current_animation = "MagentaOrb" # TEMP
				2:
					cauldron_player.current_animation = "GreenOrb"	# TEMPORARY ANIMATION
				3:
					cauldron_player.current_animation = "BlueOrb"	# TEMP
			await get_tree().create_timer(2.0).timeout
			next_stage(true, false)
		"bad":
			cauldron_player.current_animation = "none"	# TEMP
			await get_tree().create_timer(2.0).timeout
			UI.get_node("Monologue").open_3choice_dialogue("res://Scripts/Monologues/badmix.json", null)
			next_stage(false, false)

func mix():
	# when user presses mix button
	if (orb_slot.size() == 2):
		run_this()
		set_mixing_ui_visibility(false)
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
		
		_play_animation_at_position(orb_pos1, "bagpoof_come")
		get_node("LeftOrb").position = orb_pos1
		await get_tree().create_timer(0.25).timeout
		_play_animation_at_position(orb_pos2, "bagpoof_come")
		get_node("RightOrb").position = orb_pos2

func set_mixing_ui_visibility(visibility):
	var orbs = get_tree().get_nodes_in_group("MixingOrbs")
	var spots = get_tree().get_nodes_in_group("DropSpots")
	
	if (!visibility):
		for orb in orbs:
			orb.reparent(orb_holder)
			orb.visible = false
		for spot in spots:
			spot.reparent(spot_holder)
		print("OFF")
		orb_container_target_pos.x -= 750
		spot_container_target_pos.x += 750
		mix_button_target_pos.x += 750
		blur_target_alpha = 0.0;
	else:
		print("ON")
		orb_container_target_pos.x += 750
		spot_container_target_pos.x -= 750
		mix_button_target_pos.x -= 750
		blur_target_alpha = 1.0;
		reopening = true

func _play_animation_at_position(position: Vector2, animation_name: String):
	var bag_poof_animation = load("res://Scene Folder/Minigames/Cannonball_Game/BagPoof/bag_poof.tscn")
	
	var bag_poof = bag_poof_animation.instantiate()
	bag_poof.position = position
	add_child(bag_poof)
	
	bag_poof.get_node("AnimationPlayer").play(animation_name)  # Replace with your animation name
