extends Button

@export var movie_id: String

func _pressed() -> void:
	var quiz_scene = preload("res://scenes/MovieQuestions.tscn")
	var quiz_instance = quiz_scene.instantiate()

	quiz_instance.setup(movie_id)

	get_tree().root.add_child(quiz_instance)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = quiz_instance
