extends Node2D

@onready var whirlpools = get_tree().get_nodes_in_group("whirlpools")
@onready var riptides = get_tree().get_nodes_in_group("riptides")
@onready var player = $"Main Character"

@export var spin_speed: float = 0.7
@export var scale_base: float = 0.5
@export var scale_amplitude: float = 0.1
@export var scale_speed: float = 1.0
@export var pull_speed: float = 400.0
@export var riptide_speed: float = 750.0
@export var teleport_point: Vector2

var group_to_direction := {
	"riptide_right": Vector2.RIGHT,
	"riptide_left": Vector2.LEFT,
	"riptide_up": Vector2.UP,
	"riptide_down": Vector2.DOWN,
}

var scale_time := 0.0
var pulling_whirlpool: Area2D = null
var total_spin := 0.0

var active_riptide: Area2D = null
var is_in_riptide := false
var riptide_path: Array[Vector2] = []
var riptide_path_index := 0

func _ready():
	for wp in whirlpools:
		wp.connect("body_entered", Callable(self, "_on_whirlpool_body_entered").bind(wp))
	for rt in riptides:
		rt.connect("body_entered", Callable(self, "_on_riptide_body_entered").bind(rt))

func _on_whirlpool_body_entered(body, wp):
	if body == player and pulling_whirlpool == null:
		player.pause()
		player.hopping = false
		pulling_whirlpool = wp
		total_spin = 0.0

func _get_riptide_direction_group(rt: Area2D) -> String:
	for group_name in group_to_direction.keys():
		if rt.is_in_group(group_name):
			return group_name
	return ""

func _on_riptide_body_entered(body, rt):
	if body != player or is_in_riptide:
		return
	# var group_name = _get_riptide_direction_group(rt)
	# if group_name == "":
	# 	push_warning("Riptide has no direction group.")
	# 	return
	# var flow: Vector2 = group_to_direction[group_name].normalized()
	# var to_player = (player.global_position - rt.global_position).normalized()
	# if flow.dot(to_player) > 0:
	# 	print("⛔ Blocked reverse riptide entry")
	# 	return
	player.pause()
	player.hopping = false
	active_riptide = rt
	is_in_riptide = true
	riptide_path = rt.get_endpoint_chain()
	riptide_path_index = 0

func _process(delta):
	scale_time += delta
	for wp in whirlpools:
		wp.rotation += spin_speed * delta
		var scale_factor = scale_base + sin(scale_time * scale_speed) * scale_amplitude
		wp.scale = Vector2.ONE * scale_factor

	if pulling_whirlpool:
		var center = pulling_whirlpool.global_position
		var direction = (center - player.global_position).normalized()
		player.global_position += direction * pull_speed * delta

		if player.global_position.distance_to(center) < 20:
			player.global_position = teleport_point
			player.resume()
			pulling_whirlpool = null

	if is_in_riptide and riptide_path_index < riptide_path.size():
		var target = riptide_path[riptide_path_index]
		var direction = player.global_position.direction_to(target)
		player.global_position += direction * riptide_speed * delta

		if player.global_position.distance_to(target) < 5:
			player.global_position = target
			riptide_path_index += 1

			if riptide_path_index >= riptide_path.size():
				player.resume()
				is_in_riptide = false
				active_riptide = null
				riptide_path.clear()
