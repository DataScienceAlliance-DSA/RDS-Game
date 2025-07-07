extends CharacterController

@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var following_player = false

func _ready():
	super()

func _process(delta):
	if following_player:
		if (!autonomous):
			target_pos = player.global_position
			autonomous = true
			print("OFF")
		else:
			print("AUTONOMOUS")
			super(delta)
