extends Camera2D
class_name GameCamera


const SPEED : float = 10

static var player : Player = null
static var camera : GameCamera = null

@export var cutscene : bool = false
@export var cutscene_camera : int = 0

var first_frame_cam_skip : bool = true

var cam_points : Array[CameraPoint] = []

var skip_scrolling : bool = false

var previous_cam_point_id : int = -1

@onready var text_box : TextBox = $TextBox
@onready var previous_position : Vector2 = position
@onready var previous_zoom : float = zoom.x


func _ready():
	camera = self
	for node in get_children():
		if node is CameraPoint:
			cam_points.append(node)
	if Global.use_saved_pos:
		skip_scrolling = true


func _physics_process(_delta):
	var cam_point : CameraPoint = null
	var cam_point_id : int = -1
	var smallest_distance : float = 4096
	var highest_priority : int = 0
	#cutscene = false
	for i in range(cam_points.size()):
		var i_cam_point : CameraPoint = cam_points[i]
		if not i_cam_point:
			continue
		if cutscene and cutscene_camera:
			if i_cam_point.cutscene_id == cutscene_camera:
				cam_point = i_cam_point
				break
			continue
		elif i_cam_point.cutscene_id > 0:
			continue
		
		var pos_diff : Vector2 = abs(player.position - i_cam_point.position)
		if pos_diff.x > i_cam_point.snap_bounds.x:
			continue
		if pos_diff.y > i_cam_point.snap_bounds.y:
			continue
		
		var pos_distance : float = player.position.distance_to(i_cam_point.position)
		
		if i_cam_point.priority < highest_priority:
			continue
		elif i_cam_point.priority == highest_priority:
			if pos_distance > smallest_distance:
				continue
		
		cam_point = i_cam_point
		smallest_distance = pos_distance
		highest_priority = cam_point.priority
		cam_point_id = i
	
	
	if cam_point_id != previous_cam_point_id:
		previous_cam_point_id = cam_point_id
		previous_position = position
		previous_zoom = zoom.x
		
	
	var target : Vector2 = Vector2(0, 0)
	var target_zoom : float = 1.0
	if cam_point:
		#$cutscene.visible = cam_point.cutscene
		if cam_point.locked_position:
			target = cam_point.position
		else:
			target = center_between_points(player.position, cam_point.position) 
		target_zoom = cam_point.zoom
	else:
		#$cutscene.visible = false
		target = player.position
		target_zoom = 1.0
	
	if first_frame_cam_skip or Input.is_action_just_pressed("snap_camera"):
		position = target
		zoom = Vector2(target_zoom, target_zoom)
		first_frame_cam_skip = false
	elif skip_scrolling and not cutscene:
		position = target
		zoom = Vector2(target_zoom, target_zoom)
		skip_scrolling = false
	else:
		position = move_towards_point(position, target, SPEED)
		var prog : float = cam_pos_progress(position, previous_position, target)
		if prog == 0.0:
			zoom.x = previous_zoom
		elif prog == 1.0:
			zoom.x = target_zoom
		else:
			zoom.x = lerpf(previous_zoom, target_zoom, prog)
		zoom.y = zoom.x
	
	text_box.scale = Vector2(1, 1) / zoom
	
	if player.speedrun_timer > -1.0:
		$timer.visible = true
		var time_text = Global.float_to_time(player.speedrun_timer).split(".")
		$timer.text = time_text[0] + "."
		$timer/mili.text = time_text[1]
	else:
		$timer.visible = false


func move_towards_point(start : Vector2, end : Vector2, speed : float) -> Vector2:
	var diff : float = start.distance_to(end)
	if diff > speed:
		var trans : Transform2D = Transform2D()
		end = start + trans.looking_at(end - start).x * speed
	return end


func move_towards_value(start : float, end : float, speed : float) -> float:
	var diff = end - start
	if abs(diff) > speed:
		end = start + sign(diff) * speed
	return end


func cam_pos_progress(curr_pos : Vector2, prev_pos : Vector2, next_pos : Vector2) -> float:
	var dist_to_next : float = curr_pos.distance_to(next_pos)
	var dist_to_prev : float = curr_pos.distance_to(prev_pos)
	if dist_to_next + dist_to_prev == 0:
		return 1.0
	else:
		var progress : float = dist_to_prev / (dist_to_next + dist_to_prev)
		return progress


func center_between_points(start : Vector2, end : Vector2) -> Vector2:
	var diff = end - start
	start += diff * 0.5
	return start
