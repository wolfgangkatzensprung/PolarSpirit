extends Resource
class_name KeybindsResource

const MOVE_LEFT := "Left"
const MOVE_RIGHT := "Right"
const JUMP := "Jump"
const BUBBLE := "Bubble"
const DASH := "Dash"
const PAUSE := "Pause"

@export var DEFAULT_MOVE_LEFT_KEY := InputEventKey.new()
@export var DEFAULT_MOVE_RIGHT_KEY := InputEventKey.new()
@export var DEFAULT_JUMP_KEY := InputEventKey.new()
@export var DEFAULT_BUBBLE_KEY := InputEventKey.new()
@export var DEFAULT_DASH_KEY := InputEventKey.new()
@export var DEFAULT_PAUSE_KEY := InputEventKey.new()

var moveLeftKey := InputEventKey.new()
var moveRightKey := InputEventKey.new()
var jumpKey := InputEventKey.new()
var bubbleKey := InputEventKey.new()
var dashKey := InputEventKey.new()
var pauseKey := InputEventKey.new()
