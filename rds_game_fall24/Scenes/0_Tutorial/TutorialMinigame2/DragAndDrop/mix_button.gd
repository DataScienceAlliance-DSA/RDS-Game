extends TextureButton

@onready var button_primed : bool = false	# mouse over button
@onready var canvas : CanvasItem = self as CanvasItem

func _on_pressed():
	get_tree().call_group("MixingGame", "mix")
