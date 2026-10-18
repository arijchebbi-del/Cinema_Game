extends Control

var game_over = false
var correct_answers = 0
const MATCH_THRESHOLD = 0.8
var question
var answer : String
@onready var title_label: Label = $TitleLabel
@onready var poster: TextureRect = $Poster
@onready var question_label: Label = $QuestionLabel

func _ready():
	var movie = Global.selected_movie
	title_label.text = movie["title"]
	poster.texture = load(movie["poster path"])
	question = movie["questions"].pick_random()
	question_label.text = question["q"]
	answer = question["a"]
	
	# Set timer to 30 seconds
	$Timer.wait_time = 30.0
	$Timer.one_shot = true
	$Timer.timeout.connect(_on_timeout)
	$Timer.start()
	
	# Update timer display
	$TimerLabel.text = "Time: 30"
	
	# Make GameSelect buttons transparent
	Global.make_all_buttons_transparent()
	
	
	$NextButton.hide()
	
func _process(_delta):
	# Update timer display every frame
	if $Timer.is_stopped() == false:
		$TimerLabel.text = "Time: %d" % ceil($Timer.time_left)
		
func _input(event):
	if game_over or not event.is_action_pressed("ui_accept") or event.is_echo():
		return
	var input = $GuessInput.text.strip_edges().to_lower()
	var match_answer = find_match(input)
	
	if match_answer != "":
		correct_answers += 1
		if correct_answers == 1:
			check_win()
	$GuessInput.text = ""

func check_win():
	if game_over:
		return
	game_over = true
	$Timer.stop()
	if correct_answers == 1:
		Global.add_score("moviequestions", 5)
		$NextButton.show()
	else:
		Global.game_lost.emit()
		get_tree().change_scene_to_file("res://scenes/Result.tscn")
		


func _on_timeout():
	# Timer expired
	check_win()

func find_match(input: String) -> String:
	if input.similarity(answer.to_lower()) >= MATCH_THRESHOLD:
		return answer
	return ""
		
func _on_NextButton_pressed():
	get_tree().change_scene_to_file("res://scenes/game/map.tscn")
