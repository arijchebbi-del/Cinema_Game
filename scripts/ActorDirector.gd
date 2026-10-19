extends Control

@onready var choice_screen: Control = $ChoiceScreen
@onready var actor_game: Control = $ActorGame
@onready var director_game: Control = $DirectorGame
@onready var complete_screen: Control = $CompleteScreen

func _ready() -> void:
	Global.make_all_buttons_transparent()
	
	$ChoiceScreen/ButtonsBox/ActorButton.pressed.connect(_on_actor_button_pressed)
	$ChoiceScreen/ButtonsBox/DirectorButton.pressed.connect(_on_director_button_pressed)
	
	actor_game.game_completed.connect(_on_game_completed)
	director_game.game_completed.connect(_on_game_completed)
	
	choice_screen.show()
	actor_game.hide()
	director_game.hide()
	complete_screen.hide()

func _on_actor_button_pressed() -> void:
	choice_screen.hide()
	director_game.hide()
	actor_game.show()

func _on_director_button_pressed() -> void:
	choice_screen.hide()
	actor_game.hide()
	director_game.show()

func _on_game_completed(_won: bool) -> void:
	actor_game.hide()
	director_game.hide()
	choice_screen.hide()
	
	complete_screen.show()
	if complete_screen.has_method("update_result_display"):
		complete_screen.update_result_display()
