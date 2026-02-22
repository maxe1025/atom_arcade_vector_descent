extends CanvasLayer

signal resume_requested
signal quit_requested

@onready var panel: Panel = $Panel
@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

var selected_index := 0
const BUTTONS_COUNT := 2

const BTN_A     = 0b00000001
const BTN_START = 0b01000000

var controller: Controller
var btn_a_was_pressed := false
var btn_start_was_pressed := false
var input_cooldown := 0.2
var input_timer := 0.0
var open_cooldown := 0.3  # Ignore input briefly after opening
var open_timer := 0.0


func _ready():
	var controller_host = get_tree().get_current_scene().get_node("ControllerHost")
	if controller_host:
		controller = controller_host.controller

	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(func(): emit_signal("resume_requested"))
	quit_button.pressed.connect(func(): emit_signal("quit_requested"))
	resume_button.grab_focus()

	open_timer = open_cooldown  # Start with cooldown active
	_update_selection()


func _process(delta):
	open_timer -= delta
	if open_timer > 0:
		btn_a_was_pressed = true   # Prevent A from firing immediately
		btn_start_was_pressed = true  # Prevent START from firing immediately
		return  # Ignore all input until cooldown expires

	if not controller:
		return

	input_timer -= delta

	var raw_y = controller.get_axis_y()
	var buttons = controller.get_buttons()

	if input_timer <= 0:
		var move_y = (raw_y - 512.0) / 512.0
		if move_y > 0.5:
			selected_index = (selected_index - 1 + BUTTONS_COUNT) % BUTTONS_COUNT
			_update_selection()
			input_timer = input_cooldown
		elif move_y < -0.5:
			selected_index = (selected_index + 1) % BUTTONS_COUNT
			_update_selection()
			input_timer = input_cooldown

	var btn_a_pressed = (buttons & BTN_A) != 0
	if btn_a_pressed and not btn_a_was_pressed:
		if selected_index == 0:
			emit_signal("resume_requested")
		else:
			emit_signal("quit_requested")
	btn_a_was_pressed = btn_a_pressed

	var btn_start_pressed = (buttons & BTN_START) != 0
	if btn_start_pressed and not btn_start_was_pressed:
		emit_signal("resume_requested")
	btn_start_was_pressed = btn_start_pressed


func _update_selection():
	resume_button.grab_focus() if selected_index == 0 else quit_button.grab_focus()
