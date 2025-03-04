extends Path2D
class_name IceSlide

@onready var player = %Player
@onready var pathfollow = $PathFollow2D
@onready var entryPoint = $PathFollow2D/EntryPoint
@onready var anim = $AnimationPlayer

@export_enum("Left", "Right") var slideDirection:String = "Right"
@export var slideSpeed = 0.3
var dir = 1	# direction set by var slideDirection

@export var exitPointRatio = 0.95 ## if slide is very long, set to 0.98 or similar

var previousPos = Vector2.ZERO
var pre_distance = 0.0 	# fuer velocity calculation zum ende
var distanceTraveled = 0.0	# distance traveled in last frame
var slideVelocity = Vector2.ZERO	# calculated velocity

var checkForPlayerEntry = false
var slideActive = false	# player is actively sliding here
var isSlideJumping = false

func _ready():
	$AnimationPlayer.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	
	previousPos = player.global_position
	if slideDirection == "Right":
		dir = 1
	else: dir = -1
	

func _process(delta):
	if slideActive:
		pathfollow.progress_ratio += delta * slideSpeed
		
		call_deferred("CalculateSlideSpeed", delta)
		
		if (pathfollow.progress_ratio >= exitPointRatio):
			EndSlide()
	elif checkForPlayerEntry:
		MoveSlideEntryAlongWithPlayer(delta)
		
	if isSlideJumping:
		SlideJumping()
		
func CalculateSlideSpeed(delta):
	var currentPos = player.global_position
	slideVelocity = (currentPos - previousPos) / delta
	print("Slide Velocity: ", slideVelocity)
	previousPos = currentPos

func MoveSlideEntryAlongWithPlayer(delta):
	if (player.global_position.x > pathfollow.global_position.x):
		pathfollow.progress_ratio += delta * dir
	elif (player.global_position.x < pathfollow.global_position.x):
		pathfollow.progress_ratio -= delta * dir
	#print("Slide Entry Point to " + str(pathfollow.global_position.x) + " Player x : " + str(player.global_position.x))

func StartSlide():
	print("Start Slide")
	checkForPlayerEntry = false
	var dir:int
	if slideDirection == "Left":
		dir = -1
	if slideDirection == "Right":
		dir = 1
	%Player.bubbleUnlocked = false
	%Player.TryResetBubble()	# if player is in bubble, force to release
	player.StartSliding(dir)
	player.SetCurrentSlope(self)
	slideActive = true
	entryPoint.set_deferred("monitoring", false)
	call_deferred("AttachPlayer")

func EndSlide():
	print("End Slide")
	%Player.canMove = true
	%Player.bubbleUnlocked = true
	call_deferred("DetachPlayer")
	player.StopSliding()
	player.SetCurrentSlope(null)
	slideActive = false
	player.StartLaunch(slideVelocity)
	$CooldownTimer.start()
	
func AttachPlayer():
	$PathFollow2D/RemoteTransform2D.StartControlling()
	
func DetachPlayer():
	$PathFollow2D/RemoteTransform2D.StopControlling()
	player.rotation = 0.0
	
func StartJump():	## player jumps on slide
	isSlideJumping = true
	
func EndJump():
	isSlideJumping = false
	
func SlideJumping():
	return
	anim.play("SlideJump")
	
func ResetSlide():
	previousPos = Vector2.ZERO
	pathfollow.progress_ratio = 0.5
	entryPoint.set_deferred("monitoring", true)
	set_deferred("checkForPlayerEntry", true)

func _on_slide_entry_point_body_entered(_body):
	StartSlide()

func _on_entry_check_body_entered(body):
	checkForPlayerEntry = true

func _on_cooldown_timer_timeout():
	ResetSlide()
