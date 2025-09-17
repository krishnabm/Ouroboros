extends Control

var action_name := "ui_select"
var isTouch := false

func _ready():
	if OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.has_feature("android") or OS.has_feature("ios"):
		isTouch = true

func _gui_input(event: InputEvent) -> void:
	if isTouch:
		if event is InputEventScreenTouch:
			Input.action_press(action_name) if event.pressed else Input.action_release(action_name)
		else:
			Input.action_release(action_name)
	else:
		if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_LEFT:
			Input.action_press(action_name) if event.pressed else Input.action_release(action_name)
		else:
			Input.action_release(action_name)
