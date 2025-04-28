extends Sprite2D

@onready var popped = false
@export var connected_panel_element : Control

var root

func set_root(r):
	root = r

func _ready():
	$Area2D.mouse_entered.connect(_on_mouse_entered)
	$Area2D.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	if root:
		root.active_bubble = self

func _on_mouse_exited():
	if root:
		root.active_bubble = null
