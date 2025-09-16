extends Control

var pressed := false
var action_name := "ui_left"

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_LEFT:
		Input.action_press(action_name) if event.pressed else Input.action_release(action_name)
	elif event is InputEventScreenTouch:
		Input.action_press(action_name) if event.pressed else Input.action_release(action_name)
	else:
		Input.action_release(action_name)
