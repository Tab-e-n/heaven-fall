@tool
extends Line2D


enum {STATE_IDLE, STATE_PULL_START, STATE_PULL_FULL, STATE_SPIT}

const ACCELERATION : float = 50
const TOP_SPEED : float = 300 #300
const SPIT_SPEED : float = 480 #300
const PULL_SPEED_ALONG_LINE : float = 6

const TIME_TILL_FALL_STATE : float = 0.1
const EXTRA_PULL_RANGE : float = 32


var player : Player = null
var activation_delay : float = 0.0

var current_point : float = 0
var current_pull_time : float = 0
var state : int = STATE_IDLE

@onready var area : Area2D = $Area
@onready var pull_point : Vector2 = position


func _ready():
	if Engine.is_editor_hint():
		return
	
	if points.size() < 2:
		get_parent().remove_child(self)
		queue_free()
	
	#width = 0
	
	var line_poly = Geometry2D.offset_polyline(points, 64, Geometry2D.JOIN_MITER, Geometry2D.END_BUTT)
	
	for poly in line_poly:
		var col = CollisionPolygon2D.new()
		col.polygon = poly
		area.add_child(col)
		
		var pol = Polygon2D.new()
		pol.polygon = poly
		pol.color = Color.DIM_GRAY
		pol.show_behind_parent = true
		add_child(pol)


func _physics_process(delta):
	if player:
		if activation_delay > 0.0:
			activation_delay -= delta
			if activation_delay <= 0.0:
				player.change_state(player.STATE_FALL)
				state = STATE_PULL_FULL
		
		player.pulled = true
		
		if state == STATE_PULL_FULL:
			var previous_i : int = int(current_point)
			current_point += current_pull_time
			#print(current_point, " ", current_pull_time)
			var new_i : int = int(current_point)
			if new_i + 1 >= points.size():
				state = STATE_SPIT
				player.velocity = (points[points.size() - 1] - points[points.size() - 2]).normalized() * SPIT_SPEED
			elif new_i != previous_i:
				#print(new_i, " ", points.size())
				previous_i = new_i
				new_i += 1
				current_point = float(previous_i)
				var full_dist : float = points[previous_i].distance_to(points[new_i])
				if(full_dist != 0):
					current_pull_time = PULL_SPEED_ALONG_LINE / full_dist
			else:
				new_i += 1
			if state != STATE_SPIT:
				var dif : Vector2 = points[new_i] - points[previous_i]
				pull_point = global_position + points[previous_i] + dif * (current_point - float(previous_i))
				#print(state, dif)
		#print(state, " ", pull_point)
		#print(player.velocity.length())
		
		if state in [STATE_PULL_START, STATE_PULL_FULL]:
			var diff = pull_point - player.global_position
			var dir : Vector2 = diff.normalized()
			#print(pull_point)
			#print("vel ",  player.velocity)
			var pull_accel : float = ACCELERATION * (pull_point.distance_to(player.global_position) / EXTRA_PULL_RANGE)
			player.increase_velocity_vector(dir, pull_accel, TOP_SPEED)

func _on_area_body_entered(body):
	if body is Player:
		player = body
		activation_delay = TIME_TILL_FALL_STATE
		state = STATE_PULL_START
		
		var closest_points : Array[Vector2] = [Vector2(0, 0), Vector2(0, 0)]
		closest_points[0] = global_position + points[0]
		closest_points[1] = global_position + points[1]
		var distances : Array[float] = [0.0, 0.0]
		distances[0] = closest_points[0].distance_squared_to(player.global_position)
		distances[1] = closest_points[1].distance_squared_to(player.global_position)
		var point_i : Array[int] = [0, 1]
		
		for i in range(points.size() - 2):
			var point : Vector2 = global_position + points[i + 2]
			var dist : float = point.distance_squared_to(player.global_position)
			if dist < distances[0]:
				if distances[0] < distances[1]:
					closest_points[1] = closest_points[0]
					distances[1] = distances[0]
					point_i[1] = point_i[0]
				closest_points[0] = point
				distances[0] = dist
				point_i[0] = i + 2
			elif dist < distances[1]:
				closest_points[1] = point
				distances[1] = dist
				point_i[1] = i + 2
		
		#print(closest_points)
		pull_point = Geometry2D.get_closest_point_to_segment(player.global_position, closest_points[0], closest_points[1])
		#print(pull_point)
		
		var part_dist : float
		
		if point_i[0] < point_i[1]:
			current_point = point_i[0]
			part_dist = closest_points[0].distance_to(pull_point)
		else:
			current_point = point_i[1]
			part_dist = closest_points[1].distance_to(pull_point)
		
		var full_dist : float = closest_points[0].distance_to(closest_points[1]) 
		
		current_pull_time = PULL_SPEED_ALONG_LINE / full_dist
		current_point += part_dist / full_dist


func _on_area_body_exited(body):
	if body is Player:
		player.pulled = false
		player = null
		activation_delay = 0.0
		state = STATE_IDLE
