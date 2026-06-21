extends RigidBody3D

func _on_rigid_body_3d_2_body_entered(body: Node) -> void:
	queue_free()


func _on_body_entered(body: Node) -> void:
	queue_free()
