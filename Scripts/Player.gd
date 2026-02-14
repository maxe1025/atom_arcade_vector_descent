extends CharacterBody3D

var controller: Controller
const SPEED := 10.0

var fire_cooldown := 0.2
var fire_timer := 0.0


func _ready():
	var controller_host = get_tree().get_current_scene().get_node("ControllerHost")

	if controller_host:
		controller = controller_host.controller
	else:
		push_error("ControllerHost not found in the current scene!")


func _physics_process(delta):
	if controller:
		var raw_x = controller.get_axis_x()
		var raw_y = controller.get_axis_y()

		var move_x = ((raw_x - 512.0) / 512.0)
		var move_z = ((raw_y - 512.0) / 512.0)

		if abs(move_x) < 0.05:
			move_x = 0
		if abs(move_z) < 0.05:
			move_z = 0

		var side_speed = SPEED
		var forward_speed = SPEED * 0.3

		velocity.x = move_x * side_speed
		velocity.z = move_z * forward_speed
		velocity.y = 0

		move_and_slide()

	fire_timer -= delta
	if controller and controller.get_buttons() == 1 and fire_timer <= 0:
		fire()
		fire_timer = fire_cooldown


func fire():
	var projectile = preload("res://Scenes/Projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_transform.origin = global_transform.origin - global_transform.basis.z
