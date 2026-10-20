extends Node

const MATCH_THRESHOLD = 0.75
const TIME_LIMIT = 40.0
const ENDING_SCENE = "res://scenes/ui/ending-lel khesrin.tscn"
const MAP_SCENE = "res://scenes/game/map.tscn"

var game_over = false
var answer: String = ""

@onready var actors = [$actor1, $actor2, $actor3, $actor4]
@onready var guess_input: LineEdit = $LineEdit
@onready var next_button: Button = $Button
@onready var timer_label = get_node_or_null("TimerLabel")   # optional
var timer: Timer

func _ready():
	Global.make_all_buttons_transparent()

	# Timer created in code, so you don't need a Timer node
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = TIME_LIMIT
	timer.timeout.connect(_on_timeout)
	add_child(timer)

	next_button.hide()
	next_button.pressed.connect(_on_NextButton_pressed)

	var movie = get_random_movie()
	if movie.is_empty():
		push_error("No movie data found")
		return

	var keys = ["cast1", "cast2", "cast3", "cast4"]
	for i in range(4):
		set_picture(actors[i], movie[keys[i]])

	answer = movie["title"]

	timer.start()
	if timer_label:
		timer_label.text = "Time: %d" % int(TIME_LIMIT)
	guess_input.grab_focus()

func set_picture(node, tex: Texture2D):
	# works whether actor1..4 are TextureRect or TextureButton
	if node is TextureButton:
		node.texture_normal = tex
	elif node is TextureRect or node is Sprite2D:
		node.texture = tex

func _process(_delta):
	if timer_label and not timer.is_stopped():
		timer_label.text = "Time: %d" % ceil(timer.time_left)

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
	
	# Extract image paths from the nested array of objects
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
	if ResourceLoader.exists(path):
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
	game_over = true
	timer.stop()
	Global.add_score("guessmovie", 5)
	Global.mark_won("GuessMovie")
	guess_input.hide()
	next_button.show()

func _on_timeout():
	if game_over:
		return
	game_over = true
	get_tree().change_scene_to_file(ENDING_SCENE)

func find_match(input: String) -> String:
	if input.similarity(answer.to_lower()) >= MATCH_THRESHOLD:
		return answer
	return ""

func _on_NextButton_pressed():
	get_tree().change_scene_to_file(MAP_SCENE)
