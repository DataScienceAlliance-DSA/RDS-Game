extends CharacterBody2D

var player_speed = 200

# movement stack & directional velocity constants
var movement_stack = []
var no_movement = Vector2(0, 0)
var right_movement = Vector2(player_speed, 0)
var left_movement = Vector2(-1 * player_speed, 0)
var up_movement = Vector2(0, -1 * player_speed)
var down_movement = Vector2(0, player_speed)

func _ready():
	# movement stack starts with no movement, default state
	movement_stack.push_front(no_movement)

func _process(_delta):
	############################################################################
	## TENTATIVE MOVEMENT STACK SYSTEM for limiting movement to four directions.
	# ...i want to refactor so that its not 8 conditionals in a row if possible 
	
	# per each movement key, if just pressed, add the movement to stack
	if Input.is_action_just_pressed("right"):
		movement_stack.push_front(right_movement)
	# otherwise, if just released, find and remove the movement from the stack
	elif Input.is_action_just_released("right"):
		movement_stack.pop_at(movement_stack.find(right_movement))
	
	# rinse and repeat for each direction
	if Input.is_action_just_pressed("left"):
		movement_stack.push_front(left_movement)
	elif Input.is_action_just_released("left"):
		movement_stack.pop_at(movement_stack.find(left_movement))
	
	if Input.is_action_just_pressed("up"):
		movement_stack.push_front(up_movement)
	elif Input.is_action_just_released("up"):
		movement_stack.pop_at(movement_stack.find(up_movement))
	
	if Input.is_action_just_pressed("down"):
		movement_stack.push_front(down_movement)
	elif Input.is_action_just_released("down"):
		movement_stack.pop_at(movement_stack.find(down_movement))
	
	# set the velocity to top of stack (most recently pressed direction)
	self.velocity = movement_stack.front()
	self.move_and_slide()
	
	## -diego
	############################################################################
