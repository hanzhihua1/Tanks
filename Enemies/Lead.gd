extends KinematicBody2D

export (int) var speed = 75

onready var Player = get_parent().get_node("Player")

var velocity = Vector2()
var Bullet = preload("res://Enemies/TrainingBullet.tscn")
var Explosion = preload("res://Explode.tscn")
var Bundle = preload("res://Enemies/Bundle_2raycasts.tscn")

var shootdelay = 500
var bulletready = true
var pathready = false
var time = OS.get_ticks_msec() + shootdelay
var nav_time = OS.get_ticks_msec() + 500
var state = 'pathing'

var life = 1
var num_bundles = 15

var path = PoolVector2Array() setget set_path

signal dead

func _ready():
	"""
	for j in range(num_bundles):
		$Turret.add_child(Bundle.instance())
		
	
	var i = 0
	for bundle in $Turret.get_children():
		bundle.get_node("RayCast2D").rotation_degrees = i*180/num_bundles
		i += 1
	"""
	
	set_process(false)
	connect("dead", get_tree().get_root().get_node("World"), "count_num_enemies")

func get_input():
	if get_parent().has_node("Player"):
		
		$FollowPlayer.rotation = Player.position.angle_to_point(position) - PI/2
		
		if (bulletready == false) and time < OS.get_ticks_msec():
			bulletready = true
			
		aim()
		if bulletready == true:
			shoot()
			bulletready = false
			time = OS.get_ticks_msec() + shootdelay
			
		if nav_time < OS.get_ticks_msec():
			nav_time = OS.get_ticks_msec() + 500
			if ($FollowPlayer.get_collider() == Player):
				velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()*speed
				$Sprite.rotation = velocity.normalized().angle() - PI/2
				state = 'random'
			else:
				set_path(get_parent().get_parent().get_parent().find_path_to_player(position, Player.position))
				$Sprite.rotation = (path[1] - path[0]).angle() - PI/2
				state = 'pathing'
	else:
		state = 'random'
		velocity = Vector2(0, 0)

func _physics_process(delta):
	get_input()
	if state == 'random':
		#velocity = move_and_slide(velocity)
		pass
	
func aim():
	$Lead.rotation = lead_shot().angle_to_point(position) - PI/2
	
	var i = 0
	var reflect_dir
	var angle
	
	"""
	for bundle in $Turret.get_children():
		bundle.get_node("RayCast2D").rotation_degrees = i*180/num_bundles + $FollowPlayer.rotation_degrees - 90
		i += 1
	
	for bundle in $Turret.get_children():
		
		reflect_dir = (position - bundle.get_node("RayCast2D2").global_position).bounce(bundle.get_node("RayCast2D").get_collision_normal())
		angle = reflect_dir.angle()
		
		bundle.get_node("RayCast2D2").global_position = bundle.get_node("RayCast2D").get_collision_point() - 10*reflect_dir.normalized()
		

		bundle.get_node("RayCast2D2").rotation = angle + PI/2
	"""

func shoot():
	if ($FollowPlayer.get_collider() == Player):
		print(Player.velocity)
		var aim_vec = lead_shot()
		
		$Lead.rotation = lead_shot().angle_to_point(position) - PI/2
		$Sprite2.rotation = $Lead.rotation
		var b = Bullet.instance()
		b.start($Sprite2.global_position + Vector2(40, 0).rotated($Lead.rotation + PI/2), $Lead.rotation + PI/2)
		get_parent().add_child(b)
		return
	"""
	for bundle in $Turret.get_children():
		if (bundle.get_node("RayCast2D2").get_collider() == Player):
			$Sprite2.rotation = bundle.get_node("RayCast2D").rotation
			#Add some variance	
			var b = Bullet.instance()
			b.start($Sprite2.global_position + Vector2(40, 0).rotated(bundle.get_node("RayCast2D").rotation + PI/2), bundle.get_node("RayCast2D").rotation + PI/2 + rand_range(-0.15, 0.15))
			get_parent().add_child(b)
			return
	"""
	$Sprite2.rotation = Player.position.angle_to_point(position) - PI/2

	
func hit():
	var e = Explosion.instance()
	e.start(position)
	get_parent().add_child(e)
	if life == 0:
		emit_signal("dead")
		queue_free()
	else: 
		life -= 1
	
func set_path(new_path):
	if new_path.size() == 0:
		return
	set_process(true)
	path = new_path

func _process(delta):
	if state == 'pathing':
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

func lead_shot():
	var bullet_speed = 350
	var a = pow(Player.velocity.x,2) + pow(Player.velocity.y,2) - pow(bullet_speed,2)
	var b = 2*(Player.velocity.x * (Player.position.x - position.x) + Player.velocity.y*(Player.position.y - position.y))
	var c = pow(Player.position.x - position.x, 2) + pow(Player.position.y - position.y, 2)
	var disc = pow(b,2) - 4*a*c
	
	if disc < 0:
		return
	
	var t1 = (-b + sqrt(disc)) / (2 * a)
	var t2 = (-b - sqrt(disc)) / (2 * a)
	
	if t1 < 0 and t2 < 0:
		return
	if t1 > 0 and t2 < 0:
		var aim = t1*Player.velocity + Player.position
		return aim
	if t2 > 0 and t1 < 0:
		var aim = t2*Player.velocity + Player.position
		return aim
	if t1 > 0 and t2 > 0:
		if t1 < t2:
			var aim = t1*Player.velocity + Player.position
			return aim
		else:
			var aim = t2*Player.velocity + Player.position
			return aim
	if t1 == t2:
		var aim = t1*Player.velocity + Player.position
		return aim
		
	
	
