extends CanvasLayer

signal countdown_finished   # 🔥 ADD THIS

@onready var label := $Control/CountdownLabel

var cars := []

func start_countdown():
	# Freeze cars
	cars = get_tree().get_nodes_in_group("cars")
	for c in cars:
		if c is CarController:
			c.controls_enabled = false

	visible = true
	label.text = "3"
	await get_tree().create_timer(1.0).timeout

	label.text = "2"
	await get_tree().create_timer(1.0).timeout

	label.text = "1"
	await get_tree().create_timer(1.0).timeout

	label.text = "GO!"
	await get_tree().create_timer(0.7).timeout

	# Unfreeze cars
	for c in cars:
		if c is CarController:
			c.controls_enabled = true

	visible = false

	emit_signal("countdown_finished")   # 🔥 FIRE THE SIGNAL
