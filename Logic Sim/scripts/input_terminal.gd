extends Terminal
class_name InputTerminal

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			state = Global.toggle_state(state)