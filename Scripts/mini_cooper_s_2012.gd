extends CarController

# COSMETIC INFO (UI only)
var car_name := "Comet Spryte"
var country := "UK"
var engine := "1.6L I4 Supercharged"
var weight_kg := 1210
var zero_to_hundred_display := 6.9

func _ready():
	# GAMEPLAY STATS
	mass = 1210.0
	horsepower = 181
	max_rpm = 6500.0
	zero_to_hundred = 6.9
	top_speed_kmh = 225
	turn_speed = 3.0
	brake_strength = 12.0
	lateral_friction = 1.12
	transmission = "Front-wheel drive"

	# ARCADE GEAR RATIOS (Mini but fun)
	gear_count = 6
	gear_ratios = [3.20, 2.00, 1.40, 1.10, 0.90, 0.78]
	shift_up_rpm = 6450
	shift_down_rpm = 2000

	apply_stats()
	print("Child READY loaded:", car_name)
