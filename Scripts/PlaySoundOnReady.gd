extends Node2D

const YAY_SOUND = preload("res://Audio/SFX/YaySound.wav")

func _ready():
	AudioManager.PlaySound(YAY_SOUND)
