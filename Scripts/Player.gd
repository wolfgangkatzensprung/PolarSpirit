extends CharacterBody2D

#region Particles and Animations
const WALK_DUST = preload("res://Anim/WalkDust.tscn")
const JUMP_DUST = preload("res://Assets/VFX/JumpDust.tscn")
#const P_JUMP = preload("res://Assets/Particles/P_Jump.tscn")
const JUMP_START_DUST_ANIM = preload("res://Assets/Particles/JumpStartDustAnim.tscn")
const P_BUBBLE_JUMP = preload("res://Assets/Particles/P_BubbleJump.tscn")
#endregion

#region Sounds
const BUBBLE_JUMP = preload("res://Audio/SFX/BubbleJump.wav")
const RND_JUMP_SOUND = preload("res://Audio/SFX/Rnd_JumpSound.tres")
const RND_LAUNCH_SOUND = preload("res://Audio/SFX/Rnd_LaunchSound.tres")
const PLAYER_DEATH = preload("res://Audio/SFX/PlayerDeath.wav")
#endregion

@onready var bubbles = $Bubbles	# Bubble Holder Node
@onready var debugLabel = $"Debug Label"

#region Jump
var startGravity:float = ProjectSettings.get_setting("physics/2d/default_gravity")	# default gravity unchanged
var jumpGravity:float = startGravity

# after-grounded jump
@export var afterJump_time := 0.12	## how long after being grounded can player still jump
var afterJump_timer := 0.0	# descending

# pre-grounded jump
@export var preJump_time := 0.14	## how long before being grounded will players jump still count
var preJump_timer := 0.0

# jump height
var isJumping = false
@export var jumpVelocity := -900.0	## initial jump velocity right when jump button is pressed
@export var jumpPower := 66.0	## jump accelerates with this power when player holds jump button
@export var deltaJumpPower := 15.0	## how much jump power deccelerates when player holds jump button 
var currentJumpPower = jumpPower
var jumpTimer := 0.0
@export var max_jump_time := 0.23	## how long can player hold space to jump up

@export var jumpGravityMultiplier:float = 2.0	## gravity multiplier when jumping

var highJump = false	# if player holds jump to make a really high jump
#endregion

#region Fly
@export var startFlyVelocity:float = -420.0	## Player starts flying with this y velocity
var startFlyGravity:float = startGravity * 0.5
var flyGravity:float = startFlyGravity
@export var maxFlyVelocity:float = 550.0 ## maximum upward y velocity when flying
@export var maxFlyDownVelocity:float = 200.0
#endregion

#region Speed Variables
@export var speed := 330.0	## run speed
@export var bubbleJumpVelocity := -1600.0	## jump velocity when jumping on a bubbled enemy
@export var bubbleDrag := 0.5	## drag applied to Player when flying in Bubble
#endregion

#region State Variables
var facing:int = 1	# facing direction. -1 = left ; 1 = right

var canBeDamaged = true
var canMove = true
var canJump = true
var canBubble = true
var canDash = true

var isFlying = false
var isSliding = false	# disable physics process and process#
var isLaunched = false	# moved by external impulse
var isDashing = false
var isFalling = false
var isInWind = false

var isInCutscene = false

var dead = false
var enabled = true
var levelCompleted = false

@export var dashUnlocked = false
@export var bubbleUnlocked = true

enum PlayerState {
	NONE,
	IDLE,
	RUN,
	TOJUMP,
	JUMP,
	FALL,
	LAND,
	TOIDLE,
	FLY,
	TOSLIDE,
	SLIDE,
	DASH,
	DEATH,
	LEVELCOMPLETED
}
var currentState = PlayerState.IDLE
var queuedState = PlayerState.NONE	# next state. only 1 state can be in queue
#endregion

#region Special Velocity Variables
var windStrength := Vector2.ZERO # current Wind strength
var winds:Array[Wind] = []

var launchVelocity := Vector2.ZERO
@export var launchDrag := 0.1	## drag applied to player's movement while launched

@export var dashSpeed = 230.0	## velocity of dash
var dashDirection = 1
#endregion

var currentIceSlide:IceSlide

#region Health
@export var maxHealth:int = 1
var currentHealth:int = maxHealth

signal healthChanged
signal death
#endregion

func _ready():
	$AnimatedSprite2D.play("Idle")

#func _input(event):
	#if Input.is_action_just_pressed("Godmode"):
		#currentHealth = 999
		#PerformLevelCompletion()

func _process(delta):
	if isSliding:
		if Input.is_action_just_pressed("Jump") and canJump:
			StartSlideJump()
	
	HandleRaycast()
	CalculateAnimationState()
	PlayCurrentAnimation()

func _physics_process(delta):
	if dead:
		velocity.y += jumpGravity * delta	
	else:
		if isSliding or not enabled:
			return
		elif isLaunched:
			Launching(delta)
			HandleDash(delta)
			return
			
		if canMove:
			if (!isSliding and isFlying):
				BubbleFly(delta)
				
			HandleDash(delta)
			
			if (!isDashing):
				if (canJump):
					HandleJump(delta)
				if (!isFlying):
					HandleMovement()
					if isInWind:
						velocity.y += jumpGravity * jumpGravityMultiplier * delta + windStrength.y * .5
					else:
						if highJump:
							velocity.y += jumpGravity * .5 * delta
						else:
							velocity.y += jumpGravity * jumpGravityMultiplier * delta
				elif (isFlying):
					HandleBubbleMovement(delta)
				
			if velocity.y < -maxFlyVelocity:
				velocity.y = move_toward(velocity.y, -maxFlyVelocity, 30.0)
				#print("Limit Y Velocity tdo ", velocity.y)
		else:
			velocity.y += (jumpGravity + jumpGravityMultiplier) * delta
	
	move_and_slide()
	HandleCollisions()

func CalculateAnimationState(): # check if player should idle or run
	if isSliding or isDashing or isFlying or isLaunched or isFalling or dead or levelCompleted:
		return
	
	if (velocity.x != 0 and is_on_floor()):	# RUN
		SetState(PlayerState.RUN)
	elif (velocity.x == 0 and velocity.y == 0):	# IDLE
		if currentState != PlayerState.IDLE and currentState != PlayerState.LAND:
			SetState(PlayerState.TOIDLE)
			QueueState(PlayerState.IDLE)

func SetState(newState):
	if currentState != newState:
		currentState = newState

func QueueState(nextState):	## Pass PlayerState.NONE to clear queue
	queuedState = nextState

func SetIdleState():
	currentState = PlayerState.IDLE
	queuedState = PlayerState.NONE

func PlayCurrentAnimation():
	if currentState == PlayerState.DEATH:
		PlayAnimation("Death")
	else:
		match currentState:
			PlayerState.TOIDLE:
				PlayAnimation("ToIdle")
			PlayerState.IDLE:
				PlayAnimation("Idle")
			PlayerState.RUN:
				if $AnimatedSprite2D.get_animation() == "Idle":
					var walkDust = WALK_DUST.instantiate()
					get_parent().add_child(walkDust)
					if (facing < 0):
						walkDust.global_position = $WalkDustPosL.global_position
						walkDust.flip_h = true
					else:
						walkDust.global_position = $WalkDustPosR.global_position
					walkDust.play("WalkDust")
				PlayAnimation("Run")
				if not $Footsteps.is_playing():
					$Footsteps.play()
			PlayerState.TOJUMP:
				PlayAnimation("ToJump")
			PlayerState.JUMP:
				PlayAnimation("Jump")
			PlayerState.FALL:
				PlayAnimation("Fall")
			PlayerState.LAND:
				PlayAnimation("Land")
			PlayerState.FLY:
				PlayAnimation("BubbleFly")
			PlayerState.TOSLIDE:
				PlayAnimation("ToSlide")
			PlayerState.SLIDE:
				PlayAnimation("Slide")
			PlayerState.DASH:
				PlayAnimation("Dash")
			PlayerState.LEVELCOMPLETED:
				PlayAnimation("LevelCompleted")
			
	debugLabel.text = $AnimatedSprite2D.animation

func PlayAnimation(animation):
	if $AnimatedSprite2D.get_animation() != animation:
		print("Play ", animation, " animation.")
		$AnimatedSprite2D.play(animation)

func PlayLevelCompletedAnimation():
	SetState(PlayerState.LEVELCOMPLETED)

func PerformLevelCompletion():
	print("Perform Level Completion")
	levelCompleted = true
	SetState(PlayerState.IDLE)
	$AnimationPlayer.play("LevelCompleted")

func HandleRaycast():
	if dead:
		return
	var raycastLength = ($RayCast2D.get_collision_point() - $RayCast2D.global_position).length()
	FallingCheck(raycastLength)
	if isFalling and is_on_floor():
		Land()
		isFalling = false
	
func FallingCheck(raycastLength):
	if raycastLength > 5.0 and !isFalling and velocity.y > 0.0:
		await get_tree().process_frame	# wait for bubble fly reset
		call_deferred("StartFalling")	

func StartFalling():
	print("a) Player Start Falling")
	if !isFlying and !isSliding and !dead:
		SetState(PlayerState.FALL)
		QueueState(PlayerState.LAND)
	isFalling = true

func Land():
	print("LAND")
	SetState(PlayerState.LAND)
	QueueState(PlayerState.TOIDLE)
	var jumpDust = JUMP_DUST.instantiate()
	get_parent().add_child(jumpDust)
	jumpDust.global_position = $FootPos.global_position
	jumpDust.play("JumpDust")

func HandleMovement():
	var direction = Input.get_axis("Left", "Right")
	if (direction != 0):
		facing = sign(direction)
		direction = facing
		#velocity.x = direction * speed
		velocity.x = move_toward(velocity.x, direction * speed + windStrength.x, speed * .5)
		if (direction > 0 and $AnimatedSprite2D.scale.x < 0) or (direction < 0 and $AnimatedSprite2D.scale.x > 0):
			$AnimatedSprite2D.scale.x *= -1
	else:
		velocity.x = move_toward(velocity.x, 0 + windStrength.x, speed * .15)

func MoveByExternal(dir):	# move by external script
	velocity.x = move_toward(velocity.x, dir * speed, speed * .5)
func GravityByExternal(delta):
	velocity.y += (jumpGravity + jumpGravityMultiplier) * delta
func StopMovement():
	velocity.x = 0.0

func HandleBubbleMovement(delta):
	var direction = Input.get_axis("Left", "Right")
	
	if (direction != 0):
		facing = sign(direction)
		direction = facing
		if isInWind:
			velocity.x += speed * direction * delta + windStrength.x
		else:
			velocity.x = move_toward(velocity.x, direction * bubbleDrag * speed, abs(direction) * bubbleDrag * speed)
			
		if (direction > 0 and $AnimatedSprite2D.scale.x < 0) or (direction < 0 and $AnimatedSprite2D.scale.x > 0):
			$AnimatedSprite2D.scale.x *= -1
	elif direction == 0:	# no input pressed
		if isInWind:
			velocity.x += windStrength.x
		else:
			velocity.x = move_toward(velocity.x, 0, abs(velocity.x) * speed * .0002 )  
	
	print("Player BubbleFly Horizontal Movement: x = " + str(velocity.x))
	
func HandleJump(delta):	
	if not is_on_floor() and not isFlying and not Input.is_action_pressed("Jump"):
		velocity.y += jumpGravity * delta
	elif is_on_floor():
		afterJump_timer = afterJump_time
		isJumping = false
		
	if afterJump_timer > 0.0:
		afterJump_timer -= delta
	else:
		afterJump_timer = 0.0

	if Input.is_action_just_pressed("Jump"):
		if (is_on_floor() or afterJump_timer > 0):
			StartJump()
		else:
			preJump_timer = preJump_time
		
	if Input.is_action_pressed("Jump"):
		if isJumping:
			velocity.y -= currentJumpPower * delta
			currentJumpPower -= deltaJumpPower
			#print("JumpPower: ", currentJumpPower)
		else:
			preJump_timer -= delta
			if (preJump_timer > 0 and is_on_floor()):
				StartJump()
	if Input.is_action_just_released("Jump") or is_on_ceiling():
		ResetJump()
	
	if (isJumping):
		jumpTimer += delta
		if jumpTimer >= max_jump_time:
			if Input.is_action_pressed("Jump"):
				highJump = true
			ResetJump()

func StartJump():
	AudioManager.PlaySound(RND_JUMP_SOUND)
	SetState(PlayerState.TOJUMP)
	QueueState(PlayerState.JUMP)
	
	#var jumpStartDustAnim = JUMP_START_DUST_ANIM.instantiate()
	#get_parent().add_child(jumpStartDustAnim)
	#jumpStartDustAnim.global_position = $FootPos.global_position
	
	#var jumpParticles = P_JUMP.instantiate()
	#get_parent().add_child(jumpParticles)
	#jumpParticles.global_position = $FootPos.global_position
	#jumpParticles.set_emitting(true)
	
	ResetBubbleFly()
	currentJumpPower = jumpPower
	velocity.y = jumpVelocity
	isJumping = true
	afterJump_timer = 0
	preJump_timer = 0

func ResetJump():	# when maximum jump time is reached
	if !isFalling:
		$AirTimeTimer.start()
	isJumping = false
	jumpTimer = 0

func BubbleJump():	# bounce from BubbledEnemy
	AudioManager.PlaySound(RND_JUMP_SOUND)
	AudioManager.PlaySound(BUBBLE_JUMP)
	var bubbleJumpParticles = P_BUBBLE_JUMP.instantiate()
	$"..".add_child(bubbleJumpParticles)
	bubbleJumpParticles.global_position = $FootPos.global_position
	bubbleJumpParticles.emitting = true
	TryResetBubble()	# if player is in bubble, force to release
	SetState(PlayerState.JUMP)
	velocity.y = bubbleJumpVelocity

func HandleDash(delta):
	if (canDash and Input.is_action_just_pressed("Dash")):
		StartDash()
	elif (isDashing):
		Dashing(delta)

func StartDash():
	if (!dashUnlocked):
		return
	
	SetState(PlayerState.DASH)
	canDash = false
	canMove = false
	$DashTimer.start()
	$DashCooldown.start()
	isDashing = true
	dashDirection = Input.get_axis("Left", "Right")
	if (dashDirection == 0):
		dashDirection = facing

func Dashing(delta):
	#print("Dashing ", dashDirection)
	velocity.x += dashDirection * dashSpeed * delta

func BubbleFly(delta):
	if (velocity.y > 0.0 and velocity.y > maxFlyDownVelocity): # zu schnell fallend
		velocity.y = maxFlyDownVelocity
		#print("Downward fly velocity limited to ", velocity.y)
	elif velocity.y > 0.0: # normal schnell fallend
		velocity.y += flyGravity * delta + windStrength.y
		#print("Going down in bubble fly with velocity: ", velocity.y)
	
	if (velocity.y > -maxFlyVelocity):	# solange max upward velocity nicht erreicht ist
		velocity.y += flyGravity * delta + windStrength.y
	elif velocity.y < 0.0:
		# mehr Gravity falls zu schnelles upward movement
		velocity.y += 2.0 * flyGravity * delta + windStrength.y
		#print("Player velocity limited to y = ", velocity.y, " by adding gravity")
	
	print("Player Flying with velocity y = " + str(velocity.y))
	if ($FlyStartTimer.is_stopped() and is_on_floor()):
		bubbles.EndBubbleFly()
		ResetBubbleFly()

func StartFly():
	print("a) Player starts Flying")
	$FlyStartTimer.start()
	EndLaunch()
	SetState(PlayerState.FLY)
	if velocity.y <= 0.0:
		velocity.y = startFlyVelocity
	if velocity.y > 0.0:
		velocity.y = startFlyVelocity * .9
	flyGravity = startFlyGravity
	isFlying = true
	canDash = false
	canJump = false
	
func ResetBubbleFly():
	print("a) Reset Bubble Fly")
	isFlying = false
	canDash = true
	canJump = true
	
func TryResetBubble():
	$Bubbles.TryReleaseBubble()

func StartSliding(dir):
	print("Player starts sliding in Direction: ", dir)
	$Bubbles/AudioStreamPlayer_IceSlide.play()
	if (facing != dir):
		Flip()
	isSliding = true
	SetState(PlayerState.TOSLIDE)
	QueueState(PlayerState.SLIDE)
	
func StopSliding():
	print("Player stops sliding")
	$Bubbles/AudioStreamPlayer_IceSlide.stop()
	isSliding = false
	SetState(PlayerState.JUMP)

func SetCurrentSlope(iceSlide):
	currentIceSlide = iceSlide

func StartSlideJump():
	isJumping = true
	currentIceSlide.StartJump()

func EndSlideJump():
	isJumping = false
	currentIceSlide.EndJump()

func StartLaunch(vel:Vector2):
	AudioManager.PlaySound(RND_LAUNCH_SOUND)
	var maxVelocity = Vector2(3200.0, 3200.0)
	launchVelocity = vel.clamp(-maxVelocity, maxVelocity)
	isLaunched = true
	velocity = launchVelocity * 1.5
	rotation = 0.0
	print("Started Launch with Velocity: ", launchVelocity)

func Launching(delta):
	var direction = Input.get_axis("Left", "Right")
	if (direction != 0):
		facing = sign(direction)
	if direction:
		if (GetDirectionChanged()):
			Flip()
	
	velocity.x += (velocity.x + windStrength.x - velocity.x * launchDrag) * delta
	velocity.y += (velocity.y + windStrength.y - velocity.y + jumpGravity) * delta
	move_and_slide()
	#print("Launching Player with Velocity: ", velocity)
	if (is_on_floor() or is_on_wall()):
		EndLaunch()
	
func EndLaunch():
	rotation = 0.0
	isLaunched = false
	
func SetWindStrength(v):
	windStrength = v
		
func SetWindStrengthAdditive(v):
	windStrength += v
	AverageWindStrength()
func AverageWindStrength():
	windStrength /= winds.size()
	print("WindStrength averaged to " + str(windStrength) + ". Player is in " + str(winds.size()) + " Winds.")

func EnterWind(w):
	winds.append(w)
	isInWind = true
	print("In Wind")
	if winds.size() > 1:
		SetWindStrengthAdditive(w.windForce)
	else:
		SetWindStrength(w.windForce)

func LeaveWind(w):
	winds.erase(w)
	if winds.size() < 1:
		isInWind = false
		print("Not in Wind")
		SetWindStrength(Vector2.ZERO) # Reset
	else:
		SetWindStrengthAdditive(-w.windForce)
		print("Still in Wind")

func HandleCollisions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
#		print("Player collided with ", collider.name)

		if collider.is_in_group("Enemy"):
			if collider.has_method("GetDamage"):
				ApplyDamage(collider.GetDamage())	# Player take dmg
			else:
				ApplyDamage(1)
		if collider.is_in_group("Bubbled"):
			if isDashing and collider.has_method("StartKnockback"):
				var dir = sign(collider.position.x - position.x)
				collider.StartKnockback(dir)
		if collider.has_method("Free"):	# Free Penguin
			collider.Free()
	
	if is_on_ceiling() and !isFalling:
		StartFalling()
		ResetJump()
		

func ApplyDamage(d):
	if (!canBeDamaged):
		return
	print("Apply ", d, " Damage to Player")
	currentHealth = max(0, currentHealth - d)
	
	print("Player Health changed to ", currentHealth)
	emit_signal("healthChanged")
	
	$DamagedCooldown.start()
	canBeDamaged = false
	
	if (currentHealth < 1 and !dead):
		Death()
	
func ApplyHeal(h):
	currentHealth = min(maxHealth, currentHealth + h) 

func Death():
	if dead:
		return
	print("Player Death")
	dead = true
	AudioManager.PlaySound(PLAYER_DEATH)
	canMove = false
	QueueState(PlayerState.NONE)	# clear queue
	SetState(PlayerState.DEATH)
	velocity = Vector2.ZERO
	
	if !isInCutscene:
		death.emit()

func GetDirectionChanged():
	var direction = Input.get_axis("Left", "Right")
	return (direction > 0 and $AnimatedSprite2D.scale.x < 0) or (direction < 0 and $AnimatedSprite2D.scale.x > 0)

func Flip():
	$AnimatedSprite2D.scale.x *= -1

func SetCanBubble(b):
	canBubble = b

func SetEnabled():
	enabled = true
func SetDisabled():
	enabled = false

func OnDeathZoneEntered():
	call_deferred("Death")

func _on_damaged_cooldown_timeout():
	canBeDamaged = true

func _on_dash_timer_timeout():
	isDashing = false

func _on_dash_cooldown_timeout():
	canDash = true

func _on_animated_sprite_2d_animation_finished():
	if queuedState != PlayerState.NONE:
		print("Set Queued State: ", queuedState)
		SetState(queuedState)
		queuedState = PlayerState.NONE
	else:
		print("Animation finished with no queued state")

func _on_step_timer_timeout():
	if currentState == PlayerState.RUN:
		print("FOOT STEP")
		$Footsteps.play()

func _on_air_time_timer_timeout():
	highJump = false
