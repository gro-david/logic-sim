extends Node2D

@export_category('Terminals')
@export var input_terminal_scene: PackedScene
@export var output_terminal_scene: PackedScene
@export var input_terminal_count: int = 1
@export var output_terminal_count: int = 1
@export var input_terminal_spacing: int = 0
@export var output_terminal_spacing: int = 0
@export var input_terminal_x_position: float = 24
@export var output_terminal_x_position: float = 1896

@onready var center_y_position: float = get_viewport().size.y / 2
var input_terminal_instance: Terminal
var output_terminal_instance: Terminal
var input_terminal_height: float
var output_terminal_height: float

# Called when the node enters the scene tree for the first time.
func _ready():
	# instantiate the terminals to save the height then delete them
	input_terminal_instance = input_terminal_scene.instantiate()
	input_terminal_height = input_terminal_instance.sprite.texture.get_height() + input_terminal_spacing
	input_terminal_instance.queue_free()
	output_terminal_instance = output_terminal_scene.instantiate()
	output_terminal_height = output_terminal_instance.sprite.texture.get_height() + output_terminal_spacing
	
	var input_terminal_count_even := input_terminal_count % 2 == 0
	var output_terminal_count_even := output_terminal_count % 2 == 0
	if input_terminal_count_even: instantiate_terminal_even_count(input_terminal_scene, input_terminal_count, input_terminal_x_position, input_terminal_height, false)
	else: instantiate_terminal_odd_count(input_terminal_scene, input_terminal_count, input_terminal_x_position, input_terminal_height, false)
	if output_terminal_count_even: instantiate_terminal_even_count(output_terminal_scene, output_terminal_count, output_terminal_x_position, output_terminal_height, true)
	else: instantiate_terminal_odd_count(output_terminal_scene, output_terminal_count, output_terminal_x_position, output_terminal_height, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func instantiate_terminal_even_count(terminal: PackedScene, count: int, x_position: float, height: float, flip: bool):
	var half_point = int(count / 2.0)
	for i in range(count):
		# we either move the terminal down or up depending on if we are above or below the middle
		if i < half_point:
			var terminal_instance = terminal.instantiate()
			terminal_instance.global_position = Vector2(x_position, center_y_position + ((i % half_point) * height + 0.5 * height))
			terminal_instance.sprite.flip_h = flip
			add_child(terminal_instance)
		else:
			var terminal_instance = terminal.instantiate()
			terminal_instance.global_position = Vector2(x_position, center_y_position - ((i % half_point) * height + 0.5 * height))
			terminal_instance.sprite.flip_h = flip
			add_child(terminal_instance)
			
func instantiate_terminal_odd_count(terminal: PackedScene, count: int, x_position: float, height: float, flip: bool):
	var half_point = int((count - 1) / 2.0)
	for i in range(count):
		# we either move the terminal down or up or not depending on if we are below or above the middle
		if i < half_point:
			var terminal_instance = terminal.instantiate()
			terminal_instance.global_position = Vector2(x_position, center_y_position + ((i % half_point) + 1) * height)
			terminal_instance.sprite.flip_h = flip
			add_child(terminal_instance)
		elif i == half_point:
			var terminal_instance = terminal.instantiate()
			terminal_instance.global_position = Vector2(x_position, center_y_position)
			terminal_instance.sprite.flip_h = flip
			add_child(terminal_instance)
		else:
			var terminal_instance = terminal.instantiate()
			terminal_instance.global_position = Vector2(x_position, center_y_position - ((i % half_point) + 1) * height)
			terminal_instance.sprite.flip_h = flip
			add_child(terminal_instance)
