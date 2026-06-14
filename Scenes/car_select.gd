extends CanvasLayer

var car_class = ""
var car_name = ""
var car_index = 0

# -------------------------
# CAR LISTS (ORDER MATTERS)
# -------------------------

var suv_list = ["Colossus Titan Max", "Colossus Behemoth", "Straeda Pitbull"]
var compact_list = ["Schroder Atrix Q32", "Straeda B32", "Zenith Horizon", "Straeda G25"]
var muscle_list = ["Brutus Viper", "Brutus Mauler"]
var urban_list = ["Kestrel Seabird", "Berkshire Blunt", "Brutus Stingray", "Kestrel Speedster"]
var sedans_list = ["Eisenach Monarch", "Kuro Vault"]
var sport_list = ["Berkshire V12-S", "Berkshire Tempest", "Bartoli Cruiser", "Eisenach Roadstar"]
var supercars_list = ["Linetti Terror", "Kestrel Battleaxe", "Linetti Shepherd", "Linetti Firestorm"]

# -------------------------
# CAR DICTIONARIES
# -------------------------

var suv = {
	"Colossus Titan Max":["301 PP","Country: USA","HP: 195","WEIGHT: 3500 KG","0-100 KM/H: 13.5s","TOP SPEED: 170 KM/H","ENGINE: V8 6.5L","TRANSMISSION: FOUR-WHEEL DRIVE"],
	"Colossus Behemoth":["399 PP","Country: USA","HP: 316","WEIGHT: 2900 KG","0-100 KM/H: 9.3s","TOP SPEED: 208 KM/H","ENGINE: V8 6.0L","TRANSMISSION: FOUR-WHEEL DRIVE"],
	"Straeda Pitbull":["436 PP","Country: Germany","HP: 309","WEIGHT: 2520 KG","0-100 KM/H: 7.8s","TOP SPEED: 225 KM/H","ENGINE: V10 5.0L","TRANSMISSION: FOUR-WHEEL DRIVE"]
}

var compact = {
	"Schroder Atrix Q32":["508 PP","Country: Germany","HP: 247","WEIGHT: 1470 KG","0-100 KM/H: 6.4s","TOP SPEED: 250 KM/H","ENGINE: V6 3.2L","TRANSMISSION: FOUR-WHEEL DRIVE"],
	"Straeda B32":["466 PP","Country: Germany","HP: 224","WEIGHT: 1500 KG","0-100 KM/H: 6.7s","TOP SPEED: 229 KM/H","ENGINE: V6 3.2L","TRANSMISSION: FOUR-WHEEL DRIVE"],
	"Zenith Horizon":["530 PP","Country: Japan","HP: 287","WEIGHT: 1460 KG","0-100 KM/H: 5.9s","TOP SPEED: 250 KM/H","ENGINE: V6 3.5L","TRANSMISSION: REAR-WHEEL DRIVE"],
	"Straeda G25":["489 PP","Country: Germany","HP: 197","WEIGHT: 1350 KG","0-100 KM/H: 6.9s","TOP SPEED: 233 KM/H","ENGINE: L4 2.0L","TRANSMISSION: FRONT-WHEEL DRIVE"]
}

var muscle = {
	"Brutus Viper":["528 PP","Country: USA","HP: 355","WEIGHT: 1650 KG","0-100 KM/H: 5.8s","TOP SPEED: 241 KM/H","ENGINE: V8 7.0L","TRANSMISSION: REAR-WHEEL DRIVE"],
	"Brutus Mauler":["540 PP","Country: USA","HP: 360","WEIGHT: 1780 KG","0-100 KM/H: 5.6s","TOP SPEED: 245 KM/H","ENGINE: V8 7.4L","TRANSMISSION: REAR-WHEEL DRIVE"]
}

var urban_racers = {
	"Kestrel Seabird":["543 PP","Country: UK","HP: 217","WEIGHT: 935 KG","0-100 KM/H: 4.3s","TOP SPEED: 238 KM/H","ENGINE: L4 1.8L","TRANSMISSION: REAR-WHEEL DRIVE"],
	"Berkshire Blunt":["546 PP","Country: UK","HP: 396","WEIGHT: 1832 KG","0-100 KM/H: 5.2s","TOP SPEED: 250 KM/H","ENGINE: V8 4.2L","TRANSMISSION: REAR-WHEEL DRIVE"],
	"Brutus Stingray":["601 PP","Country: USA","HP: 345","WEIGHT: 1460 KG","0-100 KM/H: 5.0s","TOP SPEED: 277 KM/H","ENGINE: V8 5.7L","TRANSMISSION: REAR-WHEEL DRIVE"],
	"Kestrel Speedster":["562 PP","Country: UK","HP: 286","WEIGHT: 1145 KG","0-100 KM/H: 4.5s","TOP SPEED: 243 KM/H","ENGINE: V8 4.4L","TRANSMISSION: REAR-WHEEL DRIVE"]
}

var sedans = {
	"Eisenach Monarch":["523 PP","Country: Germany","HP: 322","WEIGHT: 2050 KG","0-100 KM/H: 6.6s","TOP SPEED: 265 KM/H","ENGINE: V12 5.4L","TRANSMISSION: REAR-WHEEL DRIVE"],
	"Kuro Vault":["503 PP","Country: Japan","HP: 290","WEIGHT: 1760 KG","0-100 KM/H: 6.3s","TOP SPEED: 248 KM/H","ENGINE: V8 4.3L","TRANSMISSION: REAR-WHEEL DRIVE"]
}

var sport = {
	"Berkshire V12-S":["643 PP","Country: UK","HP: 450","WEIGHT: 1740 KG","0-100 KM/H: 5.1s","TOP SPEED: 300 KM/H","ENGINE: V12 5.9L","TRANSMISSION: REAR-WHEEL DRIVE"],
	"Berkshire Tempest":["648 PP","Country: UK","HP: 460","WEIGHT: 1875 KG","0-100 KM/H: 4.8s","TOP SPEED: 303 KM/H","ENGINE: V12 5.9L","TRANSMISSION: REAR-WHEEL DRIVE"],
	"Bartoli Cruiser":["624 PP","Country: Italy","HP: 433","WEIGHT: 1880 KG","0-100 KM/H: 4.9s","TOP SPEED: 295 KM/H","ENGINE: V8 4.7L","TRANSMISSION: REAR-WHEEL DRIVE"],
	"Eisenach Roadstar":["567 PP","Country: Germany","HP: 335","WEIGHT: 1600 KG","0-100 KM/H: 4.4s","TOP SPEED: 265 KM/H","ENGINE: V6 3.0L","TRANSMISSION: REAR-WHEEL DRIVE"]
}

var supercars = {
	"Linetti Terror":["768 PP","Country: Italy","HP: 572","WEIGHT: 1630 KG","0-100 KM/H: 3.7s","TOP SPEED: 330 KM/H","ENGINE: V12 6.2L","TRANSMISSION: FOUR-WHEEL DRIVE"],
	"Kestrel Battleaxe":["739 PP","Country: UK","HP: 406","WEIGHT: 1078 KG","0-100 KM/H: 3.5s","TOP SPEED: 298 KM/H","ENGINE: V6 4.0L","TRANSMISSION: REAR-WHEEL DRIVE"],
	"Linetti Shepherd":["726 PP","Country: Italy","HP: 500","WEIGHT: 1430 KG","0-100 KM/H: 4.2s","TOP SPEED: 305 KM/H","ENGINE: V10 5.0L","TRANSMISSION: FOUR-WHEEL DRIVE"],
	"Linetti Firestorm":["728 PP","Country: Italy","HP: 493","WEIGHT: 1625 KG","0-100 KM/H: 4.2s","TOP SPEED: 328 KM/H","ENGINE: V12 5.7L","TRANSMISSION: REAR-WHEEL DRIVE"]
}

# -------------------------
# UNIVERSAL UI UPDATE
# -------------------------

func update_car_ui(stats: Array, name: String):
	$Control/Cars/CarName.text = name
	$Control/CarStats/PPLabel.text = stats[0]
	$Control/CarStats/CountryLabel.text = stats[1]
	$Control/CarStats/HPLabel.text = stats[2]
	$Control/CarStats/WeightLabel.text = stats[3]
	$Control/CarStats/ZeroToHundredLabel.text = stats[4]
	$Control/CarStats/TopSpeedLabel.text = stats[5]
	$Control/CarStats/EngineLabel.text = stats[6]
	$Control/CarStats/TransmissionLabel.text = stats[7]

# -------------------------
# CLASS BUTTONS
# -------------------------

func _on_4x4suv_pressed():
	car_class = "suv"
	car_index = 0
	car_name = suv_list[car_index]
	update_car_ui(suv[car_name], car_name)

func _on_compact_cars_pressed():
	car_class = "compact"
	car_index = 0
	car_name = compact_list[car_index]
	update_car_ui(compact[car_name], car_name)

func _on_muscle_cars_pressed():
	car_class = "muscle"
	car_index = 0
	car_name = muscle_list[car_index]
	update_car_ui(muscle[car_name], car_name)

func _on_urban_racers_pressed():
	car_class = "urban"
	car_index = 0
	car_name = urban_list[car_index]
	update_car_ui(urban_racers[car_name], car_name)

func _on_sedans_pressed():
	car_class = "sedans"
	car_index = 0
	car_name = sedans_list[car_index]
	update_car_ui(sedans[car_name], car_name)

func _on_sport_coupe_pressed():
	car_class = "sport"
	car_index = 0
	car_name = sport_list[car_index]
	update_car_ui(sport[car_name], car_name)

func _on_supercars_pressed():
	car_class = "supercars"
	car_index = 0
	car_name = supercars_list[car_index]
	update_car_ui(supercars[car_name], car_name)

# -------------------------
# LEFT / RIGHT SWITCHING
# -------------------------

func _input(event):
	if event.is_action_pressed("car_select_left"):
		switch_car(-1)
	if event.is_action_pressed("car_select_right"):
		switch_car(1)

func switch_car(direction):
	var list
	var dict

	match car_class:
		"suv":
			list = suv_list
			dict = suv
		"compact":
			list = compact_list
			dict = compact
		"muscle":
			list = muscle_list
			dict = muscle
		"urban":
			list = urban_list
			dict = urban_racers
		"sedans":
			list = sedans_list
			dict = sedans
		"sport":
			list = sport_list
			dict = sport
		"supercars":
			list = supercars_list
			dict = supercars

	car_index = (car_index + direction) % list.size()
	if car_index < 0:
		car_index = list.size() - 1

	car_name = list[car_index]
	update_car_ui(dict[car_name], car_name)
