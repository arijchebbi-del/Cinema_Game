
extends Control

func _ready():
	Global.make_all_buttons_transparent()
func _on_StartButton_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/GameSelect.tscn")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_StartButton_pressed()
