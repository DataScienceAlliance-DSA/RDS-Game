extends Node2D

@onready var whirlpools = get_tree().get_nodes_in_group("whirlpools")
@onready var player = $"Main Character"
@onready var whirlpool = $Whirlpool

@export var spin_speed: float = .7 # Radians per second
@export var scale_base: float = 0.5
@export var scale_amplitude: float = 0.1
@export var scale_speed: float = 1.0 # how fast it breathes
@export var pull_speed: float = 200.0
@export var teleport_point: Vector2

var scale_time := 0.0
var pulling_whirlpool: Area2D = null
var is_pulling_player = false

func _ready():
	for wp in whirlpools:
		wp.connect("body_entered", Callable(self, "_on_whirlpool_body_entered").bind(wp))
	
func _on_whirlpool_body_entered(body, wp):
	if body == player:
		print("Player entered whirlpool", wp.name)
		player.pause()
		player.hopping = false
		pulling_whirlpool = wp
		
func _process(delta):
	scale_time += delta
	for wp in whirlpools:
		# Spin the whirlpools
		wp.rotation += spin_speed * delta

		# Breathing scale effect
		var scale_factor = scale_base + sin(scale_time * scale_speed) * scale_amplitude
		wp.scale = Vector2.ONE * scale_factor
	
	# Pull player if in a vortex
	if pulling_whirlpool:
		var direction = player.global_position.direction_to(pulling_whirlpool.global_position)
		player.global_position += direction * pull_speed * delta

		if player.global_position.distance_to(pulling_whirlpool.global_position) < 20:
			player.global_position = teleport_point
			player.resume()
			pulling_whirlpool = null
