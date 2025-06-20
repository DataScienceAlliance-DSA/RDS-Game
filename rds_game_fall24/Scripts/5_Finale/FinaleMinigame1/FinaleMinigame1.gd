extends Node2D

@onready var crystal = $Crystal
@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var fox = get_tree().get_nodes_in_group("Fox")[0]
@onready var malvoren = $principal_villain

@onready var malvoren_aura = $MalvorenAura
@onready var player_aura = $PlayerAura
@onready var malvoren_smoke = $MalvorenSmoke
@onready var mind_attack = $MindAttack
@onready var mind_attack2 = $MindAttack2
@onready var paraccuracy_cast = $ParaccuracyCast/GPUParticles2D

var cm : CutsceneManager # cutscene manager for this 

@onready var panel = $MinigamePanel/Control
@onready var game_stage = 0
@onready var retrying = false

@onready var game_camera = $GameCamera
@onready var cam_zoom_target = 1.
@onready var new_zoom = 1.

func _ready(): # FINALE CUTSCENE + MINIGAME 1: SPELL GAME
	UI.set_ui_color_mode("light")
	
	var actions : Array[Action] = []
	cm = CutsceneManager.new(actions)
	add_child(cm)

	UI.start_scene_change(false, false, "")
	
	player.autonomous = true
	player.in_cutscene = true
	
	if (true): ## INTRO CUTSCENE, SET TRUE TO FALSE TO SKIP FOR DEBUGGING MINIGAME
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
		
		cm.call_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/FoxReconvening.json")
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
		
		crystal.get_node("crystal").texture = load("res://Assets/1_Fairness/FairnessEnv/veracity_crystal_animation.png")
		var crystal_rises = UniqueAction.new(crystal, Callable(crystal, "levitate"))
		actions = [crystal_rises]
		for action in actions:
			add_child(action)
		cm.set_actions(actions)
		cm.series_action()
		await cm.actions_complete
		
		cm.call_monologue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/VeracityCrystal.json")
		await cm.lines_complete
		
		malvoren.visible = true
		
		crystal_rises = UniqueAction.new(crystal, Callable(crystal, "disappear"))
		var actionH = Action.new(malvoren, "LerpMove", Vector2(960, 476), 200)
		actions = [crystal_rises, actionH]
		for action in actions:
			add_child(action)
		cm.set_actions(actions)
		cm.parallel_action()
		await cm.actions_complete
		
		player_cam.enabled = false
		
		var actionI = Action.new(fox, "LerpMove", Vector2(604, 508), 200)
		var actionJ = Action.new(player, "LerpMove", Vector2(636, 476), 200)
		actions = [actionI, actionJ]
		for action in actions:
			add_child(action)
		cm.set_actions(actions)
		cm.parallel_action()
		await cm.actions_complete
		
		var actionK = Action.new(fox, "LerpMove", Vector2(608, 508), 200)
		var actionL = Action.new(player, "LerpMove", Vector2(640, 476), 200)
		actions = [actionK, actionL]
		for action in actions:
			add_child(action)
		cm.set_actions(actions)
		cm.parallel_action()
		await cm.actions_complete
		
		cm.call_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/MeetMalvorenAgain.json")
		await cm.lines_complete
		
		cm.call_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/FoxDiscoversMalvoren.json")
		await cm.lines_complete
		
		cm.call_monologue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/MalvorenReveal.json")
		await cm.lines_complete
	
	cam_zoom_target = 1.255
	
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

func _process(_delta):
	new_zoom = lerp(new_zoom, cam_zoom_target, _delta * 2)
	game_camera.zoom = Vector2(new_zoom, new_zoom)
	
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
			
			malvoren_smoke.visible = true
			
			malvoren_spell = UniqueAction.new(malvoren, Callable(malvoren, "dematerialize_spell"))
			actions = [malvoren_spell]
			for action in actions:
				add_child(action)
			cm.set_actions(actions)
			cm.series_action()
			await cm.actions_complete
			
			panel.open_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/FoxTransparency.json", null)
		2:
			malvoren_smoke.get_node("GPUParticles2D").emitting = false
			
			var malvoren_spell = UniqueAction.new(malvoren, Callable(malvoren, "rematerialize"))
			var actions : Array[Action] = [malvoren_spell]
			for action in actions:
				add_child(action)
			cm.set_actions(actions)
			cm.series_action()
			await cm.actions_complete
			
			cm.call_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/TransparenciaCast.json")
			await cm.lines_complete
			
			mind_attack.visible = true
			mind_attack2.visible = true
			
			panel.open_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/FoxPrivacy.json", null)
		3:
			for child in mind_attack.get_children():
				child.emitting = false
			for child in mind_attack2.get_children():
				child.emitting = false
			
			cm.call_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/LockcinnoCast.json")
			await cm.lines_complete
			
			var malvoren_spell = UniqueAction.new(malvoren, Callable(malvoren, "multiply"))
			var actions : Array[Action] = [malvoren_spell]
			for action in actions:
				add_child(action)
			cm.set_actions(actions)
			cm.series_action()
			await cm.actions_complete
			
			panel.open_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/FoxVeracity.json", null)
		4:
			paraccuracy_cast.emitting = true
			cm.wait(.5)
			await cm.wait_complete
			
			var malvoren_spell = UniqueAction.new(malvoren, Callable(malvoren, "demultiply"))
			var actions : Array[Action] = [malvoren_spell]
			for action in actions:
				add_child(action)
			cm.set_actions(actions)
			cm.series_action()
			await cm.actions_complete
			
			cm.call_dialogue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame1/ParaccuracyCast.json")
			await cm.lines_complete
			
			## PLACE GUARDIAN DATA CHARM SEQUENCE HERE, then initiate memory game:
			
			run_memory_game()

func run_memory_game():
	

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
