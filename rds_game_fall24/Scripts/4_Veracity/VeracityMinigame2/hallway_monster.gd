extends CharacterController

const SPEED = 300.0

@onready var game = get_node("..")
@onready var player = get_tree().get_nodes_in_group("Player")[0]

@onready var area = get_node("Area2D")
@onready var sprite = get_node("Sprite2D")

@onready var windup_indicator = get_node("LightWindupIndicator/PointLight2D")
@onready var casting_line = get_node("Area2DRay/Line2D")
@onready var casting_particles = get_node("Area2DRay/GPUParticles2D")
@onready var casting_area = get_node("Area2DRay")
@onready var casting_shape = get_node("Area2DRay/CollisionShape2D")

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
		
		var vec = Vector2(0, sprite.modulate.a)
		if area.has_overlapping_bodies():
			vec = vec.lerp(Vector2(0, 0.), delta)
		else:
			vec = vec.lerp(Vector2(0, 1.), delta)
		sprite.modulate.a = vec.y
		
		if spell_cooldown:
			if (spell_cooldown_timer < spell_cooldown_max):
				spell_cooldown_timer += delta
			else:
				spell_windup = true
				spell_cooldown = false
				spell_windup_timer = 0.
		
		if spell_windup:
			if (spell_windup_timer < spell_windup_max):
				spell_windup_timer += delta
				
				windup_indicator.energy = -16 * cos(pow(3 * spell_windup_timer, 2)) + 16
			else:
				casting_particles.emitting = true
				spell_casting = true
				spell_windup = false
				spell_casting_timer = 0.
				windup_indicator.energy = 0.
		
		if spell_casting:
			if casting_area.get_overlapping_bodies().has(player) and !player.confused:
				player.confused = true
				player.confused_timer = 0.
			
			if (spell_casting_timer < spell_casting_max):
				spell_casting_timer += delta
				
				windup_indicator.energy = 32*(1. - (pow(spell_casting_timer, 4)))
				casting_line.width = -pow(5.35 * (spell_casting_timer - .5), 4.) + 50
				var s = -pow(2.4 * (spell_casting_timer - .5), 4.) + 2
				casting_particles.process_material.scale_min = s
				casting_particles.process_material.scale_max = s
				casting_shape.shape.size.x = s
			else:
				casting_particles.emitting = false
				spell_cooldown = true
				spell_casting = false
				spell_cooldown_timer = 0.
