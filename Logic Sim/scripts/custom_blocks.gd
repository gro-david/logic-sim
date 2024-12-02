extends Block
class_name CustomBlock

var boolean_expressions: Array
var boolean_expression_variables: Array
var block_data: Dictionary

func _ready() -> void:
	block_name = block_data['info']['block_name']
	incoming_count = block_data['info']['input_terminal_count']
	outgoing_count = block_data['info']['output_terminal_count']
	label = block_data['info']['block_name'].replace('_', ' ')
	color = Color.from_string(block_data['info']['color'], '#ffffff')
	boolean_expressions = block_data['boolean_expressions']
	boolean_expression_variables = block_data['boolean_expression_variables']
	build_mode = true

	$Area2D/CollisionShape2D.shape = RectangleShape2D.new()

	super()


func update_states():
	var incoming_as_bool: Array

	for terminal in incoming:
		incoming_as_bool.append(terminal.state == Global.State.ON)

	for i in range(len(boolean_expressions)):
		var expression = boolean_expressions[i]
		var expr = Expression.new()
		expr.parse(expression, boolean_expression_variables)
		outgoing[i].state = Global.State.ON if expr.execute(incoming_as_bool) else Global.State.OFF

func get_boolean_expression(input_terminal_expressions: Array[String]) -> Array[String]:
	print(input_terminal_expressions)
	print(boolean_expressions)
	var boolean_expression_with_inputs = boolean_expressions.duplicate()
	for i in range(len(boolean_expressions)):
		for j in range(boolean_expressions.count('i')):
			boolean_expression_with_inputs[i].replace('i' + str(j), input_terminal_expressions[j])

	return boolean_expression_with_inputs
