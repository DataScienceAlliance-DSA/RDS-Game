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
@onready var player_area = self.get_node("PlayerArea")
@onready var enter_cutscene = true
var scene_map

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

# global variables for finding interactable areas
var closest_area_index
var neighbor_areas

func _ready():
	if get_tree().current_scene.is_in_group("minigame"):
		is_minigame_scene = true # Flag as minigame scene
		print(is_minigame_scene)
	
	self.get_node("Camera2D").zoom = Vector2(cam_zoom,cam_zoom)
	
	scene_map = self.get_node("../Map") 
	if scene_map:
		var map_limits = scene_map.get_used_rect()
		var map_cellsize = scene_map.rendering_quadrant_size
		var camera = get_node("Camera2D")
		camera.limit_left = map_limits.position.x * map_cellsize
		camera.limit_right = map_limits.end.x * map_cellsize
		camera.limit_top = map_limits.position.y * map_cellsize
		camera.limit_bottom = map_limits.end.y * map_cellsize
	
	movement_stack = []

func updateAnimation():
	if velocity.length() == 0:
		# Plays idle animation based on last movement direcition
		animations.play("idle" + last_direction)  # Play idle animation
	else:
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x >0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
	
		# Updates last_direction with current direction
		last_direction = direction
		# Plays walking animation for current direction
		animations.play("walk" + direction)

func _process(_delta):
	#print(autonomous)
	if (autonomous):
		super(_delta)
		return
	
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
	find_interactables()
	if (neighbor_areas.size() != 0) and (Input.is_action_just_pressed("interaction")):
		# place code for drawing an interact UI button over closest area
		confirmed_interaction()
	
	## -deeg
	############################################################################

# successfully interacts with an in-area object...
func confirmed_interaction():
	if (neighbor_areas.size() != 0): neighbor_areas[closest_area_index].interact(self)
	movement_stack = [NO_MOVEMENT] # reset movement stack
	# above line is for if player is enabled post-interactable area

# finds all interactables and sets which one is nearest to target interactable...
func find_interactables():
	closest_area_index = 0
	neighbor_areas = player_area.get_overlapping_areas();
	var closest_distance = 0
	
	for i in neighbor_areas.size():
		var x_distance = ((neighbor_areas[i].position.x - player_area.position.x) ** 2)
		var y_distance = ((neighbor_areas[i].position.y - player_area.position.y) ** 2)
		var total_distance = ((x_distance + y_distance) ** 0.5)
		closest_area_index = i if (total_distance < closest_distance) else closest_area_index
		closest_distance = total_distance if (total_distance < closest_distance) else closest_distance

# enables player to move again...
func enable_process():
	self.autonomous = false
	#print("Before setting process: ", self.is_processing())  # Log before enablin
	self.set_process(true)
	#print("After setting process: ", self.is_processing())  # Log after enabling
	movement_stack = [NO_MOVEMENT]	# reset movement stack
