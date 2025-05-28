extends CharacterController

var action_state
var action_delta
var action_max

signal performance_completion

@onready var sprite = $Sprite2D
@onready var shader_mat = sprite.material as ShaderMaterial

@onready var apparition_1 = $CloneSprite1
@onready var apparition_2 = $CloneSprite2
@onready var apparition_1_mat = apparition_1.material as ShaderMaterial
@onready var apparition_2_mat = apparition_2.material as ShaderMaterial

@onready var shadow1 = $Shadow
@onready var shadow2 = $Shadow2
@onready var shadow3 = $Shadow3

@onready var aura_t = 0.

@onready var multiplied = false
@onready var demultiplying = false
@onready var multiplied_clock = 0.

func disappear_spell():
	action_state = "disappear_spell"
	action_delta = 0.
	action_max = 1.5
	
	get_node("CollisionShape2D").disabled = true # player cannot get moved by malvorens spell

func dematerialize_spell():
	action_state = "dematerialize_spell"
	action_delta = 0.
	action_max = 2.5
	
	sprite.use_parent_material = false

func rematerialize():
	action_state = "rematerialize"
	action_delta = 0.
	action_max = 2.5
	
	self.visible = true
	sprite.use_parent_material = false

func multiply():
	action_state = "multiply"
	action_delta = 0.
	action_max = 2.
	
	apparition_1.visible = true
	apparition_2.visible = true
	
	shadow1.visible = true
	shadow2.visible = true
	shadow3.visible = true

func demultiply():
	action_state = "demultiply"
	action_delta = 0.
	action_max = 2.
	
	demultiplying = true
	multiplied = false
	shader_mat.set_shader_parameter("strength", 0.)

func _process(delta):
	if (multiplied):
		multiplied_clock = multiplied_clock + delta
		var theta1 = fmod(multiplied_clock + PI / 2, 2 * PI)
		var theta2 = fmod(multiplied_clock + PI, 2 * PI)
		var theta3 = fmod(multiplied_clock, 2 * PI)
		sprite.position = Vector2(96. * cos(theta1), 32. * sin(theta1) - 96.)
		apparition_1.position = Vector2(96. * cos(theta2), 32. * sin(theta2) - 96.)
		apparition_2.position = Vector2(96. * cos(theta3), 32. * sin(theta3) - 96.)
		shadow1.position = Vector2(96. * cos(theta1), 32. * sin(theta1) - 32.)
		shadow2.position = Vector2(96. * cos(theta2), 32. * sin(theta2) - 32.)
		shadow3.position = Vector2(96. * cos(theta3), 32. * sin(theta3) - 32.)
		
		if (!demultiplying):
			var motion_blur = cos(multiplied_clock * 2.5)/40. - .025
			
			shader_mat.set_shader_parameter("strength", motion_blur)
			apparition_1_mat.set_shader_parameter("strength", motion_blur)
			apparition_2_mat.set_shader_parameter("strength", motion_blur)
	
	match(action_state):
		"disappear_spell":
			if (action_delta < action_max):
				action_delta = action_delta + delta
				var change_t = action_delta / action_max
				var shift_x = (sin(5*PI*(5*change_t - 4.6)))/(5*(5*change_t - 4.6))
				self.position = Vector2(self.position.x - (shift_x * 25.), self.position.y)
			else:
				self.visible = false
				action_state = ""
				performance_completion.emit()
				get_node("CollisionShape2D").disabled = true # player cannot get moved by malvorens spell
		"dematerialize_spell":
			if (action_delta < action_max):
				action_delta = action_delta + delta
				var change_t = action_delta / action_max
				shader_mat.set_shader_parameter("strength", ease(change_t, 3.4))
			else:
				self.visible = false
				action_state = ""
				performance_completion.emit()
				sprite.use_parent_material = true
		"rematerialize":
			if (action_delta < action_max):
				action_delta = action_delta + delta
				var change_t = action_delta / action_max
				shader_mat.set_shader_parameter("strength", 1. - ease(change_t, 3.4))
			else:
				action_state = ""
				performance_completion.emit()
				sprite.use_parent_material = true
		"multiply":
			if (action_delta < action_max):
				action_delta = action_delta + delta
				var change_t = action_delta / action_max
				var easer = ease(change_t, 0.4)
				var easer2 = ease(change_t, 0.1)
				sprite.position = Vector2(0., -64. * easer)
				apparition_1.position = Vector2(-96. * easer, -96. * easer)
				apparition_2.position = Vector2(96. * easer, -96. * easer)
				shadow2.position = Vector2(-96. * easer, -32. * easer)
				shadow3.position = Vector2(96. * easer, -32. * easer)
				apparition_1_mat.set_shader_parameter("strength", 1. - easer2)
				apparition_2_mat.set_shader_parameter("strength", 1. - easer2)
			else:
				multiplied = true
				action_state = ""
				performance_completion.emit()
		"demultiply":
			if (action_delta < action_max):
				action_delta = action_delta + delta
				var change_t = action_delta / action_max
				apparition_1_mat.set_shader_parameter("strength", change_t)
				apparition_2_mat.set_shader_parameter("strength", change_t)
				
				sprite.position = lerp(sprite.position, Vector2(0,0), change_t)
				apparition_1.position = lerp(apparition_1.position, Vector2(0,0), change_t)
				apparition_2.position = lerp(apparition_2.position, Vector2(0,0), change_t)
				shadow1.position = lerp(shadow1.position, Vector2(0,0), change_t)
				shadow2.position = lerp(shadow2.position, Vector2(0,0), change_t)
				shadow3.position = lerp(shadow3.position, Vector2(0,0), change_t)
			else:
				multiplied = false
				apparition_1.visible = false
				apparition_2.visible = false
				action_state = ""
				performance_completion.emit()
				
				shadow1.visible = false
				shadow2.visible = false
				shadow3.visible = false
		_:
			pass

func skip_deltas():
	action_delta = action_max
