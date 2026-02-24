extends Node

var asteroid_scene := preload("res://assets/3d/asteroid/asteroid.tscn")
var spawn_range := 40
var spawn_interval := 0.2
var spawn_timer := 0.0
var spawn_distance_min := 50
var spawn_distance_max := 90

var player: Node3D


func _ready():
	pass


func _physics_process(delta):
	if not player:
		var players = get_tree().get_nodes_in_group("player")
		player = players[0] if players.size() > 0 else null

	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = spawn_interval
		spawn_asteroid()


func spawn_asteroid():
	var asteroid = asteroid_scene.instantiate()
	var origin := Vector3.ZERO
	if player:
		origin = player.global_position
	asteroid.position = Vector3(
		origin.x + randf_range(-spawn_range, spawn_range),
		0,
		origin.z + randf_range(spawn_distance_min, spawn_distance_max)
	)
	asteroid.scale = Vector3.ONE * randf_range(0.5, 2.0)
	asteroid.rotation = Vector3(
		randf_range(0, TAU),
		randf_range(0, TAU),
		randf_range(0, TAU)
	)
	get_parent().add_child(asteroid)
