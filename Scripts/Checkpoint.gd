extends Area2D
class_name Checkpoint

const CHECKPOINT = preload("res://Audio/SFX/CheckpointGong.wav")
@onready var particleBurst = $P_CheckPoint/ActivationParticles

@export var setPcam:PhantomCamera2D ## pcam to set when checkpoint is triggered

func _on_body_entered(body):
	if $"..".GetCheckpointPos() != global_position:
		$"..".SetCheckpoint(self)

func Activate():
	AudioManager.PlaySound(CHECKPOINT)
	particleBurst.emitting = true
	$PointLight2D_Activation.visible = true
	if setPcam != null:
		call_deferred("SetPcam")
	$"..".SavePengus()

func SetPcam():
	CamTrigger.camPriority += 1
	setPcam.set_priority(CamTrigger.camPriority)
	print("Checkpoint set Pcam " + str(setPcam) + " Priority to " + str(CamTrigger.camPriority))
