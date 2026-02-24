extends Node

var controller: Controller


func _ready():
	controller = Controller.new()
	var port = get_serial_port()
	print("Attempting to connect to controller on port: ", port)
	controller.start(port)


func get_serial_port() -> String:
	var os_name = OS.get_name()
	
	match os_name:
		"Windows":
			return "COM6"
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			return "/dev/ttyACM1"
		"macOS":
			return "/dev/tty.usbmodem"
		_:
			push_warning("Unknown OS: " + os_name + ", defaulting to Linux port")
			return "/dev/ttyACM0"


func _process(_delta: float) -> void:
	if controller:
		var x = controller.get_axis_x()
		var y = controller.get_axis_y()
		var b = controller.get_buttons()

		print("X:", x, " Y:", y, " Buttons:", b)
	else:
		print("No controller found :(")
