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
	var port = SerialConfig.get_display_port()
	print("Attempting to connect to display on port: ", port)
	
	if display.connect_display(port):
		print("Display connected successfully!")
		display.set_brightness(0)
		display.show_text("Vector Descent")
	else:
		push_error("Failed to connect display on port: " + port)

func _exit_tree():
	if display:
		display.disconnect_display()
