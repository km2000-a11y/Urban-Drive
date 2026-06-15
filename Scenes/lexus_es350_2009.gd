extends CarController

# COSMETIC INFO (UI only)
var car_name := "Kuro Zephyr V6"
var country := "Japan"
var engine := "V6 3.5L"
var weight_kg := 1624
var zero_to_hundred_display := 5.80

func _ready():
	# GAMEPLAY STATS
	mass = 1624.0
	horsepower = 272
	max_rpm = 6200.0
	zero_to_hundred = 5.8
	top_speed_kmh = 242
	turn_speed = 2.45           # Slightly lower raw turn speed due to FWD understeer
	brake_strength = 11.2       # Lighter body requires slightly less braking effort
	lateral_friction = 1.05     # High front-end grip to pull through tight lines
	transmission = "Front wheel drive"

	# ES350-style handling (soft, stable, point-and-shoot, hard to spin)
	handling_type = "balanced"

	# Toyota 2GR-FE V6 6-Speed Gearing (aggressively short early gears for that 5.8s launch)
	gear_count = 6
	gear_ratios = [
		3.30,  # 1st - aggressive launch torque
		2.00,  # 2nd - keeping the 5.8s acceleration alive
		1.42,  # 3rd
		1.00,  # 4th
		0.71,  # 5th
		0.61   # 6th - top speed cruising
	]
	shift_up_rpm = 5900        # V6 revs a bit higher than the LS430's V8
	shift_down_rpm = 2500

	apply_stats()
	print("Child READY loaded:", car_name)
