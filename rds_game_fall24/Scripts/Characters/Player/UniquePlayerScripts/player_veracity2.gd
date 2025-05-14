extends CharacterController

# Checking to see scene type
var is_minigame_scene = false
var shape_index

@export var cam_zoom: float = 1.0
@export var cam_speed: float = 3.0
@onready var camera = get_node("Camera2D")

@onready var player_cast = self.get_node("PlayerCast") as RayCast2D
@onready var animations = $AnimationPlayer

@onready var in_cutscene = false

var last_direction = "Down"
var first_frame_processing = true
@onready var enter_cutscene = true

var movement_stack: Array[Vector2] = []
signal movement_updated(movement_stack)

var closest_area_index
var neighbor_areas

@onready var confused = false # slows player if confused
@onready var confused_timer = 0.
@export var confused_max : float
@onready var confused_indicator = get_node("ConfusionIndicator")

@onready var game_permits_player = true
@onready var game = get_node("..")

func _ready():
	set_process(false)
	
	if get_tree().current_scene.is_in_group("minigame"):
		is_minigame_scene = true
	
	camera.zoom = Vector2(cam_zoom, cam_zoom)
	
	if map:
		var map_limits = map.get_used_rect()
		var map_cellsize = map.rendering_quadrant_size

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
	camera.zoom = camera.zoom.lerp(Vector2(cam_zoom, cam_zoom), _delta * cam_speed)
	
	if autonomous:
		if !in_cutscene:
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
	
	# Move and animate
	if !game.game_won:
		velocity = movement_stack.front() if movement_stack.size() > 0 else Vector2.ZERO
	else:
		velocity = Vector2.ZERO
	velocity += Vector2(0, -speed if !confused else -speed / 2)
	move_and_slide()
	updateAnimation()
	
	if game.game_won:
		position = position.lerp(Vector2(798, position.y), _delta)
	
	if confused:
		confused_indicator.visible = true
		confused_indicator.rotation += _delta * 5.
		if confused_timer < confused_max:
			confused_timer += _delta
		else:
			confused = false
	else:
		confused_indicator.visible = false
		confused_indicator.rotation = 0.
	
	emit_signal("movement_updated", movement_stack)
	
	update_cast()
	if player_cast.get_collider() and Input.is_action_just_pressed("interaction"):
		confirmed_interaction()

func _on_finish_area_body_entered(body):
	if body == self:
		game.game_won = true
		game.game_running = false

func _remove_movement_direction(direction: String) -> void:
	var target_x := get_movement_vector(direction).x
	for i in range(movement_stack.size()):
		var current_x := movement_stack[i].x
		if target_x != 0.0 and sign(current_x) == sign(target_x):
			movement_stack.remove_at(i)
			break

func updateAnimation():
	if velocity.length() == 0:
		animations.play("animation_frameworks_hero_player/idle" + last_direction)
	else:
		var direction = "Down"
		if velocity.x < 0: direction = "Up"
		elif velocity.x > 0: direction = "Up"
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
