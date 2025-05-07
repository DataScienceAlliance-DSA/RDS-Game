extends PointLight2D

var candle_flicker_speed
var candle_flicker_steepness
var candle_flicker_phase
@onready var run_time = 0.0;

func _ready():
	candle_flicker_speed = randf_range(0.75, 1.5)
	candle_flicker_steepness = randf_range(1.0, 2.0)
	candle_flicker_phase = randf_range(0, candle_flicker_speed)

func _process(delta):
	run_time += delta;

	self.energy = steep_sine(1.00, 1.5, 1.50, candle_flicker_speed, -1.0)
	var scale_factor = steep_sine(0.50, 0.75, 1.50, candle_flicker_speed, 1.0)
	self.scale.x = scale_factor
	self.scale.y = scale_factor

func steep_sine(min, max, steepness, speed, yscale):
	var center = ((max - min) / 2.0) + min
	var length = (1.0 / (max - min)) * 2.0
	return (yscale * ((atan(steepness * sin(steepness * speed * run_time))) / (length * atan(steepness))) + center)
