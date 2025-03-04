extends GPUParticles2D

@onready var collision_shape_2d = $"../CollisionShape2D"
@export var velocityFactor = 2.0	## windStrength multiplied by this 

func _ready():
	process_material = process_material.duplicate()

func SetDirection(d):
	process_material.direction = d
	print("Wind Particles Direction: ", process_material.direction)

func SetVelocity(v):
	process_material.initial_velocity_min = v * velocityFactor
	print("Wind Particles Velocity: ", process_material.initial_velocity_min)
	
func SetNoiseSpeed(v:Vector3):
	process_material.turbulence_noise_speed = v
	
