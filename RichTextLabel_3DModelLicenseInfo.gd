extends RichTextLabel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _meta_clicked(meta):
	OS.set_clipboard(meta)
	OS.alert("link \"" + meta + "\"" + "copied to clipboard", "Link copied")

