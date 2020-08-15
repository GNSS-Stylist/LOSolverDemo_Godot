extends Node

var iTOW:int = 0
var iTOWstartTicks_msec:int
var iTOWStart:int = 0
var iTOWEnd:int = 1000 * 60 * 60 * 24 * 7	# Max possible ITOW value
var visibilityScriptIndex:int = 0
var dataSetIndexInUse:int = 0
export var replaySpeed:float = 1

# dataset here mean one set of start/end ITOWS and associated camera- and 
# object location/orientation scripts (= *.LOScript-files generated with 
# GNSS-Stylus-application). These can be changed with UI's "Dataset"-spinbox.
# See visibility scripts further on for scripting visibilities for different objects.
var datasets = [
	# [Start ITOW, End ITOW, Object LOScript, Camera LOScript ]
	# First item here means value 1 in UI's "Dataset"-spinbox
	
	# This is for a special quaternion interpolation test
	[124168900, 124188100, "res://LOScripts/ObjectWiggle_Object.LOScript", "res://LOScripts/ObjectWiggle_Camera_Averaged.LOScript"],

	[384480000, 384662000, "res://LOScripts/AllMoving_Object.LOScript", "res://LOScripts/AllMoving_Camera.LOScript"],
	[384909000, 385002000, "res://LOScripts/AllMoving2_Object.LOScript", "res://LOScripts/AllMoving2_Camera.LOScript"],
	[29300000,  29357000,  "res://LOScripts/AllMoving3_Object.LOScript", "res://LOScripts/AllMoving3_Camera.LOScript"],
	[383596000, 383748000, "res://LOScripts/ObjectStill_AndCat_Object.LOScript", "res://LOScripts/ObjectStill_AndCat_Camera.LOScript"],
	[115117000, 115170000, "res://LOScripts/CameraMoving_Object_Averaged.LOScript", "res://LOScripts/CameraMoving_Camera.LOScript"],
	[114841000, 115005000, "res://LOScripts/ObjectMoving_Object.LOScript", "res://LOScripts/ObjectMoving_Camera_Averaged.LOScript"],
	[123684000, 123783000, "res://LOScripts/ObjectMoving2_Object.LOScript", "res://LOScripts/ObjectMoving2_Camera_Averaged.LOScript"],
	[124141000, 124234000, "res://LOScripts/ObjectWiggle_Object.LOScript", "res://LOScripts/ObjectWiggle_Camera_Averaged.LOScript"],
]

# Use the following when full ITOW-range is needed (like when generating videos?)
var datasets_full = [ 
	# [Start ITOW, End ITOW, Object LOScript, Camera LOScript ]
	[384433000, 384719750, "res://LOScripts/AllMoving_Object.LOScript", "res://LOScripts/AllMoving_Camera.LOScript"],
	[384851500, 385029250, "res://LOScripts/AllMoving2_Object.LOScript", "res://LOScripts/AllMoving2_Camera.LOScript"],
	[29267375,  29381625,  "res://LOScripts/AllMoving3_Object.LOScript", "res://LOScripts/AllMoving3_Camera.LOScript"],
	[383576500, 383759875, "res://LOScripts/ObjectStill_AndCat_Object.LOScript", "res://LOScripts/ObjectStill_AndCat_Camera.LOScript"],
	[115090125, 115173500, "res://LOScripts/CameraMoving_Object_Averaged.LOScript", "res://LOScripts/CameraMoving_Camera.LOScript"],
	[114761500, 115028250, "res://LOScripts/ObjectMoving_Object.LOScript", "res://LOScripts/ObjectMoving_Camera_Averaged.LOScript"],
	[123591125, 123802250, "res://LOScripts/ObjectMoving2_Object.LOScript", "res://LOScripts/ObjectMoving2_Camera_Averaged.LOScript"],
	[124070000, 124252125, "res://LOScripts/ObjectWiggle_Object.LOScript", "res://LOScripts/ObjectWiggle_Camera_Averaged.LOScript"],
]

# Visibility bit masks for different objects (can be added together)
const V_TRIANGLE:int = 1 << 0
const V_CAR:int = 1 << 1
const V_CAR_BIG:int = 1 << 2
const V_HORSE:int = 1 << 3
const V_HORSE_SIDEWAYS:int = 1 << 4
const V_AEROPLANE:int = 1 << 5
const V_SPACESHIP:int = 1 << 6
const V_WEIGHTS:int = 1 << 7

# Scripts defining visibilities of different objects.
# ITOW value is used as a "key".
# Last value defines "timeshift" that is interpolated between
# ITOWs (you can, for example speed up / slow down the timeshifted object).
var visibilityScripts = {
	# Keys here are indexes into datasets-array above
	0: [	# ITOW, objects, TimeShifted object, Timeshift value
		[384433000, V_CAR, 0, -25000],
		[384522111, V_SPACESHIP, 0, -25000],
		[384547045, V_WEIGHTS, 0, -25000],
		[384555000, V_CAR, 0, -25000],
		[384572000, V_CAR, V_SPACESHIP, -25000],	# Sped-up spaceship between this and the next step (timeshift changes by 7 s in 2 seconds of "real time")
		[384574000, V_HORSE, V_SPACESHIP, -18000],	# Little less sped-up spaceship (timeshift changes by 12 s in about 21 seconds of "real time")
		[384595179, V_HORSE, 0, -6000],
		[384597179, V_HORSE_SIDEWAYS, 0, -5000],
		[384622813, V_AEROPLANE, 0, -5000],
		[384635455, V_AEROPLANE, V_SPACESHIP, -5000],
		[384654272, V_AEROPLANE, 0, -5000],
		],
	1: [	# ITOW, objects, TimeShifted object, Timeshift value
		[384851500, V_CAR, 0, -5000],
		[384935000, V_HORSE_SIDEWAYS, 0, -5000],
		[384944000, V_HORSE, 0, -5000],
		[384955000, V_WEIGHTS, 0, -5000],
		[384961000, V_AEROPLANE, 0, -5000],
		[384966000, V_AEROPLANE, V_HORSE, -5000],
		[384994000, V_AEROPLANE, 0, -5000],
		],
	2: [	# ITOW, objects, TimeShifted object, Timeshift value
		[29267375, V_TRIANGLE, 0, -5000],
		[29303000, V_CAR_BIG, 0, -5000],
		[29336000, V_CAR_BIG, V_SPACESHIP, -5000],
		[29336500, V_AEROPLANE, V_SPACESHIP, -5000],
		[29342000, V_AEROPLANE, 0, -2000],
		],
}

# Called when the node enters the scene tree for the first time.
func _ready():
	iTOWstartTicks_msec = OS.get_ticks_msec()
	var datasetSpinBox = get_node("Panel_UIControls/SpinBox_Dataset")
	datasetSpinBox.min_value = 1
	datasetSpinBox.max_value = datasets.size()
	_on_SpinBox_Dataset_value_changed(datasetSpinBox.value)

# Called every frame. 'delta' is the elapsed time since the previous frame.
# (delta not used here to get better sync when generating video)
func _process(_delta):
	camSwitch()
	handleScriptPlaybackControls()

	if Input.is_action_just_pressed("full_screen_toggle"):
		OS.window_fullscreen = !OS.window_fullscreen
	
	if get_tree().paused:
		return
	
	while (OS.get_ticks_msec() - iTOWstartTicks_msec < 0):
		# Bit rude way to fix "rewind before the start of times", but works...
		iTOWstartTicks_msec += (iTOWStart - iTOWEnd)
	iTOW = iTOWStart + (int(((OS.get_ticks_msec() - iTOWstartTicks_msec) * replaySpeed)) % (iTOWStart - iTOWEnd))

	if get_node("Panel_UIControls/CheckBox_UseVisibilityScript").pressed and  visibilityScripts.has(dataSetIndexInUse):
		if (visibilityScriptIndex > 0) and (visibilityScripts[dataSetIndexInUse][visibilityScriptIndex - 1][0] > iTOW):
			# "rewind" when time goes backwards
			while (visibilityScriptIndex > 0) and (visibilityScripts[dataSetIndexInUse][visibilityScriptIndex - 1][0] > iTOW):
				visibilityScriptIndex -= 1
			if (visibilityScriptIndex > 0):
				# need to go to previous one in this case
				visibilityScriptIndex -= 1

		if visibilityScriptIndex < visibilityScripts[dataSetIndexInUse].size():
			var interpolatedShift:int
			if visibilityScriptIndex > 0:
				var fraction:float = float (iTOW - visibilityScripts[dataSetIndexInUse][visibilityScriptIndex - 1][0]) / (visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][0] - visibilityScripts[dataSetIndexInUse][visibilityScriptIndex - 1][0])
				interpolatedShift = visibilityScripts[dataSetIndexInUse][visibilityScriptIndex - 1][3] + fraction * (visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][3] - visibilityScripts[dataSetIndexInUse][visibilityScriptIndex - 1][3])
			else:
				interpolatedShift = visibilityScripts[dataSetIndexInUse][0][3]
					
			get_node("Panel_UIControls/SpinBox_Timeshift").value = interpolatedShift

			while (visibilityScriptIndex < visibilityScripts[dataSetIndexInUse].size()) and (iTOW >= visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][0]):
				get_node("Panel_UIControls/CheckBox_Object_Triangle").pressed = visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][1] & V_TRIANGLE
				get_node("Panel_UIControls/CheckBox_Object_Car").pressed = visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][1] & V_CAR
				get_node("Panel_UIControls/CheckBox_Object_Car_Big").pressed = visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][1] & V_CAR_BIG
				get_node("Panel_UIControls/CheckBox_Object_Horse").pressed = visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][1] & V_HORSE
				get_node("Panel_UIControls/CheckBox_Object_HorseSideways").pressed = visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][1] & V_HORSE_SIDEWAYS
				get_node("Panel_UIControls/CheckBox_Object_Aeroplane").pressed = visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][1] & V_AEROPLANE
				get_node("Panel_UIControls/CheckBox_Object_Spaceship").pressed = visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][1] & V_SPACESHIP
				get_node("Panel_UIControls/CheckBox_Object_Weights").pressed = visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][1] & V_WEIGHTS
				
				get_node("Panel_UIControls/CheckBox_Timeshift_Triangle").pressed = visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][2] & V_TRIANGLE
				get_node("Panel_UIControls/CheckBox_Timeshift_Car").pressed = visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][2] & V_CAR
				get_node("Panel_UIControls/CheckBox_Timeshift_Car_Big").pressed = visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][2] & V_CAR_BIG
				get_node("Panel_UIControls/CheckBox_Timeshift_Horse").pressed = visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][2] & V_HORSE
				get_node("Panel_UIControls/CheckBox_Timeshift_HorseSideways").pressed = visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][2] & V_HORSE_SIDEWAYS
				get_node("Panel_UIControls/CheckBox_Timeshift_Aeroplane").pressed = visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][2] & V_AEROPLANE
				get_node("Panel_UIControls/CheckBox_Timeshift_Spaceship").pressed = visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][2] & V_SPACESHIP
				get_node("Panel_UIControls/CheckBox_Timeshift_Weights").pressed = visibilityScripts[dataSetIndexInUse][visibilityScriptIndex][2] & V_WEIGHTS
				visibilityScriptIndex += 1


func _on_SpinBox_Dataset_value_changed(value):
	var index:int = int(value) - 1
	
	if (index >= 0) and (index < datasets.size()):
		iTOWStart = datasets[index][0]
		iTOWEnd = datasets[index][1]
		iTOWstartTicks_msec = OS.get_ticks_msec()
		iTOW = iTOWStart
		dataSetIndexInUse = index
		visibilityScriptIndex = 0

		get_node("LOSolver_Object").loadFile(datasets[index][2])
		get_node("LOSolver_TimeShift").loadFile(datasets[index][2])
		get_node("LOSolver_Camera").loadFile(datasets[index][3])
	else:
		print("Dataset not found!")

func camSwitch():
	if Input.is_action_pressed("camera_1"):
		var camera = get_node("FirstPerson/Head/FirstPersonCamera")
		camera.current = true
	if Input.is_action_pressed("camera_2"):
		var camera = get_node("LOSolver_Camera/RigCamera")
		camera.current = true
	if Input.is_action_pressed("camera_3"):
		var camera = get_node("LOSolver_Object/ObjectCamera")
		camera.current = true

func handleScriptPlaybackControls():
	if Input.is_action_just_pressed("rewind_5s"):
		iTOWstartTicks_msec = iTOWstartTicks_msec + 5000
	if Input.is_action_just_pressed("fast_forward_5s"):
		iTOWstartTicks_msec = iTOWstartTicks_msec - 5000
	if Input.is_action_pressed("resetITOW"):
		iTOWstartTicks_msec = OS.get_ticks_msec()
