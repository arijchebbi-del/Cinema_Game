extends Control

const WIN_TARGET = 3
const MATCH_THRESHOLD = 0.7
const ENDING_SCENE = "res://scenes/ui/ending-lel khesrin.tscn"
const MAP_SCENE = "res://scenes/game/map.tscn"
const PIC_FOLDERS = [
	"res://assests/images/Level1/Main/Actors/",
	"res://assets/images/Level1/Main/Actors/",
]

var correct_answers = 0
var actor = {}
var started = false
var game_over = false
var guessed: Array = []
var lower_movies: Array = []

func _ready():
	print("Actors.gd ready")
	update_background()
	$NextButton.hide()
	$NextButton.pressed.connect(_on_NextButton_pressed)
	$Timer.one_shot = true
	$Timer.timeout.connect(_on_timeout)
	visibility_changed.connect(_try_start)
	_try_start.call_deferred()

func _try_start():
	if is_visible_in_tree() and not started:
		start_game()

func start_game():
	if started:
		return
	print("start_game called")
	correct_answers = 0
	guessed.clear()
	game_over = false
	update_background()

	$GuessInput.text = ""
	$GuessInput.show()
	$NextButton.hide()

	# Timer first, so it always runs
	started = true
	$Timer.wait_time = 60.0
	$Timer.start()
	$TimerLabel.text = "Time: 60"
	$GuessInput.grab_focus()

	actor = get_random_actor()
	if actor.is_empty():
		$ActorName.text = "No actor data found"
		return
	$ActorName.text = actor["name"]
	$ActorPic.texture = actor["pic"]
	lower_movies = actor["movies"].map(func(m): return m.to_lower())

func _process(_delta):
	if started and not game_over and not $Timer.is_stopped():
		$TimerLabel.text = "Time: %d" % ceil($Timer.time_left)

func find_picture(json_path: String) -> Texture2D:
	if ResourceLoader.exists(json_path):
		return load(json_path)
	var file_name = json_path.get_file()
	for folder in PIC_FOLDERS:
		if ResourceLoader.exists(folder + file_name):
			return load(folder + file_name)
	push_warning("Picture not found: " + json_path)
	return null

func get_random_actor() -> Dictionary:
	var file = FileAccess.open("res://Data/Actors.json", FileAccess.READ)
	if file == null:
		push_error("Could not open Actors.json")
		return {}
	var actors = JSON.parse_string(file.get_as_text())
	if actors == null or actors.is_empty():
		push_error("Actors.json could not be parsed")
		return {}
	actors.shuffle()
	for entry in actors:
		var tex = find_picture(entry["pic path"])
		if tex != null:
			return {
				"name": entry["actor"],
				"pic": tex,
				"movies": entry["movies they starred in"],
			}
	var e = actors[0]
	return {"name": e["actor"], "pic": null, "movies": e["movies they starred in"]}

func _input(event):
	if not started or game_over:
		return
	if not event.is_action_pressed("ui_accept") or event.is_echo():
		return
	var input = $GuessInput.text.strip_edges().to_lower()
	var match_title = find_match(input)
	if match_title != "" and not guessed.has(match_title):
		guessed.append(match_title)
		correct_answers += 1
		update_background()
		if correct_answers >= WIN_TARGET:
			win()
			if Global.check_victory():
				get_tree().change_scene_to_file("res://scenes/ui/eding lel rebhin.tscn")
			else:
				$NextButton.show()

	$GuessInput.text = ""

func win():
	game_over = true
	$Timer.stop()
	Global.add_score("actordirector", 5)
	Global.mark_won("ActorDirector")
	$GuessInput.hide()
	$NextButton.show()

func _on_timeout():
	if game_over:
		return
	game_over = true
	get_tree().change_scene_to_file(ENDING_SCENE)

func update_background():
	for child in get_children():
		if String(child.name).begins_with("bg"):
			child.visible = (child.name == "bg" + str(correct_answers))

func find_match(input: String) -> String:
	for title in lower_movies:
		if input.similarity(title) >= MATCH_THRESHOLD:
			return title
	return ""

func _on_NextButton_pressed():
	get_tree().change_scene_to_file(MAP_SCENE)
