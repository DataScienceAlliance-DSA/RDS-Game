extends Area2D

var item_name: String  # The name of the item, matching the sprite sheet frame names

func _ready():
	# Set up collision detection
	connect("body_entered", self._on_body_entered)

func _on_body_entered(body):
	if body.name == "CauldronArea":  # Assuming the cauldron node is named "Cauldron"
		body.on_item_entered(item_name)  # Call the cauldron's method
		queue_free()  # Remove the item from the scene
