extends Node3D

var speed := 3.0
var player: Node3D

const PLAYER_SPEED := 15.0


func _ready():
	add_to_group("asteroid")
	speed = randf_range(PLAYER_SPEED * 0.5, PLAYER_SPEED * 1.5)
	var players = get_tree().get_nodes_in_group("player")
	player = players[0] if players.size() > 0 else null


func _physics_process(delta):
	global_translate(Vector3(0, 0, -speed * delta))

	if player:
		if global_position.distance_to(player.global_position) > 120:
			queue_free()
	else:
		if global_position.z < -10:
			queue_free()
