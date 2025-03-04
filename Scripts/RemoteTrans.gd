extends RemoteTransform2D

@export var remotePath = "../../../Player"	## path to remotely controlled node

func StartControlling():
	remote_path = remotePath

func StopControlling():
	remote_path = ""
