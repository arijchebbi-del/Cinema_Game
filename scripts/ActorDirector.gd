extends Control

func _on_ActorButton_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/level1/actor_game.tscn")

func _on_DirectorButton_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/level1/director_game.tscn")
