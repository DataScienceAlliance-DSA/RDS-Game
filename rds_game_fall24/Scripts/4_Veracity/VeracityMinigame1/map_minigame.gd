## MAP_MINIGAME:
# game logic for the map minigame
extends Node2D
## - deeg

@onready var tilemap : MarginContainer = $GameCanvas/MapContainer/MapGrid # container for map tiles
@onready var active_tile : MapTile = tilemap.get_children()[0] # tile being actively moveable by player

@onready var game_clock : float = 0. # time elapsed in game
@onready var game_phase : int = 0 # phase 0: slide tiles, phase 1: drag tiles

func _process(delta):
	game_clock += delta
	
	
