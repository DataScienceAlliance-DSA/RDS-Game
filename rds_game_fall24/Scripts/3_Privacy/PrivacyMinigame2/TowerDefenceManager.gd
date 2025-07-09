extends Node
var scaling : int = 0 #Scaling for enemy health/speed
var ap :int = 0 #These are your Action Points, the currency in the game 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	scaling += 1 #This increases the enemies stats though a formula
