extends Area2D

onready var lifetimeTimer = $Lifetime

export (int) var speed
export (int) var damage
export (float) var lifetime
export (float) var steer_force

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var target = null


func init(_position, _direction, _target = null):
	position = _position
	rotation = _direction.angle()
	lifetimeTimer.wait_time = lifetime
	velocity = _direction * speed
	target = _target


func _physics_process(delta):
	if target:
		acceleration += seek()
		velocity += acceleration * delta
		velocity = velocity.clamped(speed)
		rotation = velocity.angle()
	position += velocity * delta


func explode():
	queue_free()


func seek():
	var disired = (target.position - position).normalized() * speed
	var steer = (disired - velocity).normalized() * steer_force
	return steer


func _on_Bullet_body_entered(body):
	explode()
	if body.has_method('take_damage'):
		body.take_damage(damage)


func _on_Lifetime_timeout():
	explode()
