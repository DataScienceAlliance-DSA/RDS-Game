extends Node
var scaling : int = 0 #Scaling for enemy health/speed
var ap :int = 0 #These are your Action Points, the currency in the game 
var done : int = 0#This is how close to done the node is in terms of uploading the information
var life : int = 15 #This is how many lives you have

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	done += 1 #This increases the completion of the node
