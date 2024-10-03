extends Node2D

enum CannonState{
	idle,
	dartThrown,
	reset
}

var CannonShotState

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CannonShotState = CannonState.idle
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match CannonShotState:
		CannonState.idle:
			pass
		CannonState.dartThrown:
			# if space bar is pressed
			if Input.is_action_pressed('space'):
				# adjust the cannon strength based on the holding time
				pass
		CannonState.reset:
			pass	
	pass
