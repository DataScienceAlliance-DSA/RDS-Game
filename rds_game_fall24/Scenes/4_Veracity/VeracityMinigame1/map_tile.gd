## MAP_TILE:
# tile within the tile map for the map minigame
class_name MapTile
extends Node
## - deeg

var correct_index : int
var current_index

@onready var image_node_top : Sprite2D = $ImageNodeA
@onready var image_node_bottom : Sprite2D = $ImageNodeB
@onready var border_style : Panel = $BorderPanel

var occupied_drag_tile

@onready var is_empty_tile : bool = false

func _ready():
	image_node_top.frame = correct_index
	if is_empty_tile: image_node_top.visible = false
	
	image_node_bottom.frame = correct_index
	if is_empty_tile: image_node_bottom.visible = false

func is_matched(): return correct_index == current_index

func get_current_index(): return current_index
func set_current_index(index): current_index = index

func get_correct_index(): return correct_index
func set_correct_index(index): 
	correct_index = index
	image_node_top.frame = correct_index

func set_is_empty_tile():
	is_empty_tile = true
	image_node_top.visible = false
	image_node_bottom.visible = false

func get_image_node(): return image_node_top

func disable_visuals(): border_style.visible = false
func enable_visuals(): border_style.visible = true

func set_tile_to_next_phase():
	image_node_top.visible = false

func set_border_width(width : float): 
	var stylebox = border_style.get_theme_stylebox("panel").duplicate()	
	stylebox.border_width_left = width
	stylebox.border_width_right = width
	stylebox.border_width_top = width
	stylebox.border_width_bottom = width
	border_style.add_theme_stylebox_override("panel", stylebox)
