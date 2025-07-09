extends CharacterController

@onready var player = get_tree().get_nodes_in_group("Player")[0]
@export var following_player = false

func _ready():
	anim_player = get_node("AnimationPlayer")
	target_pos = player.global_position
	super()

func _process(delta):
	if following_player:
		if (!autonomous):
			autonomous = true
		else:
			target_pos = player.global_position
			super(delta)
