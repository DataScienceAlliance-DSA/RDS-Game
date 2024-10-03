extends Node2D

@onready var item_scene = preload("res://Orb_TEST.tscn")
@onready var timer: Timer = $Timer
@export var directions : Array[Enums.Direction] = []

func _ready():
	$DirectionController.set_directions(directions)
	

func _on_conveyor_detectors_inventory_found(inventory: ConveyorInventory):
	var item = $ConveyorInventory.offload_item()
	inventory.receive_item(item)
	timer.start()


func _on_timer_timeout():
	var item_sprite = item_scene.instantiate()
	var item_number = randi() % 10
	
	var item_node = item_sprite as Node
	item_sprite.frame = item_number
	
	match item_number:
		0:	# 
			item_node.name = "RedOrb"
		1: 
			item_node.name = "OrangeOrb"
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
	
	$ConveyorInventory.generate_item(item_sprite)
	$ConveyorDetectors.start_checking()


func _on_direction_controller_directions_changed(to_directions):
	$ConveyorDetectors.set_directions(to_directions)
