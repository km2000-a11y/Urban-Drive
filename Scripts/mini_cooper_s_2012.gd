extends CarController

# COSMETIC INFO (UI only)
var car_name := "Comet Spryte"
var country := "UK"
var engine := "L4 1.6L"
var weight_kg := 1210
var zero_to_hundred_display := 6.90

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

	# SHORTER, HOT HATCH GEARS
	gear_count = 6
	gear_ratios = [3.8, 2.4, 1.8, 1.4, 1.15, 0.95]
	shift_up_rpm = 6200
	shift_down_rpm = 2000

	# DISTINCT HANDLING PROFILE
	handling_type = "fwd_hot_hatch"

	# APPLY BASE STATS + HANDLING
	apply_stats()
	apply_handling_profile()

	# MINI-ONLY ACCELERATION BUFF
	

	print("Child READY loaded:", car_name)
