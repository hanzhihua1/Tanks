extends KinematicBody2D

export (int) var speed = 100

onready var Player = get_parent().get_node("Player")

var velocity = Vector2()
var Bullet = preload("res://Enemies/SniperBullet.tscn")
var Explosion = preload("res://Explode.tscn")
var Bundle = preload("res://Enemies/Bundle_3raycasts.tscn")

var shootdelay = 1500
var bulletready = true
var time = OS.get_ticks_msec() + shootdelay

var num_bundles = 20

signal dead

func _ready():
	for j in range(num_bundles):
		$Turret.add_child(Bundle.instance())
	
	var i = 0
	for bundle in $Turret.get_children():
		bundle.get_node("RayCast2D").rotation_degrees = i*180/num_bundles 
		i += 1
	
	set_process(false)
	connect("dead", get_tree().get_root().get_node("World"), "count_num_enemies")

func get_input():
	if get_parent().has_node("Player"):
		
		$Sprite.rotation = velocity.normalized().angle() - PI/2
		$FollowPlayer.rotation = (position - Player.position).angle() + PI/2
		
		if (bulletready == false) and time < OS.get_ticks_msec():
			bulletready = true
			
		aim()
		if bulletready == true:
			shoot()
			bulletready = false
			time = OS.get_ticks_msec() + shootdelay
	else:
		velocity = Vector2(0, 0)

func _physics_process(delta):
	get_input()
	#velocity = move_and_slide(velocity)
	
func aim():
	var i = 0
	for bundle in $Turret.get_children():
		bundle.get_node("RayCast2D").rotation_degrees = i*180/num_bundles + $FollowPlayer.rotation_degrees - 90
		i += 1
	
	# Calculate reflection raycasts
	for bundle in $Turret.get_children():
		
		var reflect_dir = (position - bundle.get_node("RayCast2D2").global_position).bounce(bundle.get_node("RayCast2D").get_collision_normal())
		var angle = reflect_dir.angle()
		
		bundle.get_node("RayCast2D2").global_position = bundle.get_node("RayCast2D").get_collision_point() - 10*reflect_dir.normalized()
		
		bundle.get_node("RayCast2D2").rotation = angle + PI/2
	
	for bundle in $Turret.get_children():
		
		var reflect_dir = (bundle.get_node("RayCast2D2").global_position - bundle.get_node("RayCast2D3").global_position).bounce(bundle.get_node("RayCast2D2").get_collision_normal())
		var angle = reflect_dir.angle()
		
		bundle.get_node("RayCast2D3").global_position = bundle.get_node("RayCast2D2").get_collision_point() - 10*reflect_dir.normalized()
		
		bundle.get_node("RayCast2D3").rotation = angle + PI/2

func shoot():
	if ($FollowPlayer.get_collider() == Player):
		$Sprite2.rotation = Player.position.angle_to_point(position) - PI/2
		#Add some variance	
		var b = Bullet.instance()
		b.start($Sprite2.global_position + Vector2(40, 0).rotated($Sprite2.rotation + PI/2), $Sprite2.rotation + PI/2)
		get_parent().add_child(b)
		return
	for bundle in $Turret.get_children():
		if (bundle.get_node("RayCast2D2").get_collider() == Player):
			$Sprite2.rotation = bundle.get_node("RayCast2D").rotation
			#Add some variance	
			var b = Bullet.instance()
			b.start($Sprite2.global_position + Vector2(40, 0).rotated(bundle.get_node("RayCast2D").rotation + PI/2), bundle.get_node("RayCast2D").rotation + PI/2)
			get_parent().add_child(b)
			return
		if (bundle.get_node("RayCast2D3").get_collider() == Player):
			$Sprite2.rotation = bundle.get_node("RayCast2D").rotation
			#Add some variance	
			var b = Bullet.instance()
			b.start($Sprite2.global_position + Vector2(40, 0).rotated(bundle.get_node("RayCast2D").rotation + PI/2), bundle.get_node("RayCast2D").rotation + PI/2)
			get_parent().add_child(b)
			return
	
	
	$Sprite2.rotation = Player.position.angle_to_point(position) - PI/2

	
func hit():
	emit_signal("dead")
	var e = Explosion.instance()
	e.start(position)
	get_parent().add_child(e)
	queue_free()

