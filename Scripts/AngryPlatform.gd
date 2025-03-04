extends Path2D

@onready var pathfollow = $PathFollow2D
@onready var raycast = $PathFollow2D/RayCast2D

@export var speed = 0.5
@export var crushDistance = 40.0 ## should crush player when distance to ceiling is lower than this

var triggered = false
var playerOnPlatform = false

func _process(delta):
	if triggered:
		var distanceToCeiling = abs(pathfollow.global_position - raycast.get_collision_point())
		if distanceToCeiling < crushDistance and playerOnPlatform:
			%Player.ApplyDamage(10)

func _on_area_2d_body_entered(body):
	playerOnPlatform = true
	
	if !triggered:
		$AnimationPlayer.play("AngryPlatform")
		triggered = true

func _on_area_2d_body_exited(body):
	playerOnPlatform = false
