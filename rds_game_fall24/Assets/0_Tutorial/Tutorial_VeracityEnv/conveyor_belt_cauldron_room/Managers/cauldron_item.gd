extends Area2D

const grav : float = 9.81
@onready var x_speed : int = 100
@onready var y_speed : float = 0
@onready var trashing : bool = false

var item_body : Node2D
var item_canvas : CanvasItem

func _ready():
	pass

func _process(delta):
	if trashing:
		y_speed += grav
		self.position += Vector2(x_speed, y_speed) * delta
