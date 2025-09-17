extends Line2D

@export_range(4, 10000, 1) var segment_count: int
@export_range(4, 10000, 1) var radius: int
@export var speed: int
@export var turn_radius: int

@onready var snake_spawn: Marker2D = %SnakeSpawn
@onready var left_turn_marker: Marker2D = $leftTurnMarker
@onready var right_turn_marker: Marker2D = $rightTurnMarker
@onready var eat_sounds: AudioStreamPlayer = %EatSounds

var seg_dist: float = 0.0
var clockwise: bool = false
var foodCoord: Vector2 = Vector2(0,0)
var screenSize: Vector2 = Vector2(0,0)
var isDead: bool = false
var baseGradient: Gradient = null
var eatGradient: Gradient = null

signal ate_food
signal died
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_circle_points(snake_spawn.global_position)
	calculate_segment_distance()
	screenSize = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),ProjectSettings.get_setting("display/window/size/viewport_height"))
	
	# Pick a base color (greenish for snake)
	var base_color: Color = Color.SEA_GREEN
	# Complementary color (reddish)
	var comp_color: Color = Color.INDIAN_RED

	# Define gradient points
	baseGradient = Gradient.new()
	baseGradient.set_offset(0, 0.0)
	baseGradient.set_offset(1, 1.0)
	baseGradient.interpolation_color_space = Gradient.GRADIENT_COLOR_SPACE_LINEAR_SRGB
	baseGradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_LINEAR
	eatGradient = Gradient.new()
	eatGradient.set_offset(0, 0.0)
	eatGradient.set_offset(1, 1.0)
	eatGradient.interpolation_color_space = Gradient.GRADIENT_COLOR_SPACE_LINEAR_SRGB
	eatGradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_LINEAR
	
	baseGradient.add_point(-1.0, Color.ANTIQUE_WHITE)
	baseGradient.add_point(0.0, Color.ANTIQUE_WHITE)
	baseGradient.add_point(1.0, Color.ANTIQUE_WHITE)
	
	eatGradient.add_point(-1.0, Color.INDIAN_RED)
	eatGradient.add_point(0.0, Color.INDIAN_RED)
	eatGradient.add_point(1.0, Color.ANTIQUE_WHITE)


func add_circle_points(center: Vector2) -> void:
	for i in range(segment_count):
		var angle = (2.0 * PI * i) / segment_count
		var x = center.x + radius * cos(angle)
		var y = center.y + radius * sin(angle)
		add_point(Vector2(x, y))
		
func try_eat(index: int) -> bool:
	if Geometry2D.is_point_in_polygon(foodCoord, points.slice(0,index+1)):
		return true
	else:
		return false

func debug_draw_vec(origin:Vector2, dest:Vector2):
	draw_line(origin, origin + dest, Color.RED, 2)

func debug_draw_point(pt:Vector2):
	draw_circle(pt,500,Color.AQUA,true)

func steer_left():
	var headPos: Vector2 = get_point_position(0)
	var secondPos: Vector2 = get_point_position(1)
	var snakeDirection = (headPos - secondPos).normalized()
	var leftTurnPoint = get_offset_point(headPos, snakeDirection, 180, turn_radius)
	
	left_turn_marker.global_position = leftTurnPoint
	
	snake_spawn.global_position = left_turn_marker.global_position
	clockwise = false
	
func steer_right():
	var headPos: Vector2 = get_point_position(0)
	var secondPos: Vector2 = get_point_position(1)
	var snakeDirection = (headPos - secondPos).normalized()
	var rightTurnPoint = get_offset_point(headPos, snakeDirection, 0, turn_radius)
	
	right_turn_marker.global_position = rightTurnPoint
	
	snake_spawn.global_position = right_turn_marker.global_position
	clockwise = true
	
func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("ui_select") or Input.is_action_pressed("ui_accept"):
		if clockwise:
			steer_left()
		elif !clockwise:
			steer_right()

func _process(delta: float) -> void:
	if isDead:
		return

	var headPos: Vector2 = get_point_position(0)
	var tailPos: Vector2 = get_point_position(get_point_count()-1)
	
	if check_hit_boundary(headPos):
		isDead = true
		died.emit()
	
	var move_vec: Vector2 = get_tangent_direction(headPos, snake_spawn.global_position)
	
	headPos = headPos + speed*move_vec*delta
	
	set_point_position(0,headPos)

	var prevPos = headPos
	var isClosedLoopNow = false

	for i in range(1, get_point_count()):
		var curPos: Vector2 = get_point_position(i)
		

		if (curPos.distance_to(prevPos) > seg_dist):
			var dir = (prevPos - curPos).normalized()
			curPos = prevPos - dir * seg_dist
			set_point_position(i, curPos)
		prevPos = curPos
		
		if i > 10:
			if (headPos.distance_to(curPos) < 25):
				isClosedLoopNow = true
				default_color = Color.INDIAN_RED
				gradient = eatGradient
				if try_eat(i):
					eat_sounds.play(0.1)
					# Messy way of adding 3 points
					for _x in range(5):
						add_point(tailPos)
					ate_food.emit()
					break
			else:
				if not isClosedLoopNow:
					default_color = Color.ANTIQUE_WHITE
					gradient = baseGradient

func calculate_segment_distance():
	seg_dist = get_point_position(0).distance_to(get_point_position(1))

func get_offset_point(origin: Vector2, direction: Vector2, angle_degrees: float, distance: float) -> Vector2:
	var rotationAngle = direction.angle_to(Vector2.UP)
	var angle_radians = deg_to_rad(angle_degrees)
	var offset = Vector2(cos(angle_radians), sin(angle_radians)) * distance
	
	var trueOffsetPos =  origin + offset.rotated(-rotationAngle)
	return trueOffsetPos
	
func get_tangent_direction(point: Vector2, center: Vector2) -> Vector2:
	var radius_vector = point - center
	var tangent = Vector2(radius_vector.y, -radius_vector.x) if not clockwise else Vector2(-radius_vector.y, radius_vector.x)
	return tangent.normalized()

func check_hit_boundary(headPos:Vector2) -> bool:
	if point_segment_distance(Vector2(0,0), Vector2(screenSize.x,0),headPos) < 20:
		return true
	if point_segment_distance(Vector2(screenSize.x,0), Vector2(screenSize.x,screenSize.y),headPos) < 20:
		return true
	if point_segment_distance(Vector2(0,0), Vector2(0,screenSize.y),headPos) < 20:
		return true
	if point_segment_distance(Vector2(0,screenSize.y), Vector2(screenSize.x,screenSize.y),headPos) < 20:
		return true
	return false

func point_segment_distance(line_start: Vector2, line_end: Vector2, to_point: Vector2) -> float:
	var line_vec = line_end - line_start
	var point_vec = to_point - line_start
	
	# Handle edge case: segment is a single point
	if line_vec.length_squared() == 0:
		return point_vec.length()
	
	# Project point_vec onto line_vec (normalized via dot product)
	var t = point_vec.dot(line_vec) / line_vec.length_squared()
	
	# Clamp t to stay within the segment [0, 1]
	t = clamp(t, 0.0, 1.0)
	
	# Closest point on the segment
	var projection = line_start + line_vec * t
	
	# Distance from point to that closest point
	return to_point.distance_to(projection)
