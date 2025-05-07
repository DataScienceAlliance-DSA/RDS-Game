extends StaticBody2D

signal bag_triggered  # Custom signal
var has_triggered = false
var main_scene: Node = null

func _on_trigger_area_body_entered(body):
	if body.name == "Cannonball" and not has_triggered:
		var cannon = get_node("../cannon")
		cannon.timer.stop()
		body.get_node("../cannon").set_process(true)
		emit_signal("bag_triggered")
		has_triggered = true
		
		#disable cannonball after collision
		body.queue_free()
