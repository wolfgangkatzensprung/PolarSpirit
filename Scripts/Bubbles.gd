extends Node2D

var bubbleScene = preload("res://Assets/Bubble.tscn")
const RND_PLAYER_SHOOT = preload("res://Audio/SFX/Rnd_PlayerShoot.tres")
const P_MUZZLE_FLASH_L = preload("res://Assets/Particles/P_MuzzleFlash_L.tscn")
const P_MUZZLE_FLASH_R = preload("res://Assets/Particles/P_MuzzleFlash_R.tscn")

@onready var firePointL = $"../FirePoint L"
@onready var firePointR = $"../FirePoint R"

@onready var player = $".."

var currentBubble:Bubble	# currently held bubble

@export var startScale := 0.01	## die Scale, mit der die Bubble instanziert wird
var currentScale := startScale
var scaleDelta := 0.03

@export var growingSpeed := 0.6	## growing speed of bubble scale
@export var maxScale := .036	## maximum scale of bubble

@export var relativeVelocity := 4.2 ## reziproker speed unterschied zwischen kleinen und grossen bubbles
@export var shootVelocity := 600.0	## general speed of shot bubble

#@export var flyThreshold := 0.1	## scale delta threshold: when will player start flying from blowing bubble 

func _input(_event):
	if player.dead or player.isSliding or !player.bubbleUnlocked or !Input.is_action_just_pressed("Bubble") or !player.canBubble:
		return
	else:
		print("StartBubble")
		StartBlowBubble()

func _process(delta):
	var flyThreshold = delta
	
	if player.dead or !player.bubbleUnlocked:
		return

	if (currentBubble != null):
		if Input.is_action_just_released("Bubble"):
			TryReleaseBubble()
		else:
			currentScale = lerpf(currentScale, maxScale, scaleDelta)
			currentBubble.SetScale(Vector2(currentScale, currentScale))
			scaleDelta += delta * growingSpeed
			
			#print("ScaleDelta: ", scaleDelta)
			#print("CurrentScale: ", currentScale)
			
			if (scaleDelta > flyThreshold && !player.isFlying):
				player.StartFly()

func StartBlowBubble():
	scaleDelta = 0.0
	currentScale = startScale
	player.SetCanBubble(false)
	currentBubble = bubbleScene.instantiate()
	add_child(currentBubble, 1)
	currentBubble.position = Vector2.ZERO

	#print("Player Position:", global_position)
	#print("Bubble Position:", currentBubble.global_position)

func TryReleaseBubble():
	player.ResetBubbleFly()
	 
	for child in get_children():
		if child is Bubble:
			AudioManager.PlaySound(RND_PLAYER_SHOOT)	
			currentBubble = child
			call_deferred("ReleaseBubble", shootVelocity)
			$BubbleCooldown.start()

func ReleaseBubble(vel):
	var dir = get_parent().get_node("AnimatedSprite2D").scale.x	# player direction
	if dir < 0:
		var muzzleParticle = P_MUZZLE_FLASH_L.instantiate()
		firePointL.add_child(muzzleParticle)
		muzzleParticle.emitting = true
	else:
		var muzzleParticle = P_MUZZLE_FLASH_R.instantiate()
		firePointR.add_child(muzzleParticle)
		muzzleParticle.emitting = true
	
	var bubbleVelocity = Vector2(vel * dir, 0)
	#print("Release Bubble")
	currentBubble.add_to_group("Windable")
	currentBubble.call_deferred("StartBubbleShot")
	var parentScene = player.get_parent()
	currentBubble.reparent(parentScene)
	#print("Bubble Parent: ", parentScene)
	currentBubble.SetVelocity(bubbleVelocity * (1 / (currentScale * relativeVelocity)))
	currentBubble = null

func EndBubbleFly():
	currentBubble.PopBubble()
	currentBubble = null
	player.SetCanBubble(true)

func _on_bubble_cooldown_timeout():
	player.SetCanBubble(true)

func _on_player_death():
	for child in get_children():
		if child is Bubble:
			child.queue_free()
