extends Node2D

@export var item_scene: PackedScene
#@export var spawn_interval := 1.5

func _ready():
	#$SpawnTimer.wait_time = spawn_interval
	$SpawnTimer.start()

func _on_spawn_timer_timeout():
	print("timer has timed out")
	var item = item_scene.instantiate()
	add_child(item)
	item.global_position = $Path2D.global_position + $Path2D.curve.sample_baked(0)  # Optional: set initial pos
	item.start_path_movement($Path2D)
