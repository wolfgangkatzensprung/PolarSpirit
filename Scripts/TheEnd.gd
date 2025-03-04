extends Node2D

const END_MUSIC = preload("res://Audio/Music/240302_PolarSpiritEnd.wav")

var readyForTheEnd = true
var endStarted = false
var timerFinished = false

func _input(event):
	if timerFinished:
		if endStarted and readyForTheEnd and event.is_pressed():
			readyForTheEnd = false
			%Player.bubbleUnlocked = false
			StartEndSequence()
	
func StartEndSequence():
	print("Start End Sequence")
	$AnimationPlayer.play("TheEnd")
	
func StartEndMusic():
	AudioManager.PlayMusic(END_MUSIC)
	AudioManager.FadeInMusic(1.0)
	
func SetEndpointReached():
	$"../EndPoint".ReachEndPoint()

func _on_area_2d_body_entered(body):
	if !endStarted:
		endStarted = true
		$TheEndTimer.start()
		AudioManager.FadeOutMusic(1.0)
		%Player.canMove = false
		$Path2D_Player/PathFollow2D/RemoteTransform2D.StartControlling()
		%Player.velocity = Vector2.ZERO

func _on_the_end_timer_timeout():
	timerFinished = true
