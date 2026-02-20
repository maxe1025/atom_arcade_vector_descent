extends Node

var display: Display

func _ready():
	display = Display.new()
	var port = get_serial_port()
	print("Attempting to connect to display on port: ", port)
	
	if display.connect_display(port):
		print("Display connected successfully!")
		display.set_brightness(8)
		display.show_text("READY!")
	else:
		push_error("Failed to connect display on port: " + port)

func get_serial_port() -> String:
	var os_name = OS.get_name()
	
	match os_name:
		"Windows":
			return "COM7"
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			return "/dev/ttyUSB0"
		"macOS":
			return "/dev/tty.usbmodem2"
		_:
			push_warning("Unknown OS: " + os_name + ", defaulting to Linux port")
			return "/dev/ttyACM1"

func _exit_tree():
	if display:
		display.disconnect_display()
