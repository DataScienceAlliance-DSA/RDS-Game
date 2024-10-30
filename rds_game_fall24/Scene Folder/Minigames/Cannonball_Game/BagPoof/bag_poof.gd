extends Sprite2D

signal animation_complete  # Custom signal to notify main scene

func _on_animation_player_animation_finished(anim_name):
	print("YAEY")
	emit_signal("animation_complete")
	queue_free()
