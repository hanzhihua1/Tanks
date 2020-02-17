extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var lives = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Player_dead():
	if lives > 0:
		lives -= 1
		
		var t = Timer.new()
		t.set_wait_time(2)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		get_tree().reload_current_scene()
	else:
		print('gameover')

func next_level():
	# Remove the current level
	
	#get_tree().change_scene("res://Levels/World2.tscn")
