extends CanvasLayer

@export_category('Scenes')
@export var wire_scene: PackedScene
@export var and_scene: PackedScene
@export var or_scene: PackedScene
@export var not_scene: PackedScene

@export_category('Nodes')
@export var wire_btn: Button
@export_category('Block Buttons')
@export var and_btn: Button
@export var or_btn: Button
@export var not_btn: Button

@export_category('Other Buttons')
@export var save_btn: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	wire_btn.pressed.connect(instantiate_wire.bind())
	and_btn.pressed.connect(instantiate_block.bind(and_scene))
	or_btn.pressed.connect(instantiate_block.bind(or_scene))
	not_btn.pressed.connect(instantiate_block.bind(not_scene))
	save_btn.pressed.connect(get_parent().save.bind())


func instantiate_block(scene: PackedScene):
	var instance = scene.instantiate()
	instance.name = str(get_parent().block_count)
	get_parent().block_count += 1
	get_parent().blocks.add_child(instance)
	if not instance.get_meta('type') == 'block': return
	instance.build_mode = true

func instantiate_wire():
	var instance = wire_scene.instantiate()
	instance.name = str(get_parent().wire_count)
	get_parent().wire_count += 1
	get_parent().wires.add_child(instance)
	if not instance.get_meta('type') == 'block': return
	instance.build_mode = true
