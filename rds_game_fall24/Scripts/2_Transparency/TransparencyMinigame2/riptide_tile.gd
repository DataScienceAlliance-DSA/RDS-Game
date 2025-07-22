extends Area2D

enum RiptideOrientations {
	RIGHT,
	LEFT,
	UP,
	DOWN
}

@export var orientation : RiptideOrientations = RiptideOrientations.RIGHT
@export var riptide_speed : float = 50.

@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var player_caught = false

# child references
@onready var sprite = $Sprite2D

func _ready():
	# set sprite orientation and offsets of riptide
	match orientation:
		RiptideOrientations.RIGHT: 
			sprite.rotation = PI / 2
			sprite.offset = Vector2(90, 0)
		RiptideOrientations.LEFT: 
			sprite.rotation = 3 * PI / 2
			sprite.offset = Vector2(-90, 0)
		RiptideOrientations.UP: 
			sprite.rotation = 0
			sprite.offset = Vector2(0, 90)
		RiptideOrientations.DOWN: 
			sprite.rotation = PI
			sprite.offset = Vector2(0, -90)
		_: 
			sprite.rotation = 0
			sprite.offset = Vector2(0, 90)

func _process(delta):
	if player_caught:
		match orientation:
			RiptideOrientations.RIGHT:
				player.global_position.x += delta * riptide_speed
			RiptideOrientations.LEFT:
				player.global_position.x -= delta * riptide_speed
			RiptideOrientations.UP:
				player.global_position.y -= delta * riptide_speed
			RiptideOrientations.DOWN:
				player.global_position.y += delta * riptide_speed

func _on_body_entered(body):
	if player == body:
		# SETTING PLAYER ANIMATION FOR MOVING OVER RIPTIDE
		match orientation:
			RiptideOrientations.RIGHT:
				player.force_animation("walkRight")
			RiptideOrientations.LEFT:
				player.force_animation("walkLeft")
			RiptideOrientations.UP:
				player.force_animation("walkUp")
			RiptideOrientations.DOWN:
				player.force_animation("walkDown")
		player.set_process(false)
		player_caught = true

func _on_body_exited(body):
	if player == body:
		# RESET PLAYERS MOVEMENT STACK
		player.reset_player()
		player.set_process(true)
		player_caught = false
