extends Camera2D
class_name GameCamera


const SPEED : float = 15

static var player : Player = null
static var cutscene : bool = false

var first_frame_cam_skip : bool = true

var cam_position : Array[CameraPoint] = []

var auto_skip_cutscene : bool = false

func _ready():
	for node in get_children():
		if node is CameraPoint:
			cam_position.append(node)
	if Global.use_saved_pos:
		auto_skip_cutscene = true


func _physics_process(_delta):
	var cam_point : CameraPoint = null
	var smallest_distance : float = 4096
	var highest_priority : int = 0
	cutscene = false
	for i_cam_point in cam_position:
		if not i_cam_point:
			continue
		if i_cam_point.cutscene:
			cam_point = i_cam_point
			cutscene = true
			break
		
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
	
	
	var target : Vector2 = Vector2(0, 0)
	if cam_point:
		$cutscene.visible = cam_point.cutscene
		if cam_point.locked_position:
			target = cam_point.position
		else:
			target = center_between_points(player.position, cam_point.position) 
	else:
		$cutscene.visible = false
		target = player.position
	
	if first_frame_cam_skip or Input.is_action_just_pressed("snap_camera"):
		position = target
		first_frame_cam_skip = false
	elif auto_skip_cutscene and not cutscene:
		position = target
		auto_skip_cutscene = false
	else:
		position = move_towards_point(position, target)
	
	if player.speedrun_timer > -1.0:
		$timer.visible = true
		var time_text = Global.float_to_time(player.speedrun_timer).split(".")
		$timer.text = time_text[0] + "."
		$timer/mili.text = time_text[1]
	else:
		$timer.visible = false


func move_towards_point(start : Vector2, end : Vector2) -> Vector2:
	var diff : float = start.distance_to(end)
	if diff > SPEED:
		var trans : Transform2D = Transform2D()
		end = start + trans.looking_at(end - start).x * SPEED
	return end


func move_towards_value(start : float, end : float) -> float:
	var diff = end - start
	if abs(diff) > SPEED:
		end = start + sign(diff) * SPEED
	return end


func center_between_points(start : Vector2, end : Vector2) -> Vector2:
	var diff = end - start
	start += diff * 0.5
	return start
