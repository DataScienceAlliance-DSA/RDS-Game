extends CharacterBody2D

const PLAYER_SPEED = 200

# movement stack & directional velocity constants
var movement_stack = []
const NO_MOVEMENT = Vector2(0, 0)
const RIGHT_MOVEMENT = Vector2(PLAYER_SPEED, 0)
const LEFT_MOVEMENT = Vector2(-1 * PLAYER_SPEED, 0)
const UP_MOVEMENT = Vector2(0, -1 * PLAYER_SPEED)
const DOWN_MOVEMENT = Vector2(0, PLAYER_SPEED)

func _ready():
	# movement stack starts with no movement, default state
	movement_stack.push_front(NO_MOVEMENT)

func _process(_delta):
	############################################################################
	## TENTATIVE MOVEMENT STACK SYSTEM for limiting movement to four directions.
	# ...i want to refactor so that its not 8 conditionals in a row if possible 
	
	# per each movement key, if just pressed, add the movement to stack
	if Input.is_action_just_pressed("right"):
		movement_stack.push_front(RIGHT_MOVEMENT)
	# otherwise, if just released, find and remove the movement from the stack
	elif Input.is_action_just_released("right"):
		movement_stack.pop_at(movement_stack.find(RIGHT_MOVEMENT))
	
	# rinse and repeat for each direction
	if Input.is_action_just_pressed("left"):
		movement_stack.push_front(LEFT_MOVEMENT)
	elif Input.is_action_just_released("left"):
		movement_stack.pop_at(movement_stack.find(LEFT_MOVEMENT))
	
	if Input.is_action_just_pressed("up"):
		movement_stack.push_front(UP_MOVEMENT)
	elif Input.is_action_just_released("up"):
		movement_stack.pop_at(movement_stack.find(UP_MOVEMENT))
	
	if Input.is_action_just_pressed("down"):
		movement_stack.push_front(DOWN_MOVEMENT)
	elif Input.is_action_just_released("down"):
		movement_stack.pop_at(movement_stack.find(DOWN_MOVEMENT))
	
	# set the velocity to top of stack (most recently pressed direction)
	self.velocity = movement_stack.front()
	self.move_and_slide()
	
	## -diego
	############################################################################
