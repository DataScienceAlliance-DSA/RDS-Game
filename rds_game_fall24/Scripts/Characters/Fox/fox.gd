extends CharacterBody2D

# for setting called-animation based on character velocity
@onready var fox_anim = get_node("AnimationPlayer")
var last_direction = "Down" # Initial default direction

@export var following_player : bool

@export var follow_speed = 150.0
@export var lag_distance = 125.0
@onready var player = get_tree().get_nodes_in_group("Player")[0]

func _ready():
	fox_anim.play("idleDown")  # Play the Idle animation by default

func _physics_process(delta):
	if (following_player):
		var player_position = player.position
		var direction = player_position - position
		print(direction)
		
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

func update_animation():
	if velocity.length() == 0:
		fox_anim.play("idle" + last_direction)
	else:
		var direction = "Down"
		if velocity.x < 0:
			direction = "Left"
		elif velocity.x > 0:
			direction = "Right"
		elif velocity.y < 0:
			direction = "Up"
			
		last_direction = direction
		fox_anim.play("walk" + direction)

func force_animation(animation):
	fox_anim.play(animation)
