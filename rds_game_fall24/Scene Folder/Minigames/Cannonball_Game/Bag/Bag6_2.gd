extends StaticBody2D

signal bag_triggered  # Custom signal
var has_triggered = false

func _on_trigger_area_body_entered(body):
	print("Entered area: ", body.name)  # Debug statement
	if body.name == "Cannonball" and not has_triggered:
		emit_signal("bag_triggered")
		has_triggered = true
		print("cannonball has entered and triggered")

		#disable cannonball after collision
		body.queue_free()
