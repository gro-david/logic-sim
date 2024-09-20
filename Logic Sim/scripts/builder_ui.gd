extends CanvasLayer

@export_category('Scenes')
@export var wire_scene: PackedScene
@export var and_scene: PackedScene
#@export var or_scene: PackedScene
@export var not_scene: PackedScene

@export_category('Nodes')
@export var name_edit: LineEdit
@export var color_picker: ColorPickerButton
@export_category('Block Buttons')
@export var and_btn: Button
#@export var or_btn: Button
@export var not_btn: Button

@export_category('Other Buttons')
@export var wire_btn: Button
@export var save_btn: Button

@export_category('Scenes')
@export var custom_block_button: PackedScene
@export var custom_block: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	wire_btn.pressed.connect(instantiate_wire.bind())
	and_btn.pressed.connect(instantiate_block.bind(and_scene))
	#or_btn.pressed.connect(instantiate_block.bind(or_scene))
	not_btn.pressed.connect(instantiate_block.bind(not_scene))
	save_btn.pressed.connect(get_parent().save.bind())

	name_edit.text = get_parent().built_block_name
	color_picker.color = get_parent().built_block_color

	for file in DirAccess.get_files_at(Global.block_path):
		var json = JSON.parse_string(FileAccess.open(Global.block_path + '/' + file, FileAccess.READ).get_as_text())
		var button: CustomBlockButton = custom_block_button.instantiate()
		button.name = json['info']['block_name']
		button.text = json['info']['block_name'].to_upper()
		button.corresponding_block_data_path = Global.block_path + '/' + file
		button.edit_block.connect(edit_custom_block.bind())
		button.delete_block.connect(delete_custom_block.bind())
		button.instantiate_block.connect(instantiate_custom_block.bind())
		$inventory.add_child(button)


func instantiate_block(scene: PackedScene):
	var instance = scene.instantiate()
	instance.name = str(get_parent().block_count)
	instance.build_mode = true
	get_parent().block_count += 1
	get_parent().blocks.add_child(instance)

func instantiate_wire():
	var instance = wire_scene.instantiate()
	instance.name = str(get_parent().wire_count)
	get_parent().wire_count += 1
	get_parent().wires.add_child(instance)


func _on_name_text_changed(new_text:String) -> void:
	get_parent().built_block_name = new_text

func _on_color_picker_color_changed(color:Color) -> void:
	get_parent().built_block_color = color

func edit_custom_block(block_path: String) -> void:
	pass

func delete_custom_block(block_path: String) -> void:
	var confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.confirmed.connect(_on_delete_confirmed.bind(block_path))
	confirmation_dialog.dialog_text = 'Are you sure you want to delete ' + block_path.split('/')[-1].split('.')[0] + '?'
	confirmation_dialog.ok_button_text = 'Yes'
	confirmation_dialog.cancel_button_text = 'No'
	confirmation_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	confirmation_dialog.popup()
	add_child(confirmation_dialog)

func _on_delete_confirmed(block_path: String) -> void:
	DirAccess.remove_absolute(block_path)

func instantiate_custom_block(block_path: String):
	var block_data = JSON.parse_string(FileAccess.open(block_path, FileAccess.READ).get_as_text())
	var instance: CustomBlock = custom_block.instantiate()
	instance.name = str(get_parent().block_count)
	instance.build_mode = true
	instance.block_data = block_data
	get_parent().block_count += 1
	get_parent().blocks.add_child(instance)
