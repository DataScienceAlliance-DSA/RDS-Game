extends CharacterBody2D

@export var follow_speed = 150.0
@export var lag_distance = 125.0
@onready var player = get_parent().get_node("Player")

func _physics_process(delta):
	var player_position = player.position
	var direction = player_position - position

	var distance_to_player = direction.length()

	if distance_to_player > lag_distance:
		# Determine the primary direction to move in (horizontal or vertical)
		if abs(direction.x) > abs(direction.y):
			# Move horizontally
			if direction.x > 0:
				velocity = Vector2(follow_speed, 0)  # Move right
			else:
				velocity = Vector2(-follow_speed, 0)  # Move left
		else:
			# Move vertically
			if direction.y > 0:
				velocity = Vector2(0, follow_speed)  # Move down
			else:
				velocity = Vector2(0, -follow_speed)  # Move up
	else:
		velocity = Vector2.ZERO  # Stop moving when within lag distance

	move_and_slide()
