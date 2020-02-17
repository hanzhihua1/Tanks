extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func find_path_to_player(from_pos, to_pos):
	return get_node('Navigation2D').get_simple_path(from_pos,to_pos, false)
