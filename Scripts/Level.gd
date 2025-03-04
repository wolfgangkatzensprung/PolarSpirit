extends Node2D
class_name Level

const MAIN_CAM = preload("res://Assets/MainCam.tscn")

@export var levelMusic:AudioStream
@export var isCaveLevel:bool = false

@export var endPoint:Node2D	## if EndPod int is nested, it needs to be assigned here

@export var tutorialStones:Array[Sprite2D]

var checkPoints:Array[Checkpoint]
var checkpointPos:Vector2 # global position of latest checkpoint

var endPointReached = false

signal checkpointEntered
signal dialogueEntered
signal dialogueExited
signal penguCollected
signal savePengus
signal startCutscene

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	AudioManager.FadeInMusic(2.0)	# length of fade animation
	
	GetEndPoint().reached.connect(SetEndPointReached)
	var userInterface = get_tree().get_first_node_in_group("UI")
	if userInterface != null:
		userInterface.controllerModeChanged.connect(OnControllerModeChanged)
	
	if levelMusic != null:
		AudioManager.PlayMusic(levelMusic)
	if (get_tree().get_nodes_in_group("MainCam").size() < 1):	# if no maincam
		print("Spawn MainCam")
		var mainCam = MAIN_CAM.instantiate()
		get_tree().get_root().add_child.call_deferred(mainCam)
	
	if isCaveLevel:
		AudioManager.SetCaveSpace()
	else:
		AudioManager.SetDefaultSpace() 

func Unload():
	if $"../CanvasLayer/UserInterface" != null:
		$"../CanvasLayer/UserInterface".controllerModeChanged.disconnect(OnControllerModeChanged)
	SavePengus()
	queue_free()

func GetEndPoint():
	if endPoint:
		return endPoint
	else:
		return $EndPoint

func SetEndPointReached():
	endPointReached = true

func GetPlayer():
	return %Player

func SetCheckpoint(cp:Checkpoint):
	if !checkPoints.has(cp):
		checkPoints.append(cp)
		checkpointPos = cp.global_position
		checkpointEntered.emit()
		cp.Activate()
		print("Assigned Checkpoint at: ", cp.global_position)
	else:
		print("Checkpoint not assigned.")
	
func GetCheckpointPos()->Vector2: # return spawn position (checkpoint pos, or if doesnt exist, start pos)
	return checkpointPos
	
func HasCheckpoint():	 ## has activated a checkpoint
	return !checkPoints.is_empty()

func EnterDialogue():	
	dialogueEntered.emit()

func LeaveDialogue():
	dialogueExited.emit()

func PenguCollected(pengName):
	print("Collected Pengu ", pengName)
	penguCollected.emit(pengName)
		
func SavePengus():	# touch checkpoint or finish level to save collected pengus
	savePengus.emit()

func StartCutscene():
	startCutscene.emit()

func OnControllerModeChanged(cMode):
	if tutorialStones != null:
		for t in tutorialStones:
			if t.has_method("SetSprite"):
				t.SetSprite(cMode)
func AddTutorialStone(tut):
	tutorialStones.append(tut)

func _on_cutscene_trigger_body_entered(body):
	StartCutscene()
