extends Control

var game_over = false
var correct_answers = 0
const MATCH_THRESHOLD = 0.3
var question
var answer : String

@onready var poster: TextureRect = $"poster frame/poster image"
@onready var question_label: Label = $"question label"
@onready var guess_input: LineEdit = $answer
@onready var next_button: Button = $Button
@onready var timer: Timer = $Timer
@onready var timer_label: Label = $TimerLabel

func _ready():
	var movie = Global.selected_movie
	if movie == null or movie.is_empty():
		push_error("Global.selected_movie is empty")
		return

	# Poster
	var path: String = movie["poster path"]
	if ResourceLoader.exists(path):
		poster.texture = load(path)
	else:
		push_error("Poster not found: " + path)

	# Question
	question = movie["questions"].pick_random()
	question_label.text = question["q"]
	answer = question["a"]

	# Timer
	timer.wait_time = 30.0
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)
	timer.start()
	timer_label.text = "Time: 30"

	Global.make_all_buttons_transparent()

	next_button.hide()
	next_button.pressed.connect(_on_NextButton_pressed)

func _process(_delta):
	if not timer.is_stopped():
		timer_label.text = "Time: %d" % ceil(timer.time_left)

func _input(event):
	if game_over or not event.is_action_pressed("ui_accept") or event.is_echo():
		return
	var input = guess_input.text.strip_edges().to_lower()
	if find_match(input) != "":
		correct_answers += 1
		check_win()
	guess_input.text = ""

func check_win():
	if game_over:
		return
	game_over = true
	timer.stop()
	if correct_answers >= 1:
		Global.add_score("moviequestions", 5)
		next_button.show()
	else:
		Global.game_lost.emit()
		get_tree().change_scene_to_file("res://scenes/ui/ending-lel khesrin.tscn")

func _on_timeout():
	check_win()

func find_match(input: String) -> String:
	if input.similarity(answer.to_lower()) >= MATCH_THRESHOLD:
		return answer
	return ""

func _on_NextButton_pressed():
	get_tree().change_scene_to_file("res://scenes/game/map.tscn")
