extends CanvasLayer

@onready var stopwatch_label := $Control/StopwatchLabel
@onready var lap_label := $Control/LapLabel
@onready var pos_label := $Control/PositionLabel

# COP CHASE HUD NODES
@onready var cop_timer_label := $Control/CopTimerLabel
@onready var cop_captured_label := $Control/CopCapturedLabel
@onready var emp_lock_label := $Control/EmpLockLabel
@onready var crosshair_draw := $Control/CrosshairDraw

# ============================
# COP CHASE HUD
# ============================

func update_cop_timer(seconds_left: int) -> void:
	if GameMode.game_mode != "Cop Chase":
		return
	var minutes = seconds_left / 60
	var seconds = seconds_left % 60
	cop_timer_label.text = "%02d:%02d" % [minutes, seconds]

func update_captured(count: int, total: int) -> void:
	if GameMode.game_mode != "Cop Chase":
		return
	cop_captured_label.text = "%d/%d" % [count, total]

func show_emp_lock(countdown: int) -> void:
	if GameMode.game_mode != "Cop Chase":
		return
	emp_lock_label.text = "LOCKING %d" % countdown
	crosshair_draw.set_crosshair(true)

func hide_emp_lock() -> void:
	emp_lock_label.text = ""
	crosshair_draw.set_crosshair(false)

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
