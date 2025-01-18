extends CharacterBody2D

@export var follow_speed = 150.0
@export var lag_distance = 75.0  # Distance to maintain from the main character

#var NO_MOVEMENT = Vector2(0, 0)
#var RIGHT_MOVEMENT = Vector2(follow_speed, 0)
#var LEFT_MOVEMENT = Vector2(-1 * follow_speed, 0)
#var UP_MOVEMENT = Vector2(0, -1 * follow_speed)
var movement_stack = []

func _ready():
	var main_character = get_node("../Player")
	main_character.movement_updated.connect(_on_movement_updated)

func _on_movement_updated(updated_stack):
	movement_stack = updated_stack.duplicate()
	print("fox", movement_stack)

func _process(_delta):
	if movement_stack.size() > 0:
		var direction = movement_stack.front()
		var distance = direction.length()
		
		if distance > lag_distance:
			self.velocity = movement_stack.front()
			self.move_and_slide()
