extends Sprite2D

signal animation_complete  # Custom signal to notify main scene

@onready var node = self as Node2D
var bag_position

func _process(delta):
	pass
	# node.position = bag_position

func _on_animation_player_animation_finished(anim_name):
	emit_signal("animation_complete")
	queue_free()
