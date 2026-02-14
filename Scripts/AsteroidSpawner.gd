extends Node

var asteroid_scene := preload("res://Scenes/Asteroid.tscn")
var spawn_range := 20
var spawn_interval := 1.0
var spawn_timer := 0.0

func _physics_process(delta):
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = spawn_interval
		spawn_asteroid()

func spawn_asteroid():
	var asteroid = asteroid_scene.instantiate()
	asteroid.position = Vector3(
		randf_range(-spawn_range, spawn_range),
		0,
		randf_range(10, 30)
	)
	asteroid.scale = Vector3.ONE * randf_range(0.5, 2.0)
	get_parent().add_child(asteroid)
