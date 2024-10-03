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

@export_category('Scenes')
@export var popup_panel_scene: PackedScene
var connected_wire: Wire

var state: Global.State:
	set(value):
		state = value
		sprite.self_modulate = on_color if state == Global.State.ON else off_color
		state_changed.emit()

# place wires/change the state of the terminal
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if not event is InputEventMouseButton or not event.pressed or Input.is_action_pressed('ctrl'): return
	if event.button_index == MOUSE_BUTTON_LEFT:
		# if we are editing the wires we will not change the state but save the current terminal to be able to reference it
		if Global.edit_wires:
			Global.terminal = self
		else:
			if not allow_user_input: return
			state = Global.toggle_state(state)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		add_child(popup_panel_scene.instantiate())
		$PopupPanel/ColorPicker.color_changed.connect(_on_color_picker_color_changed.bind())
		$PopupPanel.position = position
		$PopupPanel.popup()

# delete oneself from the arrays if we are getting deleted
func _notification(what):
	if (what == NOTIFICATION_PREDELETE):
		if is_instance_valid(connected_wire): connected_wire.queue_free()


func _on_color_picker_color_changed(color: Color) -> void:
	on_color = color
