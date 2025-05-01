# A_STAR_2D_VISUALIZER:
# performs debug draws to visualize all valid and invalid cells of an AStar2D node
class_name AStar2DVisualizer
extends Node2D
# - deeg

@export var point_radius : float = 6
@export var scale_multiplier : float = 16
@export var offset : Vector2 = Vector2(0,0)
@export var enabled_point_color : Color = Color('00ff00')
@export var disabled_point_color : Color = Color('ff0000')
@export var line_color : Color = Color('0000ff')
@export var line_width : float = 2

var astar : AStar2D

func visualize(new_astar : AStar2D):
	astar = new_astar
	queue_redraw()

func _point_pos(id):
	return offset + astar.get_point_position(id) * scale_multiplier

func _draw():
	
	if not astar:
		return
	
	for point in astar.get_point_ids():
		
		# for other in astar.get_point_connections(point):
			# draw_line(_point_pos(point), _point_pos(other), line_color, line_width)
			
		var point_color = disabled_point_color if astar.is_point_disabled(point) else enabled_point_color
		draw_circle(_point_pos(point), point_radius, point_color)
