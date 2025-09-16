extends Node

var _line_node: MeshInstance2D
var _line_mesh: ImmediateMesh

var _line_data = []



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_line_node = MeshInstance2D.new()
	_line_mesh = ImmediateMesh.new()
	
	_line_node.mesh = _line_mesh
	
	add_child(_line_node)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_line_mesh.clear_surfaces()
	
	if (_line_data.size() == 0):
		return
		
	_line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	var done_indices = []
	
	for i in range(_line_data.size()):
		var line = _line_data[i]
		
		var start = line["start"]
		var end = line["end"]
		var color = line["color"]
		var remaining = line["remaining"]
		
		_line_mesh.surface_set_color(color)
		_line_mesh.surface_add_vertex_2d(start)
		_line_mesh.surface_add_vertex_2d(end)

		remaining -= delta
		
		line["remaining"] = remaining
		
		if	(remaining <= 0.0):
			done_indices.push_back(i)
			
	_line_mesh.surface_end()
	
	done_indices.reverse()
	
	for i in done_indices:
		_line_data.remove_at(i)

func draw_line(start: Vector2, end: Vector2, color: Color = Color.RED, duration: float = 0)-> void:
	_line_data.push_back(
		{
			"start":start,
			"end":end,
			"color":color,
			"remaining":duration
		}
	)
