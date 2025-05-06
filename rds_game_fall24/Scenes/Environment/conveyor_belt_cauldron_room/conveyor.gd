extends Node2D

@onready var item_scene = preload("res://Scene Folder/Environment/conveyor_belt_cauldron_room/Managers/ConveyorItem.tscn")
@onready var cauldron_animator = get_node("../Cauldron/AnimationPlayer")

func reset_cutscene():
	for belt in self.get_children():
		if (belt.get_child(0).get_child(1).get_child_count() > 0):
			belt.get_child(0).get_child(1).get_child(0).queue_free()
			cauldron_animator.set_current_animation("NonOrb")
	
	var item1_area = item_scene.instantiate()
	
	var item_script = load("res://ConveyorBelt Master/Managers/cauldron_item.gd")
	item1_area.set_script(item_script)
	
	var item1_node = item1_area as Node
	var item1_sprite = item1_area.get_child(0) as Sprite2D
	
	var item1_node2 = item1_area as Node2D
	item1_node2.rotation = PI
	
	item1_sprite.frame = (randi() % 3) + 5
	item1_node.name = "NonOrb"
	
	self.get_child(14).get_child(0).generate_item(item1_area)
	
	var item2_area = item_scene.instantiate()
	
	item2_area.set_script(item_script)
	
	var item2_node = item2_area as Node
	var item2_sprite = item2_area.get_child(0) as Sprite2D
	
	var item_number = (randi() % 5)
	item2_sprite.frame = item_number
	
	var item2_node2 = item2_area as Node2D
	item2_node2.rotation = PI
	
	match item_number:
		0:	# 
			item2_node.name = "MagentaOrb"
		1: 
			item2_node.name = "PinkOrb"
		2:
			item2_node.name = "TealOrb"
		3:
			item2_node.name = "BlueOrb"
		4:
			item2_node.name = "GreenOrb"
		5:
			item2_node.name = "YellowOrb"
		_:
			item2_node.name = "NonOrb"
	
	self.get_child(12).get_child(0).generate_item(item2_area)
	
	var item3_area = item_scene.instantiate()
	
	item3_area.set_script(item_script)
	
	var item3_node = item3_area as Node
	var item3_sprite = item3_area.get_child(0) as Sprite2D
	var item3_node2 = item3_area as Node2D
	item3_node2.rotation = PI
	
	item3_sprite.frame = 9
	item3_node.name = "NonOrb"
	self.get_child(10).get_child(0).generate_item(item3_area)
