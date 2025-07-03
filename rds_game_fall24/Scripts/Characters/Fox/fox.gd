extends CharacterController

@onready var player = get_tree().get_nodes_in_group("Player")[0]

func _ready():
	super()

func _process(delta):
	if (!autonomous):
		target_pos = player.global_position
		autonomous = true
	else:
		super(delta)
