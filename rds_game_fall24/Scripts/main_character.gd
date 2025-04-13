extends CharacterController

# Checking to see scene type
var is_minigame_scene = false

# Variable initialization prior to the Fairness Minigame 1
var shape_index

# used to create different zoom aspects for individual scenes
@export var cam_zoom : float = 1. # sets camera zoom

#used to enable the fox as a following sprite
@onready var follower = get_parent().get_node("Follower")  # Reference to the follower

var player_speed = 200
@onready var player_cast = self.get_node("PlayerCast") as RayCast2D
@onready var enter_cutscene = true

# for setting called-animation based on character velocity
@onready var animations = $AnimationPlayer
var last_direction = "Down" # Initial default direction


# movement stack & directional velocity constants
var NO_MOVEMENT = Vector2(0, 0)
var RIGHT_MOVEMENT = Vector2(player_speed, 0)
var LEFT_MOVEMENT = Vector2(-1 * player_speed, 0)
var UP_MOVEMENT = Vector2(0, -1 * player_speed)
var DOWN_MOVEMENT = Vector2(0, player_speed)
@onready var movement_stack = [UP_MOVEMENT]
signal movement_updated(movement_stack)

# checks if current frame in process is the first non-autonomous frame
@onready var first_frame_processing = true

# global variables for finding interactable areas
var closest_area_index
var neighbor_areas

func _ready():
	set_process(false)
	
	if get_tree().current_scene.is_in_group("minigame"):
		is_minigame_scene = true # Flag as minigame scene
		print(is_minigame_scene)
	
	self.get_node("Camera2D").zoom = Vector2(cam_zoom,cam_zoom)
	
	if map:
		var map_limits = map.get_used_rect()
		var map_cellsize = map.rendering_quadrant_size
		var camera = get_node("Camera2D")
		camera.limit_left = map_limits.position.x * map_cellsize
		camera.limit_right = map_limits.end.x * map_cellsize
		camera.limit_top = map_limits.position.y * map_cellsize
		camera.limit_bottom = map_limits.end.y * map_cellsize
	
	movement_stack = []
	set_process(true)

func updateAnimation():
	if velocity.length() == 0:
		# Plays idle animation based on last movement direcition
		animations.play("animation_frameworks_hero_player/idle" + last_direction)  # Play idle animation
	else:
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x >0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
	
		# Updates last_direction with current direction
		last_direction = direction
		# Plays walking animation for current direction
		animations.play("animation_frameworks_hero_player/walk" + direction)

func reset_camera():
	self.get_node("Camera2D").global_position = self.global_position

func _process(_delta):
	if (autonomous):
		super(_delta)
		return
	
	# safety net to avoid checking inputs if first non-autonomous frame
	if (first_frame_processing):
		first_frame_processing = false
		return
	# input on first frame plays twice, and breaks the movement stack
	# hence, safety net :-3
	
	############################################################################
	## TENTATIVE MOVEMENT STACK SYSTEM for limiting movement to four directions.
	# ...i want to refactor so that its not 8 conditionals in a row if possible 
	# per each movement key, if just pressed, add the movement to stack
	if Input.is_action_just_pressed("right"):
		movement_stack.push_front(RIGHT_MOVEMENT)
	# otherwise, if just released, find and remove the movement from the stack
	elif Input.is_action_just_released("right") and movement_stack.has(RIGHT_MOVEMENT):
		movement_stack.pop_at(movement_stack.find(RIGHT_MOVEMENT))
	
	# rinse and repeat for each direction
	if Input.is_action_just_pressed("left"):
		movement_stack.push_front(LEFT_MOVEMENT)
	elif Input.is_action_just_released("left") and movement_stack.has(LEFT_MOVEMENT):
		movement_stack.pop_at(movement_stack.find(LEFT_MOVEMENT))
	
	if Input.is_action_just_pressed("up"):
		movement_stack.push_front(UP_MOVEMENT)
	elif Input.is_action_just_released("up") and movement_stack.has(UP_MOVEMENT):
		movement_stack.pop_at(movement_stack.find(UP_MOVEMENT))
	
	if Input.is_action_just_pressed("down"):
		movement_stack.push_front(DOWN_MOVEMENT)
	elif Input.is_action_just_released("down") and movement_stack.has(DOWN_MOVEMENT):
		movement_stack.pop_at(movement_stack.find(DOWN_MOVEMENT))
	
	# set the velocity to top of stack (most recently pressed direction)
	if movement_stack.size() != 0: self.velocity = movement_stack.front()
	else: self.velocity = Vector2(0.,0.)
	self.move_and_slide()
	self.updateAnimation()
	
	# Emit the updated movement stack
	emit_signal("movement_updated", movement_stack)
	
	## AREA INTERACTION for interactables
	update_cast()
	if ((player_cast.get_collider() != null) and (Input.is_action_just_pressed("interaction"))):
		# place code for drawing an interact UI button over closest area
		confirmed_interaction()
	
	## -deeg
	############################################################################

func update_cast():
	if (movement_stack.size() > 0):
		if (movement_stack.front() != NO_MOVEMENT):
			match(movement_stack.front()):
				RIGHT_MOVEMENT:
					player_cast.target_position = Vector2(160,0)
					player_cast.position = Vector2(-30,0)
				LEFT_MOVEMENT:
					player_cast.target_position = Vector2(-160,0)
					player_cast.position = Vector2(30,0)
				UP_MOVEMENT:
					player_cast.target_position = Vector2(0,-111)
					player_cast.position = Vector2(0,12)
				DOWN_MOVEMENT:
					player_cast.target_position = Vector2(0,111)
					player_cast.position = Vector2(0,-12)


# successfully interacts with an in-area object...
func confirmed_interaction():
	player_cast.get_collider().interact(self)
	movement_stack = [NO_MOVEMENT] # reset movement stack
	# above line is for if player is enabled post-interactable area

# enables player to move again...
func enable_process():
	self.autonomous = false
	#print("Before setting process: ", self.is_processing())  # Log before enablin
	self.set_process(true)
	#print("After setting process: ", self.is_processing())  # Log after enabling
	movement_stack = [NO_MOVEMENT]	# reset movement stack

# PAUSES ALL STATES OF CHARACTER (animation, movement, etc.)
func pause():
	animations.pause()
	movement_stack = [NO_MOVEMENT]
	super()
# RESUMES
func resume():
	animations.play()
	super()
