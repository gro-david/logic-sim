extends Node2D

@export_category('Nodes')
@export var line: Line2D
@export var input_terminal: Terminal
@export var output_terminal: Terminal

@export_category('Colors')
@export var on_color: Color
@export var off_color: Color

@export_group('Test')
@export var state: Global.State:
	# when this changes, update the color and emit the signal to notify the blocks
	set(value):
		state = value
		line.self_modulate = on_color if state == Global.State.ON else off_color

@export var start_placed: bool = false:
	set(value):
		start_placed = value
		if start_placed:
			show()
			calculate_line_points()

@export var end_placed: bool = false:
	set(value):
		end_placed = value
		if end_placed:
			show()
			calculate_line_points()

var additional_points: Array[Vector2] = []
# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta('type', 'wire')
	state = Global.State.OFF
	Global.edit_wires = true
	Global.terminal_changed.connect(set_terminal.bind())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if start_placed and end_placed: return
	if start_placed or end_placed:
		global_position = Vector2.ZERO
		calculate_line_points()
	else:
		global_position = get_global_mouse_position()

func _unhandled_input(event: InputEvent) -> void:
	get_viewport().set_input_as_handled()
	if not start_placed and not end_placed or (start_placed and end_placed): return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# actually we are appending the last two elements one more time, but after appending the second from the back the first one from the back becomes the second one
		line.points[-1] = Helpers.get_position_on_building_grid(line.points[-1])
		line.points[-2] = Helpers.get_position_on_building_grid(line.points[-2])
		line.add_point(line.get_point_position(line.get_point_count() - 3))
		line.add_point(line.get_point_position(line.get_point_count() - 3))
		check_for_wire_completed.call_deferred()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if line.get_point_count() == 3:
			queue_free()
			return
		line.remove_point(line.get_point_count() - 1)
		line.remove_point(line.get_point_count() - 1)

func check_for_wire_completed():
	if not (start_placed and end_placed): return
	line.remove_point(line.get_point_count() - 1)
	line.remove_point(line.get_point_count() - 1)


func set_terminal():
	# if the terminal is the same one as one of the other ones we just return.
	if Global.terminal == input_terminal or Global.terminal == output_terminal: return
	# depending on if the terminal allows input we either set the input or the output
	if Global.terminal.input_terminal:
		set_input_terminal()
	else:
		set_output_terminal()

func set_input_terminal():
	# the input terminal needs to be able to receive input.
	if not Global.terminal.input_terminal: return
	# we do not want allow a recursive connection
	if output_terminal and output_terminal.parent_block and Global.terminal.parent_block == output_terminal.parent_block: return
	# transfer the input terminal and change the signals to correspond to the end of the wire
	input_terminal = Global.terminal
	start_placed = true
	input_terminal.state_changed.connect(update_states.bind())
	# we check if the other terminal is not null. if this is the case the wire has been finished so we disconnect the signal and exit edit mode
	if output_terminal != null:
		Global.terminal_changed.disconnect(set_terminal.bind())
		Global.edit_wires = false

func set_output_terminal():
	# if the output terminal can receive input, its not allowed
	if Global.terminal.input_terminal: return
	# the two terminals cannot be the same one
	if Global.terminal == input_terminal: return
	# we do not want to allow a recursive connection
	if input_terminal and input_terminal.parent_block and Global.terminal.parent_block == input_terminal.parent_block: return
	# save the output terminal and disconnect the signal
	output_terminal = Global.terminal
	end_placed = true
	# we check if the other terminal is not null. if this is the case the wire has been finished so we disconnect the signal and exit edit mode
	if input_terminal != null:
		Global.terminal_changed.disconnect(set_terminal.bind())
		Global.edit_wires = false

func calculate_line_points():
	var rounded_mouse_position: Vector2 = get_global_mouse_position()
	if start_placed and not end_placed: calculate_line_points_backend(input_terminal.connection_node.global_position, rounded_mouse_position)
	elif end_placed and not start_placed: calculate_line_points_backend(output_terminal.connection_node.global_position, rounded_mouse_position)
	elif start_placed and end_placed: add_collision_shapes()


func calculate_line_points_backend(start: Vector2, end: Vector2):
	line.points[0] = start
	line.points[-1] = end
	line.points[-2] = Vector2(line.points[-3].x, line.points[-1].y) if not Settings.wire_curve_direction_toggled else Vector2(line.points[-1].x, line.points[-3].y)

func add_collision_shapes() -> void:
	for i in line.get_point_count() - 2:
		var point = line.get_point_position(i)
		var next_point = line.get_point_position(i + 1)
		var collision_shape: CollisionShape2D = CollisionShape2D.new()
		collision_shape.shape = SegmentShape2D.new()
		collision_shape.shape.a = point
		collision_shape.shape.b = next_point
		$Area2D.add_child(collision_shape)

func update_states():
	state = input_terminal.state
	output_terminal.state = input_terminal.state
