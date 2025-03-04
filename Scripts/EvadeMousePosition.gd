extends VBoxContainer

var i:float = 0.0

func _process(delta):
	var viewPort = get_viewport().get_visible_rect().size
	var mousePos = get_viewport().get_mouse_position()
	position.x = move_toward(position.x, mousePos.x - viewPort.x / 2, 100)
	position.y = move_toward(position.y, mousePos.y - viewPort.y / 2, 199)
	
	print("TEST: ", move_toward(25, 50, 10))
	i += delta
