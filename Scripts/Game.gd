extends Node2D
class_name Game

@export var testMode:bool = false

@export var levels:Array[String] = [
	"IntroLevel 1",
	"IntroLevel 2",
]

@export var menuMusic:AudioStream

@onready var userInterface = $CanvasLayer/UserInterface
@onready var overlay = $CanvasLayer/TransitionOverlay

var introScene

var gameStartedForFirstTime = true
var levelPaused = false
var levelFinished = false # when true, load next level after fade anim is finished

var currentLevel:Level
var levelIndex:int = 0

var lastCheckpointPos = null
var respawnAtCheckPoint = false
var allowRespawn = false # if player has died

var isInDialog = false

static var penguAmountTotal:int = 0	# amount of pengus to show in UI
static var collectedPengus:Array[String] # pengus that have been freed during a level, and have not yet been added to pengusCollectedTotal array
static var savedPengus:Array[String]	# completely collected and saved pengus

func _input(_event):
	if currentLevel != null:
		if Input.is_action_just_released("Pause") and not isInDialog and not overlay.GetIsFading():
			if !currentLevel.get_tree().paused:
				AudioManager.PlayPauseSound()
			TogglePause()
	
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if not testMode:
		$"CanvasLayer/UserInterface/Label_UI Debug".visible = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	
	if menuMusic:
		AudioManager.PlayMusic(menuMusic)

func Start():
	print("Start Game!")
	if gameStartedForFirstTime:
		introScene = LoadIntroSequence()
		call_deferred("LoadingDone")
		gameStartedForFirstTime = false
	else:
		LoadLevel(levels[levelIndex])
		call_deferred("LoadingDone")

func LoadLevel(levelString):
	print("Load Level ", levelString)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	ResetPcamHost()
	
	var levelPath = "res://Levels/Fabrizio/" + levelString + ".tscn"
	var levelScene = load(levelPath)
	print("Load Level ", levelString)
	currentLevel = levelScene.instantiate()
	print("Current Level: ", currentLevel)
	add_child(currentLevel)
	userInterface.Reset()
	
	var endPoint = currentLevel.GetEndPoint()
	var player = currentLevel.GetPlayer()
	
	player.canMove = false
	
	currentLevel.checkpointEntered.connect(OnCheckpointEntered)
	currentLevel.penguCollected.connect(OnPenguCollected)
	currentLevel.savePengus.connect(OnSavePengus)
	currentLevel.startCutscene.connect(OnCutsceneStarted)
	
	if (player != null):
		player.death.connect(OnPlayerDeath)
		if respawnAtCheckPoint:
			player.global_position = lastCheckpointPos
			print("Spawn Player on Checkpoint: ", lastCheckpointPos)
		
	if (endPoint != null):
		endPoint.reached.connect(OnEndPointReached)
	else: print("Next Level doesnt have EndPoint!")
		
	currentLevel.dialogueEntered.connect(EnterDialogue)
	currentLevel.dialogueExited.connect(ExitDialogue)
	
	overlay.FadeIn()
	
	call_deferred("ResumeLevel")
	
func LoadingDone():	# when started from Menu
	overlay.LoadingDone()

func LoadScene(nextScene):
	overlay.FadeIn()
	var nextSceneInstance = nextScene.instantiate()
	print("Load Scene ", nextSceneInstance)
	add_child(nextSceneInstance)
	userInterface.Reset()

func LoadIntroSequence():
	var introSequence = load("res://Scenes/Introsequenz.tscn")
	overlay.FadeIn()
	var introSequenceInstance = introSequence.instantiate()
	print("Load Intro ", introSequenceInstance)
	add_child(introSequenceInstance)
	introSequenceInstance.introFinished.connect(OnIntroFinished)
	userInterface.Reset()
	return introSequenceInstance

func GameWon():
	LoadScene(load("res://Scenes/WinScreen.tscn"))

func Quit():
	get_tree().quit()

func UnloadLevel(level):
	if level and not level.is_queued_for_deletion():
		print("Unload Level ", level)
		ResetPcamHost()
		if level.HasCheckpoint():
			var cpPos = level.GetCheckpointPos()
			lastCheckpointPos = cpPos
		if levelIndex < 1:
			call_deferred("TryResetCutscene")	# Reset Cutscene Bars after Level 1
		level.Unload()
	else:
		print("Tried unloading Level but there is no level assigned or it is already queued")
	currentLevel = null

func TryResetCutscene():
	if currentLevel != null:
		overlay.ResetCutsceneBars()
	
func ResetPcamHost(): # PhantomCamera Hack to prevent null reference
	var pcamHost:PhantomCameraHost = $MainCam.get_child(0)
	pcamHost._active_pcam = null
	pcamHost._active_pcam_missing = true
	pcamHost._active_pcam_priority = -1

func FinishLevel():
	overlay.SetLevelProgress(levelIndex + 1)
	respawnAtCheckPoint = false
	overlay.FadeOut()
	#PauseLevel()
	print("Level Finished! " + str(penguAmountTotal) + " Pengus have been freed in total!")
	levelFinished = true

func SetLastCheckpoint(cpPos):
	lastCheckpointPos = cpPos
	print("Checkpoint assigned to Game at ", lastCheckpointPos)

func GetCurrentLevelScene():
	return currentLevel
	
func TogglePause():
	if currentLevel != null:
		userInterface.Toggle("PauseMenu")
		if (levelPaused):
			userInterface.HideAllMenus()
			ResumeLevel()
		else:
			PauseLevel()
	
func PauseLevel():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	levelPaused = true
	currentLevel.get_tree().paused = levelPaused

func ResumeLevel():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	levelPaused = false
	currentLevel.get_tree().paused = levelPaused

func ReloadInCurrentLevel():
	currentLevel.queue_free()
	LoadLevel(levels[levelIndex])

func EnterDialogue():
	overlay.ShowCutsceneBars()
	isInDialog = true
func ExitDialogue():
	overlay.ResetCutsceneBars()
	isInDialog = false

func LevelTransition():
	UnloadLevel(currentLevel)
	levelFinished = false
	levelIndex += 1
	if (levels.size() == levelIndex):
		GameWon()
	else:
		LoadLevel(levels[levelIndex])

func AllowPlayerMovement():
	if currentLevel != null:
		currentLevel.GetPlayer().canMove = true

func OnIntroFinished():
	print("On Intro Finished")
	introScene.queue_free()
	LoadLevel(levels[levelIndex])

func OnPenguCollected(penguName):
	print("Pengu Collected")
	penguAmountTotal += 1
	userInterface.SetPenguAmount(penguAmountTotal)
	userInterface.DisplayPengus()
	if !collectedPengus.has(penguName):
		collectedPengus.append(penguName)
	
func OnSavePengus():	
	savedPengus.append_array(collectedPengus)
	collectedPengus.clear()
	penguAmountTotal = savedPengus.size()
	print(penguAmountTotal, " Pengus Saved: ")
	for pName in savedPengus:
		print(pName)

func OnCutsceneStarted():
	overlay.ShowCutsceneBars()

func OnCheckpointEntered():
	respawnAtCheckPoint = true
	SetLastCheckpoint(currentLevel.GetCheckpointPos())
	
func OnEndPointReached():
	$Timer_LevelFinish.start()
	if levelIndex != (levels.size() - 1):	# fade out music, except for EndScreen
		AudioManager.FadeOutMusic(3.6)

func OnPlayerDeath():
	OnSavePengus()
	overlay.FadeOut()
	allowRespawn = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name.contains("FadeOut"):
		print("FadeOut Anim Finished")
		if levelFinished:
			if levelIndex >= levels.size() - 1:
				userInterface.SetPenguAmount_LastTransition(penguAmountTotal)
			overlay.ShowLevelTransitionScreen()

		if allowRespawn:
			allowRespawn = false
			call_deferred("ReloadInCurrentLevel")
		
	elif anim_name == "ToLoadingScreen":
		Start()	# when Loading Screen is completely visible, start load Level
	elif anim_name == "LevelTransition":
		LevelTransition()	# when LevelTransition Screen is fully visible, start unloading Level etc
		
func _on_play_button_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	AudioManager.PlayUISound()
	AudioManager.FadeOutMusic(2.0)
	overlay.ToLoadingScreen()

func _on_quit_button_pressed():
	AudioManager.PlayUISound()
	Quit()

func _on_settings_button_pressed():
	AudioManager.PlayUISound()
	userInterface.Toggle("SettingsMenu")

func _on_back_to_menu_button_pressed():
	AudioManager.PlayUISound()
	userInterface.HideAllMenus()
	userInterface.Toggle("MainMenu")
	UnloadLevel(currentLevel)

func _on_menu_button_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	AudioManager.PlayUISound()
	UnloadLevel(currentLevel)
	userInterface.HideAllMenus()
	userInterface.ShowMenu("MainMenu")

func _on_resume_button_pressed():	# resume from pause menu
	AudioManager.PlayUISound()
	TogglePause()
	userInterface.HideAllMenus()

func _on_controls_button_pressed():
	AudioManager.PlayUISound()
	userInterface.HideAllMenus()
	userInterface.ShowMenu("ControlsMenu")

func _on_sound_button_pressed():
	AudioManager.PlayUISound()
	userInterface.HideAllMenus()
	userInterface.ShowMenu("SoundMenu")

func _on_sound_button_pause_menu_pressed():
	AudioManager.PlayUISound()
	userInterface.HideAllMenus()
	userInterface.ShowMenu("SoundPauseMenu")

func _on_controls_button_pause_menu_pressed():
	AudioManager.PlayUISound()
	userInterface.HideAllMenus()
	userInterface.ShowMenu("ControlsPauseMenu")

func _on_timer_level_finish_timeout():
	if not levelFinished:
		FinishLevel()
