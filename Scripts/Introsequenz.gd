extends Node2D

const INTRO_MUSIC = preload("res://Audio/Music/240125_Pengu Intro.wav")

@onready var introAnims:Array = [$"Animation_Sequenz-1_Birds", $"Animation_Sequenz-2_Tryout", $"Animation_Sequenz-3_Found", $"Animation_Sequenz-4_Inside", $"Animation_Sequenz-5_Loot", $"Animation_Sequenz-6_Treasure", $"Animation_Sequenz-7_Equip", $"Animation_Sequenz-8_End"]
@onready var animNodes:Array = [$Anim1, $Anim2, $Anim3, $Anim4, $Anim5, $Anim6, $Anim7, $Anim8]
var animIndex:int = 0

signal introFinished

var cancelTimer = 0.0
var cancelTime = 1.0
var isCanceling = false

func _ready():
	AudioManager.PlayMusic(INTRO_MUSIC)
	PlaySequenz()
	
func _process(delta):
	if isCanceling:
		return

	if Input.is_action_pressed("Pause"):
		cancelTimer += delta
		print("Cancel Timer: " + str(cancelTimer))
		if cancelTimer > cancelTime:
			isCanceling = true
			FadeOut()
			$CancelFadeTimer.start()
	elif Input.is_action_just_released("Pause"):
		print("Cancel Button released")
		cancelTimer = 0.0

func EndIntro():
		print("Intro Finished!")
		introFinished.emit()

func OnAnimationFinished(_anim_name):
	if animIndex == 7:
		EndIntro()
		return
	
	animNodes[animIndex].call_deferred("set_visible", false)
	animIndex += 1
	animNodes[animIndex].set_visible(true)
	PlaySequenz()

func PlaySequenz():
	introAnims[animIndex].play("Anim" + str(animIndex + 1))

func FadeOut():
	$"../CanvasLayer/TransitionOverlay".FadeOut()

func _on_cancel_fade_timer_timeout():
	EndIntro()
