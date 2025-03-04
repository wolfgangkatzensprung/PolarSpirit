extends Control
class_name HotkeyRebindButton

@onready var label = $HBoxContainer/Label as Label
@onready var button = $HBoxContainer/Button as Button

@export var actionName:String = "Jump"

func _ready():
	set_process_unhandled_key_input(false)
	SetActionName()
	SetKeyText()

func _unhandled_key_input(event):
		RebindActionKey(event)
		button.button_pressed = false

#func LoadKeybind():
	#RebindActionKey(keybinds.GetKeybind(actionName))

func SetActionName():
	label.text = actionName
	
func SetKeyText():
	var actionEvents = InputMap.action_get_events(actionName)
	#print(actionEvents)
	var actionEvent:InputEvent = actionEvents[actionEvents.size() - 1]
	#print("Action Event: ", actionEvent, " for ", name)
	var physicalKeycode:Key
	physicalKeycode = actionEvent.physical_keycode
	var actionKeycode = OS.get_keycode_string(physicalKeycode)
	button.text = "%s" % actionKeycode
	
func RebindActionKey(event):
	print("Key bound: " + str(event))
	var actionEvents = InputMap.action_get_events(actionName)
	InputMap.action_erase_event(actionName, actionEvents[actionEvents.size() - 1])
	InputMap.action_add_event(actionName, event)
	#keybinds.SetKeybind(actionName, event)
	
	set_process_unhandled_key_input(false)
	SetKeyText()
	SetActionName()

func _on_button_toggled(toggled_on):
	print("Button Toggled. Action Name: ", actionName)
	if toggled_on:
		button.text = "Press any key..."
		set_process_unhandled_key_input(toggled_on)
		
		for i in get_tree().get_nodes_in_group("HotkeyButton"):
			if i.actionName != actionName:
				i.button.toggle_mode = false
				i.set_process_unhandled_key_input(false)
	else:
		for i in get_tree().get_nodes_in_group("HotkeyButton"):
			if i.actionName != actionName:
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)
				
		SetKeyText()
