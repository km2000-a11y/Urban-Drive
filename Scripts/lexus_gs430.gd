extends CarController

# COSMETIC INFO (UI only)
var def_car_name := "Kuro Persian"
var country := "Japan"
var engine := "V8 4.3L"
var weight_kg := 1660
var zero_to_hundred_display := 6.10

func _ready():
	# GAMEPLAY STATS — Smooth, torquey Japanese executive sedan
	mass = 1660.0
	horsepower = 278
	max_rpm = 6200.0                 # 3UZ‑FE V8: silky, mature, effortless mid‑range pull
	zero_to_hundred = 5.8
	top_speed_kmh = 258
	turn_speed = 2.45                # Calm steering; precise but not aggressive
	brake_strength = 11.4            # Confident Lexus brakes; strong without being sporty harsh
	lateral_friction = 1.06          # Balanced RWD grip with smooth cornering behavior
	transmission = "Rear wheel drive"

	# Kuro Executive 5-Speed V8 Gearbox
	# Tuned for smooth torque delivery, refined acceleration, and highway elegance
	gear_count = 5
	gear_ratios = [
		3.36,  # 1st - smooth but strong launch, not violent
		2.04,  # 2nd - keeps the Persian in its torque-rich mid-range
		1.40,  # 3rd
		1.00,  # 4th - direct drive for refined pull
		0.75   # 5th - long overdrive for quiet 248 km/h cruising
	]
	shift_up_rpm = 6000
	shift_down_rpm = 2500

	# DISTINCT HANDLING PROFILE — Calm, elegant, torquey executive sedan
	handling_type = "executive_sedan"

	apply_stats()
	print("Child READY loaded:", def_car_name)
