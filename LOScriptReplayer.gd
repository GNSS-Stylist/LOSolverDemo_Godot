extends Spatial

enum QUAT_INTERPOLATION_METHOD { lastValue, nextValue, nearestValue, slerp, slerpni, cubic_slerp }
enum ORIGIN_INTERPOLATION_METHOD { lastValue, nextValue, nearestValue, linear, cubic }

export var loFilename:String = ""
export var iTOWShift:int = 0

export (ORIGIN_INTERPOLATION_METHOD) var originInterpolationMethod = ORIGIN_INTERPOLATION_METHOD.cubic
export(QUAT_INTERPOLATION_METHOD) var quatInterpolationMethod = QUAT_INTERPOLATION_METHOD.slerp

var loData = {}
var loDataKeys

var nextMatchingITOWIndex:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if loFilename.length() > 0:
		# Try to load file at this phase only if defined.
		loadFile(loFilename)
	
func loadFile(fileName):
	loData.clear()
	loDataKeys = []

	var file = File.new()
	#var metadata = {}
	if file.open(fileName, File.READ) != OK:
		print("Can't open file " + fileName)
		return
	var line
	while not file.eof_reached():
		line = file.get_line()
		var subStrings = line.split("\t")
		if subStrings.size() < 2:
			continue
		
		if subStrings[0] == "META":
			if subStrings[1] == "END":
				break
			# TODO: Add some sanity checks here.
			# (now just skipping all checks...)
	
	line = file.get_line()
	if line != "iTOW\tOrigin_X\tOrigin_Y\tOrigin_Z\tBasis_XX\tBasis_XY\tBasis_XZ\tBasis_YX\tBasis_YY\tBasis_YZ\tBasis_ZX\tBasis_ZY\tBasis_ZZ":
		printt("Invalid header line in " + loFilename)
		return

	while not file.eof_reached():
		# TODO: Maybe add some error checking here...
		line = file.get_line()
		var subStrings = line.split("\t")
		if (subStrings.size() >= (1 + (4 * 3))):
			var itow = subStrings[0].to_int()
			
			#Coordinates in Godot's native "EUS"-convention:
			var origin = Vector3(subStrings[1], subStrings[2], subStrings[3])
			var unitVecX = Vector3(subStrings[4], subStrings[5], subStrings[6])
			var unitVecY = Vector3(subStrings[7], subStrings[8], subStrings[9])
			var unitVecZ = Vector3(subStrings[10], subStrings[11], subStrings[12])

# These convert NED-coordinates to godot's "EUS" on the fly
#			var origin = Vector3(subStrings[2].to_float(), -subStrings[3].to_float(), -subStrings[1].to_float())
#			var unitVecX = Vector3(subStrings[5].to_float(), -subStrings[6].to_float(), -subStrings[4].to_float())
#			var unitVecY = Vector3(subStrings[8].to_float(), -subStrings[9].to_float(), -subStrings[7].to_float())
#			var unitVecZ = Vector3(subStrings[11].to_float(), -subStrings[12].to_float(), -subStrings[10].to_float())

			var basis = Basis(unitVecX, unitVecY, unitVecZ).orthonormalized()
#			var tr = Transform(unitVecX, unitVecY, unitVecZ, origin)
			
			var quat = Quat(basis)
			
			loData[itow] = [origin, quat]
	
	loDataKeys = loData.keys()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if loData.empty():
		return
		
	var currentITOW:int = get_node("/root/Main").iTOW + iTOWShift
	
	if nextMatchingITOWIndex < loDataKeys.size():
		for _i in range(10):
			# Maybe this faster than using bsearch every time(?)
			# Run this some rounds to allow some hickups in screen update etc.
			if nextMatchingITOWIndex < loDataKeys.size() and currentITOW >= loDataKeys[nextMatchingITOWIndex]:
				# Typical case: monotonically increasing ITOW
				nextMatchingITOWIndex += 1
				continue
			elif nextMatchingITOWIndex > 0 and currentITOW < loDataKeys[nextMatchingITOWIndex - 1]:
				# Another typical(ish?) case: monotonically decreasing ITOW
				nextMatchingITOWIndex -= 1
				continue
			else:
				break
		
		if (nextMatchingITOWIndex > 0 and nextMatchingITOWIndex < loDataKeys.size() and 
			(currentITOW < loDataKeys[nextMatchingITOWIndex - 1] or 
				currentITOW >= loDataKeys[nextMatchingITOWIndex])):
			# ITOW changed too fast
			# -> Use bsearch to find the correct index
			nextMatchingITOWIndex = loDataKeys.bsearch(currentITOW)
	elif currentITOW < loDataKeys[loDataKeys.size() - 1]:
		# "Rewind" while in the last item
		nextMatchingITOWIndex = loDataKeys.bsearch(currentITOW)
	
	var nextMatchingITOWValue:int

	if nextMatchingITOWIndex < loDataKeys.size():
		nextMatchingITOWValue = loDataKeys[nextMatchingITOWIndex]
	else:
		nextMatchingITOWValue = loDataKeys[loDataKeys.size() - 1]
	
	var origin:Vector3
	var quat:Quat
	
	if nextMatchingITOWIndex <= 0:
		origin = loData[nextMatchingITOWValue][0]
		quat = loData[nextMatchingITOWValue][1]
	elif nextMatchingITOWValue == currentITOW:
		origin = loData[nextMatchingITOWValue][0]
		quat = loData[nextMatchingITOWValue][1]
	elif nextMatchingITOWIndex >= loDataKeys.size() - 1:
		origin = loData[loDataKeys[loDataKeys.size() -1]][0]
		quat = loData[loDataKeys[loDataKeys.size() -1]][1]
	else:
		var lastMatchingITOWValue:int = loDataKeys[nextMatchingITOWIndex - 1]
		var fraction:float = float(currentITOW - lastMatchingITOWValue) / (nextMatchingITOWValue - lastMatchingITOWValue)
		if nextMatchingITOWIndex == 1 or nextMatchingITOWIndex == loDataKeys.size() - 1:
			# linear interpolation
			origin = loData[lastMatchingITOWValue][0].linear_interpolate(loData[nextMatchingITOWValue][0], fraction)
			quat = loData[lastMatchingITOWValue][1].slerp(loData[nextMatchingITOWValue][1], fraction)
		else:
			var origin_a:Vector3 = loData[loDataKeys[nextMatchingITOWIndex - 1]][0]
			var origin_b:Vector3 = loData[loDataKeys[nextMatchingITOWIndex]][0]

			match originInterpolationMethod:
				ORIGIN_INTERPOLATION_METHOD.lastValue:
					origin = origin_a
				ORIGIN_INTERPOLATION_METHOD.nextValue:
					origin = origin_b
				ORIGIN_INTERPOLATION_METHOD.nearestValue:
					origin = origin_a if fraction < 0.5 else origin_b
				ORIGIN_INTERPOLATION_METHOD.linear:
					origin = origin_a.linear_interpolate(origin_b, fraction)
				ORIGIN_INTERPOLATION_METHOD.cubic:
					var origin_pre_a:Vector3 = loData[loDataKeys[nextMatchingITOWIndex - 2]][0]
					var origin_post_b:Vector3 = loData[loDataKeys[nextMatchingITOWIndex + 1]][0]
					origin = origin_a.cubic_interpolate(origin_b, origin_pre_a, origin_post_b, fraction)
				_:
					origin = origin_a

			match quatInterpolationMethod:
				QUAT_INTERPOLATION_METHOD.lastValue:
					quat = loData[lastMatchingITOWValue][1]
				QUAT_INTERPOLATION_METHOD.nextValue:
					quat = loData[nextMatchingITOWValue][1]
				QUAT_INTERPOLATION_METHOD.nearestValue:
					quat = loData[lastMatchingITOWValue][1] if fraction < 0.5 else loData[nextMatchingITOWValue][1]
				QUAT_INTERPOLATION_METHOD.slerp:
					quat = loData[lastMatchingITOWValue][1].slerp(loData[nextMatchingITOWValue][1], fraction)
				QUAT_INTERPOLATION_METHOD.slerpni:
					# Causes some strange jitter
					quat = loData[lastMatchingITOWValue][1].slerpni(loData[nextMatchingITOWValue][1], fraction)
				QUAT_INTERPOLATION_METHOD.cubic_slerp:
					# Causes even stranger jitter
					var quat_pre_a:Quat = loData[loDataKeys[nextMatchingITOWIndex - 2]][1]
					var quat_a:Quat = loData[loDataKeys[nextMatchingITOWIndex - 1]][1]
					var quat_b:Quat = loData[loDataKeys[nextMatchingITOWIndex]][1]
					var quat_post_b:Quat = loData[loDataKeys[nextMatchingITOWIndex + 1]][1]
					quat = quat_a.cubic_slerp(quat_b, quat_pre_a, quat_post_b, fraction)
				_:
					quat = loData[lastMatchingITOWValue][1]
	
	var basis = Basis(quat)
	var tr = Transform(basis, origin)
	transform = tr
