extends TextureRect

@onready var button_primed : bool = false	# mouse over button
@onready var canvas : CanvasItem = self as CanvasItem

func _process(delta):
	if button_primed and Input.is_action_just_pressed("left_click"):
		get_tree().call_group("MixingGame", "mix")

func _on_mouse_entered():
	canvas.modulate = Color(215.0/255.0, 155.0/255.0, 25.0/255.0, 1.0)
	button_primed = true

func _on_mouse_exited():
	canvas.modulate = Color(254.0/255.0, 206.0/255.0, 126.0/255.0, 1.0)
	button_primed = false
