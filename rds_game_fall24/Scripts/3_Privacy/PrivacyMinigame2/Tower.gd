extends CharacterBody2D
@onready var rangeshape = $CollisionShape2D
var bullet_path = preload("res://Scenes/3_Privacy/PrivacyMinigame2/Fireball.tscn")
var range : int = 50 #sets range
var damage : int = 3 #sets damage
var atksp : int = 2 #sets attack speed



# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
