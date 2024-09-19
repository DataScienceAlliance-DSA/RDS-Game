extends CharacterBody2D


# Movement variables
var speed := 400  # Adjust this to control how fast the character moves
var move_direction := Vector2.ZERO  # This will store the direction of movement

func _process(_delta):
	# Reset the move_direction
	move_direction = Vector2.ZERO

	# Check for input and adjust the move_direction accordingly
	if Input.is_action_pressed("right"):
		move_direction.x += 1
	if Input.is_action_pressed("left"):
		move_direction.x -= 1
	if Input.is_action_pressed("down"):
		move_direction.y += 1
	if Input.is_action_pressed("up"):
		move_direction.y -= 1

	# Normalize the move_direction vector to prevent faster diagonal movement
	if move_direction.length() > 0:
		move_direction = move_direction.normalized()

	# Apply movement by setting the velocity property of CharacterBody2D
	velocity = move_direction * speed

	# Move the character based on the velocity
	move_and_slide()
