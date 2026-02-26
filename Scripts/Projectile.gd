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

		# Play destroy sound at scene level so it survives queue_free
		var destroy_player := AudioStreamPlayer.new()
		destroy_player.stream = load("res://assets/audio/Destroy.wav")
		destroy_player.volume_db = -3.0
		get_tree().current_scene.add_child(destroy_player)
		destroy_player.finished.connect(destroy_player.queue_free)
		destroy_player.play()

		queue_free()
