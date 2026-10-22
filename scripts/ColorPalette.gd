extends Control

var game_over = false
var correct_answers = 0
const MATCH_THRESHOLD = 0.75
var answer : String





func _ready():
	var movie=get_random_movie()
	if movie.is_empty():
		return
	
	$palette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$palette.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	$palette.texture = movie["color palette"]
	answer = movie["title"]
	Global.current_game="palette"
	Global.current_movie=movie
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
	$NextButton.pressed.connect(_on_NextButton_pressed)

func _process(_delta):
	# Update timer display every frame
	if $Timer.is_stopped() == false:
		$TimerLabel.text = "Time: %d" % ceil($Timer.time_left)

func get_random_movie() -> Dictionary:
	var file = FileAccess.open("res://Data/ColorPalette.json", FileAccess.READ)
	if file == null:
		push_error("Could not open colorpalette.json")
		return {}

	var movies = JSON.parse_string(file.get_as_text())
	

	var entry = movies.pick_random()
	return {
		"title": entry["title"],
		"color palette": load(entry["color palette"]),   # Texture2D
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
	var won: bool
	won = correct_answers >= 1
	
	if won:
		Global.add_score("guessmovie", 5)
		Global.mark_won("GuessMovie")
	Global.last_won = won
	
	get_tree().change_scene_to_file("res://scenes/ui/LevelResult.tscn")

func _on_timeout():
	# Timer expired
	check_win()

func find_match(input: String) -> String:
	if input.similarity(answer.to_lower()) >= MATCH_THRESHOLD:
		return answer
	return ""
		
func _on_NextButton_pressed():
	get_tree().change_scene_to_file("res://scenes/game/map.tscn")
