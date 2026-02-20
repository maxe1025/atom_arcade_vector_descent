extends Node

# You have the following functions:
# connect_display(port: String) -> bool
# disconnect_display()
# show_text(text: String)
# clear()
# set_brightness(level: int (0-15))

var display: Display

func _ready():
	display = Display.new()
	var port = get_serial_port()
	print("Attempting to connect to display on port: ", port)
	
	if display.connect_display(port):
		print("Display connected successfully!")
		display.set_brightness(0)
		display.show_text("Vector Descent")

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
