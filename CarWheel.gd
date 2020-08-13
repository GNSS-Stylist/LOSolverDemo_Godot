extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rotationSpeed = 200
var lastGlobalOrigin = Vector3(0, 0, 0) as Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	lastGlobalOrigin = self.global_transform.origin
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var parent = self.get_parent()
	var globalMovement = parent.global_transform.origin - lastGlobalOrigin

	# "Forward" as "seen" by the wheel
	var forwardMovement = parent.global_transform.basis.z.dot(globalMovement)
	
	# This is to make the wheel turning speed to slow down when the car is scaled up
	# (Double size car -> halve the speed)
	forwardMovement /= parent.global_transform.basis.z.length()
	
	# This will accumulate rounding error over time, but since the rotation
	# axis is basis.x, it will not turn the wheel "out of it's place"
	self.transform = self.transform.rotated(self.transform.basis.x, forwardMovement * rotationSpeed * delta).orthonormalized()
	lastGlobalOrigin = parent.global_transform.origin
