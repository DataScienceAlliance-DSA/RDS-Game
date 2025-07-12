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
			if (player.global_position.distance_to(self.global_position) > 128.):
				autonomous = true
			else:
				set_directional_anim(char_dir_theta, false)
		else:
			target_pos = player.global_position
			super(delta)
