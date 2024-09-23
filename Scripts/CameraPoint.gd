@tool
extends Polygon2D
class_name CameraPoint


@export var locked_position : bool = false
@export var snap_bounds : Vector2 = Vector2(640, 384)
@export var zoom : float = 1.0
@export var priority : int = 100
@export var cutscene_id : int = 0


func _ready():
	if Engine.is_editor_hint():
		z_index = -100
		color = Color(0.9, 0.5, 0.9, 0.25)
		polygon = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1)]
	else:
		visible = false
		polygon = []


func _physics_process(_delta):
	if Engine.is_editor_hint():
		scale.x = snap_bounds.x
		scale.y = snap_bounds.y
	#else:
		#if cutscene_id > 0:
			#pass
