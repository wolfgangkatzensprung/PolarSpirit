extends StaticBody2D
class_name Pengu	# Pengu Collectable

const particles = preload("res://Assets/Particles/P_FreePenguin.tscn")
const PENGU_WAVING = preload("res://Assets/Collectables/Pengu_Waving.tscn")

@export var penguName:String = "Hans"

var free:bool

func _ready():
	if Game.savedPengus.has(penguName):
		queue_free()

func Free():	
	if free:
		return
	free = true
	print("Free the Penguins!")
	var p = particles.instantiate()
	get_parent().add_child(p)
	p.global_position = global_position
	p.emitting = true
	for pChild in p.get_children():
		if pChild.has_method("set_emitting"):
			pChild.set_emitting(true)
	var penguWaving = PENGU_WAVING.instantiate()
	get_parent().add_child(penguWaving)
	penguWaving.global_position = global_position
	get_parent().PenguCollected(penguName)
	queue_free()
