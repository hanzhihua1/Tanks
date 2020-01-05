extends KinematicBody2D

var speed = 350
var velocity = Vector2()
var Explosion = preload("res://Explode2.tscn")

# Called when the node enters the scene tree for the first time.

func start(pos, dir):
	rotation = dir
	position = pos
	velocity = Vector2(speed, 0).rotated(rotation)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.collider.has_method("hit"):
			collision.collider.hit()
			queue_free()
		else:
			velocity = velocity.bounce(collision.normal)
			
func hit():
	var e = Explosion.instance()
	e.start(position)
	get_parent().add_child(e)
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
    queue_free()