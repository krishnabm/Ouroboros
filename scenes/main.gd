extends CanvasLayer

@onready var start_text: Label = %StartText
@onready var high_score_label: Label = %HighScoreLabel
@onready var vol_button: TextureButton = %VolButton
@onready var mute_button: TextureButton = %MuteButton

var muted := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var highScoreVal = GameParams.get_value_or_default("highScore", false)
	high_score_label.text += str(highScoreVal)
	
	mute_button.visible = !muted
	vol_button.visible = muted

	if OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.has_feature("android") or OS.has_feature("ios"):
		start_text.text = "Tap anywhere to begin"
	else:
		start_text.text = "Press any key to begin"

func mute_master():
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus, true)

func unmute_master():
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus, false)
	
#func _input(event: InputEvent) -> void:
	## Handle mobile taps (touch)
	#if event is InputEventScreenTouch and event.pressed:
		#_go_to_game_scene()
#
	## Handle desktop + Android mouse-emulated taps
	#elif event is InputEventMouseButton and event.pressed:
		## On Android, a finger tap often shows up as a mouse button 1 (left click)
		#if event.button_index == MOUSE_BUTTON_LEFT :
			#_go_to_game_scene()
#
	## Handle any key press (desktop)
	#elif event is InputEventKey and event.pressed:
		#_go_to_game_scene()

func _unhandled_input(event: InputEvent) -> void:
	# Handle mobile taps (touch)
	if event is InputEventScreenTouch and event.pressed:
		_go_to_game_scene()

	# Handle desktop clicks (mouse button)
	elif event is InputEventMouseButton and event.pressed:
		_go_to_game_scene()

	# Handle any key press (desktop)
	elif event is InputEventKey and event.pressed:
		_go_to_game_scene()


func _go_to_game_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _go_to_tutorial_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/tutorial.tscn")
	
func _on_vol_button_pressed() -> void:
	unmute_master()
	muted = false
	mute_button.visible = !muted
	vol_button.visible = muted

func _on_mute_button_pressed() -> void:
	mute_master()
	muted = true
	mute_button.visible = !muted
	vol_button.visible = muted


func _on_touch_anywhere_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_LEFT:
		_go_to_game_scene()
	elif event is InputEventScreenTouch:
		_go_to_game_scene()


func _on_tutorial_button_pressed() -> void:
	_go_to_tutorial_scene()
