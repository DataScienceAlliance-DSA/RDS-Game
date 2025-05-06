extends TextureProgressBar

var direction: int = 1  # 1 for increasing, -1 for decreasing
var speed: float = 30.0  # Adjust this value for speed
var is_fluctuating: bool = false # Controls whether it flucuates
var last_value: float = 0 # Variable to store the last value

func _ready():
	set_process(true)  # Ensures that _process is called
	
func _process(delta: float) -> void:
	# Only update if fluctuating
	if is_fluctuating:
		self.value += direction * speed * delta
		
		# Store the last value before it changes
		last_value = value

	# If the value reaches the boundaries, reverse the direction
	if value >= 80:
		value = 80
		direction = -1
	elif value <= 0:
		value = 0
		direction = 1

#Function to start fluctuation
func start_fluctuating():
	is_fluctuating = true
	last_value = value
	
#Function to stop fluctuation
func stop_fluctuating():
	is_fluctuating = false
	var temp_value = last_value # Store the last value to return
	value = 0 # Reset the value to 0
	return temp_value
