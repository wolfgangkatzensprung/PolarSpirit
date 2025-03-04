extends Node
class_name Keybinds

const KEYBIND_DEFAULTS = preload("res://Settings/KeybindDefaults.tres")
@onready var keybindResource = KEYBIND_DEFAULTS

func _ready():
	HandleSignals()
	CreateDict()

func HandleSignals():
	pass

func GetKeybind(action:String):
	match action:
		keybindResource.MOVE_LEFT:
			return KEYBIND_DEFAULTS.MOVE_LEFT
		keybindResource.MOVE_RIGHT:
			return KEYBIND_DEFAULTS.MOVE_RIGHT
		keybindResource.JUMP:
			return KEYBIND_DEFAULTS.JUMP
		keybindResource.BUBBLE:
			return KEYBIND_DEFAULTS.BUBBLE
		keybindResource.DASH:
			return KEYBIND_DEFAULTS.DASH
		keybindResource.PAUSE:
			return KEYBIND_DEFAULTS.PAUSE

func SetKeybind(action:String, event):
	match action:
		keybindResource.MOVE_LEFT:
			keybindResource.moveLeftKey = event
		keybindResource.MOVE_RIGHT:
			keybindResource.moveRightKey = event
		keybindResource.JUMP:
			keybindResource.jumpKey = event
		keybindResource.BUBBLE:
			keybindResource.bubbleKey = event
		keybindResource.DASH:
			keybindResource.dashKey = event
		keybindResource.PAUSE:
			keybindResource.pauseKey = event
			
func CreateDict()->Dictionary:
	var keybindsContainer = {
		KEYBIND_DEFAULTS.MOVE_LEFT : KEYBIND_DEFAULTS.moveLeftKey,
		KEYBIND_DEFAULTS.MOVE_RIGHT : KEYBIND_DEFAULTS.moveRightKey,
		KEYBIND_DEFAULTS.JUMP : KEYBIND_DEFAULTS.jumpKey,
		KEYBIND_DEFAULTS.BUBBLE : KEYBIND_DEFAULTS.bubbleKey,
		KEYBIND_DEFAULTS.DASH : KEYBIND_DEFAULTS.dashKey,
		KEYBIND_DEFAULTS.PAUSE : KEYBIND_DEFAULTS.pauseKey
	}
	return keybindsContainer
	
func OnKeybindsLoaded(data:Dictionary):
	var loadedMoveLeft := InputEventKey.new()
	var loadedMoveRight := InputEventKey.new()
	var loadedJump := InputEventKey.new()
	var loadedBubble := InputEventKey.new()
	var loadedDash := InputEventKey.new()
	var loadedPause := InputEventKey.new()
	
	loadedMoveLeft.keycode = data.moveLeft
	loadedMoveRight = data.moveRight
	loadedJump = data.jump
	loadedBubble = data.bubble
	loadedDash = data.dash
	loadedPause = data.pause
	
	keybindResource.moveLeftKey = loadedMoveLeft
	keybindResource.moveRightKey = loadedMoveRight
	keybindResource.jumpKey = loadedJump
	keybindResource.bubbleKey = loadedBubble
	keybindResource.dashKey = loadedDash
	keybindResource.pauseKey = loadedPause
