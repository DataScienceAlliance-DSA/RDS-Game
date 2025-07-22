extends Area2D
@onready var player = get_tree().get_nodes_in_group("Player")[0]
var occupied = false

func _on_body_entered(body):
	if body == player:	
		player.autonomous = true
		occupied = true

func _on_body_exited(body):
	if body == player:
		player.autonomous = false
		occupied = false

func _process(delta):
	while occupied == true:
		print("stucked")
