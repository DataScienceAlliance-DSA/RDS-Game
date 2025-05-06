class_name UniqueAction
extends Action

var performance : Callable

func _init(actor : Node2D, performance : Callable):
	self.actor = actor
	self.performance = performance

func cue():
	performance.call()
	await actor.performance_completion
	action_completed.emit()

func skip_action():
	actor.skip_deltas()
