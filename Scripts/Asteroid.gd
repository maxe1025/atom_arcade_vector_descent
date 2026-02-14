extends Node3D

var speed := 3.0


func _ready():
	add_to_group("asteroid")


func _physics_process(delta):
	global_translate(Vector3(0, 0, -speed * delta))

	if global_position.z < -10:
		queue_free()
