extends Sprite2D

# Arrow keys move the player. Change the speed and press F5 to try it!
@export var speed := 250.0

func _process(delta):
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += dir * speed * delta
