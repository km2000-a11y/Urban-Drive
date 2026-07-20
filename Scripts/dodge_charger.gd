extends CarController

# COSMETIC INFO (UI only)
var def_car_name := "Brutus Mammoth"
var country := "USA"
var engine := "V8 5.7L"
var weight_kg := 1828
var zero_to_hundred_display := 5.90

func _ready():
	# GAMEPLAY STATS — American RWD muscle sedan
	mass = 1828.0
	horsepower = 340
	max_rpm = 5800.0                 # Classic 5.7L pushrod V8, strong low-end torque
	zero_to_hundred = 5.9
	top_speed_kmh = 253
	turn_speed = 2.35                # Heavier steering feel; stable but not razor-sharp
	brake_strength = 11.0            # Muscle-sedan braking: strong but not sports-car level
	lateral_friction = 1.02          # RWD grip with slight looseness under throttle
	transmission = "Rear wheel drive"

	# Brutus Heavy-Duty 5-Speed Muscle Gearbox
	# Tuned for torque delivery, highway pull, and classic American muscle feel
	gear_count = 5
	gear_ratios = [
		2.92,  # 1st - big torque hit off the line
		1.96,  # 2nd - keeps the Mammoth in its mid-range grunt
		1.46,  # 3rd
		1.00,  # 4th - direct drive for strong acceleration
		0.74   # 5th - long overdrive for 253 km/h
	]
	shift_up_rpm = 5600
	shift_down_rpm = 2400

	# DISTINCT HANDLING PROFILE — Big, loud, American muscle sedan
	handling_type = "muscle_sedan"

	apply_stats()
	print("Child READY loaded:", def_car_name)
