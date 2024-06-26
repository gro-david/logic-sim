extends Node2D
class_name Terminal

signal state_changed

@export_category('Colors')
@export var on_color: Color
@export var off_color: Color

@export_category('Nodes')
@export var sprite: Sprite2D
@export var connection_node: Node2D
@export var parent_block: Block

@export_category('Config')
@export var input_terminal: bool = false
@export var allow_user_input: bool = false

var state: Global.State:
	set(value):
		state = value
		sprite.self_modulate = on_color if state == Global.State.ON else off_color
		state_changed.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# if we are editing the wires we will not change the state but save the current terminal to be able to reference it
			if Global.edit_wires:
				Global.terminal = self
			else:
				if not allow_user_input: return
				state = Global.toggle_state(state)
