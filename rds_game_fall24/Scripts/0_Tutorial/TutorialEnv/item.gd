extends Node2D

var speed := 120.0
var t := 0.0
var path: Path2D
var done := false

func start_path_movement(path_ref: Path2D):
	path = path_ref
	done = false
	t = 0.0
	set_process(true)

func _process(delta):
	if done or not path:
		return

	t += delta * speed
	var total_len = path.curve.get_baked_length()

	if t >= total_len:
		enter_cauldron()
		return

	var pos = path.curve.sample_baked(t)
	global_position = path.global_position + pos

func enter_cauldron():
	var cauldron = get_tree().get_root().get_node("MainScene/CauldronArea")  # update this path
	if cauldron:
		cauldron.item_stack.append(self)
		cauldron.enable_animation()

	queue_free()
