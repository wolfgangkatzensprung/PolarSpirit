extends AudioStreamPlayer2D

func _ready():
	var length = stream.get_length()
	var rnd = randf_range(0.0, length)
	seek(rnd)
