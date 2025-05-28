extends CharacterController

var action_state
var action_delta
var action_max

@onready var sprite = $crystal
@onready var sprite_anim = $crystal/Sprite2D

signal performance_completion

func levitate():
	sprite.visible = true
	action_state = "levitate"
	action_delta = 0.
	action_max = 5.
	sprite_anim.play("spin")

func disappear():
	action_state = "disappear"
	action_delta = 0.
	action_max = 1.

func _process(delta):
	match(action_state):
		"levitate":
			if (action_delta < action_max):
				action_delta = action_delta + delta
				var t = action_delta / action_max
				
				if (action_delta < 2.):
					var f = exp(action_delta * 1.535)
					
					sprite.modulate.a = 0.5 * sin(action_delta * f - PI / 2.) + 0.5
				else:
					sprite.modulate.a = 1.
				self.position = self.position - Vector2(0, 25) * delta
			else:
				action_state = ""
				performance_completion.emit()
		"disappear":
			if (action_delta < action_max):
				action_delta = action_delta + delta
				var t = action_delta / action_max
				sprite.modulate.a = 1. - t
			else:
				self.visible = false
				action_state = ""
				performance_completion.emit()
		_:
			pass

func skip_deltas():
	action_delta = action_max
