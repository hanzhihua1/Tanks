extends KinematicBody2D

export (int) var speed = 100

onready var Player = get_parent().get_node("Player")

var velocity = Vector2()
var Bullet = preload("res://EnemyBullet.tscn")
var Explosion = preload("res://Explode.tscn")

var shootdelay = 500
var bulletready = true
var time = OS.get_ticks_msec() + shootdelay
var nav_time = OS.get_ticks_msec() + 500

var path = PoolVector2Array() setget set_path

func _ready():
	set_process(false)

func get_input():
	if get_parent().has_node("Player"):
		$Sprite2.rotation = Player.position.angle_to_point(position) - PI/2
		$Sprite.rotation = velocity.normalized().angle() - PI/2
		$RayCast2D3.rotation = $Sprite2.rotation
		
		if (bulletready == false) and time < OS.get_ticks_msec():
			bulletready = true
			
		aim()
		if bulletready == true:
			shoot()
			bulletready = false
			time = OS.get_ticks_msec() + shootdelay
			
		if nav_time < OS.get_ticks_msec():
			nav_time = OS.get_ticks_msec() + 500
			#velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()*speed
	else:
		velocity = Vector2(0, 0)

func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)
	
func aim():
	$RayCast2D.rotation_degrees = OS.get_ticks_msec()/30
	$RayCast2D2.global_position = $RayCast2D.get_collision_point()
	
	var angle = (position - $RayCast2D2.global_position).bounce($RayCast2D.get_collision_normal()).angle()
	$RayCast2D2.rotation = angle + PI/2

func shoot():
	if ($RayCast2D.get_collider() == Player) or ($RayCast2D2.get_collider() == Player):
		#Add some variance	
		var b = Bullet.instance()
		b.start($Sprite2.global_position + Vector2(40, 0).rotated($RayCast2D.rotation + PI/2), $RayCast2D.rotation + PI/2 + rand_range(-0.1, 0.1))
		get_parent().add_child(b)
	if ($RayCast2D3.get_collider() == Player):
		#Add some variance	
		var b = Bullet.instance()
		b.start($Sprite2.global_position + Vector2(40, 0).rotated($Sprite2.rotation + PI/2), $Sprite2.rotation + PI/2 + rand_range(-0.1, 0.1))
		get_parent().add_child(b)
	
func hit():
	var e = Explosion.instance()
	e.start(position)
	get_parent().add_child(e)
	queue_free()
	
func set_path(new_path):
	if new_path.size() == 0:
		return
	set_process(true)
	path = new_path

func _process(delta):
	move_along_path(speed * delta)
	
func move_along_path(distance):
	var start_point = position
	for i in range(path.size()):
		var distance_to_next = start_point.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0.0:
			position = start_point.linear_interpolate(path[0], distance/distance_to_next)
			break
		elif distance < 0.0:
			position = path[0]
			set_process(false)
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)
