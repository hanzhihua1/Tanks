extends Node2D
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.

export var num_enemies = 3

func _ready():
	Game.level = 2
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func find_path_to_player(from_pos, to_pos):
	return get_node('Navigation2D').get_simple_path(from_pos,to_pos, false)
	
func count_num_enemies():
	num_enemies -= 1
	if num_enemies == 0:
		$Timer.start()
		$UI/Label.visible = true
		


func _on_Timer_timeout():
	get_tree().change_scene("res://Levels/World3.tscn")

func restart_scene():
	if Game.lives > 0:
		Game.lives -= 1
		$UI/Label.text = 'You Lose!'
		$UI/Label.visible = true
		var t = Timer.new()
		t.set_wait_time(2)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		get_tree().reload_current_scene()
	else:
		$UI/Label.text = 'Game Over'
		$UI/Label.visible = true
		var t = Timer.new()
		t.set_wait_time(2)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		Game.lives = 3
		Game.level = 1
		get_tree().change_scene("res://Levels/World1.tscn")
