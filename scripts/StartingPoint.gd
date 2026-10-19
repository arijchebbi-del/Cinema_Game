extends Control

func _ready():
	Global.make_all_buttons_transparent()
	$Button.pressed.connect(_on_Button_pressed)

func _on_Button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/map.tscn")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_Button_pressed()
