extends Node2D

const UI_SFX = preload("res://Audio/SFX/Rnd_BubblePopSound.tres")
const ICE_CRACKING = preload("res://Audio/SFX/IceCracking2.wav")

var currentMusic:AudioStreamPlayer

func PlaySound(stream:AudioStream):
	var instance = AudioStreamPlayer.new()
	instance.stream = stream
	instance.finished.connect(RemoveInstance.bind(instance))
	instance.bus = "SFX"
	add_child(instance)
	instance.play()

func PlayLocalSound(stream:AudioStream, globalPos:Vector2):
	var instance = AudioStreamPlayer2D.new()
	instance.global_position = globalPos
	instance.stream = stream
	instance.finished.connect(RemoveInstance.bind(instance))
	instance.bus = "SFX"
	add_child(instance)
	instance.play()
	
func PlayUISound():
	var instance = AudioStreamPlayer.new()
	instance.stream = UI_SFX
	instance.finished.connect(RemoveInstance.bind(instance))
	instance.bus = "SFX"
	add_child(instance)
	instance.play()

func PlayPauseSound():
	var instance = Node2D.new()
	var streamInstance = AudioStreamPlayer.new()
	streamInstance.stream = ICE_CRACKING
	streamInstance.finished.connect(RemoveInstance.bind(instance))
	streamInstance.bus = "SFX"
	add_child(instance)
	instance.process_mode = Node.PROCESS_MODE_ALWAYS
	instance.add_child(streamInstance)
	streamInstance.play()

func PlayMusic(stream:AudioStream):
	if (currentMusic != null):
		RemoveInstance(currentMusic)
	
	var musicInstance = AudioStreamPlayer.new()
	musicInstance.stream = stream
	musicInstance.finished.connect(RemoveInstance.bind(musicInstance))
	musicInstance.bus = "Music"
	add_child(musicInstance)
	musicInstance.play()
	musicInstance.set
	currentMusic = musicInstance

func SetCaveSpace():	## set sound effect space to Cave
	print("Set Cave Space")
	var soundBusIndex = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_send(soundBusIndex, "SFX_Cave")
	
func SetDefaultSpace():	## set sound effect space back to default
	print("Set Default Space")
	var soundBusIndex = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_send(soundBusIndex, "Master")
	
func RemoveInstance(instance):
	instance.queue_free()

func RestartMusic():
	currentMusic.play()
	
func FadeOutMusic(duration: float):
	print("Fade Out Music")
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(currentMusic, "volume_db", -80.0, duration)

func FadeInMusic(duration: float):
	print("Fade In Music")
	if currentMusic != null:
		var tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_EXPO)
		tween.tween_property(currentMusic, "volume_db", 0.0, duration)
