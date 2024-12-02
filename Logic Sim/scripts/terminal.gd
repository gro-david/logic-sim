extends Node2D
class_name Terminal

signal state_changed

@export_category('Colors')
@export var on_color: Color
@export var off_color: Color

@export_category('Nodes')
@export var sprite: Polygon2D
@export var connection_node: Node2D
@export var parent_block: Block
@export var label_node: Label
@export var panel: PanelContainer

@export_category('Config')
@export var input_terminal: bool = false
@export var allow_user_input: bool = false
@export var terminal_height: float = 96
@export var output_terminal_offset = 10

@export_category('Scenes')
@export var popup_panel_scene: PackedScene

var connected_wire: Wire
var side: Global.Side
var label: String:
	set(value):
		label = value
		label_node.text = value
		panel.size = panel.get_minimum_size()
var state: Global.State:
	set(value):
		state = value
		sprite.color = on_color if state == Global.State.ON else off_color
		state_changed.emit()

func _ready() -> void:
	state = Global.State.OFF
	label = 'Unnamed Terminal'

# place wires/change the state of the terminal
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if not event is InputEventMouseButton or not event.pressed or Input.is_action_pressed('ctrl'): return
	if Global.edit_mode: edit_mode_input_behavior(event)
	else: normal_mode_input_behavior(event)
func normal_mode_input_behavior(event: InputEventMouseButton) -> void:
	pass
func edit_mode_input_behavior(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		# if we are editing the wires we will not change the state but save the current terminal to be able to reference it
		if Global.edit_wires:
			Global.terminal = self
		else:
			if not allow_user_input: return
			state = Global.toggle_state(state)
	elif event.button_index == MOUSE_BUTTON_RIGHT and not Global.edit_mode:
		add_child(popup_panel_scene.instantiate())

		$PopupPanel.position = position
		$PopupPanel/VBoxContainer/LineEdit.text = label
		$PopupPanel/VBoxContainer/Button.pressed.connect(queue_free)
		$PopupPanel.popup_hide.connect(func(): $PopupPanel.queue_free())
		$PopupPanel/VBoxContainer/LineEdit.text_submitted.connect(_on_line_edit_text_submitted.bind())
		$PopupPanel/VBoxContainer/ColorPicker.color_changed.connect(_on_color_picker_color_changed.bind())

		$PopupPanel.popup()

# delete oneself from the arrays if we are getting deleted
func _notification(what):
	if (what == NOTIFICATION_PREDELETE):
		if is_instance_valid(connected_wire): connected_wire.queue_free()

func _on_color_picker_color_changed(color: Color) -> void:
	on_color = color

func flip():
	$Polygon2D.scale.x *= -1
	$Area2D.scale.x *= -1

func _on_area_2d_mouse_entered() -> void:
	Global.cursor_in_element = true
func _on_area_2d_mouse_exited() -> void:
	Global.cursor_in_element = false

func _on_line_edit_text_submitted(new_text):
	label = new_text
