extends Node2D

@onready var text = $CanvasLayer/MarginContainer/TextEdit

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text.position.y += delta
