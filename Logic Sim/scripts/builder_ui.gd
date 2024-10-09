extends CanvasLayer
class_name BuilderUI

@export_category('Scenes')
@export var wire_scene: PackedScene
@export var and_scene: PackedScene
@export var not_scene: PackedScene

@export_category('Nodes')
@export var name_edit: LineEdit
@export var color_picker: ColorPickerButton
@export_category('Block Buttons')
@export var and_btn: Button
@export var not_btn: Button

@export_category('Other Buttons')
@export var wire_btn: Button
@export_category('HUD Buttons')
@export var save_btn: Button
@export var clear_btn: Button
@export var edit_btn: Button

@export_category('Scenes')
@export var custom_block_button: PackedScene
@export var custom_block: PackedScene
@export var terminal: PackedScene

# this will store all of the blocks instances as a value and the path of the as a key
var custom_buttons_to_blocks: Dictionary = {}
var blocks_being_placed: Array = []

@onready var builder: Builder = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.builder_ui = self
	wire_btn.pressed.connect(instantiate_wire.bind())
	and_btn.pressed.connect(instantiate_block.bind(and_scene))
	not_btn.pressed.connect(instantiate_block.bind(not_scene))
	save_btn.pressed.connect(builder.save.bind())
	clear_btn.pressed.connect(clear_builder.bind())
	edit_btn.pressed.connect(edit_builder_layout.bind())

	name_edit.text = builder.built_block_name
	color_picker.color = builder.built_block_color

	Global.block_placed.connect(func(): blocks_being_placed.clear())

	load_custom_blocks()

func instantiate_block(scene: PackedScene):
	var instance = scene.instantiate()
	instance.name = str(builder.block_count)
	instance.build_mode = true

	builder.block_count += 1
	builder.blocks.add_child(instance)

	multi_placement_behavior(instance)

func instantiate_wire():
	var instance = wire_scene.instantiate()
	instance.name = str(builder.wire_count)
	builder.wire_count += 1
	builder.wires.add_child(instance)


func _on_name_text_changed(new_text:String) -> void:
	builder.built_block_name = new_text

func _on_color_picker_color_changed(color:Color) -> void:
	builder.built_block_color = color

func edit_custom_block(block_path: String) -> void:
	pass

func delete_custom_block(block_path: String) -> void:
	var confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.confirmed.connect(_on_delete_confirmed.bind(block_path))
	confirmation_dialog.dialog_text = 'Are you sure you want to delete ' + block_path.split('/')[-1].split('.')[0] + '? This may delete blocks on the builder.'
	confirmation_dialog.ok_button_text = 'Yes'
	confirmation_dialog.cancel_button_text = 'No'
	confirmation_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	confirmation_dialog.popup()
	add_child(confirmation_dialog)

func _on_delete_confirmed(block_path: String) -> void:
	DirAccess.remove_absolute(block_path)
	for block in custom_buttons_to_blocks[block_path]:
		if not is_instance_valid(block): continue
		block.queue_free()
	load_custom_blocks.call_deferred()

func instantiate_custom_block(block_path: String):
	var block_data = JSON.parse_string(FileAccess.open(block_path, FileAccess.READ).get_as_text())
	var instance: CustomBlock = custom_block.instantiate()
	instance.name = str(builder.block_count)
	instance.build_mode = true
	instance.block_data = block_data
	custom_buttons_to_blocks[block_path].append(instance)

	builder.block_count += 1
	builder.blocks.add_child(instance)

	multi_placement_behavior(instance)

func multi_placement_behavior(instance: Block) -> void:
	for i in range(len(blocks_being_placed)):
		if not is_instance_valid(blocks_being_placed[i]):
			blocks_being_placed.remove_at(i)

	if len(blocks_being_placed) > 0:
		instance.placement_offset = Vector2(0, -(blocks_being_placed[-1].block_height / 2) - (instance.block_height / 2) - instance.multi_placement_y_gap) + blocks_being_placed[-1].placement_offset
	blocks_being_placed.append(instance)

func clear_builder():
	var confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.confirmed.connect(_on_clear_confirmed)
	confirmation_dialog.dialog_text = 'Are you sure you want to clear the builder?'
	confirmation_dialog.ok_button_text = 'Yes'
	confirmation_dialog.cancel_button_text = 'No'
	confirmation_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	confirmation_dialog.popup()
	add_child(confirmation_dialog)

func _on_clear_confirmed():
	for wire in builder.get_node('wires').get_children():
		wire.queue_free()
	for block in builder.get_node('blocks').get_children():
		block.queue_free()
	for _terminal in builder.input_terminals:
		_terminal.queue_free()
	for _terminal in builder.output_terminals:
		_terminal.queue_free()

	builder.input_terminals.clear()
	builder.output_terminals.clear()

func edit_builder_layout() -> void:
	Global.edit_mode = true

	for block in blocks_being_placed:
		block.queue_free()
	blocks_being_placed.clear()

	$inventory.hide()
	edit_btn.text = 'Exit Edit Mode'
	edit_btn.pressed.disconnect(edit_builder_layout.bind())
	edit_btn.pressed.connect(save_builder_layout.bind())

func save_builder_layout() -> void:
	Global.edit_mode = false

	$inventory.show()
	edit_btn.text = 'Enter Edit Mode'
	edit_btn.pressed.disconnect(save_builder_layout.bind())
	edit_btn.pressed.connect(edit_builder_layout.bind())

func load_custom_blocks():
	custom_buttons_to_blocks.clear()

	for button in get_tree().get_nodes_in_group('custom_block_buttons'):
		button.queue_free()

	for file in DirAccess.get_files_at(Global.block_path):
		var json = JSON.parse_string(FileAccess.open(Global.block_path + '/' + file, FileAccess.READ).get_as_text())
		var button: CustomBlockButton = custom_block_button.instantiate()
		button.name = json['info']['block_name']
		button.text = json['info']['block_name'].to_upper()
		button.corresponding_block_data_path = Global.block_path + '/' + file
		button.edit_block.connect(edit_custom_block.bind())
		button.delete_block.connect(delete_custom_block.bind())
		button.instantiate_block.connect(instantiate_custom_block.bind())
		button.add_to_group('custom_block_buttons')
		$inventory.add_child(button)

		custom_buttons_to_blocks[Global.block_path + '/' + file] = []


func _on_input_terminal_place_area_input_event(_viewport:Node, event:InputEvent, _shape_idx:int) -> void:
	if not Global.edit_mode: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		builder.instantiate_terminal(builder.input_terminal_scene, builder.get_global_mouse_position(), true)


func _on_output_terminal_place_region_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not Global.edit_mode: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		builder.instantiate_terminal(builder.input_terminal_scene, builder.get_global_mouse_position(), false)
