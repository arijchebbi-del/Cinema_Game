extends Label

var full_text: String = ""

func _ready():
	full_text = text
	text = ""

	for i in range(full_text.length()):
		text += full_text[i]
		await get_tree().create_timer(0.06).timeout
