extends CharacterBody3D

# Define the buttons for bitwise AND operation.
# This is necessary because of multiple button presses at the same time.
# E.g. "A" and "B" together .get_buttons() will return 3.
# Button "A" pressed will return 1 and "B" pressed will return 2.
const BTN_A     = 0b00000001  # Bit 0
const BTN_B     = 0b00000010  # Bit 1
const BTN_X     = 0b00000100  # Bit 2
const BTN_Y     = 0b00001000  # Bit 3
const BTN_LB    = 0b00010000  # Bit 4
const BTN_RB    = 0b00100000  # Bit 5
const BTN_START = 0b01000000  # Bit 6

var controller: Controller
var display: Display

const SPEED := 15.0
const MAX_HP := 10
var current_hp := MAX_HP
var points := 0

const ACCELERATION := 20.0
const DECELERATION := 15.0
const TILT_ANGLE := 0.05
const TILT_SPEED := 5.0

var fire_cooldown := 0.6
var fire_timer := 0.0
var damage_cooldown := 1.0
var damage_timer := 0.0

var target_velocity := Vector3.ZERO
var current_tilt := Vector3.ZERO

var display_mode := "hp"
var display_switch_timer := 0.0
const DISPLAY_SWITCH_INTERVAL := 2.0

var pause_menu_scene := preload("res://scenes/pause_menu.tscn")
var pause_menu: CanvasLayer = null
var is_paused := false
var btn_start_was_pressed := false

var music_player: AudioStreamPlayer
var shoot_player: AudioStreamPlayer
var death_player: AudioStreamPlayer


func _ready():
	add_to_group("player")
	process_mode = Node.PROCESS_MODE_ALWAYS

	music_player = AudioStreamPlayer.new()
	music_player.stream = load("res://assets/audio/BackgroundMusic.wav")
	music_player.volume_db = -15.0
	add_child(music_player)
	music_player.finished.connect(_on_music_finished)
	music_player.play()

	shoot_player = AudioStreamPlayer.new()
	shoot_player.stream = load("res://assets/audio/Shoot.wav")
	add_child(shoot_player)

	death_player = AudioStreamPlayer.new()
	death_player.stream = load("res://assets/audio/YouLose.wav")
	death_player.volume_db = 0.0
	add_child(death_player)

	var controller_host = get_tree().get_current_scene().get_node("ControllerHost")
	var display_host = get_tree().get_current_scene().get_node("DisplayHost")

	if controller_host:
		controller = controller_host.controller
	else:
		push_error("ControllerHost not found in the current scene!")
	
	if display_host:
		display = display_host.display
	else:
		push_error("DisplayHost not found in the current scene!")


# Movement and button handling is implemented here
func _physics_process(delta):
	if controller:
		var buttons = controller.get_buttons()
		var btn_start_pressed = (buttons & BTN_START) != 0
		if btn_start_pressed and not btn_start_was_pressed:
			if is_paused:
				_resume()
			else:
				_pause()
		btn_start_was_pressed = btn_start_pressed

	if is_paused or current_hp <= 0:
		return
	
	fire_timer -= delta
	damage_timer -= delta
	display_switch_timer -= delta
	
	if display_switch_timer <= 0:
		display_switch_timer = DISPLAY_SWITCH_INTERVAL
		display_mode = "points" if display_mode == "hp" else "hp"
		update_display()
	
	if controller:
		var raw_x = controller.get_axis_x()
		var raw_y = controller.get_axis_y()
		var buttons = controller.get_buttons()

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

		if (buttons & BTN_A) != 0 and fire_timer <= 0:
			fire()
			fire_timer = fire_cooldown


func fire():
	var projectile = preload("res://assets/3d/player/projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_transform.origin = global_transform.origin - global_transform.basis.z

	if shoot_player:
		shoot_player.play()

	if projectile.has_signal("asteroid_destroyed"):
		projectile.asteroid_destroyed.connect(_on_asteroid_destroyed)


func _on_asteroid_destroyed():
	add_points(10)


func add_points(amount: int):
	points += amount
	
	if display:
		display.show_text("P: " + str(points))
		display_mode = "points"
		display_switch_timer = DISPLAY_SWITCH_INTERVAL


func take_damage(amount: int):
	if damage_timer > 0:
		return
	
	current_hp -= amount
	damage_timer = damage_cooldown
	
	if display:
		if current_hp <= 0:
			on_death()
		else:
			display.show_text("HIT! HP: " + str(current_hp))
			display.set_brightness(15)
			await get_tree().create_timer(0.3).timeout
			display.set_brightness(8)
			
			display_mode = "hp"
			display_switch_timer = DISPLAY_SWITCH_INTERVAL


func on_death():
	if music_player:
		music_player.stop()
	if death_player:
		death_player.play()

	if display:
		display.set_brightness(15)
		display.show_text("GAME OVER")
		await get_tree().create_timer(2.0).timeout
		display.show_text("FINAL SCORE: " + str(points))

	set_physics_process(false)
	
	await get_tree().create_timer(8.0).timeout
	get_tree().reload_current_scene()


func update_display():
	if not display:
		return
	
	if display_mode == "hp":
		display.show_text("HP: " + str(current_hp))
	else:
		display.show_text("P: " + str(points))


func _on_collision_area_area_entered(area: Area3D) -> void:
	var other = area.get_parent()
	if other.is_in_group("asteroid"):
		take_damage(1)
		other.queue_free()


func _pause():
	is_paused = true
	get_tree().paused = true
	pause_menu = pause_menu_scene.instantiate()
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(pause_menu)
	pause_menu.resume_requested.connect(_resume)
	pause_menu.quit_requested.connect(_quit_to_launcher)


func _resume():
	is_paused = false
	get_tree().paused = false
	if pause_menu:
		pause_menu.queue_free()
		pause_menu = null


func _quit_to_launcher():
	get_tree().paused = false
	_launch_launcher()
	get_tree().quit()


func _launch_launcher():
	var launcher_path: String
	if OS.get_name() == "Windows":
		launcher_path = OS.get_executable_path().get_base_dir().path_join("..\\..\\launcher.exe")
	else:
		launcher_path = OS.get_executable_path().get_base_dir().path_join("../../launcher.arm64")
	
	if FileAccess.file_exists(launcher_path):
		OS.create_process(launcher_path, [])
	else:
		push_error("Launcher not found at: " + launcher_path)

func _on_music_finished():
	music_player.play()
