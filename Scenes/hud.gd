extends CanvasLayer

@onready var stopwatch_label := $Control/StopwatchLabel
@onready var lap_label := $Control/LapLabel
@onready var pos_label := $Control/PositionLabel

# ============================
# NORMAL RACE HUD
# ============================

func update_stopwatch(ms: int) -> void:
	var minutes = ms / 60000
	var seconds = (ms % 60000) / 1000.0
	stopwatch_label.text = "%02d:%05.2f" % [minutes, seconds]

func update_lap(current: int, total: int) -> void:
	lap_label.text = "Lap: %d/%d" % [current, total]

func update_position(pos: int, total: int) -> void:
	var suffix := "th"
	if pos == 1: suffix = "st"
	elif pos == 2: suffix = "nd"
	elif pos == 3: suffix = "rd"
	pos_label.text = "%d%s/%d" % [pos, suffix, total]
