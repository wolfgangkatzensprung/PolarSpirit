extends HSlider

@export var busName:String
var busIndex

func _ready():
	busIndex = AudioServer.get_bus_index(busName)
	var volume = value
	if (SaveSystem.has(busName)):
		volume = SaveSystem.get_var(busName)
	AudioServer.set_bus_volume_db(busIndex, linear_to_db(volume))
	value = volume

func _on_value_changed(value):
	AudioServer.set_bus_volume_db(busIndex, linear_to_db(value))
	SaveSystem.set_var(busName, value)
	print(busName, " Bus Volume: ", AudioServer.get_bus_volume_db(busIndex))
