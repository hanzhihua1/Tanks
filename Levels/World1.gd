extends Node2D
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
var num_enemies = 3
signal level_complete

func _ready():
	connect('level_complete', get_tree().get_root().get_node('Game'), "next_level")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func find_path_to_player(from_pos, to_pos):
	return get_node('Navigation2D').get_simple_path(from_pos,to_pos, false)
	
func count_num_enemies():
	num_enemies -= 1
	if num_enemies == 0:
		print('level complete')
		emit_signal("level_complete")
		get_tree().change_scene("res://Levels/World2.tscn")
