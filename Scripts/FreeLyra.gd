extends Node2D

const P_FREE_PENGUIN = preload("res://Assets/Particles/P_FreePenguin.tscn")

func _on_dialog_trigger_start_body_entered(body):
	var particles = P_FREE_PENGUIN.instantiate()
	$"../Fairy_DialogueStart".add_child(particles)
	particles.position = Vector2.ZERO
	particles.emitting = true
	for pChild in particles.get_children():
		if pChild.has_method("set_emitting"):
			pChild.set_emitting(true)
	
	$"../Fairy_Frozen".set_visible(false)
	$"../Fairy_DialogueStart".set_visible(true)
