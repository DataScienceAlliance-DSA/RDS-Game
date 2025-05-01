extends Area2D

@onready var end_point: Node2D = $EndPoint
@onready var collider: CollisionShape2D = $Collider
@onready var blocker: StaticBody2D = $Blocker

@export var tile_size: int = 128  # Size of one riptide tile

var group_to_direction := {
	"riptide_right": Vector2.RIGHT,
	"riptide_left": Vector2.LEFT,
	"riptide_up": Vector2.UP,
	"riptide_down": Vector2.DOWN,
}

var flow_direction := Vector2.ZERO
var next_riptide: Area2D = null  # The next tile in sequence

func _ready():
	flow_direction = _get_direction_from_group()
	_find_next_riptide()

# func allow_entry(player_pos: Vector2) -> bool:
# 	var group_name = ""
# 	for g in group_to_direction:
# 		if is_in_group(g):
# 			group_name = g
# 			break
#
# 	if group_name == "":
# 		return true  # fail-safe: allow
#
# 	var flow = group_to_direction[group_name].normalized()
# 	var to_player = (player_pos - global_position).normalized()
#
# 	# True only if approaching against the flow
# 	return flow.dot(to_player) < 0

func _on_body_entered(body):
	if body.name == "Main Character":
		# var should_allow = allow_entry(body.global_position)
		# blocker.set_deferred("collision_layer", 0 if should_allow else 1)
		# blocker.set_deferred("collision_mask", 0 if should_allow else 1)
		# blocker.visible = not should_allow
		pass

func _get_direction_from_group() -> Vector2:
	for group in group_to_direction:
		if is_in_group(group):
			return group_to_direction[group]
	return Vector2.ZERO

func _find_next_riptide():
	var candidates = get_tree().get_nodes_in_group("riptides")
	var target_pos = global_position + flow_direction * tile_size

	for riptide in candidates:
		if riptide == self:
			continue
		if riptide.global_position.distance_to(target_pos) < 2.0:
			next_riptide = riptide
			break

func get_endpoint_chain(visited := []) -> Array[Vector2]:
	if self in visited:
		return []

	visited.append(self)

	var chain: Array[Vector2] = [end_point.global_position]

	var candidates = get_tree().get_nodes_in_group("riptides")
	for r in candidates:
		if r == self or not r is Area2D or r in visited:
			continue
		if r.global_position.distance_to(global_position) <= tile_size + 2.0:
			if r.has_method("get_endpoint_chain"):
				var next_chain = r.get_endpoint_chain(visited)
				for point in next_chain:
					if point is Vector2:
						chain.append(point)
				break

	return chain
