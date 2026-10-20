extends Control


signal next_pressed

# ---------------- Config ----------------
## Scene loaded when pressing Next. Leave empty to only emit `next_pressed`
## (useful if a game manager handles the flow).
@export_file("*.tscn") var next_scene_path: String = ""

## Order must match how you store current_game if it's an int.
const GAME_NAMES := ["cast", "palette", "plot", "question"]

## Keys looked up when current_movie is a Dictionary / Object.
const TITLE_KEYS := "title"
const QUESTION_ANSWER_KEYS := ["question_answer", "answer", "correct_answer"]

const WIN_COLOR := Color("5ee07a")
const LOSS_COLOR := Color("ff5c5c")

# ---------------- Nodes ----------------
@onready var win_text: CanvasItem = $WinText
@onready var loss_text: CanvasItem = $LossText
@onready var next_button: Button = $NextButton
@onready var answer_container: Control = $AnswerContainer
@onready var answer_label: Label = $AnswerContainer/AnswerLabel

var _tween: Tween


func _ready() -> void:
	next_button.pressed.connect(_on_next_button_pressed)
	# Hidden until show_result() is called.
	win_text.hide()
	loss_text.hide()
	answer_container.modulate.a = 0.0
	next_button.disabled = true
	show_result(Global.last_won)


## Call this right after instancing/switching to the scene.
## `won`: whether the player answered correctly.

func show_result(won: bool) -> void:
	win_text.visible = won
	loss_text.visible = not won

	answer_label.text = _build_answer_text(won)
	answer_label.add_theme_color_override("font_color", WIN_COLOR if won else LOSS_COLOR)

	_play_intro(won)


# ---------------- Answer text ----------------
func _build_answer_text(won: bool) -> String:
	var title := _get_movie_title()
	var game := _get_game_name()
	var text := ""

	match game:
		"cast":
			text = "The movie was:%s" % title
		"palette":
			text = "The movie was:%s" % title
		"plot":
			text = "The movie was:%s" % title
		"question":
			var ans := _get_question_answer()
			if ans == "":
				ans = title
			text = "Correct answer:%s" % [ans]
		_:
			text = title


	return text


func _get_movie_title() -> String:
	var movie = Global.current_movie
	if movie == null:
		return "Unknown movie"
	if movie is String:
		return movie
	var value = movie["title"]
	return str(value) if value != null else "Unknown movie"


func _get_question_answer() -> String:
	var movie = Global.current_movie
	if movie == null or movie is String:
		return ""
	var value = Global.current_question["a"]
	return str(value) if value != null else ""


## Reads the first existing key from a Dictionary or Object/Resource.
func _lookup(source, keys: Array):
	for key in keys:
		if source is Dictionary:
			if source.has(key):
				return source[key]
		elif source is Object:
			var v = source.get(key)  # returns null if the property doesn't exist
			if v != null:
				return v
	return null


func _get_game_name() -> String:
	var game = Global.current_game
	if game is int:
		return GAME_NAMES[game] if game >= 0 and game < GAME_NAMES.size() else ""
	return str(game).to_lower()


# ---------------- Animation ----------------
func _play_intro(won: bool) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()

	var banner: Control = win_text if won else loss_text
	banner.modulate.a = 0.0
	banner.pivot_offset = banner.size / 2.0
	banner.scale = Vector2(0.6, 0.6)
	answer_container.modulate.a = 0.0
	next_button.disabled = false
	
	

	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(banner, "modulate:a", 1.0, 0.3)
	_tween.tween_property(banner, "scale", Vector2.ONE, 0.4) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.chain().tween_property(answer_container, "modulate:a", 1.0, 0.4)
	_tween.chain().tween_callback(func(): next_button.disabled = false)


# ---------------- Navigation ----------------
func _on_next_button_pressed() -> void:
	next_button.disabled = false
	next_pressed.emit()
	if Global.check_victory():
		get_tree().change_scene_to_file("res://scenes/ui/eding lel rebhin.tscn")
	else:
		if Global.last_won:
			get_tree().change_scene_to_file("res://scenes/game/map.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/ui/ending-lel khesrin.tscn")
