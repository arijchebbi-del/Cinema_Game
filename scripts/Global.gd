extends Node
var next_game: String = ""
var score: int = 0
var games_won: int = 0
var total_games: int = 3
var selected_movie: Dictionary = {} #level2
var current_movie: Dictionary = {}
var current_game: String=""
var current_question
var last_won: bool


# Track individual game wins
var GuessMovie: bool = false
var MovieQuestions: bool = false
var ActorDirector: bool = false
var last_result: String = ""
signal game_won(game_name: String, points: int)
signal game_lost()

var won_games: Array = []

func mark_won(game_name: String) -> void:
	if not won_games.has(game_name):
		won_games.append(game_name)


func add_score(game_name: String, points: int):
	score += points
	games_won += 1
	match game_name.to_lower():
		"guessmovie":
			GuessMovie = true
		"moviequestions":
			MovieQuestions = true
		"actordirector":
			ActorDirector = true
	
	game_won.emit(game_name, points)
	print("Game Won: ", game_name, " | Total Score: ", score, "/15 (", games_won, "/", total_games, " games won)")

func is_game_won(game_name: String) -> bool:
	match game_name.to_lower():
		"guessmovie": return GuessMovie
		"moviequestions": return MovieQuestions
		"actordirector": return ActorDirector
	return false

func check_victory() -> bool:
	return games_won >= total_games

func make_button_transparent(button: Button):
	var transparent_style = StyleBoxFlat.new()
	transparent_style.bg_color = Color.TRANSPARENT
	
	# Apply to ALL button states
	button.add_theme_stylebox_override("pressed", transparent_style)
	button.add_theme_stylebox_override("hover", transparent_style)
	button.add_theme_stylebox_override("focus", transparent_style)
	button.add_theme_stylebox_override("disabled", transparent_style)
	button.add_theme_stylebox_override("normal", transparent_style)
	
	#button.disabled=true

func make_all_buttons_transparent():
	var buttons = get_tree().get_nodes_in_group("buttons")
	for button in buttons:
		if button is Button:
			make_button_transparent(button)
	
	# Also make specific scene buttons transparent (fallback)
	var root = get_tree().current_scene
	if root:
		for child in root.get_children():
			if child is Button:
				make_button_transparent(child)
			# Check grandchildren too
			for grandchild in child.get_children():
				if grandchild is Button:
					make_button_transparent(grandchild)
					
func reset_game():
	score = 0
	games_won = 0
	GuessMovie = false
	MovieQuestions = false
	ActorDirector = false
	won_games.clear()
	selected_movie = {}
	current_movie = {}
	current_game = ""
	current_question = null
	last_won = false
	last_result = ""
	next_game = ""
