extends Control

var movies: Array = []

func _ready():
	var file = FileAccess.open("res://Data/Questions.json", FileAccess.READ)
	if file == null:
		push_error("Impossible d'ouvrir Questions.json")
		return
	movies = JSON.parse_string(file.get_as_text())
	file.close()


	for i in range(8):
		var poster = get_node_or_null("poster%d" % (i + 1))
		if poster == null:
			push_warning("poster%d introuvable" % (i + 1))
			continue
		poster.pressed.connect(_on_movie_pressed.bind(i))

func _on_movie_pressed(index: int):
	if index >= movies.size():
		push_error("Pas de film à l'index %d dans le JSON" % index)
		return
	Global.selected_movie = movies[index]
	get_tree().change_scene_to_file("res://scenes/game/level 2/questions.tscn")
