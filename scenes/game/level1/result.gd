extends Control

@onready var choice_screen = $ChoiceScreen
@onready var actor_button = $ChoiceScreen/ButtonsBox/ActorButton
@onready var director_button = $ChoiceScreen/ButtonsBox/DirectorButton

@onready var actor_game = $ActorGame
@onready var director_game = $DirectorGame
@onready var complete_screen = $CompleteScreen

func _ready():
	Global.make_all_buttons_transparent()

	# Hide game screens initially so only ChoiceScreen is interactive
	actor_game.hide()
	director_game.hide()
	complete_screen.hide()
	choice_screen.show()

	# Connect button signals dynamically
	if not actor_button.pressed.is_connected(_on_actor_button_pressed):
		actor_button.pressed.connect(_on_actor_button_pressed)

	if not director_button.pressed.is_connected(_on_director_button_pressed):
		director_button.pressed.connect(_on_director_button_pressed)

func _on_actor_button_pressed():
	choice_screen.hide()
	actor_game.show()

func _on_director_button_pressed():
	choice_screen.hide()
	director_game.show()
