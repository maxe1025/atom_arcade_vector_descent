extends Node3D

signal asteroid_destroyed

var speed := 30.0

func _ready():
	add_to_group("projectile")


func _physics_process(delta):
	global_translate(Vector3(0, 0, speed * delta))

	if global_position.z < -50:
		queue_free()


func _on_area_3d_area_entered(area: Area3D) -> void:
	var other = area.get_parent()
	if other.is_in_group("asteroid"):
		other.queue_free()
		asteroid_destroyed.emit()
		queue_free()
