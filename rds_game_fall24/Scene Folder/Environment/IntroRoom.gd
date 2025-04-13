extends Node2D

var cm : CutsceneManager # cutscene manager for this 

@onready var monologue_ui = UI.get_node("Monologue")
@onready var fox = get_tree().get_nodes_in_group("Fox")[0]

func _ready():
	var player = get_tree().get_nodes_in_group("Player")[0]
	player.get_node("Camera2D").limit_right = 3776.
	
	# Get Actors (Node2Ds)
	var actorA = get_node("characters/student_npc1")
	var actorB = get_node("characters/student_npc2")
	var actorC = get_node("characters/student_npc3")
	var actorD = get_node("characters/student_npc4")
	var actorE = get_node("characters/student_npc5")
	var malvoren = get_node("characters/principal_villain")
	var thornewood = get_node("characters/ProfessorThornewood")
	
	match (PS.library_state):
		0:
			# DISABLE PLAYER WHILE CUTSCENES ARE OCCURRING
			player.autonomous = true
			
			get_node("LibraryToCourtyardExit/CollisionShape2D").disabled = true
			
			fox.following_player = false
			fox.visible = false
			fox.get_node("FoxCollider").disabled = true
			
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
			add_child(cm)
			
			# OPEN SCENE
			UI.start_scene_change(false, true, "")
			
			cm.parallel_action()
			
			cm.wait(1.0)
			cm.call_monologue("res://Scripts/Monologues/Intro/PlayerMonologue.json")
			
			await cm.actions_complete
			
			cm.call_monologue("res://Scripts/Monologues/Intro/ThornewoodSpeech.json")
			
			await cm.lines_complete
			
			var action_malvoren_entrance = Action.new(malvoren, "LerpMove", malvoren.position + Vector2(500,0,),200)
			actions = [action_malvoren_entrance]
			for action in actions:
				add_child(action)
			
			cm.set_actions(actions)
			cm.series_action()
			
			cm.wait(1.000)
			
			await cm.wait_complete
			
			cm.call_monologue("res://Scripts/Monologues/Intro/MalvorenEntrance.json")
			
			await cm.lines_complete
			
			
			# malvoren takes her leave by disappearing via a vanishing spell
			var malvoren_spell = UniqueAction.new(malvoren, Callable(malvoren, "disappear_spell"))
			actions = [malvoren_spell]
			for action in actions:
				add_child(action)
			
			cm.set_actions(actions)
			cm.series_action()
			
			await cm.actions_complete
			
			
			# the professor tells the students to follow along to be shown to their dormitories
			# at the same time, the camera pans to a glowing bookshelf, and the hero notices
			var player_cam = player.get_node("Camera2D")
			var actionCam = Action.new(player_cam, "LerpMove", Vector2(179, -245), 300)
			actionP = Action.new(player, "LerpMove", player.position + Vector2(0.1,0), 200)
			actions = [actionCam, actionP]
			for action in actions:
				add_child(action)
			
			cm.set_actions(actions)
			cm.series_action()
			
			await cm.actions_complete
			
			cm.call_monologue("res://Scripts/Monologues/Intro/PlayerNoticesGlow.json")
			await cm.lines_complete
			
			cm.call_monologue("res://Scripts/Monologues/Intro/ThornewoodLeadsStudents.json")
			await cm.lines_complete
			
			actionA = Action.new(actorA, "LerpMove", actorA.position - Vector2(1500,0), 200)
			actionB = Action.new(actorB, "LerpMove", actorB.position - Vector2(1500,0), 200)
			actionC = Action.new(actorC, "LerpMove", actorC.position - Vector2(1500,0), 200)
			actionD = Action.new(actorD, "LerpMove", actorD.position - Vector2(1500,0), 200)
			actionE = Action.new(actorE, "LerpMove", actorE.position - Vector2(1500,0), 200)
			var actionTW = Action.new(thornewood, "LerpMove", thornewood.position - Vector2(1500,0), 225)
			actions = [actionA, actionB, actionC, actionD, actionE, actionTW]
			for action in actions:
				add_child(action)
			
			cm.set_actions(actions)
			cm.parallel_action()
			
			cm.wait(1.0)
			await cm.wait_complete
			
			# the player walks vertically aligned to the bookshelf, faces it, then the camera readjusts and cutscene ends
			var actionPa = Action.new(player, "LerpMove", Vector2(1050, 608), 200)
			var actionPb = Action.new(player, "LerpMove", Vector2(1050, 500), 200)
			actionCam = Action.new(player_cam, "LerpMove", player.position / 1000., 200)
			actions = [actionCam, actionPa, actionPb]
			for action in actions:
				add_child(action)
			
			cm.set_actions(actions)
			cm.series_action()
			
			await cm.actions_complete
			
			actionCam = Action.new(player_cam, "LerpMove", Vector2(0, -100), 200)
			actions = [actionCam]
			for action in actions:
				add_child(action)
			
			cm.set_actions(actions)
			cm.series_action()
			await cm.actions_complete
			
			cm.call_monologue("res://Scripts/Monologues/Intro/PlayerApproachesGlow.json")
			await cm.lines_complete
			
			actionCam = Action.new(player_cam, "LerpMove", player.position / 1000., 200)
			actions = [actionCam]
			for action in actions:
				add_child(action)
			
			cm.set_actions(actions)
			cm.series_action()
			
			await cm.actions_complete
			
			cm.cut()
			
			PS.library_state = 1 # next time player enters room, scene will be on state #1 from now on
			player.autonomous = false
			
		1:
			player.position = PS.spawning_at
			
			malvoren.queue_free()
			thornewood.queue_free()
			
			fox.following_player = false
			fox.visible = false
			fox.get_node("FoxCollider").disabled = true
			
			get_node("bookshelves/SecretBookshelf/DoorArea").open_bookshelf()
			UI.start_scene_change(false, false, "")
			get_node("LibraryToCourtyardExit/CollisionShape2D").disabled = false
		2:
			player.position = PS.spawning_at
			
			malvoren.queue_free()
			thornewood.queue_free()
			
			fox.following_player = true
			fox.visible = true
			fox.get_node("FoxCollider").disabled = false
			
			get_node("bookshelves/SecretBookshelf/DoorArea").open_bookshelf()
			UI.start_scene_change(false, false, "")
			get_node("LibraryToCourtyardExit/CollisionShape2D").disabled = false
