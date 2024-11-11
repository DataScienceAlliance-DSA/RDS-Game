extends CharacterBody2D

# for setting called-animation based on character velocity
@onready var animations = $FoxSprite/FoxAnim
var last_direction = "Right" # Initial default direction

# movement stack & directional velocity constants
var NO_MOVEMENT = Vector2(0, 0)

func _ready():
	animations.play("idleRight")  # Play the Idle animation by default
