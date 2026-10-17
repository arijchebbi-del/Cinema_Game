extends Control

func _ready():
	# Hide ALL backgrounds first
	for i in [0, 5, 10, 15]:
		var bg = get_node_or_null(str(i))
		if bg:
			bg.visible = false
	
	# Show correct background based on score
	var score = Global.score
	var correct_bg = get_node_or_null(str(score))
	if correct_bg:
		correct_bg.visible = true
		print("Showing result background: ", score)
	else:
		# Fallback to 0 if score is invalid
		get_node("0").visible = true
		print("Invalid score, showing 0")
	
	# Make GameSelect buttons transparent
	Global.make_all_buttons_transparent()

func _on_RestartButton_pressed():
	Global.reset_game()
	get_tree().change_scene_to_file("res://Scenes/StartingPoint.tscn")

func _input(event):
	if event.is_action_pressed("ui_enter"):
		_on_RestartButton_pressed()
