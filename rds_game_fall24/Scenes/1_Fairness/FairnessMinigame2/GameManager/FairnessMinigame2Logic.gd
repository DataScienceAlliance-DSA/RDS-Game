# FAIRNESS_MINIGAME_2_LOGIC:
# handles stage difficulty progressio
# handles game timers and animations
# handles reading for correct player input
extends Node2D
# - deeg

# game has two stages, five problems for each stage, one minute per stage
# player has one of six weights to choose from always: {5, 10, 15, 20, 25, 30}
# STAGE 1:
# player can add weights only to the left plate to match the immovable weights on the right plate
# _ _ _ = 5 0 0
# _ _ _ = 5 10 0
# _ _ _ = 15 20 25
# _ _ _ = 50 0 0
# _ _ _ = 5 20 35
# STAGE 2:
# player can only add 2 weights to the left plate to match the immovable weights on the right plate
# _ _ 0 = 5 5 15
# _ _ 0 = 15 5 20
# _ _ 0 = 20 20 5
# _ _ 0 = 10 40 5
# _ _ 0 = 25 5 10
# IDEAS FOR THIRD STAGE? negative weights, immovable weights and player weights on both sides?

@onready var rock_weight = load("res://Scenes/1_Fairness/FairnessMinigame2/RockWeight.tscn")
@onready var bag_poof = load("res://Scenes/UniversalComponents/bag_poof.tscn")

@onready var timer = get_node("GameTimer")
@onready var timer_label = get_node("TimerLabel")

@onready var left_pan_spots = get_tree().get_nodes_in_group("LeftPan")[0].get_children()

@onready var problem_index = 0 # game problem that player is at (1-10)
var weight_spots
@onready var current_weights = []
var weight_goal

func _ready():
	UI.start_scene_change(false, false, "")
	
	# KICK OFF STAGE 1
	weight_spots = []
	var drop_spots_right = get_tree().get_nodes_in_group("RightPan")[0].get_children()
	for spot in get_tree().get_nodes_in_group("DropSpotGroup"):
		if "DropSpotRight" in spot.name:
			spot.remove_from_group("DropSpotGroup")
			weight_spots.append(spot)
	
	next_problem()

func _process(delta):
	# Get the remaining time
	var time_left = timer.time_left
	
	#Calculate minutes and seconds
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	
	#Format the time as MM:SS
	var time_text = "%02d:%02d" % [minutes, seconds]
	
	#Update the RichText Label
	timer_label.text = time_text

	var weight_score = 0. # dictates game's weight score, not for angular node changes like in Scale.gd
	
	for spot in left_pan_spots:
		for stuff in spot.get_children():
			if (stuff.get_child_count() != 0):
				weight_score += stuff.name.to_float()
	
	if (weight_score == weight_goal):
		weight_goal = -1. # prevention of double-trigger in-between frames
		next_problem()

func spawn_weight(value, spot):
	var new_weight = rock_weight.instantiate()
	var new_poof = bag_poof.instantiate()
	
	new_weight.start_from = spot.global_position - Vector2(0., 450.)
	new_weight.fall_to = spot.global_position
	new_weight.t = 0.
	
	spot.add_child(new_poof)
	spot.add_child(new_weight)
	new_weight.name = str(value)
	if (value == 30) or (value == 35) or (value == 50): 
		new_weight.get_node("TextEdit").text = "[center]" + str(value) + "[/center]"
		new_weight.texture = load("res://Assets/1_Fairness/FairnessMinigame2/weight_50.png")
	else:
		new_weight.get_node("TextEdit").text = ""
		new_weight.texture = load("res://Assets/1_Fairness/FairnessMinigame2/weight_" + str(value) + ".png")
	
	
	
	new_poof.scale = Vector2(0.025, 0.025)
	new_poof.get_node("AnimationPlayer").current_animation = "bagpoof_go"
	
	current_weights.append(new_weight)

func next_problem():
	print(current_weights)
	for i in range(current_weights.size()):
		var this_weight = current_weights.pop_back()
		this_weight.queue_free()
	print(current_weights)
	problem_index = problem_index + 1
	match(problem_index):
		1:
			spawn_weight(5., weight_spots[1])
			await get_tree().create_timer(0.2).timeout
			weight_goal = 5.
		2:
			spawn_weight(10., weight_spots[0])
			await get_tree().create_timer(0.2).timeout
			spawn_weight(5., weight_spots[2])
			await get_tree().create_timer(0.2).timeout
			weight_goal = 15.
		3:
			spawn_weight(15., weight_spots[0])
			await get_tree().create_timer(0.2).timeout
			spawn_weight(20., weight_spots[1])
			await get_tree().create_timer(0.2).timeout
			spawn_weight(25., weight_spots[2])
			await get_tree().create_timer(0.2).timeout
			weight_goal = 60.
		4:
			spawn_weight(50., weight_spots[0])
			await get_tree().create_timer(0.2).timeout
			weight_goal = 50.
		5:
			spawn_weight(5., weight_spots[0])
			await get_tree().create_timer(0.2).timeout
			spawn_weight(20., weight_spots[1])
			await get_tree().create_timer(0.2).timeout
			spawn_weight(35., weight_spots[2])
			await get_tree().create_timer(0.2).timeout
			weight_goal = 60.
		6:
			win_game()

func win_game():
	for weight in current_weights:
		current_weights.erase(weight)
		weight.queue_free()
	
	PS.village_state = 3
	UI.start_scene_change(true, true, "res://Scenes/1_Fairness/FairnessEnv/fairness_village.tscn")
	_on_game_timer_timeout()

func _on_game_timer_timeout():
	UI.get_node("Monologue").open_3choice_dialogue("res://Resources/Texts/Monologues/1_Fairness/FairnessMinigame2/FoxFairness1Failure.json", null)
	await UI.get_node("Monologue").closed_signal
	UI.start_scene_change(true, true, "res://Scenes/1_Fairness/FairnessMinigame1/GameManager/fairness_minigame_2.tscn")
	print("times up")
