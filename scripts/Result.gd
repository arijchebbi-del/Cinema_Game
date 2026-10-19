extends Control

func _ready() -> void:
	Global.make_all_buttons_transparent()
	
	if has_node("NextButton"):
		var next_btn = $NextButton
		if not next_btn.pressed.is_connected(_on_next_button_pressed):
			next_btn.pressed.connect(_on_next_button_pressed)

	update_result_display()

func update_result_display() -> void:
	var actor_won_node = get_node_or_null("ActorGameWon")
	var director_won_node = get_node_or_null("DirectorGameWon")
	var times_up_node = get_node_or_null("TimesUp")

	# Hide all result nodes first
	if actor_won_node: actor_won_node.hide()
	if director_won_node: director_won_node.hide()
	if times_up_node: times_up_node.hide()

	# Read result from Global
	var result = Global.get("last_result") if "last_result" in Global else ""

	# Show corresponding node
	match result:
		"actor_win":
			if actor_won_node: actor_won_node.show()
		"director_win":
			if director_won_node: director_won_node.show()
		"times_up":
			if times_up_node: times_up_node.show()
		_:
			if times_up_node: times_up_node.show()

func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/map.tscn")

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_accept"):
		_on_next_button_pressed()
