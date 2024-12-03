extends Block
class_name CustomBlock

var boolean_expressions: Dictionary
var boolean_expression_variables: Array
var block_data: Dictionary

func _ready() -> void:
	block_name = block_data['info']['block_name']
	input_terminal_count = block_data['info']['input_terminal_count']
	output_terminal_count = block_data['info']['output_terminal_count']
	label = block_data['info']['block_name'].replace('_', ' ')
	color = Color.from_string(block_data['info']['color'], '#ffffff')
	boolean_expressions = block_data['boolean_expressions']
	boolean_expression_variables = block_data['boolean_expression_variables']
	build_mode = true

	$Area2D/CollisionShape2D.shape = RectangleShape2D.new()

	super()


func update_states():
	Helpers.debug(self, 24, output_terminals)
	var incoming_as_bool: Array

	for terminal in input_terminals:
		incoming_as_bool.append(terminal.state == Global.State.ON)

	for terminal in output_terminals:
		var terminal_id = terminal.id
		var expression_statement = boolean_expressions[terminal_id]
		var expression = Expression.new()

		expression.parse(expression_statement, boolean_expression_variables)
		terminal.state = Global.State.ON if expression.execute(incoming_as_bool) else Global.State.OFF

func get_boolean_expression(input_terminal_expressions: Array[String]) -> Array[String]:
	var boolean_expression_with_inputs = boolean_expressions.duplicate()
	for boolean_expression in boolean_expressions:
		for i in range(len(boolean_expression_variables)):
			var boolean_expression_variable = boolean_expression_variables[i]
			boolean_expression.replace(boolean_expression_variable, input_terminal_expressions[i])
	return boolean_expression_with_inputs
