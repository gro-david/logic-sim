extends CanvasLayer

@export_category('Scenes')
@export var wire_scene: PackedScene
@export var and_scene: PackedScene
@export var or_scene: PackedScene
@export var not_scene: PackedScene

@export_category('Nodes')
@export_category('Block Buttons')
@export var wire_btn: Button
@export var and_btn: Button
@export var or_btn: Button
@export var not_btn: Button

@export_category('Other Buttons')
@export var save_btn: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	wire_btn.pressed.connect(instantiate_scene.bind(wire_scene))
	and_btn.pressed.connect(instantiate_scene.bind(and_scene))
	or_btn.pressed.connect(instantiate_scene.bind(or_scene))
	not_btn.pressed.connect(instantiate_scene.bind(not_scene))
	save_btn.pressed.connect(get_parent().save.bind())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func instantiate_scene(scene: PackedScene):
	var instance = scene.instantiate()
	get_parent().blocks.add_child(instance)
	if not instance.get_meta('type') == 'block': return
	instance.build_mode = true
