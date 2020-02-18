extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	showlevel()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Life.text = "Lives : "+str(Game.lives)
	$Level.text = "Level "+str(Game.level)

func showlevel():
	$ShowLevel.start()
	$Level.visible = true

func _on_ShowLevel_timeout():
	$Level.visible = false
