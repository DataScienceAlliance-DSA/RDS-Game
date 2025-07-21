extends Node2D

func _ready():
	var player = get_tree().get_nodes_in_group("Player")[0]
	player.get_node("Camera2D").limit_right = 3776.

	## Get Actors (Node2Ds)
	var actorA = get_node("characters/student_npc1")
	var actorB = get_node("characters/student_npc2")
	var actorC = get_node("characters/student_npc3")
	var actorD = get_node("characters/student_npc4")
	var actorE = get_node("characters/student_npc5")
	var malvoren = get_node("characters/principal_villain")
	var thornewood = get_node("characters/ProfessorThornewood")
	match (PS.library_state):
		0:
			pass
