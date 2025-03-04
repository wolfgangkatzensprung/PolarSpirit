extends Node2D

@export var shakeMagnitude : float = 0.1
@export var shakeSpeed : float = 5.0

var startPos:Vector2

func _ready():
	startPos = position

func _process(delta):
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	var noiseX = noise.get_noise_2d($ShakeTimer.time_left * shakeSpeed, 0.0)
	var noiseY = noise.get_noise_2d(0.0, $ShakeTimer.time_left * shakeSpeed)
		
	var offset = Vector2(shakeMagnitude * randf_range(-noiseX, noiseX), shakeMagnitude * randf_range(-noiseY, noiseY))
	position = startPos + offset
	
func _on_shake_timer_timeout():
	$ShakeTimer.start()
