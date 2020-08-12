extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var rotationSpeed = -5000
export var speedFilterCoeff = 0.001
var filteredOrigin = Vector3(0, 0, 0) as Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	filteredOrigin = self.global_transform.origin
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	filteredOrigin = filteredOrigin + (self.global_transform.origin - filteredOrigin) * pow(speedFilterCoeff, delta)
	var filteredSpeed = (self.global_transform.origin - filteredOrigin).length()
	self.transform = self.transform.rotated(self.transform.basis.z, filteredSpeed * rotationSpeed * delta).orthonormalized()
#	self.transform = self.transform.rotated(self.transform.basis.z, rotationSpeed * delta).orthonormalized()
