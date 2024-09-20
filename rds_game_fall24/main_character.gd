extends CharacterBody2D

var currPos = [960, 1024]

func _input(event):
	if event.is_action_pressed("right"):
		currPos[0] += 64
		
	elif event.is_action_pressed("left"):
		currPos[0] -= 64
		
	elif event.is_action_pressed("up"):
		currPos[1] -= 64
		
	elif event.is_action_pressed("down"):
		currPos[1] += 64
		
	self.position = Vector2(currPos[0], currPos[1])
		
