extends Node

var player_name := "Player"
var results: Array = []


func clear():
	results.clear()


func add_result(name: String, car: String, time_ms: int):
	results.append({
		"name": name,
		"car": car,
		"time": time_ms
	})


func get_sorted() -> Array:
	var sorted_results := results.duplicate()
	sorted_results.sort_custom(func(a, b):
		return a["time"] < b["time"]
	)
	return sorted_results
