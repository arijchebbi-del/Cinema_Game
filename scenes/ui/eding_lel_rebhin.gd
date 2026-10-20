extends Control

@onready var video = $VideoStreamPlayer
@onready var photo = $TextureRect
@onready var button = $Button
@onready var points_label = $points

func _ready():
	print("WIN SCENE LOADED")

	photo.hide()
	button.hide()
	points_label.hide()

	button.pressed.connect(_on_Button_pressed)

	if video.stream == null:
		print("No video assigned, showing win screen directly")
		_show_win_screen()
		return

	video.loop = false
	video.finished.connect(_on_video_finished)
	video.play()

	# Safety net: if "finished" never fires, show the screen anyway
	await get_tree().create_timer(30.0).timeout
	if not photo.visible:
		print("Video timeout, showing win screen")
		_show_win_screen()

func _on_video_finished():
	print("Video finished")
	_show_win_screen()

func _show_win_screen():
	if photo.visible:
		return

	photo.show()
	button.show()
	points_label.show()
	points_label.text = "Final Score: " + str(Global.score)

	photo.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(photo, "modulate:a", 1.0, 1.5)

func _on_Button_pressed():
	Global.score = 0
	get_tree().change_scene_to_file("res://scenes/ui/starting.tscn")
