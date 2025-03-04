extends Control

var speed = 1.0

func _process(delta):
	var viewPort = get_viewport().get_visible_rect().position
	var mousePos = get_viewport().get_mouse_position()
	var targetPos = Vector2(mousePos.x - viewPort.x, mousePos.y - viewPort.y)
	position = position.lerp(targetPos, delta * speed)
	
