extends Node2D

@onready var text = $CanvasLayer/MarginContainer/TextEdit

func _process(delta):
	text.position.y += delta * 30.
