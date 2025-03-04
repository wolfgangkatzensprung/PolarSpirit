extends AnimationPlayer

@export var firstAnimation:String = "Start"
@export var secondAnimation:String = "End"

func PlayFirstAnimation(_b):
	play(firstAnimation)
	
func PlaySecondAnimation(_b):
	play(secondAnimation)

func PlayFirstAnimationBackward(_b):
	play_backwards(firstAnimation)
