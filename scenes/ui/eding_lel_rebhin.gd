
extends Control

@onready var video = $VideoStreamPlayer
@onready var photo = $TextureRect
@onready var button = $Button
@onready var points_label = $points

var points = 0

func _ready():
	photo.hide()
	button.hide()
	points_label.hide()
	points_label.text = str(points)

	video.finished.connect(_on_video_finished)

func _on_video_finished():
	photo.show()
	photo.modulate.a = 0.0

	button.show()
	points_label.show()

	var tween = create_tween()
	tween.tween_property(photo, "modulate:a", 1.0, 1.5)

func update_points(new_points: int):
	points = new_points
	points_label.text = str(points)
