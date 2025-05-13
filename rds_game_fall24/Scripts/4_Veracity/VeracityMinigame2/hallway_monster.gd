extends CharacterController

const SPEED = 300.0

@onready var game = get_node("..")
@onready var player = get_tree().get_nodes_in_group("Player")[0]

@onready var windup_indicator = get_node("LightWindupIndicator/PointLight2D")

# SPELL TIMERS
@onready var spell_cooldown_timer = 0.
@export var spell_cooldown_max : float
@onready var spell_windup_timer = spell_windup_max
@export var spell_windup_max : float
@onready var spell_casting_timer = spell_casting_max
@export var spell_casting_max : float
@onready var spell_cooldown = true
@onready var spell_windup = false
@onready var spell_casting = false

func _process(delta):
	velocity = Vector2.ZERO
	
	if game.game_running:
		velocity += Vector2(0, -speed)
		move_and_slide()
		
		position = position.lerp(Vector2(player.global_position.x, position.y), delta * .5)
		
		if spell_cooldown:
			if (spell_cooldown_timer < spell_cooldown_max):
				spell_cooldown_timer += delta
				print("charging up... " + str(spell_cooldown_timer / spell_cooldown_max * 100.) + "%")
			else:
				spell_windup = true
				spell_cooldown = false
				spell_windup_timer = 0.
		
		if spell_windup:
			if (spell_windup_timer < spell_windup_max):
				spell_windup_timer += delta
				print("winding up... " + str(spell_windup_timer / spell_windup_max * 100.) + "%")
				
				windup_indicator.energy = -8 * cos(pow(3 * spell_windup_timer, 2)) + 8
			else:
				spell_casting = true
				spell_windup = false
				spell_casting_timer = 0.
				windup_indicator.energy = 0.
		
		if spell_casting:
			if (spell_casting_timer < spell_casting_max):
				spell_casting_timer += delta
				print("casting... " + str(spell_casting_timer / spell_casting_max * 100.) + "%")
			else:
				spell_cooldown = true
				spell_casting = false
				spell_cooldown_timer = 0.
