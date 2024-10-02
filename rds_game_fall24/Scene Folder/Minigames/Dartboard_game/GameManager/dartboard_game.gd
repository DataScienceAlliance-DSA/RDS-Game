extends Node2D

# define different game states
enum GameState{
	Start,
	Play,
	Win,
	Lose
}

# set the current game state to 'Start'
var CurrentGameState = GameState.Start

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match CurrentGameState:
		# if game state is start, then [do something]
		GameState.Start:
			pass
		# if game state is play, then [do something]
		GameState.Play:
			pass
		# if game state is win, then [do something]
		GameState.Win:
			print("You won!")
		# if game state is lose, then [do something]
		GameState.Lose:
			print("You lost!")
	pass
