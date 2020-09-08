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

	get_node("../LOSolver_Object_A/Triangle").visible = get_node("CheckBox_Object_Triangle").pressed
	get_node("../LOSolver_Object_A/Car").visible = get_node("CheckBox_Object_Car").pressed
	get_node("../LOSolver_Object_A/Car_Big").visible = get_node("CheckBox_Object_Car_Big").pressed
	get_node("../LOSolver_Object_A/Horse").visible = get_node("CheckBox_Object_Horse").pressed
	get_node("../LOSolver_Object_A/Horse_Sideways").visible = get_node("CheckBox_Object_HorseSideways").pressed
	get_node("../LOSolver_Object_A/Aeroplane").visible = get_node("CheckBox_Object_Aeroplane").pressed
	get_node("../LOSolver_Object_A/Spaceship").visible = get_node("CheckBox_Object_Spaceship").pressed
	get_node("../LOSolver_Object_A/BasisTips").visible = get_node("CheckBox_Object_Basis").pressed

	get_node("../LOSolver_Object_Pre_A/BasisTips").visible = get_node("CheckBox_Object_Basis").pressed
	get_node("../LOSolver_Object_B/BasisTips").visible = get_node("CheckBox_Object_Basis").pressed
	get_node("../LOSolver_Object_Post_B/BasisTips").visible = get_node("CheckBox_Object_Basis").pressed


	get_node("../LOSolver_Interpolated/Triangle").visible = get_node("CheckBox_Timeshift_Triangle").pressed
	get_node("../LOSolver_Interpolated/Car").visible = get_node("CheckBox_Timeshift_Car").pressed
	get_node("../LOSolver_Interpolated/Car_Big").visible = get_node("CheckBox_Timeshift_Car_Big").pressed
	get_node("../LOSolver_Interpolated/Horse").visible = get_node("CheckBox_Timeshift_Horse").pressed
	get_node("../LOSolver_Interpolated/Horse_Sideways").visible = get_node("CheckBox_Timeshift_HorseSideways").pressed
	get_node("../LOSolver_Interpolated/Aeroplane").visible = get_node("CheckBox_Timeshift_Aeroplane").pressed
	get_node("../LOSolver_Interpolated/Spaceship").visible = get_node("CheckBox_Timeshift_Spaceship").pressed
	get_node("../LOSolver_Interpolated/Basis").visible = get_node("CheckBox_Timeshift_Basis").pressed

	get_node("../LOSolver_Interpolated").iTOWShift = get_node("SpinBox_Timeshift").value

	get_node("../Panel_3DModelLicenseInfo").visible = get_node("CheckBox_3DModelInfo").pressed
