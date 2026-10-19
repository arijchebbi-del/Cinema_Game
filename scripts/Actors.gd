extends Control

const WIN_TARGET = 4
const MATCH_THRESHOLD = 0.7
const ENDING_SCENE = "res://scenes/ui/ending-lel khesrin.tscn"
const MAP_SCENE = "res://scenes/game/map.tscn"

var correct_answers = 0
var actor
var started = false
var game_over = false
var guessed: Array = []
var lower_movies: Array = []

func _ready():
	$NextButton.hide()
	$NextButton.pressed.connect(_on_NextButton_pressed)
	$Timer.one_shot = true
	$Timer.timeout.connect(_on_timeout)

# Called by Level1 when the player picks this game
func start_game():
	actor = get_random_actor()
	if actor.is_empty():
		return
	$ActorName.text = actor["name"]
	$ActorPic.texture = actor["pic"]
	lower_movies = actor["movies"].map(func(m): return m.to_lower())

	correct_answers = 0
	guessed.clear()
	game_over = false
	started = true

	$Timer.wait_time = 60.0
	$Timer.start()
	$TimerLabel.text = "Time: 60"
	$GuessInput.text = ""
	$GuessInput.grab_focus()
	update_background()

func _process(_delta):
	if started and not $Timer.is_stopped():
		$TimerLabel.text = "Time: %d" % ceil($Timer.time_left)

func get_random_actor() -> Dictionary:
	var file = FileAccess.open("res://Data/Actors.json", FileAccess.READ)
	if file == null:
		push_error("Could not open Actors.json")
		return {}
	var actors = JSON.parse_string(file.get_as_text())
	actors.shuffle()
	for entry in actors:
		if ResourceLoader.exists(entry["pic path"]):
			return {
				"name": entry["actor"],
				"pic": load(entry["pic path"]),
				"movies": entry["movies they starred in"],
			}
		push_warning("Missing image: " + entry["pic path"])
	return {}

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
	# Rediriger vers l'écran de fin pour les perdants
	get_tree().change_scene_to_file("res://scenes/ui/ending-lel khesrin.tscn")
func update_background():
	for i in range(WIN_TARGET + 1):
		var bg = get_node_or_null("bg" + str(i))
		if bg:
			bg.visible = (i == correct_answers)

func find_match(input: String) -> String:
	for title in lower_movies:
		if input.similarity(title) >= MATCH_THRESHOLD:
			return title
	return ""

func _on_NextButton_pressed():
	get_tree().change_scene_to_file(MAP_SCENE)
