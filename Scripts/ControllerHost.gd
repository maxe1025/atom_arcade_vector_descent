extends Node

var controller: Controller

func _ready():
	controller = Controller.new()
	var port = SerialConfig.get_controller_port()
	print("Attempting to connect to controller on port: ", port)
	controller.start(port)

func _process(_delta: float) -> void:
	if controller:
		var x = controller.get_axis_x()
		var y = controller.get_axis_y()
		var b = controller.get_buttons()
		print("X:", x, " Y:", y, " Buttons:", b)
	else:
		print("No controller found :(")
