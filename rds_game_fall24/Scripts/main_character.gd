extends CharacterController

# Checking to see scene type
var is_minigame_scene = false
var shape_index

@export var cam_zoom: float = 1.0
@export var cam_speed: float = 3.0

@onready var follower = get_parent().get_node("Follower")
@onready var player_cast = self.get_node("PlayerCast") as RayCast2D
@onready var animations = $AnimationPlayer

var last_direction = "Down"
var first_frame_processing = true
@onready var enter_cutscene = true

var movement_stack: Array[Vector2] = []
signal movement_updated(movement_stack)

var closest_area_index
var neighbor_areas

func _ready():
	set_process(false)
	
	if get_tree().current_scene.is_in_group("minigame"):
		is_minigame_scene = true
	
	self.get_node("Camera2D").zoom = Vector2(cam_zoom, cam_zoom)
	
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

func get_movement_vector(direction: String) -> Vector2:
	match direction:
		"right": return Vector2(speed, 0)
		"left": return Vector2(-speed, 0)
		"up": return Vector2(0, -speed)
		"down": return Vector2(0, speed)
		_: return Vector2.ZERO

func _process(_delta):
	print("HERE")
	self.get_node("Camera2D").zoom = self.get_node("Camera2D").zoom.lerp(Vector2(cam_zoom, cam_zoom), _delta * cam_speed)
	
	if autonomous:
		super(_delta)
		return
	
	if first_frame_processing:
		first_frame_processing = false
		return
	
	# Input detection using movement stack
	if Input.is_action_just_pressed("right"):
		movement_stack.push_front(get_movement_vector("right"))
	elif Input.is_action_just_released("right"):
		_remove_movement_direction("right")
	
	if Input.is_action_just_pressed("left"):
		movement_stack.push_front(get_movement_vector("left"))
	elif Input.is_action_just_released("left"):
		_remove_movement_direction("left")
	
	if Input.is_action_just_pressed("up"):
		movement_stack.push_front(get_movement_vector("up"))
	elif Input.is_action_just_released("up"):
		_remove_movement_direction("up")
	
	if Input.is_action_just_pressed("down"):
		movement_stack.push_front(get_movement_vector("down"))
	elif Input.is_action_just_released("down"):
		_remove_movement_direction("down")
	
	# Move and animate
	velocity = movement_stack.front() if movement_stack.size() > 0 else Vector2.ZERO
	move_and_slide()
	updateAnimation()
	
	emit_signal("movement_updated", movement_stack)
	
	update_cast()
	if player_cast.get_collider() and Input.is_action_just_pressed("interaction"):
		confirmed_interaction()

func _remove_movement_direction(direction: String):
	var vector = get_movement_vector(direction)
	if movement_stack.has(vector):
		movement_stack.pop_at(movement_stack.find(vector))

func updateAnimation():
	if velocity.length() == 0:
		animations.play("animation_frameworks_hero_player/idle" + last_direction)
	else:
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"

		last_direction = direction
		animations.play("animation_frameworks_hero_player/walk" + direction)

func update_cast():
	if movement_stack.size() == 0:
		return
	
	var move = movement_stack.front()
	
	if move.x > 0:
		player_cast.target_position = Vector2(160, 0)
		player_cast.position = Vector2(-30, 0)
	elif move.x < 0:
		player_cast.target_position = Vector2(-160, 0)
		player_cast.position = Vector2(30, 0)
	elif move.y < 0:
		player_cast.target_position = Vector2(0, -111)
		player_cast.position = Vector2(0, 12)
	elif move.y > 0:
		player_cast.target_position = Vector2(0, 111)
		player_cast.position = Vector2(0, -12)

func confirmed_interaction():
	player_cast.get_collider().interact(self)
	movement_stack = [Vector2.ZERO]

func enable_process():
	autonomous = false
	set_process(true)
	movement_stack = [Vector2.ZERO]

func pause():
	animations.pause()
	movement_stack = [Vector2.ZERO]
	super()

func resume():
	animations.play()
	super()
