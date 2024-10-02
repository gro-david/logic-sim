extends Control

func _ready() -> void:
	mouse_entered.connect(func(): Global.cursor_on_ui = true)
	mouse_exited.connect(func(): Global.cursor_on_ui = false)
