extends Node

const MATCH_THRESHOLD = 0.6
const TIME_LIMIT = 40.0
const ENDING_SCENE = "res://scenes/ui/ending-lel khesrin.tscn"
const MAP_SCENE = "res://scenes/game/map.tscn"

var game_over = false
var answer: String = ""

@onready var actors = [$actor1, $actor2, $actor3, $actor4]
@onready var guess_input: LineEdit = $LineEdit
@onready var next_button: Button = $Button
@onready var timer_label: Label = $TimerLabel
@onready var timer: Timer = $Timer

func _ready():
	Global.make_all_buttons_transparent()

	# Configure the Timer node from the scene
	timer.one_shot = true
	timer.wait_time = TIME_LIMIT
	timer.timeout.connect(_on_timeout)

	next_button.hide()
	next_button.pressed.connect(_on_NextButton_pressed)

	var movie = get_random_movie()
	if movie.is_empty():
		push_error("No movie data found")
		return

	set_picture(actors[0], movie.get("cast1"))
	set_picture(actors[1], movie.get("cast2"))
	set_picture(actors[2], movie.get("cast3"))
	set_picture(actors[3], movie.get("cast4"))

	answer = movie.get("title", "")
	Global.current_game="cast"
	Global.current_movie=movie
	timer.start()
	guess_input.grab_focus()

func set_picture(node, tex: Texture2D):
	if tex == null:
		return
	if node is TextureButton:
		node.texture_normal = tex
	elif node is TextureRect or node is Sprite2D:
		node.texture = tex

func _process(_delta):
	if timer and not timer.is_stopped() and not game_over:
		timer_label.text = "Temps: %d s" % int(ceil(timer.time_left))

func get_random_movie() -> Dictionary:
	var file = FileAccess.open("res://Data/Cast.json", FileAccess.READ)
	if file == null:
		push_error("Could not open Cast.json")
		return {}
	var movies = JSON.parse_string(file.get_as_text())
	if movies == null or movies.is_empty():
		push_error("Cast.json is empty or invalid")
		return {}

	var entry = movies.pick_random()
	
	var cast_paths = {}
	if entry.has("cast") and entry["cast"] is Array:
		for item in entry["cast"]:
			for key in item:
				cast_paths[key] = item[key]

	return {
		"title": entry.get("title", ""),
		"cast1": load_pic(cast_paths.get("cast1", "").strip_edges()),
		"cast2": load_pic(cast_paths.get("cast2", "").strip_edges()),
		"cast3": load_pic(cast_paths.get("cast3", "").strip_edges()),
		"cast4": load_pic(cast_paths.get("cast4", "").strip_edges()),
	}

func load_pic(path: String) -> Texture2D:
	if path != "" and ResourceLoader.exists(path):
		return load(path)
	push_warning("Picture not found: " + path)
	return null

func _input(event):
	if game_over or not event.is_action_pressed("ui_accept") or event.is_echo():
		return
	var input = guess_input.text.strip_edges().to_lower()
	if find_match(input) != "":
		win()
		
	guess_input.text = ""

func win():
	if game_over:
		return
	game_over = true
	$Timer.stop()
	var won: bool
	won = true
	
	if won:
		Global.add_score("guessmovie", 5)
		Global.mark_won("guessmovie")

	Global.last_won = won
	
	get_tree().change_scene_to_file("res://scenes/ui/LevelResult.tscn")


func _on_timeout():
	if game_over:
		return
	game_over = true
	get_tree().change_scene_to_file("res://scenes/ui/LevelResult.tscn")

func find_match(input: String) -> String:
	if input.similarity(answer.to_lower()) >= MATCH_THRESHOLD:
		return answer
	return ""

func _on_NextButton_pressed():
	get_tree().change_scene_to_file(MAP_SCENE)
