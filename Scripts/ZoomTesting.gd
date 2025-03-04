extends Node2D

@onready var pcam:PhantomCamera2D = $PhantomCamera2D

var zoomSpeed = 0.05
var moveSpeed = 1000.0

func _process(delta):
	var moveX = Input.get_axis("Left", "Right")
	var moveY = Input.get_axis("Up", "Down")
	pcam.position.x += moveX * moveSpeed * delta
	pcam.position.y += moveY * moveSpeed * delta
	
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
				var zoomStrength = 1.0
				zoom(zoomStrength)
			# zoom out
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
				var zoomStrength = -1.0
				zoom(zoomStrength)

func zoom(delta_zoom):
	var zoom = delta_zoom * zoomSpeed
	pcam.camera_zoom += Vector2(zoom, zoom)

