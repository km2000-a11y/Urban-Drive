extends CanvasLayer

func _physics_process(delta: float) -> void:
	$Control/Speed.text=str(int (round(Global.speed)))+" km/h"
