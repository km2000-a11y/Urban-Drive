extends CarController

# COSMETIC INFO (UI only)
var car_name := "Comet Spryte"
var country := "UK"
var engine := "1.6L I4 Supercharged"
var weight_kg := 1210
var top_speed_kmh := 225
var zero_to_hundred_display := 6.9

func _ready():
	# GAMEPLAY STATS (override parent defaults)
	mass = 1210.0
	horsepower = 181
	max_rpm = 6500.0
	zero_to_hundred = 6.9
	top_speed = 62.5          # 225 km/h
	turn_speed = 3.0
	brake_strength = 19.0
	lateral_friction = 1.12
	transmission = "Front-wheel drive"

	# IMPORTANT: Recalculate torque + accel AFTER overrides
	apply_stats()
	print("Child READY loaded:", car_name)
