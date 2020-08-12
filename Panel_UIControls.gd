extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	get_node("../LOSolver_Camera/GreenScreen").visible = get_node("CheckBox_GreenScreen").pressed
	get_node("../Ground").visible = get_node("CheckBox_Ground").pressed
	get_node("../GreenCylinder").visible = get_node("CheckBox_GreenCylinder").pressed

	get_node("../LOSolver_Object/Triangle").visible = get_node("CheckBox_Object_Triangle").pressed
	get_node("../LOSolver_Object/Car").visible = get_node("CheckBox_Object_Car").pressed
	get_node("../LOSolver_Object/Car_Big").visible = get_node("CheckBox_Object_Car_Big").pressed
	get_node("../LOSolver_Object/Horse").visible = get_node("CheckBox_Object_Horse").pressed
	get_node("../LOSolver_Object/Horse_Sideways").visible = get_node("CheckBox_Object_HorseSideways").pressed
	get_node("../LOSolver_Object/Aeroplane").visible = get_node("CheckBox_Object_Aeroplane").pressed
	get_node("../LOSolver_Object/Spaceship").visible = get_node("CheckBox_Object_Spaceship").pressed
	get_node("../LOSolver_Object/Weights").visible = get_node("CheckBox_Object_Weights").pressed

	get_node("../LOSolver_TimeShift/Triangle").visible = get_node("CheckBox_Timeshift_Triangle").pressed
	get_node("../LOSolver_TimeShift/Car").visible = get_node("CheckBox_Timeshift_Car").pressed
	get_node("../LOSolver_TimeShift/Car_Big").visible = get_node("CheckBox_Timeshift_Car_Big").pressed
	get_node("../LOSolver_TimeShift/Horse").visible = get_node("CheckBox_Timeshift_Horse").pressed
	get_node("../LOSolver_TimeShift/Horse_Sideways").visible = get_node("CheckBox_Timeshift_HorseSideways").pressed
	get_node("../LOSolver_TimeShift/Aeroplane").visible = get_node("CheckBox_Timeshift_Aeroplane").pressed
	get_node("../LOSolver_TimeShift/Spaceship").visible = get_node("CheckBox_Timeshift_Spaceship").pressed
	get_node("../LOSolver_TimeShift/Weights").visible = get_node("CheckBox_Timeshift_Weights").pressed

	get_node("../LOSolver_TimeShift").iTOWShift = get_node("SpinBox_Timeshift").value

	get_node("../Panel_3DModelLicenseInfo").visible = get_node("CheckBox_3DModelInfo").pressed
