extends Control



func _on_Button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/level3/color_palette.tscn")

func _on_Button2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/level3/cast.tscn")
	
func _on_Button3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/level3/bad_plot.tscn")
