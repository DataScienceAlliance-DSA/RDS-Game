# Attach this to the node with AudioStreamPlayer
extends AudioStreamPlayer

func _ready():
	stream.loop = true
	play()  # Starts playing when the scene runs
