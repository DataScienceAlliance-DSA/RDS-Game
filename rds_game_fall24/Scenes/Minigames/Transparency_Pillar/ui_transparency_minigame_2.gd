extends CanvasLayer

@onready var package_counter_label = $PackageCounter

func _ready():
	# Find and connect to the game controller signal
	var game_controller = get_tree().current_scene
	game_controller.packages_updated.connect(_on_packages_updated)

func _on_packages_updated(count: int):
	package_counter_label.clear()
	package_counter_label.append_text("[center][b]" + str(count) + "[/b]")
