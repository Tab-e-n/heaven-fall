extends Area2D


const ACCELERATION : float = 40
const DECCELERATION : float = 30
const TOP_SPEED : float = 450

const TIME_TILL_FALL_STATE : float = 0.1

@export var pull_speed : float = TOP_SPEED
@export var direction : Vector2 = Vector2(1, 0)
@export var color : Color = Color(0.9, 0.6, 0.6, 1)

var player : Player = null
var start_fall_state : float = 0.0


func _ready():
	$sprite.rotation = direction.angle()
	$sprite.color = color
	$bg.color = Color(color.r * 0.8, color.g * 0.8, color.b * 0.85, color.a)


func _physics_process(delta):
	if player:
		if start_fall_state > 0.0:
			start_fall_state -= delta
			if start_fall_state <= 0.0:
				player.change_state(player.STATE_FALL)
		
		player.pulled = true
		var diff = global_position - player.global_position
		player.increase_velocity_vector(direction, ACCELERATION, pull_speed)
		
		var dir : Vector2 = Vector2(0, 0)
		if direction.x == 0:
			dir.x = sign(diff.x)
		if direction.y == 0:
			dir.y = sign(diff.y)
		player.increase_velocity_vector(dir, ACCELERATION, TOP_SPEED)
		player.decrease_velocity_vector(DECCELERATION, direction.x == 0, direction.y == 0)


func _on_body_entered(body):
	if body is Player:
		player = body
		start_fall_state = TIME_TILL_FALL_STATE


func _on_body_exited(body):
	if body is Player:
		player.pulled = false
		player = null
		start_fall_state = 0.0
