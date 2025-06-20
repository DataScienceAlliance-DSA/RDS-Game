extends Area2D

@onready var island = get_parent()

var delivered: bool = false

func interact(player):
	if delivered:
		return
	
	var game_controller = get_tree().current_scene
	
	game_controller.packages_remaining -= 1
	print("Delivered package! Packages left:", game_controller.packages_remaining)
	
	game_controller.emit_signal("packages_updated", game_controller.packages_remaining)
	
	# Updated: Set checkpoint based on player's current position, not island node
	game_controller.checkpoint_position = player.global_position
	
	delivered = true
	
	if (game_controller.packages_remaining == 0): 
		game_controller.end_game()

