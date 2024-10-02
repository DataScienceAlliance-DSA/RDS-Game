extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mode = RigidBody2D.MODE_KINEMATIC

func ThrowDart():
	mode = RigidBody2D.MODE_RIGID
