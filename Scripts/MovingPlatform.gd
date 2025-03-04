extends Node2D

const platformSprite = preload("res://Sprites/hs_contactAmovingplatform01_b_.png")
const activatedPlatformSprite = preload("res://Sprites/hs_contactBmovingplatform01_b.png")

const PLATFORM_START = preload("res://Audio/SFX/PlatformStart.wav")

@onready var pathfollow = $PathFollow2D

@export var speed = 0.5
@export var contactTrigger = false
@export var deactivateOnExit = false

var triggered = false

func _ready():
	if contactTrigger:
		SetDisabled()

func _process(delta):
	if contactTrigger and not triggered:
			return
	
	pathfollow.progress_ratio += delta * speed
	if (speed > 0 and pathfollow.progress_ratio >= 0.95):
		speed *= -1
	elif speed < 0 and pathfollow.progress_ratio <= 0.05:
		speed *= -1

func SetDisabled():
	$AnimatableBody2D/Sprite2D.modulate = Color(.5, .7, .9, 1.0)
	$AnimatableBody2D/Sprite2D.texture = platformSprite
func SetEnabled():
	AudioManager.PlayLocalSound(PLATFORM_START, $AnimatableBody2D.global_position)
	$AnimatableBody2D/Sprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)
	$AnimatableBody2D/Sprite2D.texture = activatedPlatformSprite

func _on_area_2d_body_entered(_body):
	triggered = true
	if contactTrigger:
		SetEnabled()

func _on_area_2d_body_exited(_body):
	if contactTrigger:
		if deactivateOnExit:
			triggered = false
			SetDisabled()
