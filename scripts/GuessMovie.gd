extends Control

func _ready() -> void:
	Global.make_all_buttons_transparent()
	$Button.pressed.connect(_on_Button_pressed)
	$Button2.pressed.connect(_on_Button2_pressed)
	$Button3.pressed.connect(_on_Button3_pressed)

func _on_Button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/level 3/color.tscn")

func _on_Button2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/level 3/cast.tscn")
	
func _on_Button3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/level 3/description.tscn")
