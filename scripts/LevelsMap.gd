extends Control

const GAMES = ["GuessMovie", "MovieQuestions", "ActorDirector"]


func _ready():
	# Update button states and background
	update_game_select_display()
	Global.make_all_buttons_transparent()
	# Listen for game won events
	Global.game_won.connect(_on_game_won)

func update_game_select_display():
	update_button_states()
	update_background_texture()




func update_button_states():
	var buttons = {
		"GuessMovie": $GuessMovieButton,
		"MovieQuestions": $MovieQuestionsButton,
		"ActorDirector": $ActorDirectorButton,
	}

	# Games not won yet
	var remaining = []
	for g in GAMES:
		if not Global.is_game_won(g):
			remaining.append(g)

	var won_count = GAMES.size() - remaining.size()

	if won_count == 1:
		# Pick the second game randomly, but only once
		if Global.next_game == "" or Global.is_game_won(Global.next_game):
			Global.next_game = remaining.pick_random()

		# Only the randomly chosen game is clickable
		for g in GAMES:
			buttons[g].disabled = (g != Global.next_game)
	else:
		# 0 won: free choice. 2 won: only the last one remains.
		Global.next_game = ""
		for g in GAMES:
			buttons[g].disabled = Global.is_game_won(g)
	
# NEW: Update background TextureRect based on game states
func update_background_texture():
	# Get game states: [GuessMovie, MovieQuestions, ActorDirector]
	var game1_won = Global.is_game_won("GuessMovie")      # Position 1
	var game2_won = Global.is_game_won("MovieQuestions") # Position 2  
	var game3_won = Global.is_game_won("ActorDirector") # Position 3
	
	# Build XOX string: Game1 + Game2 + Game3
	var background_name = ""
	background_name += "X" if game1_won else "O"
	background_name += "X" if game2_won else "O"
	background_name += "X" if game3_won else "O"
	
	print("Game state: ", background_name, " (", game1_won, ",", game2_won, ",", game3_won, ")")
	
	# Hide ALL background TextureRects first
	for i in range(7):
		var texture = get_node(get_child(i).get_path())
		print(texture)
		if texture:
			texture.visible = false
	
	# Show the correct background
	var correct_bg = get_node_or_null(background_name)
	if correct_bg:
		correct_bg.visible = true
		print("Showing background: ", background_name)
	else:
		print("WARNING: Background '", background_name, "' not found!")

func _on_game_won(_game_name: String):
	# Update display when game is won
	update_game_select_display()

func _on_Lock1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/level3/options.tscn")

func _on_Lock2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/level 2/level 2;film posters.tscn")

func _on_Lock3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/level1/level_1_backup.tscn")
