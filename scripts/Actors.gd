extends Control

signal game_completed(won: bool)

const WIN_TARGET = 4
const MATCH_THRESHOLD = 0.7

var correct_answers: int = 0
var actor: Dictionary = {}
var game_over: bool = false
var guessed: Array = []
var lower_movies: Array = []

func _ready() -> void:
	correct_answers = 0
	game_over = false
	guessed.clear()

	Global.make_all_buttons_transparent()

	actor = get_random_actor()
	if actor.is_empty():
		push_error("Impossible de charger les données de l'acteur.")
		return

	if has_node("ActorName"):
		$ActorName.text = actor.get("name", "")
	if has_node("ActorPic") and actor.get("pic") != null:
		$ActorPic.texture = actor["pic"]
		
	var movies_list: Array = actor.get("movies", [])
	lower_movies.clear()
	for m in movies_list:
		lower_movies.append(str(m).strip_edges().to_lower())

	# Connexion forcée du signal du LineEdit
	if has_node("GuessInput"):
		var input_node = $GuessInput
		input_node.focus_mode = Control.FOCUS_CLICK
		if input_node.text_submitted.is_connected(_on_guess_submitted):
			input_node.text_submitted.disconnect(_on_guess_submitted)
		input_node.text_submitted.connect(_on_guess_submitted)

	if has_node("NextButton"):
		$NextButton.focus_mode = Control.FOCUS_NONE
		$NextButton.hide()
		if not $NextButton.pressed.is_connected(_on_NextButton_pressed):
			$NextButton.pressed.connect(_on_NextButton_pressed)

	if has_node("Timer"):
		$Timer.wait_time = 60.0
		$Timer.one_shot = true
		if not $Timer.timeout.is_connected(_on_timeout):
			$Timer.timeout.connect(_on_timeout)
		$Timer.start()
	
	if has_node("TimerLabel"):
		$TimerLabel.text = "Time: 60"

	update_background()

func _process(_delta: float) -> void:
	if has_node("Timer") and not $Timer.is_stopped() and has_node("TimerLabel"):
		$TimerLabel.text = "Time: %d" % ceil($Timer.time_left)

func get_random_actor() -> Dictionary:
	var json_path = "res://Data/Actors.json"
	if not FileAccess.file_exists(json_path):
		push_error("Fichier introuvable : " + json_path)
		return {}

	var file = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		return {}

	var actors = JSON.parse_string(file.get_as_text())
	if actors == null or not (actors is Array) or actors.is_empty():
		push_error("Le fichier Actors.json est vide ou mal formaté.")
		return {}

	var entry = actors.pick_random()
	var pic_path: String = entry.get("pic path", entry.get("pic_path", ""))
	pic_path = pic_path.replace("res://assests/", "res://assets/")

	var pic_texture = null
	if ResourceLoader.exists(pic_path):
		pic_texture = load(pic_path)

	var actor_name = entry.get("actor", entry.get("name", "Inconnu"))
	var actor_movies = entry.get("movies they acted in", entry.get("movies", []))

	return {
		"name": actor_name,
		"pic": pic_texture,
		"movies": actor_movies,
	}

func _on_guess_submitted(raw_input: String) -> void:
	if game_over:
		return

	var input = raw_input.strip_edges().to_lower()
	if input == "":
		return

	var match_title = find_match(input)

	if match_title != "" and not guessed.has(match_title):
		guessed.append(match_title)
		correct_answers += 1
		update_background()
		if correct_answers >= WIN_TARGET:
			check_win()

	if has_node("GuessInput"):
		$GuessInput.text = ""

func find_match(input: String) -> String:
	for title in lower_movies:
		if input == title or input in title or title in input or input.similarity(title) >= MATCH_THRESHOLD:
			return title
	return ""

func update_background() -> void:
	# Masquer bg0 à bg4
	for i in range(5):
		var bg = get_node_or_null("bg" + str(i))
		if bg:
			bg.visible = false

	# Afficher le background correspondant au score actuel
	var target_index = clampi(correct_answers, 0, 4)
	var current_bg = get_node_or_null("bg" + str(target_index))
	if current_bg:
		current_bg.visible = true

func check_win() -> void:
	if game_over:
		return
	game_over = true

	if has_node("Timer"):
		$Timer.stop()

	if correct_answers >= WIN_TARGET:
		Global.add_score("actordirector", 5)
		Global.mark_won("ActorDirector")
		if "last_result" in Global:
			Global.last_result = "actor_win"
		game_completed.emit(true)
	else:
		if "last_result" in Global:
			Global.last_result = "times_up"
		Global.game_lost.emit()
		game_completed.emit(false)

func _on_timeout() -> void:
	check_win()

func _on_NextButton_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/map.tscn")
