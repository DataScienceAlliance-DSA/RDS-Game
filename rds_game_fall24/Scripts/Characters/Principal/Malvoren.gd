extends CharacterController

var action_state
var action_delta
var action_max

signal performance_completion

@onready var aura = $AuraSprite
@onready var aura_light = $AuraSprite/AuraLight

@onready var aura_t = 0.

func disappear_spell():
	action_state = "disappear_spell"
	action_delta = 0.
	action_max = 1.5
	
	get_node("CollisionShape2D").disabled = true # player cannot get moved by malvorens spell

func _process(delta):
	# AURA ANIMATION IS AUTONOMOUS IN BACKGROUND, SEPARATE FROM CUSTCENE MANAGER ACTIONS
	if aura.visible:
		aura_t = aura_t + delta
		
		aura.rotation = aura_t
		aura_light.energy = -5. * cos(3. * aura_t) + 5.
		
		if action_delta > 0.:
			var scale_x = .125 * cos(3. * (aura_t - 1.)) + .875
			aura.scale = Vector2(scale_x, scale_x)
	
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
		_:
			pass

func skip_deltas():
	action_delta = action_max
