extends CanvasLayer

func _process(delta: float) -> void:
	$Control/Speed.text = str(int(round(Global.speed))) + " km/h"
	$Control/Gear.text = "G" + str(Global.gear)
