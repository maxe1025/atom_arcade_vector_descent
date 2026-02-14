extends CharacterBody3D

var controller: Controller
const SPEED := 15.0

const ACCELERATION := 20.0
const DECELERATION := 15.0
const TILT_ANGLE := 0.05
const TILT_SPEED := 5.0

var fire_cooldown := 0.6
var fire_timer := 0.0

var target_velocity := Vector3.ZERO
var current_tilt := Vector3.ZERO


func _ready():
	var controller_host = get_tree().get_current_scene().get_node("ControllerHost")

	if controller_host:
		controller = controller_host.controller
	else:
		push_error("ControllerHost not found in the current scene!")

# Movement is implemented here
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

		target_velocity.x = move_x * side_speed
		target_velocity.z = move_z * forward_speed
		target_velocity.y = 0

		if target_velocity.length() > 0:
			velocity.x = move_toward(velocity.x, target_velocity.x, ACCELERATION * delta)
			velocity.z = move_toward(velocity.z, target_velocity.z, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
			velocity.z = move_toward(velocity.z, 0, DECELERATION * delta)
		
		velocity.y = 0

		var target_tilt := Vector3.ZERO
		target_tilt.z = move_x * TILT_ANGLE
		target_tilt.x = -move_z * TILT_ANGLE
		
		current_tilt = current_tilt.lerp(target_tilt, TILT_SPEED * delta)
		
		rotation.x = current_tilt.x
		rotation.z = current_tilt.z

		move_and_slide()

	fire_timer -= delta
	if controller and controller.get_buttons() == 1 and fire_timer <= 0:
		fire()
		fire_timer = fire_cooldown


func fire():
	var projectile = preload("res://Scenes/Projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_transform.origin = global_transform.origin - global_transform.basis.z
