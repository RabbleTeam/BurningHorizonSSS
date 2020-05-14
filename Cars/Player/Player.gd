#ДОЛЖНО НАСЛЕДОВАТЬ "res://Cars/Car.gd"!!!
extends KinematicBody2D


onready var gunTimer = $GunTimer
onready var gun = $Gun

export (PackedScene) var projectile
export (int) var wheel_base = 70
export (int) var steering_angle = 35
export (int) var engine_power = 800
export (float) var friction = -1.9
export (float) var drag = -0.001
export (int) var braking = -450
export (int) var max_speed_reverce = 250
export (int) var slip_speed = 400
export (float) var traction_fast = 0.1
export (float) var traction_slow = 0.5
export (float) var gun_cooldown
export (int) var max_health
export (int) var gun_speed = 7

var health = max_health
var acceleration = Vector2.ZERO
var velocity = Vector2.ZERO
var steer_direction
var can_shoot = true
var alive = true

signal health_changed
signal dead
signal shoot


func _ready():
	gunTimer.wait_time = gun_cooldown

#Работает криво, пофиксить
func _process(delta):
	#Мягкое вращение оружия
	var target_dir = (get_global_mouse_position() - global_position).normalized()
	var current_dir = Vector2(1, 0).rotated(gun.global_rotation)
	gun.global_rotation = current_dir.linear_interpolate(target_dir, gun_speed * delta).angle()
	#gun.look_at(get_global_mouse_position())


func _physics_process(delta):
	if not alive:
		return
	acceleration = Vector2.ZERO
	get_input()
	apply_friction()
	calculate_steering(delta)
	velocity += acceleration * delta
	velocity = move_and_slide(velocity)

func apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	acceleration += drag_force + friction_force


func get_input():
	var turn = 0
	if Input.is_action_pressed("right"):
		turn += 1
	if Input.is_action_pressed("left"):
		turn -= 1
	steer_direction = turn * deg2rad(steering_angle)
	if Input.is_action_pressed("forward"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("backward"):
		acceleration = transform.x * braking
	if Input.is_action_just_pressed("attack"):
		shoot()


func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = velocity.linear_interpolate(new_heading * velocity.length(), traction)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverce)
	rotation = new_heading.angle()


func shoot():
	if can_shoot:
		can_shoot = false
		gunTimer.start()
		var dir = Vector2(1, 0).rotated(gun.global_rotation)
		emit_signal('shoot', projectile, $Gun/Muzzle.global_position, dir)


func _on_GunTimer_timeout():
	can_shoot = true
