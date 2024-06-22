extends Control
class_name Terminal

signal state_changed

@export_category('Colors')
@export var on_color: Color
@export var off_color: Color

@export_category('Nodes')
@export var sprite: Sprite2D

@onready var connection_position = $connection.global_position

var state: Global.State:
	# when this changes, update the color and emit the signal to notify the blocks
	set(value):
		state = value
		sprite.self_modulate = on_color if state == Global.State.ON else off_color
		state_changed.emit()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
