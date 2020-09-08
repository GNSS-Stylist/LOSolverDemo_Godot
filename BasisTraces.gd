extends ImmediateGeometry

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var tipXHistory = []
var tipYHistory = []
var tipZHistory = []

const tipHistoryLength = 1000

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var interpolatedTipX = get_node("../LOSolver_Interpolated/Basis/XAxisTip")
	var interpolatedTipY = get_node("../LOSolver_Interpolated/Basis/YAxisTip")
	var interpolatedTipZ = get_node("../LOSolver_Interpolated/Basis/ZAxisTip")
	
	if (tipXHistory.size() == 0 or
		interpolatedTipX.global_transform.origin != tipXHistory[tipXHistory.size()-1] or
		interpolatedTipY.global_transform.origin != tipYHistory[tipYHistory.size()-1] or
		interpolatedTipZ.global_transform.origin != tipZHistory[tipZHistory.size()-1]
	):
		tipXHistory.push_back(interpolatedTipX.global_transform.origin)
		tipYHistory.push_back(interpolatedTipY.global_transform.origin)
		tipZHistory.push_back(interpolatedTipZ.global_transform.origin)

	while tipXHistory.size() > tipHistoryLength:
		tipXHistory.pop_front()
	while tipYHistory.size() > tipHistoryLength:
		tipYHistory.pop_front()
	while tipZHistory.size() > tipHistoryLength:
		tipZHistory.pop_front()

	clear()

	begin(Mesh.PRIMITIVE_POINTS)
	set_color(Color(0.5,0,0,1))
	for coords in tipXHistory:
		add_vertex(coords)
	end()

	begin(Mesh.PRIMITIVE_POINTS)
	set_color(Color(0,0.5,0,1))
	for coords in tipYHistory:
		add_vertex(coords)
	end()

	begin(Mesh.PRIMITIVE_POINTS)
	set_color(Color(0,0,0.5,1))
	for coords in tipZHistory:
		add_vertex(coords)
	end()

	var PreATipX = get_node("../LOSolver_Object_Pre_A/BasisTips/XAxisTip")
	var PreATipY = get_node("../LOSolver_Object_Pre_A/BasisTips/YAxisTip")
	var PreATipZ = get_node("../LOSolver_Object_Pre_A/BasisTips/ZAxisTip")

	var ATipX = get_node("../LOSolver_Object_A/BasisTips/XAxisTip")
	var ATipY = get_node("../LOSolver_Object_A/BasisTips/YAxisTip")
	var ATipZ = get_node("../LOSolver_Object_A/BasisTips/ZAxisTip")

	var BTipX = get_node("../LOSolver_Object_B/BasisTips/XAxisTip")
	var BTipY = get_node("../LOSolver_Object_B/BasisTips/YAxisTip")
	var BTipZ = get_node("../LOSolver_Object_B/BasisTips/ZAxisTip")

	var PostBTipX = get_node("../LOSolver_Object_Post_B/BasisTips/XAxisTip")
	var PostBTipY = get_node("../LOSolver_Object_Post_B/BasisTips/YAxisTip")
	var PostBTipZ = get_node("../LOSolver_Object_Post_B/BasisTips/ZAxisTip")

	begin(Mesh.PRIMITIVE_LINE_STRIP)
	set_color(Color(0,0,0,1))
	add_vertex(PreATipX.global_transform.origin)
	add_vertex(ATipX.global_transform.origin)
	add_vertex(BTipX.global_transform.origin)
	add_vertex(PostBTipX.global_transform.origin)
	end()

	begin(Mesh.PRIMITIVE_LINE_STRIP)
	set_color(Color(0,0,0,1))
	add_vertex(PreATipY.global_transform.origin)
	add_vertex(ATipY.global_transform.origin)
	add_vertex(BTipY.global_transform.origin)
	add_vertex(PostBTipY.global_transform.origin)
	end()

	begin(Mesh.PRIMITIVE_LINE_STRIP)
	set_color(Color(0,0,0,1))
	add_vertex(PreATipZ.global_transform.origin)
	add_vertex(ATipZ.global_transform.origin)
	add_vertex(BTipZ.global_transform.origin)
	add_vertex(PostBTipZ.global_transform.origin)
	end()
	
func clearHistory():
	tipXHistory.clear()
	tipYHistory.clear()
	tipZHistory.clear()
