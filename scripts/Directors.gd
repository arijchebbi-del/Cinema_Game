extends Control

signal game_completed(won: bool)

const WIN_TARGET = 3
const MATCH_THRESHOLD = 0.8

var correct_answers = 0
var director: Dictionary = {}
var game_over = false
var guessed: Array = []
var lower_movies: Array = []

func _ready():
	Global.make_all_buttons_transparent()

	# Remove focus mode from buttons to prevent Enter key accidental presses
	if has_node("NextButton"):
		$NextButton.focus_mode = Control.FOCUS_NONE
		$NextButton.hide()
		if not $NextButton.pressed.is_connected(_on_NextButton_pressed):
			$NextButton.pressed.connect(_on_NextButton_pressed)

	director = get_random_director()
	if director.is_empty():
		push_error("Impossible de charger les données du réalisateur.")
		return

	if has_node("ActorName"):
		$ActorName.text = director.get("name", "")
	elif has_node("DirectorName"):
		$DirectorName.text = director.get("name", "")

	if has_node("DirectorPic") and director.get("pic") != null:
		$DirectorPic.texture = director["pic"]
	elif has_node("ActorPic") and director.get("pic") != null:
		$ActorPic.texture = director["pic"]

	var movies_list: Array = director.get("movies", [])
	lower_movies = movies_list.map(func(m): return str(m).to_lower())

	# Connect text submission explicitly instead of _input()
	if has_node("GuessInput"):
		$GuessInput.focus_mode = Control.FOCUS_CLICK
		if not $GuessInput.text_submitted.is_connected(_on_guess_submitted):
			$GuessInput.text_submitted.connect(_on_guess_submitted)

	if has_node("Timer"):
		$Timer.wait_time = 60.0
		$Timer.one_shot = true
		if not $Timer.timeout.is_connected(_on_timeout):
			$Timer.timeout.connect(_on_timeout)
		$Timer.start()

	if has_node("TimerLabel"):
		$TimerLabel.text = "Time: 60"

	update_background()

func _process(_delta):
	if has_node("Timer") and not $Timer.is_stopped() and has_node("TimerLabel"):
		$TimerLabel.text = "Time: %d" % ceil($Timer.time_left)

func get_random_director() -> Dictionary:
	var json_path = "res://Data/Directors.json"
	if not FileAccess.file_exists(json_path):
		push_error("Fichier introuvable : " + json_path)
		return {}

	var file = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		return {}

	var directors = JSON.parse_string(file.get_as_text())
	if directors == null or not (directors is Array) or directors.is_empty():
		push_error("Le fichier Directors.json est vide ou mal formaté.")
		return {}

	var entry = directors.pick_random()
	var pic_path: String = entry.get("pic path", entry.get("pic_path", ""))
	pic_path = pic_path.replace("res://assests/", "res://assets/")

	var pic_texture = null
	if ResourceLoader.exists(pic_path):
		pic_texture = load(pic_path)
	else:
		push_error("Image du réalisateur introuvable au chemin : " + pic_path)

	var director_name = entry.get("director", entry.get("name", "Inconnu"))
	var director_movies = entry.get("movies they directed", entry.get("movies", []))

	return {
		"name": director_name,
		"pic": pic_texture,
		"movies": director_movies,
	}

func _on_guess_submitted(raw_input: String) -> void:
	if game_over:
		return

	var input = raw_input.strip_edges().to_lower()
	var match_title = find_match(input)

	if match_title != "" and not guessed.has(match_title):
		guessed.append(match_title)
		correct_answers += 1
		update_background()
		if correct_answers >= WIN_TARGET:
			check_win()

	if has_node("GuessInput"):
		$GuessInput.text = ""

func check_win():
	if game_over:
		return
	game_over = true
	if has_node("Timer"):
		$Timer.stop()

	if correct_answers >= WIN_TARGET:
		Global.add_score("actordirector", 5)
		Global.mark_won("ActorDirector")
		if "last_result" in Global:
			Global.last_result = "director_win"
		game_completed.emit(true)
	else:
		if "last_result" in Global:
			Global.last_result = "times_up"
		Global.game_lost.emit()
		game_completed.emit(false)

func update_background():
	# Hide all backgrounds bg0 through bg3
	for i in range(4):
		var bg = get_node_or_null("bg" + str(i))
		if bg:
			bg.visible = false

	# Show current background for correct answer count
	var current_bg = get_node_or_null("bg" + str(correct_answers))
	if current_bg:
		current_bg.visible = true

func _on_timeout():
	check_win()

func find_match(input: String) -> String:
	for title in lower_movies:
		if input.similarity(title) >= MATCH_THRESHOLD:
			return title
	return ""

func _on_NextButton_pressed():
	get_tree().change_scene_to_file("res://scenes/game/map.tscn")
