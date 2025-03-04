extends TextureButton

func _input(event):
	if is_visible_in_tree() and event.is_action_released("MenuBack"):
		emit_signal("pressed")
