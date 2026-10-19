extends Control

func _ready():
	Global.make_all_buttons_transparent()

	$ChoiceScreen.show()
	$ActorGame.hide()
	$DirectorGame.hide()

	$ChoiceScreen/ButtonsBox/ActorButton.pressed.connect(_on_ActorButton_pressed)
	$ChoiceScreen/ButtonsBox/DirectorButton.pressed.connect(_on_DirectorButton_pressed)

func _on_ActorButton_pressed() -> void:
	$ChoiceScreen.hide()
	$ActorGame.show()
	$ActorGame.start_game()

func _on_DirectorButton_pressed() -> void:
	$ChoiceScreen.hide()
	$DirectorGame.show()
	$DirectorGame.start_game()
