extends Node2D

const P_STAR_PARTICLES = preload("res://Assets/Particles/P_StarParticles.tscn")

func UnlockBubble():
	%Player.bubbleUnlocked = true
	var particles = P_STAR_PARTICLES.instantiate()
	%Player.add_child(particles)
	particles.global_position = %Player.global_position
	particles.emitting = true

func _on_dialog_trigger_body_exited(body):
	UnlockBubble()
