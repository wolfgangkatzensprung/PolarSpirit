extends PathFollow2D

@export var speed = 0.5
var direction = 1

var canMove = true
var canFlip = true

func _process(delta):
	if (!canMove):
		return
	
	progress_ratio += delta * direction * speed
	
	if progress_ratio >= 1.0:
		progress_ratio = 1.0
		direction = -1
	elif progress_ratio <= 0.0:
		progress_ratio = 0.0
		direction = 1

func Flip():
	canFlip = false
	direction = -direction
	$Sprite2D.scale.x = -$Sprite2D.scale.x
	$FlipTimer.start()

func _on_flip_timer_timeout():
	canFlip = true
