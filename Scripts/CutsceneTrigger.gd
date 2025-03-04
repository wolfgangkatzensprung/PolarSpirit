extends Area2D

@onready var player = %Player
var movePlayer = false
var applyGravity = false

func _physics_process(delta):
	if movePlayer:
		player.MoveByExternal(1.0)	# move player to the right
		player.move_and_slide()
	if applyGravity:
		player.GravityByExternal(delta)

func _on_body_entered(body):
	print("Play Level 1 Cutscene")
	$AnimationPlayer.play("CutsceneLevel1")
	player.SetState(player.PlayerState.IDLE)
	player.StopMovement()
	player.canMove = false
	player.isInCutscene = true
	
func StartMovePlayer():
	player.SetDisabled()
	movePlayer = true

func EndMovePlayer():
	movePlayer = false
	
func StartJumpPlayer():
	player.StartJump()

func EndJumpPlayer():
	player.ResetJump()
	applyGravity = true
