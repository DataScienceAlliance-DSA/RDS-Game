extends Node2D

@onready var item_scene = preload("res://ConveyorBelt Master/Managers/ConveyorItem.tscn")
@onready var timer: Timer = $Timer
@export var directions : Array[Enums.Direction] = []

func _ready():
	$DirectionController.set_directions(directions)
	

func _on_conveyor_detectors_inventory_found(inventory: ConveyorInventory):
	var item = $ConveyorInventory.offload_item()
	inventory.receive_item(item)
	timer.start()


func _on_timer_timeout():
	var item_area = item_scene.instantiate()
	var item_number = randi() % 10
	
	var item_script = load("res://ConveyorBelt Master/Managers/cauldron_item.gd")
	item_area.set_script(item_script)
	
	var item_node = item_area as Node
	
	var item_sprite = item_area.get_child(0) as Sprite2D
	item_sprite.frame = item_number
	
	match item_number:
		0:	# 
			item_node.name = "MagentaOrb"
		1: 
			item_node.name = "PinkOrb"
		2:
			item_node.name = "TealOrb"
		3:
			item_node.name = "BlueOrb"
		4:
			item_node.name = "GreenOrb"
		5:
			item_node.name = "YellowOrb"
		_:
			item_node.name = "NonOrb"
	
	$ConveyorInventory.generate_item(item_area)
	$ConveyorDetectors.start_checking()


func _on_direction_controller_directions_changed(to_directions):
	$ConveyorDetectors.set_directions(to_directions)
