extends Node2D

# EXPORT FOR DEBUGGING, SET ALL TO 0 WHENEVER PREPARING FOR BUILD
@export var library_state : int
@export var cauldron_state : int
@export var village_state : int
@export var dungeon_state : int # 0: pillar, 1: minigame 2 (memory)

@export var spawning_at = Vector2(0,0)

@export var text_character_speed = 0.01

var in_intro_room = false

func reset_states():
	library_state = 0
	cauldron_state = 0
	village_state = 0
	dungeon_state = 0
	
func _ready():
	set_process(false)

func _process(delta):
	print("in intro room")
	if (Input.is_action_just_pressed("interaction") and in_intro_room):
		print("Interaction pressed: ", Global.interaction_pressed)
		Global.interaction_pressed = true;
		set_process(false)
