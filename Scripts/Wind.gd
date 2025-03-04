extends Area2D
class_name Wind

@onready var particles = $GPUParticles2D

@export var windForce : Vector2 = Vector2(100, 0)

var physicalStrength = 200.0 ## factor for Rigidbody interactions

func _ready():
	var dir = Vector3(windForce.x, windForce.y, 0.0).normalized()
	dir = dir.rotated(Vector3.FORWARD, rotation)
	particles.SetDirection(dir)
	particles.SetVelocity(windForce.length())
	particles.rotation 
	particles.SetNoiseSpeed(dir)

func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Windable"):
			if (body.has_method("apply_central_force")):	# for Rigidbodies
				body.apply_central_force(windForce * delta * physicalStrength)
				
func _on_body_entered(body):
	if body.is_in_group("Windable"):
		if (body.has_method("SetWindStrength")):
			body.SetWindStrength(windForce)
		if body.has_method("EnterWind"):
			body.EnterWind(self)

func _on_body_exited(body):
	if body.is_in_group("Windable"):
		if (body.has_method("SetWindStrength")):
			body.SetWindStrength(Vector2.ZERO)
		if body.has_method("LeaveWind"):
			body.LeaveWind(self)
