extends TextureButton

@onready var button_primed : bool = false	# mouse over button
@onready var canvas : CanvasItem = self as CanvasItem

func _process(delta):
	if Input.is_action_just_pressed("left_click"):
		get_tree().call_group("MixingGame", "mix")
