extends Area3D

func _on_body_entered(body: Node3D) -> void:
	 		
		DuelManager.register_lap(body)
		NormalRaceManager.register_lap(body)
