extends Node2D

var cm : CutsceneManager # cutscene manager for this 
@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var game_cam = get_node("Camera2D")

var new_map
var old_map
@onready var hall_map = load("res://Scenes/4_Veracity/VeracityMinigame2/hall_repeat.tscn")

var trigger_map_spawn
var trigger_map_delete

func _ready():
	game_cam.reparent(self)
	
	game_cam.limit_top = -99999
	game_cam.limit_bottom = 0
	
	# intro_cutscene()
	player.autonomous = false
	
	new_map = get_tree().get_nodes_in_group("FirstMap")[0]
	old_map = null
	trigger_map_spawn = true
	trigger_map_delete = false

func _process(delta):
	var apos = fmod(abs(player.position.y), 2304.)
	if apos >= 626 and apos < 1252 and trigger_map_delete:
		if old_map:
			old_map.queue_free()
			old_map = null
		trigger_map_spawn = true
		trigger_map_delete = false
	if ((apos >= 1252 and apos < 2304)) and trigger_map_spawn:
		old_map = new_map
		new_map = hall_map.instantiate()
		add_child(new_map)
		move_child(new_map, 0)
		new_map.position = old_map.position - Vector2(0., 2304.)
		trigger_map_delete = true
		trigger_map_spawn = false
	
	game_cam.global_position -= Vector2(0, delta * 200.)
	if (player.global_position.y > game_cam.global_position.y):
		player.speed = 250.
	else:
		player.speed = 200.

func intro_cutscene():
	var fox = get_node("Fox")
	
	# DISABLE PLAYER WHILE CUTSCENES ARE OCCURRING
	player.autonomous = true
	
	# ActionGroup A - Setup (students walk to principal)
	var actionA = Action.new(player, "LerpMove", Vector2(798, -1920), 200)
	var actionB = Action.new(fox, "LerpMove", Vector2(864, -1920), 200)
	
	var actions : Array[Action] = [actionA, actionB]
	for action in actions:
		add_child(action)
	
	cm = CutsceneManager.new(actions)
	add_child(cm)
	
	cm.parallel_action()
	
	cm.call_dialogue("res://Resources/Texts/Dialogues/0_Tutorial/TutorialEnv/FoxBlurb.json")
	await cm.actions_complete
	
	cm.call_dialogue("res://Resources/Texts/Dialogues/0_Tutorial/TutorialMinigame1/UnhappyCannon.json")
	await cm.lines_complete
