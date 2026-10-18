extends Control

@onready var timer_label: Label = $TimerLabel
@onready var timer: Timer = $Timer

func _ready():
	timer.wait_time = 60
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	timer_label.text = "60"
	timer.start()

func _process(_delta):
	timer_label.text = str(ceil(timer.time_left))

func _on_timer_timeout():
	timer_label.text = "TIME'S UP!"
