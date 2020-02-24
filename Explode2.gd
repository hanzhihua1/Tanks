extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var anim_finished = false
var sound_finished = false

# Called when the node enters the scene tree for the first time.
func start(pos):
	$AnimatedSprite.position = pos
	$AnimatedSprite.frame = 0
	$Explode.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _process(delta):
	if sound_finished and anim_finished:
		queue_free()


func _on_AnimatedSprite_animation_finished():
	anim_finished = true
	$AnimatedSprite.visible = false


func _on_Explode_finished():
	sound_finished = true
