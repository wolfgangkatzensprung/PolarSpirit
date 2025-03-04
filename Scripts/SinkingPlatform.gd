extends Node2D

func StartSinking(_body):
	$AnimationPlayer.play("SinkingPlatform")

func Reset(_body):
	$AnimationPlayer.play_backwards("SinkingPlatform")
