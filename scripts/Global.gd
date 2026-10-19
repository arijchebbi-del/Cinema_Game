extends Node

var score: int = 0
var games_won: int = 0
var total_games: int = 3
var selected_movie: Dictionary = {} #level2
var next_game : String

# Track individual game wins
var guess_movie: bool = false
var movie_questions: bool = false
var actor_director: bool = false

signal game_won(game_name: String, points: int)
signal game_lost()

func reset_game():
	score = 0
	games_won = 0
	guess_movie = false
	movie_questions = false
	actor_director = false

func add_score(game_name: String, points: int):
	score += points
	games_won += 1
	match game_name.to_lower():
		"guessmovie":
			guess_movie = true
		"moviequestions":
			movie_questions = true
		"actordirector":
			actor_director = true
	
	game_won.emit(game_name, points)
	print("Game Won: ", game_name, " | Total Score: ", score, "/15 (", games_won, "/", total_games, " games won)")

func is_game_won(game_name: String) -> bool:
	match game_name.to_lower():
		"guessmovie": return guess_movie
		"moviequestions": return movie_questions
		"actordirector": return actor_director
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
