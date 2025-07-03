## MAP_MINIGAME:
# game logic for the map minigame
extends Node2D
## - deeg

@onready var tilemap : GridContainer = $GameCanvas/GameContainer/HBoxContainer/MapPanel/Control/MapGrid # container for map tiles
@onready var timer : RichTextLabel = $GameCanvas/TimerContainer/TimerDisplay
@onready var tilepanel : HBoxContainer = $GameCanvas/GameContainer/HBoxContainer/TilePanel/MarginContainer/HBoxContainer

@onready var game_clock : float = 0. # time elapsed in game
@onready var game_phase : int = 0 # phase 0: shift tiles, phase 1: drag tiles

@export var phase_1_timer : float
@export var phase_2_timer : float

# tile dragging phase
var dragged_tile
var selected_spot
var all_tile_nodes : Array = []

func _ready():
	var index = 0
	var spot_numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8]
	for tile in tilemap.get_children():
		tile.set_current_index(index)
		var chosen_index = randi() % spot_numbers.size()
		var chosen_correct_number = spot_numbers.pop_at(chosen_index)
		tile.set_correct_index(chosen_correct_number)
		if chosen_correct_number == 8: tile.set_is_empty_tile()
		index += 1
	
	var draggable_numbers = [0, 1, 2, 3, 4, 5, 6, 7]
	for tile in tilepanel.get_children():
		var draggable = tile.get_node("Control/Sprite2D")
		var chosen_index = randi() % draggable_numbers.size()
		var chosen_number = draggable_numbers.pop_at(chosen_index)
		draggable.set_index(chosen_number)
	
	var hbox = $GameCanvas/GameContainer/HBoxContainer/TilePanel/MarginContainer/HBoxContainer
	for panel in hbox.get_children():
		var button = panel.get_node("Control/Sprite2D/Button")
		button.button_down.connect(_on_tile_button_down.bind(button))
		all_tile_nodes.append(button)
	
	var map_grid = $GameCanvas/GameContainer/HBoxContainer/MapPanel/Control/MapGrid
	for spot in map_grid.get_children():
		spot.mouse_entered.connect(_on_spot_mouse_entered.bind(spot))
		spot.mouse_exited.connect(_on_spot_mouse_exited.bind(spot))

func _process(delta):
	game_clock += delta
	if (game_clock < phase_1_timer):
		set_timer_display(phase_1_timer - game_clock)
		shift_phase_input()
	elif (game_clock < phase_2_timer + phase_1_timer): 
		if game_phase == 0: increment_game_phase()
		
		set_timer_display(phase_1_timer + phase_2_timer - game_clock)
		drag_phase_input()
	else:
		if game_phase == 1: increment_game_phase()
		
		pass

func set_timer_display(time):
	var min = floor(time / 60.)
	var sec = time - min * 60.
	var between = ":0" if sec < 10. else ":"
	if game_phase == 1: timer.text = "[right][color=purple]"
	else: timer.text = "[right][color=white]"
	timer.text += str(min) + between + str(int(sec))

func shift_phase_input():
	## SELECT TILE
	var empty_tile = find_empty_tile()
	var index = empty_tile.get_current_index()

	var target_index := -1

	if Input.is_action_just_pressed("up") and index < 6:
		target_index = index + 3
	elif Input.is_action_just_pressed("down") and index > 2:
		target_index = index - 3
	elif Input.is_action_just_pressed("left") and (index % 3) < 2:
		target_index = index + 1
	elif Input.is_action_just_pressed("right") and (index % 3) > 0:
		target_index = index - 1

	if target_index != -1:
		var target_tile = tilemap.get_children()[target_index]
		swap_tiles(empty_tile, target_tile)

func find_empty_tile():
	for tile in tilemap.get_children():
		if tile.is_empty_tile:
			return tile
	return null

func drag_phase_input():
	if dragged_tile: dragged_tile.global_position = get_viewport().get_mouse_position()
	
	if Input.is_action_just_released("left_click"):
		if dragged_tile:
			if !selected_spot:
				dragged_tile.position = Vector2(0., 0.)
			else:
				if selected_spot.occupied_drag_tile:
					selected_spot.occupied_drag_tile.position = Vector2(0.,0.)
					selected_spot.set_current_index(-1)
				dragged_tile.global_position = selected_spot.global_position + selected_spot.size * .5 * .2
				selected_spot.occupied_drag_tile = dragged_tile
				selected_spot.set_current_index(dragged_tile.index)
			for tile in all_tile_nodes:
				tile.mouse_filter = Control.MOUSE_FILTER_STOP  # Equivalent to 0
			print("Released:", dragged_tile.name)
			dragged_tile.z_index = 0
			dragged_tile = null
		check_puzzle_completion()

func increment_game_phase():
	game_phase += 1
	for tile in tilemap.get_children():
		tile.set_tile_to_next_phase()
	
	if game_phase == 1:
		var index = 0
		for tile in tilemap.get_children():
			tile.set_correct_index(index)
			tile.set_current_index(-1)
			index += 1
		var tween_0 = get_tree().create_tween()
		tween_0.tween_property(get_node("GameCanvas/GameContainer/HBoxContainer/TilePanel"), "size_flags_stretch_ratio", 7, 2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		for panel in tilepanel.get_children():
			var tween_i = get_tree().create_tween()
			var sprite = panel.get_node("Control/Sprite2D")
			tween_i.tween_property(sprite, "scale", Vector2(1.,1.), 2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

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

func swap_tiles(active_tile, empty_tile):
	var stored_index = empty_tile.current_index
	empty_tile.current_index = active_tile.current_index
	active_tile.current_index = stored_index
	
	tilemap.move_child(active_tile, active_tile.current_index)
	tilemap.move_child(empty_tile, empty_tile.current_index)
	
	check_puzzle_completion()

func check_puzzle_completion():
	if game_phase == 0:
		for tile in tilemap.get_children():
			if !tile.is_matched(): return
		win_game()
	if game_phase == 1:
		var matched_tile_count = 0
		for tile in tilemap.get_children():
			if tile.is_matched(): matched_tile_count += 1
			print(str(tile.get_current_index()) + "   " + str(tile.get_correct_index()))
		if matched_tile_count == 8: win_game()

func win_game():
	timer.text = "[center][color=green]WON"
	set_process(false)
