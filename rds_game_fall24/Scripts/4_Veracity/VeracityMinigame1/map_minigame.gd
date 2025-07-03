## MAP_MINIGAME:
# game logic for the map minigame
extends Node2D
## - deeg

@onready var tilemap : GridContainer = $GameCanvas/HBoxContainer/CenterPanel/Control/MapGrid # container for map tiles
@onready var active_tile : MapTile = tilemap.get_children()[0] # tile being actively moveable by player

@onready var game_clock : float = 0. # time elapsed in game
@onready var game_phase : int = 0 # phase 0: shift tiles, phase 1: drag tiles

func _ready():
	var index = 0
	for tile in tilemap.get_children():
		tile.set_current_index(index)
		index += 1

func _process(delta):
	game_clock += delta
	if (game_clock < 210.): 
		shift_phase_input()
	else: 
		if game_phase == 0: increment_game_phase()
		shift_phase_input()
	
	## VISUAL PROCESS
	var width_f = 48. + 8. * cos(4. * game_clock)
	active_tile.set_border_width(width_f)

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

func drag_phase_input():
	pass

func increment_game_phase():
	game_phase += 1
	for tile in tilemap.get_children():
		tile.set_tile_to_next_phase()

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
