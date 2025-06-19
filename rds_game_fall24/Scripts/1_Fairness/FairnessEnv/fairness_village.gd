extends Node2D

@onready var player = get_tree().get_nodes_in_group("Player")[0]

@export var default_spawn : Vector2
@onready var crystal = $PodiumGroup/Crystal

var cm : CutsceneManager # cutscene manager for this 

func _ready():
	player.global_position = PS.spawning_at
	UI.start_scene_change(false, false, "")
	
	match(PS.village_state):
		1:
			if PS.spawning_at != Vector2(0.,0.): player.global_posiion = PS.spawning_at
			else: player.global_position = default_spawn
		2:
			if PS.spawning_at != Vector2(0.,0.): player.global_posiion = PS.spawning_at
			else: player.global_position = default_spawn
		3:
			player.autonomous = true
			print(player.autonomous)
			
			player.global_position = Vector2(1629,-1839)
			# player.reset_camera()
			
			var crystal_rises = UniqueAction.new(crystal, Callable(crystal, "levitate"))
			var actions : Array[Action] = [crystal_rises]
			for action in actions:
				add_child(action)
			
			cm = CutsceneManager.new(actions)
			add_child(cm)
			
			cm.series_action()
			
			await cm.actions_complete
			
			cm.call_dialogue("res://Resources/Texts/Dialogues/1_Fairness/FairnessEnv/FairnessCrystal2.json")
			
			await cm.lines_complete
			
			UI.start_scene_change(true, true, "res://Scenes/2_Transparency/TransparencyMinigame1/Cargo_Game.tscn") # TBD: FINISH CUTSCENES FROM FIGMA HERE, THEN PERMIT PLAYER TO GO TO DOCK
