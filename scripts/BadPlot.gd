extends Control

var game_over = false
var correct_answers = 0
const MATCH_THRESHOLD = 0.75
var answer : String

@onready var plot: Label = $Descrip


func _ready():
	var movie=get_random_movie()
	if movie.is_empty():
		return
	
	$Descrip.text = movie["plot descrip"]
	answer = movie["title"]
	
	# Set timer to (40 seconds)
	$Timer.wait_time = 40.0
	$Timer.one_shot = true
	$Timer.timeout.connect(_on_timeout)
	$Timer.start()
	
	
	# Update timer display
	$TimerLabel.text = "Time: 40"
	
	# Make GameSelect buttons transparent
	Global.make_all_buttons_transparent()
	
	
	$NextButton.hide()

func _process(_delta):
	# Update timer display every frame
	if $Timer.is_stopped() == false:
		$TimerLabel.text = "Time: %d" % ceil($Timer.time_left)

func get_random_movie() -> Dictionary:
	var file = FileAccess.open("res://Data/BadPlotDescrip.json", FileAccess.READ)
	if file == null:
		push_error("Could not open colorpalette.json")
		return {}

	var movies = JSON.parse_string(file.get_as_text())
	

	var entry = movies.pick_random()
	return {
		"title": entry["title"],
		"plot descrip": load(entry["plot descrip"]),   # Texture2D
	}
	
func _input(event):
	if game_over or not event.is_action_pressed("ui_accept") or event.is_echo():
		return
	var input = $GuessInput.text.strip_edges().to_lower()
	var match_title = find_match(input)
	
	if match_title != "" :
		correct_answers += 1
		
		if correct_answers ==1 :
			check_win()
	$GuessInput.text = ""

func check_win():
	if game_over:
		return
	game_over = true
	$Timer.stop()
	if correct_answers == 1:
		Global.add_score("guessmovie", 5)
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
