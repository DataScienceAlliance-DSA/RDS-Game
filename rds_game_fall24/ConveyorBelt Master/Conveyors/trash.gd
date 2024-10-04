extends Node2D

var item
var trash_timer : float

func _ready():
	self.set_process(false)

func _on_conveyor_inventory_item_held():
	item = $ConveyorInventory.offload_item()
	
	item.trashing = true
	self.set_process(true)
	
	print("CLIPPED")

func _process(delta):
	trash_timer += delta
	if trash_timer > 0.25:
		item.queue_free()
		set_process(false)
		trash_timer = 0
