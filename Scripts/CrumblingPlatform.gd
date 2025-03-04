extends StaticBody2D

const CRUMBLING_PLATFORM = preload("res://Audio/SFX/CrumblingPlatform.wav")
const P_APPEARING_PLATFORM_PARTICLES = preload("res://Assets/Particles/P_Appearing_Platform_Particles.tscn")

@export var cantRespawn = false

func _on_area_2d_body_entered(body):
	AudioManager.PlaySound(CRUMBLING_PLATFORM)
	$AnimationPlayer.play("Crumble")
	
func Respawn():
	if cantRespawn:
		return
		
	var respawnParticles = P_APPEARING_PLATFORM_PARTICLES.instantiate()
	add_child(respawnParticles)
	respawnParticles.global_position = global_position
	respawnParticles.emitting = true
	for child in respawnParticles.get_children():
		if child.has_method("set_emitting"):
			child.set_emitting(true)
	
	$AnimationPlayer.play("Respawn")
	$Area2D.monitoring = true
