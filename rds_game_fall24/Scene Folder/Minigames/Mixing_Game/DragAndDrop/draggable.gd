extends Sprite2D

var is_dragging = false # stage management
var mouse_offset #center mouse on click
var delay = 0.1
var drop_spots
var start_position = Vector2()

func _ready():
	start_position = self.position
	drop_spots = get_tree().get_nodes_in_group('DropSpotGroup')
	print(drop_spots)

func _physics_process(delta):
	if is_dragging == true:
		var tween = get_tree().create_tween()
		tween.tween_property(
			self,
			'position', 
			get_global_mouse_position() - mouse_offset, 
			delay * delta
		)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if get_rect().has_point(to_local(event.position)):
				is_dragging = true
				mouse_offset = get_global_mouse_position() - global_position
		else:
			is_dragging = false
			var planned_position
			for drop_spot in drop_spots:
				print(str(drop_spot) + "     " + str(drop_spot.get_overlapping_areas()))
				if ((drop_spot.has_overlapping_areas())
					and 
					(drop_spot.get_overlapping_areas().has(self.get_node("Area2D")))
					and
					(drop_spot.get_overlapping_areas().size() == 1)
				):
					var snap_position = drop_spot.position
					var tween = get_tree().create_tween()
					tween.tween_property(
						self,
						'position', 
						snap_position, 
						delay
					)
					return
			self.position = start_position
