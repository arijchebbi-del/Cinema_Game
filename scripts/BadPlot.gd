extends Control

const MATCH_THRESHOLD = 0.7

var game_over = false
var correct_answers = 0
var answer: String

@onready var plot_label: Label = $Label
@onready var guess_input: LineEdit = $LineEdit
@onready var next_button: Button = $Button
@onready var timer: Timer = $Timer

@onready var timer_label: Label = $TimerLabel


var time_left := 40.0

func _ready():
	# Start the countdown first, so a data problem can't block it
	time_left = 40.0
	timer.wait_time = time_left
	timer.one_shot = true
	if not timer.timeout.is_connected(_on_timeout):
		timer.timeout.connect(_on_timeout)
	timer.start()
	timer_label.text = "Time: 40"
	print("timer started, label = ", timer_label)

	guess_input.text_submitted.connect(_on_guess_submitted)
	next_button.pressed.connect(_on_next_button_pressed)
	next_button.hide()

	var movie = get_random_movie()
	Global.current_game="plot"
	Global.current_movie=movie
	if movie.is_empty():
		plot_label.text = "Failed to load movie data"
		return

	plot_label.text = movie["plot descrip"]
	answer = movie["title"]

	Global.make_all_buttons_transparent()
	guess_input.grab_focus()


func _process(delta):
	if game_over:
		return
	time_left = max(time_left - delta, 0.0)
	timer_label.text = "Time: %d" % ceil(time_left)

func get_random_movie() -> Dictionary:
	var file = FileAccess.open("res://Data/BadPlotDescrip.json", FileAccess.READ)
	if file == null:
		push_error("Could not open BadPlotDescrip.json")
		return {}

	var movies = JSON.parse_string(file.get_as_text())
	if movies == null or not movies is Array or movies.is_empty():
		push_error("Invalid JSON in BadPlotDescrip.json")
		return {}

	var entry = movies.pick_random()
	return {
		"title": entry["title"],
		"plot descrip": entry["plot descrip"],  # plain String
	}


func _on_guess_submitted(text: String):
	if game_over:
		return
	var input = text.strip_edges().to_lower()
	if find_match(input) != "":
		correct_answers += 1
		check_win()
	guess_input.text = ""


func check_win():
	if game_over:
		return
	game_over = true
	$Timer.stop()
	var won: bool
	won = correct_answers >= 1
	
	if won:
		Global.add_score("guessmovie", 5)
		Global.mark_won("guessmovie")
	Global.last_won = won
	
	get_tree().change_scene_to_file("res://scenes/ui/LevelResult.tscn")



func _on_timeout():
	check_win()


func find_match(input: String) -> String:
	if input.similarity(answer.to_lower()) >= MATCH_THRESHOLD:
		return answer
	return ""


func _on_next_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game/map.tscn")
