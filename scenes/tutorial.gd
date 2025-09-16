extends CanvasLayer
@onready var screenshot: TextureRect = %Screenshot

const slide1 = preload("res://res/tutorialSlides/1.png")

var curSlide := 1
var isTouch = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.has_feature("android") or OS.has_feature("ios"):
		isTouch = true
		
	curSlide = 1
	screenshot.texture = slide1

func prev_slide() -> void:
	curSlide -= 1
	
	if curSlide == 0:
		curSlide = 5
	
	if isTouch and curSlide == 3:
		curSlide = 2
	if !isTouch and curSlide == 4:
		curSlide = 3

	screenshot.texture = load("res://res/tutorialSlides/" + str(curSlide) +".png")

func next_slide() -> void:
	curSlide += 1
	
	if curSlide == 6:
		curSlide = 1
	
	if isTouch and curSlide == 3:
		curSlide = 4
	if !isTouch and curSlide == 4:
		curSlide = 5

	screenshot.texture = load("res://res/tutorialSlides/" + str(curSlide) +".png")

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
		if Input.is_action_pressed("ui_left"):
			prev_slide()
			
		if Input.is_action_pressed("ui_right"):
			next_slide()

func _on_left_button_pressed() -> void:
	prev_slide()


func _on_right_button_pressed() -> void:
	next_slide()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
