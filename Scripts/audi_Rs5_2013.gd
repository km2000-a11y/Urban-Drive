extends CarController

# COSMETIC INFO (UI only)
var car_name := "Schroder Predator"
var country := "Germany"
var engine := "V8 4.2L"
var weight_kg := 1780
var zero_to_hundred_display := 4.60

func _ready():
	# GAMEPLAY STATS
	mass = 1780.0
	horsepower = 450
	max_rpm = 7000.0
	zero_to_hundred = 4.6
	top_speed_kmh = 284
	turn_speed = 2.80              # Heavy AWD coupe, stable but not razor sharp
	brake_strength = 13.8           # Big RS brakes
	lateral_friction = 1.16         # Quattro grip advantage
	transmission = "Four wheel drive"

	# RS5 handling: planted, grippy, heavy front, stable at high speed
	

	# Audi 7‑speed S‑tronic dual‑clutch (RS5 gearbox)
	gear_count = 7
	gear_ratios = [
		3.19,  # 1st - strong AWD launch
		2.19,  # 2nd - big midrange shove
		1.52,  # 3rd
		1.05,  # 4th
		0.79,  # 5th
		0.67,  # 6th
		0.56   # 7th - long overdrive for 280+ km/h
	]

	shift_up_rpm = 6800
	shift_down_rpm = 3000

	apply_stats()
	print("Child READY loaded:", car_name)
