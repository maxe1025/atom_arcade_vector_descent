extends Node3D

var controller = Controller.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	controller.start("COM3")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if controller:
		var x = controller.get_axis_x()
		var y = controller.get_axis_y()
		var b = controller.get_buttons()

		print("X:", x, " Y:", y, " Buttons:", b)
	else:
		print("No controller found :(")
