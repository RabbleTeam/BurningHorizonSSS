extends "res://Projectiles/Bullet.gd"


onready var trail = $Trail


func _process(_delta):
	trail.angle = global_rotation
