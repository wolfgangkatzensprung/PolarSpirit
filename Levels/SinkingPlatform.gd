extends Node2D

var sinking = false
var resetting = false
var playerOnPlatform = false

func StartSinking():
	sinking = true
	$AnimationPlayer.play("SinkingPlatform")

func Reset():
	resetting = true
	$AnimationPlayer.play("ResetSinkingPlatform")

func Wobble():
	$AnimationPlayer.play("Wobble")

func _on_area_2d_body_entered(_body):
	playerOnPlatform = true
	if not sinking and not resetting:
		StartSinking()

func _on_area_2d_body_exited(_body):
	playerOnPlatform = false
	if not sinking:
		Reset()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "SinkingPlatform":
		sinking = false
		if not playerOnPlatform:
			Reset()
	elif anim_name == "ResetSinkingPlatform":
		resetting = false
		if playerOnPlatform:
			StartSinking()
		else:
			Wobble()
