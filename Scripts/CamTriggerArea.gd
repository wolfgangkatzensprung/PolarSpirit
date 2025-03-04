extends Area2D
class_name CamTrigger

@export var pcam:PhantomCamera2D	## assigned PhantomCamera
@export var backtrackPcam:PhantomCamera2D ## Pcam to switch to after exiting this CamTrigger. Leave empty for no backtracking
@export var permanentCameraSwap = true	## if cam should stay prioritized after player exits area2d

@export var levelBorder:StaticBody2D	## Level Rand Wand taucht hinterm Player auf

static var camPriority:int = 20 # consecutively updated global highest priority

func _on_body_entered(body):
	SetPriority(pcam, camPriority)
	print(name, " entered. Priority: ", camPriority)
	if (levelBorder != null):
		call_deferred("SpawnLevelBorder")
	camPriority += 1
	print("Highest Pcam Priority set to ", camPriority)

func SpawnLevelBorder():
	levelBorder.get_child(0).disabled = false

func _on_body_exited(body):
	if $"..".endPointReached:
		return

	if !permanentCameraSwap:
		SetPriority(pcam, 0)
	elif (permanentCameraSwap):
		SetPriority(pcam, camPriority)
		
	if backtrackPcam != null:
		SetPriority(backtrackPcam, camPriority)

func SetPriority(cam, prio):
	print("Set Priority " + str(prio) + " for " + str(cam))
	cam.set_priority(prio)
