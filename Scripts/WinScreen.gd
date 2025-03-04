extends CanvasLayer

func _input(event):
	if event.is_action_released("Pause"):
		get_tree().reload_current_scene()
