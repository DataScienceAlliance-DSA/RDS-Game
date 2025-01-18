extends Node2D

var cm : CutsceneManager # cutscene manager for this 

func _ready():
	# DISABLE PLAYER WHILE CUTSCENES ARE OCCURRING
	var player = get_node("Player")
	player.set_process(false)
	
	var monologue_ui = UI.get_node("Monologue")
	
	# Get Actors (Node2Ds)
	var actorA = get_node("student_npcs/student_npc1")
	var actorB = get_node("student_npcs/student_npc2")
	var actorC = get_node("student_npcs/student_npc3")
	var actorD = get_node("student_npcs/student_npc4")
	var actorE = get_node("student_npcs/student_npc5")
	
	# ActionGroup A - Setup (students walk to principal)
	var actionA = Action.new(actorA, "LerpMove", actorA.position - Vector2(3150,0), 200)
	var actionB = Action.new(actorB, "LerpMove", actorB.position - Vector2(3150,0), 200)
	var actionC = Action.new(actorC, "LerpMove", actorC.position - Vector2(3150,0), 200)
	var actionD = Action.new(actorD, "LerpMove", actorD.position - Vector2(3150,0), 200)
	var actionE = Action.new(actorE, "LerpMove", actorE.position - Vector2(3150,0), 200)
	var actionP = Action.new(player, "LerpMove", player.position - Vector2(3150,0), 200)
	
	var actions : Array[Action] = [actionA, actionB, actionC, actionD, actionE, actionP]
	for action in actions:
		add_child(action)
	
	
	# ActionGroup A - Parallel Call
	cm = CutsceneManager.new(actions)
	cm.parallel_action()
	
	await get_tree().create_timer(1.0).timeout
	monologue_ui.open_3choice_dialogue("res://Scripts/Monologues/Intro/PlayerMonologue.json", null)
	
	await cm.cutscene_complete
	
	
	monologue_ui.open_3choice_dialogue("res://Scripts/Monologues/Intro/MalvorenSpeech.json", null)
	
	# RE ENABLE THE PLAYER
	player.set_process(true)

func _process(delta):
	pass
