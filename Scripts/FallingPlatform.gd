extends StaticBody2D

const FALLING_PLATFORM = preload("res://Audio/SFX/FallingPlatform.wav")
const P_APPEARING_PLATFORM_PARTICLES = preload("res://Assets/Particles/P_Appearing_Platform_Particles.tscn")

@export var cantRespawn = false

func _on_area_2d_body_entered(body):
	print("Falling Platform Fall")
	$AnimationPlayer.play("Fall")
	
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

func FallSound():
	AudioManager.PlaySound(FALLING_PLATFORM)
