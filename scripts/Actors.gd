extends Control

var correct_answers = 0 
var actor
var game_over = false
var guessed: Array = []
var lower_movies: Array = [] 
const MATCH_THRESHOLD = 0.7

func _ready():
	actor=get_random_actor()
	if actor.is_empty():
		return
	$ActorName.text = actor["name"]
	$ActorPic.texture = actor["pic"]
	lower_movies=actor["movies"].map(func(m): return m.to_lower())
	
	# Set timer to 1 minute (60 seconds)
	$Timer.wait_time = 60.0
	$Timer.one_shot = true
	$Timer.timeout.connect(_on_timeout)
	$Timer.start()
	
	# Show initial background (0 correct)
	update_background()
	
	# Update timer display
	$TimerLabel.text = "Time: 60"
	
	# Make GameSelect buttons transparent
	Global.make_all_buttons_transparent()
	
	
	$NextButton.hide()

func _process(_delta):
	# Update timer display every frame
	if $Timer.is_stopped() == false:
		$TimerLabel.text = "Time: %d" % ceil($Timer.time_left)

func get_random_actor() -> Dictionary:
	var file = FileAccess.open("res://Data/Actors.json", FileAccess.READ)
	if file == null:
		push_error("Could not open actors.json")
		return {}

	var actors = JSON.parse_string(file.get_as_text())
	

	var entry = actors.pick_random()
	return {
		"name": entry["actor"],
		"pic": load(entry["pic path"]),   # Texture2D
		"movies": entry["movies they starred in"],   # Array of Strings
	}
	
func _input(event):
	if game_over or not event.is_action_pressed("ui_accept") or event.is_echo():
		return
	var input = $GuessInput.text.strip_edges().to_lower()
	var match_title = find_match(input)
	
	if match_title != "" and not guessed.has(match_title):
		guessed.append(match_title)
		correct_answers += 1
		update_background()
		if correct_answers >= 4:
			check_win()
	$GuessInput.text = ""

func check_win():
	if game_over:
		return
	game_over = true
	$Timer.stop()
	if correct_answers >= 4:
		Global.add_score("actordirector", 5)
		$NextButton.show()
	else:
		Global.game_lost.emit()
		get_tree().change_scene_to_file("res://scenes/Result.tscn")
		
func update_background():
	# Hide ALL backgrounds first
	for i in range(4):
		var bg = get_node_or_null("bg" + str(i))
		if bg:
			bg.visible = false
	

	if correct_answers <= 3:
		var current_bg = get_node_or_null("bg" + str(correct_answers))
		if current_bg:
			current_bg.visible = true
			print("Showing background: bg", correct_answers)
		else:
			print("WARNING: bg", correct_answers, " not found!")
			
			
			

func _on_timeout():
	# Timer expired
	check_win()

func find_match(input: String) -> String:
	for title in lower_movies:
		if input.similarity(title) >= MATCH_THRESHOLD:
			return title
	return ""

func _on_NextButton_pressed():
	get_tree().change_scene_to_file("res://scenes/game/map.tscn")
