extends Node

var selected_car: String = ""          # scene path
var selected_car_name: String = ""     # car name string

var selected_ai_car: String = ""       # scene path
var selected_ai_car_name: String = ""  # car name string

var selected_color: Color = Color.WHITE
var selected_class: String = ""

var class_lists := {
	"special": ["Bartoli Cruiser"],
	"suv": ["Straeda Pitbull","Colossus Behemoth","Kuro Fortress","Colossus Titan Max"],
	"compact": ["Zenith Horizon","Schroder Atrix Q32","Straeda G25","Straeda B32"],
	"muscle": ["Brutus Mauler","Brutus Viper"],
	"urban": ["Brutus Stingray","Kestrel Speedster","Kestrel Seabird","Kuro Zephyr V6","Eisenach Roadstar","Berkshire Blunt"],
	"sedans": ["Eisenach Monarch","Schroder Kaiser","Kuro Vault","Kronstadt Blade"],
	"sport": ["Gruber Targa","Berkshire Tempest","Berkshire V12-S","Bartoli Cruiser"],
	"sport_racing": ["Kestrel Battleaxe","Linetti Shepherd","Brutus Venom"],
	"supercars": ["Linetti Terror","Linetti Firestorm","Kestrel Guillotine"]
}
