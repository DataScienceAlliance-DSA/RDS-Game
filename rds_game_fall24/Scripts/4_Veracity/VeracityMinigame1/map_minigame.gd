## MAP_MINIGAME:
# game logic for the map minigame
extends Node2D
## - deeg

@onready var tilemap : GridContainer = $GameCanvas/HBoxContainer/CenterPanel/Control/MapGrid # container for map tiles
@onready var active_tile : MapTile = tilemap.get_children()[0] # tile being actively moveable by player

@onready var game_clock : float = 0. # time elapsed in game
@onready var game_phase : int = 0 # phase 0: shift tiles, phase 1: drag tiles

# tile dragging phase
var dragged_tile
var selected_spot
var all_tile_nodes : Array = []

func _ready():
	var index = 0
	for tile in tilemap.get_children():
		tile.set_current_index(index)
		index += 1
	
	var left_vbox = $GameCanvas/HBoxContainer/LeftPanel/MarginContainer/VBoxContainer
	var right_vbox = $GameCanvas/HBoxContainer/RightPanel/MarginContainer/VBoxContainer
	for vbox in [left_vbox, right_vbox]:
		for child in vbox.get_children():
			var button = child.get_node("Control/Sprite2D/Button")
			button.button_down.connect(_on_tile_button_down.bind(button))
			all_tile_nodes.append(button)
	
	var map_grid = $GameCanvas/HBoxContainer/CenterPanel/Control/MapGrid
	for spot in map_grid.get_children():
		spot.mouse_entered.connect(_on_spot_mouse_entered.bind(spot))
		spot.mouse_exited.connect(_on_spot_mouse_exited.bind(spot))

func _process(delta):
	game_clock += delta
	if (game_clock < 5.): # set to 210
		shift_phase_input()
	else: 
		if game_phase == 0: increment_game_phase()
		drag_phase_input()

func shift_phase_input():
	## SELECT TILE
	active_tile.disable_visuals()
	if (Input.is_action_just_pressed("left")) and (active_tile.get_current_index() % 3 != 0):
		active_tile = tilemap.get_children()[active_tile.get_current_index() - 1]
	if (Input.is_action_just_pressed("right")) and ((active_tile.get_current_index() - 2) % 3 != 0):
		active_tile = tilemap.get_children()[active_tile.get_current_index() + 1]
	if (Input.is_action_just_pressed("up")) and (active_tile.get_current_index() > 2):
		active_tile = tilemap.get_children()[active_tile.get_current_index() - 3]
	if (Input.is_action_just_pressed("down")) and (active_tile.get_current_index() < 6):
		active_tile = tilemap.get_children()[active_tile.get_current_index() + 3]
	
	## SHIFT TILE
	if (Input.is_action_just_pressed("interaction")):
		var neighboring_tiles = get_active_neighboring_tiles()
		
		for tile in neighboring_tiles:
			if tile.is_empty_tile():
				swap_tiles(tile)
				break
	
	active_tile.enable_visuals()
	
	## VISUAL PROCESS
	var width_f = 48. + 8. * cos(4. * game_clock)
	active_tile.set_border_width(width_f)

func drag_phase_input():
	if dragged_tile: dragged_tile.global_position = get_viewport().get_mouse_position()
	
	if Input.is_action_just_released("left_click"):
		if dragged_tile:
			if !selected_spot:
				dragged_tile.position = Vector2(0., 0.)
			else:
				if selected_spot.occupied_drag_tile:
					selected_spot.occupied_drag_tile.position = Vector2(0.,0.)
				dragged_tile.global_position = selected_spot.global_position + selected_spot.size * .5 * .235
				selected_spot.occupied_drag_tile = dragged_tile
			for tile in all_tile_nodes:
				tile.mouse_filter = Control.MOUSE_FILTER_STOP  # Equivalent to 0
			print("Released:", dragged_tile.name)
			dragged_tile.z_index = 0
			dragged_tile = null

func increment_game_phase():
	game_phase += 1
	active_tile.disable_visuals()
	active_tile = null
	for tile in tilemap.get_children():
		tile.set_tile_to_next_phase()

func _on_tile_button_down(tile_node):
	if game_phase == 0: return # if not in drag phase, stop
	
	for tile in all_tile_nodes:
		tile.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Equivalent to 2
	
	dragged_tile = tile_node.get_parent()
	dragged_tile.z_index = 1
	print("Tile selected for dragging:", dragged_tile.name)

func _on_spot_mouse_entered(spot_node):
	selected_spot = spot_node
	print("Entered spot:", selected_spot.name)

func _on_spot_mouse_exited(spot_node):
	if selected_spot == spot_node:
		selected_spot = null
		print("Exited spot:", spot_node.name)

func swap_tiles(empty_tile):
	var stored_index = empty_tile.current_index
	empty_tile.current_index = active_tile.current_index
	active_tile.current_index = stored_index
	
	tilemap.move_child(active_tile, active_tile.current_index)
	tilemap.move_child(empty_tile, empty_tile.current_index)

func get_active_neighboring_tiles():
	var neighboring_tiles = []
	if (active_tile.get_current_index() % 3 != 0):
		neighboring_tiles.append(tilemap.get_children()[active_tile.get_current_index() - 1])
	if ((active_tile.get_current_index() - 2) % 3 != 0):
		neighboring_tiles.append(tilemap.get_children()[active_tile.get_current_index() + 1])
	if (active_tile.get_current_index() > 2):
		neighboring_tiles.append(tilemap.get_children()[active_tile.get_current_index() - 3])
	if (active_tile.get_current_index() < 6):
		neighboring_tiles.append(tilemap.get_children()[active_tile.get_current_index() + 3])
	return neighboring_tiles
