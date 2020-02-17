extends KinematicBody2D

export (int) var speed = 100

onready var Player = get_parent().get_node("Player")

var velocity = Vector2()
var Bullet = preload("res://Bullet.tscn")
var Explosion = preload("res://Explode.tscn")

var shootdelay = 800
var time = OS.get_ticks_msec() + shootdelay
var nav_time = OS.get_ticks_msec() + 1000

var path = PoolVector2Array() setget set_path

signal dead

func _ready():
	set_process(false)
	connect("dead", get_tree().get_root().get_node("World"), "count_num_enemies")

func get_input():
	if get_parent().has_node("Player"):
		$Sprite2.rotation = Player.position.angle_to_point(position) - PI/2
		$Sprite.rotation = velocity.normalized().angle() - PI/2
		$RayCast2D.rotation = $Sprite2.rotation
		
		if time < OS.get_ticks_msec():
			#shoot()
			time = OS.get_ticks_msec() + shootdelay
		if nav_time < OS.get_ticks_msec():
			set_path(get_parent().get_parent().get_parent().find_path_to_player(position, Player.position))
	else:
		velocity = Vector2(0, 0)

func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)

func shoot():
	if $RayCast2D.get_collider() == Player:
		var b = Bullet.instance()
		b.start($Sprite2.global_position + Vector2(40, 0).rotated($Sprite2.rotation + PI/2), $Sprite2.rotation + PI/2)
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
