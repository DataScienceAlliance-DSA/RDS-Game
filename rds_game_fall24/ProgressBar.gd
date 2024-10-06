extends ProgressBar

var direction: int = 1  # 1 for increasing, -1 for decreasing
var speed: float = 5.0  # Adjust this value for speed

func _ready():
	set_process(true)  # Ensures that _process is called
	
func _process(delta: float) -> void:
	 # Debugging: print current value to see if it's updating
	print("Current value: ", value)
	# Update the progress bar value based on the direction
	self.value += direction * speed * delta

	# If the value reaches the boundaries, reverse the direction
	if value >= 10:
		value = 10
		direction = -1
	elif value <= 0:
		value = 0
		direction = 1
