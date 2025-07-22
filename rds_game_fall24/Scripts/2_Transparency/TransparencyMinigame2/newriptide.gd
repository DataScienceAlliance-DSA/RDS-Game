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
		if is_in_group("Left"):
			player.global_position.x -= delta
		if is_in_group("Right"):
			player.global_position.x += delta
		if is_in_group("Up"):
			player.global_position.y -= delta
		if is_in_group("Down"):
			player.global_position.y += delta



