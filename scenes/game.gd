extends CanvasLayer

const FOOD = preload("res://scenes/food.tscn")
const ULTRA_FOOD = preload("res://scenes/ultra_food.tscn")
var foodExists: bool = false
var foodSpawn: Marker2D
var hardcoreWarning := 0
var isHardcore: bool = false
var scoreVal := 0
var highScoreVal := 0
var warningsSeen := 0
var isTouch := false
var bgmInteractive: AudioStreamPlaybackInteractive = null
@onready var snake: Line2D = %Snake
@onready var score: Label = %Score
@onready var hardcore_timer: Timer = %HardcoreTimer
@onready var speed_up_timer: Timer = %SpeedUpTimer
@onready var end_timer: Timer = %EndTimer
@onready var walls: ColorRect = %Walls
@onready var end_label: Label = %EndLabel
@onready var narrative_label: Label = %NarrativeLabel
@onready var left_zone: Control = %LeftZone
@onready var right_zone: Control = %RightZone
@onready var bgm: AudioStreamPlayer = %BGM


var endTexts = ["Cursesss!", "Shucksss!", "By my hissing fangsss!", "Ssserpent’s ssspite!", "Sssilly me!", "Foiled Plansss!"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#(bgm.stream as AudioStreamInteractive).set_current("Normal")
	bgmInteractive = bgm.get_stream_playback()
	bgm.play()
	bgm["parameters/switch_to_clip"] = "Normal"
	#bgmInteractive.switch_to_clip_by_name("Normal")
	
	if OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.has_feature("android") or OS.has_feature("ios"):
		isTouch = true
	
	isHardcore = false
	highScoreVal = GameParams.get_value_or_default("highScore", false)
	warningsSeen = GameParams.get_value_or_default("warningsSeen", false)
	spawn_food()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !foodExists:
		spawn_food()

func spawn_food():
	var spawn = get_tree().get_nodes_in_group("FoodSpawnPoints")
	var foodNode = null
	if isHardcore:
		spawn.append_array(get_tree().get_nodes_in_group("UltraFoodSpawnPoints"))
		foodNode = ULTRA_FOOD.instantiate()
	else:
		foodNode = FOOD.instantiate()
		
	foodSpawn = spawn[randi() % spawn.size()]
	foodSpawn.add_child(foodNode)
	foodExists = true
	snake.foodCoord = foodSpawn.global_position


func _on_snake_ate_food() -> void:
	foodExists = false
	
	var hardStarted = not hardcore_timer.is_stopped()
	if !isHardcore and !hardStarted and hardcoreWarning >= 5:
		hardcore_timer.start()
		var dialogIndex = warningsSeen % 3
		if dialogIndex == 0:
			narrative_label.text = "Now suffer my wrath!!!"
		elif dialogIndex == 1:
			narrative_label.text = "Prepare to die!"
		elif dialogIndex == 2:
			narrative_label.text = "...."
		warningsSeen += 1
		GameParams.update_param("warningsSeen", warningsSeen)
		var tween = create_tween()
		tween.tween_property(narrative_label, "visible_ratio", 1.0, 2.0)
		tween.tween_property(narrative_label, "visible_ratio", 1.0, 2.0)
		tween.tween_property(narrative_label, "visible_ratio", 0.0, 0.01)

	if !isHardcore and !hardStarted and hardcoreWarning < 5:
		hardcoreWarning += 1
		if hardcoreWarning == 1 or hardcoreWarning == 3:
			var dialogIndex = (warningsSeen + hardcoreWarning - 1) % 3
			if dialogIndex == 0:
				narrative_label.text = "You dare pilfer my bounty, fool!!??"
			elif dialogIndex == 1:
				narrative_label.text = "You're back again?"
			elif dialogIndex == 2:
				narrative_label.text = "...this is getting tedious"
			
			var tween = create_tween()
			tween.tween_property(narrative_label, "visible_ratio", 1.0, 2.0)
			tween.tween_property(narrative_label, "visible_ratio", 1.0, 2.0)
			tween.tween_property(narrative_label, "visible_ratio", 0.0, 0.01)
		
			
		
	var ateGolden = false
	for child in foodSpawn.get_children():
		if child.scene_file_path == "res://scenes/ultra_food.tscn":
			ateGolden = true
		child.queue_free()
	
	if ateGolden:
		scoreVal += 50
		score.text = str(score.text.to_int() + 50)
	else:
		scoreVal += 10
		score.text = str(score.text.to_int() + 10)
		
	if scoreVal > highScoreVal:
		highScoreVal = scoreVal
		GameParams.update_param("highScore", highScoreVal)

func _on_hardcore_timer_timeout() -> void:
	isHardcore = true
	bgm["parameters/switch_to_clip"] = "Danger"
	#bgmInteractive.switch_to_clip_by_name("Danger")
	speed_up_timer.start()
	walls.material = load("res://res/material/hardcore.tres")

func _on_speed_up_timer_timeout() -> void:
	snake.speed += 50

func _on_snake_died() -> void:
	bgm["parameters/switch_to_clip"] = "Lose"
	#bgmInteractive.switch_to_clip_by_name("Lose")
	end_timer.start()
	end_label.text = endTexts[randi() % endTexts.size()]
	var tween = create_tween()
	tween.tween_property(end_label, "visible_ratio", 1.0, 1.0)


func _on_end_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
