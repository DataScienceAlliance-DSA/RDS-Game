class_name SaveGame
extends Resource

const SAVE_GAME := "user://savegame.tres"

@export var library_state: int = 0
@export var cauldron_state: int = 0

func save_game():
	var data = ResourceSaver.save(self, SAVE_GAME)

func load_game():
	var data = ResourceLoader.load(SAVE_GAME)
	if data != null and data is Resource:
		return data
	else:
		return null
