extends Node2D

@onready var crystal = $Crystal
@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var fox = get_tree().get_nodes_in_group("Fox")[0]
@onready var malvoren = $principal_villain

var cm : CutsceneManager # cutscene manager for this 

func _ready():
	intro_cutscene()
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func intro_cutscene():
	UI.start_scene_change(false, false, "")
	
	player.autonomous = true
	
	var actionA = Action.new(player, "LerpMove", Vector2(800, 1152), 200)
	var actionB = Action.new(fox, "LerpMove", Vector2(672, 1152), 200)
	# var crystal_rises = UniqueAction.new(crystal, Callable(crystal, "levitate"))
	var actions : Array[Action] = [actionA, actionB]
	for action in actions:
		add_child(action)
	
	cm = CutsceneManager.new(actions)
	add_child(cm)
	
	cm.parallel_action()
	await cm.actions_complete
	var actionC = Action.new(player, "LerpMove", Vector2(784, 1152), 200)
	actions = [actionC]
	for action in actions:
		add_child(action)
	cm.set_actions(actions)
	cm.series_action()
	await cm.actions_complete
	
	cm.call_dialogue("res://Resources/Texts/Dialogues/1_Fairness/FairnessEnv/FairnessCrystal2.json")
	await cm.lines_complete
	
	var actionD = Action.new(fox, "LerpMove", Vector2(736, 1152), 200)
	var actionE = Action.new(player, "LerpMove", Vector2(864, 1152), 200)
	actions = [actionD, actionE]
	for action in actions:
		add_child(action)
	cm.set_actions(actions)
	cm.parallel_action()
	await cm.actions_complete
	
	var actionF = Action.new(fox, "LerpMove", Vector2(736, 507), 200)
	var actionG = Action.new(player, "LerpMove", Vector2(864, 507), 200)
	actions = [actionF, actionG]
	for action in actions:
		add_child(action)
	cm.set_actions(actions)
	cm.parallel_action()
	await cm.actions_complete
	
	var player_cam = player.get_node("Camera2D")
	var actionCam = Action.new(player_cam, "LerpMove", Vector2(-64, -64), 200)
	actions = [actionCam]
	for action in actions:
		add_child(action)
	cm.set_actions(actions)
	cm.series_action()
	await cm.actions_complete
	
	var crystal_rises = UniqueAction.new(crystal, Callable(crystal, "levitate"))
	actions = [crystal_rises]
	for action in actions:
		add_child(action)
	cm.set_actions(actions)
	cm.series_action()
	await cm.actions_complete
	
	cm.call_dialogue("res://Resources/Texts/Dialogues/1_Fairness/FairnessEnv/FairnessCrystal2.json")
	await cm.lines_complete
	
	malvoren.visible = true
	var actionH = Action.new(malvoren, "LerpMove", Vector2(960, 476), 200)
	actions = [actionH]
	for action in actions:
		add_child(action)
	cm.set_actions(actions)
	cm.series_action()
	await cm.actions_complete
	
	player_cam.enabled = false
	
	var actionI = Action.new(fox, "LerpMove", Vector2(604, 540), 200)
	var actionJ = Action.new(player, "LerpMove", Vector2(636, 508), 200)
	actions = [actionI, actionJ]
	for action in actions:
		add_child(action)
	cm.set_actions(actions)
	cm.parallel_action()
	await cm.actions_complete
	
	var actionK = Action.new(fox, "LerpMove", Vector2(608, 540), 200)
	var actionL = Action.new(player, "LerpMove", Vector2(640, 508), 200)
	actions = [actionK, actionL]
	for action in actions:
		add_child(action)
	cm.set_actions(actions)
	cm.parallel_action()
	await cm.actions_complete
