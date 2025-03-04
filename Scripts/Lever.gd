extends Area2D

const CLICK = preload("res://Audio/SFX/Click.wav")

func Activate():
	print("Lever activated!")
	AudioManager.PlaySound(CLICK)
	queue_free()

func _on_body_entered(body):
	Activate()
