extends KinematicBody2D

export (int) var speed = 200

var velocity = Vector2()
var Bullet = preload("res://Bullet.tscn")
var Explosion = preload("res://Explode.tscn")
var MAX_BULLETS = 5

signal dead

func get_input():
	$Sprite2.rotation = get_global_mouse_position().angle_to_point(position) - PI/2
	velocity = Vector2()
	if Input.is_action_pressed('right'):
	    velocity.x += 1
	if Input.is_action_pressed('left'):
	    velocity.x -= 1
	if Input.is_action_pressed('down'):
	    velocity.y += 1
	if Input.is_action_pressed('up'):
	    velocity.y -= 1
	velocity = velocity.normalized() * speed
	$Sprite.rotation = velocity.normalized().angle() - PI/2
	if Input.is_action_just_pressed("click"):
		var all_bullets = get_tree().get_nodes_in_group("bullets")
		print(all_bullets)
		if len(all_bullets) < MAX_BULLETS:
			shoot()

func _physics_process(delta):
    get_input()
    velocity = move_and_slide(velocity)

func shoot():
	var b = Bullet.instance()
	b.add_to_group('bullets')
	b.start($Sprite2.global_position + Vector2(40, 0).rotated($Sprite2.rotation + PI/2), $Sprite2.rotation + PI/2)
	get_parent().add_child(b)
	
func hit():
	var e = Explosion.instance()
	e.start(position)
	get_parent().add_child(e)
	emit_signal("dead")
	queue_free()