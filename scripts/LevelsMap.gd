extends Control

const GAMES = ["GuessMovie", "MovieQuestions", "ActorDirector"]


# Which button opens which game
@onready var buttons = {
	"ActorDirector": $Lock3,
	"MovieQuestions": $Lock2,
	"GuessMovie": $Lock1,
}


func _ready():
	Global.make_all_buttons_transparent()

	$Lock1.pressed.connect(_on_Lock1_pressed)
	$Lock2.pressed.connect(_on_Lock2_pressed)
	$Lock3.pressed.connect(_on_Lock3_pressed)

	if Global.has_signal("game_won"):
		Global.game_won.connect(_on_game_won)

	update_button_states()

func update_button_states():
	var remaining = []
	for g in GAMES:
		if not Global.is_game_won(g):
			remaining.append(g)


	Global.next_game = ""
	for g in GAMES:
		buttons[g].disabled = Global.is_game_won(g)

func _on_game_won(_game_name: String):
	update_button_states()

func _on_Lock1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/level 3/options.tscn")

func _on_Lock2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/level 2/level 2;film posters.tscn")

func _on_Lock3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/level1/level_1_backup.tscn")
