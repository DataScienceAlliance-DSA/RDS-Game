class_name GroupAction
extends Action

var actions : Array[Action]  	# Action array, all to be performed at once when this GroupAction is called

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func cue():
	for action in actions:
		print("Actor: " + str(actor) + ", Type: " + str(type))
		action.set_process(true) # begin performing the action
		
		walk_t = 0.
		start_pos = actor.position
		
		await action_completed
		action.set_process(false) # end the action
		emit_signal("action_completed", self) # tell cutscene manager its ended

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
