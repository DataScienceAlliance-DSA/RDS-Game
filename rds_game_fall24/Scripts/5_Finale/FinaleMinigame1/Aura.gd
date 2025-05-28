extends CharacterController

var action_state
var action_delta
var action_max

signal performance_completion

@onready var aura = $AuraSprite
@onready var aura_light = $AuraSprite/AuraLight
@onready var aura_light2 = $AuraSprite/AuraSprite/AuraLight2

@onready var aura_t = 0.

func aura_spell():
	action_state = "aura_spell"
	action_delta = 0.
	action_max = 1.
	
	aura.visible = true

func aura_spell_cancel():
	action_state = "aura_spell_cancel"
	action_delta = 0.
	action_max = 1.

func _process(delta):
	# AURA ANIMATION IS AUTONOMOUS IN BACKGROUND, SEPARATE FROM CUSTCENE MANAGER ACTIONS
	if aura.visible:
		aura_t = aura_t + delta
		
		aura.rotation = aura_t
		aura_light.energy = -5. * cos(3. * aura_t) + 5.
		aura_light2.energy = -5. * cos(3. * aura_t) + 5.
		
		if action_delta > 0.:
			var scale_x = .125 * cos(3. * (aura_t - 1.)) + .875
			aura.scale = Vector2(scale_x, scale_x)
	
	match(action_state):
		"aura_spell":
			if (action_delta < action_max):
				action_delta = action_delta + delta
				var change_t = action_delta / action_max
				var scale_x = ease(change_t, .2)
				aura.scale = Vector2(scale_x, scale_x)
			else:
				performance_completion.emit()
		"aura_spell_cancel":
			if (action_delta < action_max):
				action_delta = action_delta + delta
				var change_t = action_delta / action_max
				var opacity_x = ease(change_t, 3.4)
				aura.modulate.a = 1. - opacity_x
			else:
				aura.visible = false
				performance_completion.emit()
		_:
			pass

func skip_deltas():
	action_delta = action_max
