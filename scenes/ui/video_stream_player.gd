extends VideoStreamPlayer


func _ready():
	print("VIDEO SCRIPT IS RUNNING")
	play()
	print("Playing: ", is_playing())
