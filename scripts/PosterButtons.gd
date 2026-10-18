extends Control

var movies: Array = []

func _ready():
	var file = FileAccess.open("res://Data/Questions.json", FileAccess.READ)
	movies = JSON.parse_string(file.get_as_text())
	file.close()

	#the same order as the JSON:
	var buttons = $ButtonContainer.get_children()
	for i in buttons.size():
		buttons[i].pressed.connect(_on_movie_pressed.bind(i))

func _on_movie_pressed(index: int):
	Global.selected_movie = movies[index]
	get_tree().change_scene_to_file("res://scenes/question_scene.tscn")
