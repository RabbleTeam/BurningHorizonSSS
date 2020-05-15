extends Node2D


func _ready():
	set_camera_limits()


func set_camera_limits():
	var map_limits = $ViewportContainer/Viewport/TestWorld/YSort/RoadOverlap.get_used_rect()
	var map_cellsize = $ViewportContainer/Viewport/TestWorld/YSort/RoadOverlap.cell_size
	$ViewportContainer/Viewport/TestWorld/Camera2D.limit_left = map_limits.position.x * map_cellsize.x
	$ViewportContainer/Viewport/TestWorld/Camera2D.limit_right = map_limits.end.x * map_cellsize.x
	$ViewportContainer/Viewport/TestWorld/Camera2D.limit_top = map_limits.position.y * map_cellsize.y
	$ViewportContainer/Viewport/TestWorld/Camera2D.limit_bottom = map_limits.end.y * map_cellsize.y


func _on_Car_shoot(projectile, _position, _direction, target):
	var p = projectile.instance()
	add_child(p)
	p.init(_position, _direction, target)
