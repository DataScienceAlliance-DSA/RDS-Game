extends Node2D

@onready var whirlpools = get_tree().get_nodes_in_group("whirlpools")
@onready var riptides = get_tree().get_nodes_in_group("riptides")
@onready var player = $"Main Character"

@export var spin_speed: float = 0.7
@export var scale_base: float = 0.5
@export var scale_amplitude: float = 0.1
@export var scale_speed: float = 1.0
@export var pull_speed: float = 200.0
@export var riptide_speed: float = 250.0
@export var teleport_point: Vector2

var group_to_direction := {
	"riptide_right": Vector2.RIGHT,
	"riptide_left" : Vector2.LEFT,
	"riptide_up": Vector2.UP,
	"riptide_down": Vector2.DOWN
}

var scale_time := 0.0
var pulling_whirlpool: Area2D = null
var total_spin := 0.0

var active_riptide: Area2D = null
var riptide_end_point: Vector2
var is_in_riptide := false

func _ready():
	for wp in whirlpools:
		wp.connect("body_entered", Callable(self, "_on_whirlpool_body_entered").bind(wp))
	for rt in riptides:
		rt.connect("body_entered", Callable(self, "_on_riptide_body_entered").bind(rt))
		print("Connected to riptide:", rt.name)
	print("Found", riptides.size(), "riptides")

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
	
	# Optional: debug output if none found
	print("Warning: Riptide", rt.name, "is not in any direction group.")
	return ""
	
func _get_farthest_endpoint_in_group(origin_riptide: Area2D, group_name: String, from_pos: Vector2, flow_dir: Vector2) -> Vector2:
	var candidates := get_tree().get_nodes_in_group(group_name)
	var best_point = from_pos
	var max_alignment = -INF

	for rt in candidates:
		if rt == origin_riptide:
			continue
		if not rt.has_node("EndPoint"):
			continue

		var endpoint = rt.get_node("EndPoint").global_position
		var to_end = endpoint - from_pos
		var alignment = flow_dir.dot(to_end)

		if alignment > max_alignment:
			max_alignment = alignment
			best_point = endpoint

	# Always consider the current tile's EndPoint too
	if origin_riptide.has_node("EndPoint"):
		var self_end = origin_riptide.get_node("EndPoint").global_position
		var self_alignment = flow_dir.dot(self_end - from_pos)
		if self_alignment > max_alignment:
			best_point = self_end

	return best_point

func _on_riptide_body_entered(body, rt):
	if body != player or is_in_riptide:
		return

	player.pause()
	player.hopping = false
	active_riptide = rt
	is_in_riptide = true

	var group_name := _get_riptide_direction_group(rt)
	if group_name == "":
		push_warning("Riptide not assigned to a direction group!")
		is_in_riptide = false
		return

	var flow_dir = group_to_direction[group_name]
	riptide_end_point = _get_farthest_endpoint_in_group(rt, group_name, player.global_position, flow_dir)
	
func _process(delta):
	scale_time += delta
	for wp in whirlpools:
		wp.rotation += spin_speed * delta
		var scale_factor = scale_base + sin(scale_time * scale_speed) * scale_amplitude
		wp.scale = Vector2.ONE * scale_factor

	if pulling_whirlpool:
		var center = pulling_whirlpool.global_position
		var offset = player.global_position - center
		var spin_this_frame = spin_speed * delta
		total_spin += spin_this_frame
		var rotated = offset.rotated(spin_this_frame)
		var inward = -offset.normalized() * pull_speed * delta
		player.global_position = center + rotated + inward

		if player.global_position.distance_to(center) < 20 and total_spin >= TAU:
			player.global_position = teleport_point
			player.resume()
			pulling_whirlpool = null

	if is_in_riptide and active_riptide:
		var direction = player.global_position.direction_to(riptide_end_point)
		player.global_position += direction * riptide_speed * delta

		if player.global_position.distance_to(riptide_end_point) < 5:
			player.global_position = riptide_end_point
			player.resume()
			is_in_riptide = false
			active_riptide = null
