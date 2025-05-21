extends Node2D

@onready var crystal = $Crystal
@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var fox = get_tree().get_nodes_in_group("Fox")[0]
@onready var malvoren = $principal_villain

@onready var malvoren_aura = $MalvorenAura
@onready var player_aura = $PlayerAura

var cm : CutsceneManager # cutscene manager for this 

@onready var panel = $MinigamePanel/Control
@onready var game_stage = 0
@onready var retrying = false

func _ready():
	var actions : Array[Action] = []
	cm = CutsceneManager.new(actions)
	add_child(cm)

	UI.start_scene_change(false, false, "")
	
	player.autonomous = true
	player.in_cutscene = true
	
	if (false): ## INTRO CUTSCENE, SET TRUE TO FALSE TO SKIP FOR DEBUGGING MINIGAME
		var actionA = Action.new(player, "LerpMove", Vector2(800, 1152), 200)
		var actionB = Action.new(fox, "LerpMove", Vector2(672, 1152), 200)
		# var crystal_rises = UniqueAction.new(crystal, Callable(crystal, "levitate"))
		actions = [actionA, actionB]
		for action in actions:
			add_child(action)
		cm.set_actions(actions)
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
	
	# MALVOREN CASTS HER AURA...
	var malvoren_spell = UniqueAction.new(malvoren_aura, Callable(malvoren_aura, "aura_spell"))
	actions = [malvoren_spell]
	for action in actions:
		add_child(action)
	cm.set_actions(actions)
	cm.series_action()
	await cm.actions_complete
	
	# she prides herself on her strength
	cm.call_monologue("res://Resources/Texts/Monologues/5_Finale/FinaleMinigame1/Malvoren01.json")
	await cm.lines_complete
	
	# player begins spell selection game
	panel.open_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/FoxFairness1.json", null)
	
	var spell_container = panel.get_node("MarginContainer/VBoxContainer/HBoxContainer/Panel2/VBoxContainer/Spells/GridContainer") as Node
	for spell in spell_container.get_children():
		var button = spell.get_node("TextureRect").get_children()[0]
		button.pressed.connect(register_button_press.bind(button))
	
	return

func _process(_delta):
	for button in panel.buttons:
		if !panel.current_dialogue_ended: 
			button.disabled = true
			button.mouse_default_cursor_shape = Input.CURSOR_ARROW
		else: 
			button.disabled = false
			button.mouse_default_cursor_shape = Input.CURSOR_POINTING_HAND

func perform_spell_cutscene():
	game_stage = game_stage + 1
	panel.close_dialogue()
	match(game_stage):
		1:	# casting fairnomos
			
			# PLAYER CASTS THEIR AURA...
			var player_spell = UniqueAction.new(player_aura, Callable(player_aura, "aura_spell"))
			var actions : Array[Action] = [player_spell]
			for action in actions:
				add_child(action)
			cm.set_actions(actions)
			cm.series_action()
			await cm.actions_complete
			
			cm.call_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/FairnomosCast.json")
			await cm.lines_complete
			
			# both auras die out, due to equality
			player_spell = UniqueAction.new(player_aura, Callable(player_aura, "aura_spell_cancel"))
			var malvoren_spell = UniqueAction.new(malvoren_aura, Callable(malvoren_aura, "aura_spell_cancel"))
			actions = [player_spell, malvoren_spell]
			for action in actions:
				add_child(action)
			cm.set_actions(actions)
			cm.parallel_action()
			await cm.actions_complete
			
			panel.open_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/FoxTransparency.json", null)
		2:
			cm.call_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/TransparenciaCast.json")
			await cm.lines_complete
			panel.open_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/FoxPrivacy.json", null)
		3:
			cm.call_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/LockcinnoCast.json")
			await cm.lines_complete
			panel.open_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/FoxVeracity.json", null)
		4:
			cm.call_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/ParaccuracyCast.json")
			await cm.lines_complete

func continue_retry():
	panel.current_dialogue_ended = false
	cm.call_monologue("res://Resources/Texts/Monologues/5_Finale/FinaleMinigame1/FoxRetry.json")
	await cm.lines_complete
	panel.current_dialogue_ended = true

func register_button_press(button):
	if !panel.current_dialogue_ended: return
	
	if !retrying:
		match(game_stage):
			0:	## fairness
				if button.name == "fairness":
					perform_spell_cutscene()
				else:
					call_retry(0)
			1:	## transparency
				if button.name == "transparency":
					perform_spell_cutscene()
				else:
					call_retry(1)
			2:	## privacy
				if button.name == "privacy":
					perform_spell_cutscene()
				else:
					call_retry(2)
			3:	## veracity
				if button.name == "veracity":
					perform_spell_cutscene()
				else:
					call_retry(3)
	else:
		match(game_stage):
			0:	## fairness
				if button.name == "fairness":
					close_retry()
					perform_spell_cutscene()
				else:
					continue_retry()
			1:	## transparency
				if button.name == "transparency":
					close_retry()
					perform_spell_cutscene()
				else:
					continue_retry()
			2:	## privacy
				if button.name == "privacy":
					close_retry()
					perform_spell_cutscene()
				else:
					continue_retry()
			3:	## veracity
				if button.name == "veracity":
					close_retry()
					perform_spell_cutscene()
				else:
					continue_retry()

func call_retry(stage):
	retrying = true
	panel.open_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/FoxIncorrect.json", null)
	match(stage):
		0:
			panel.load_image("res://Assets/5_Finale/fairness_scene.png")
		1:
			panel.load_image("res://Assets/5_Finale/transparency_scene.png")
		2:
			panel.load_image("res://Assets/5_Finale/privacy_scene.png")
		3:
			panel.load_image("res://Assets/5_Finale/veracity_scene.png")

func close_retry():
	retrying = false
	panel.load_image("")
