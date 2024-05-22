extends StaticBody2D


const ACCELERATION : float = 16
const TOP_SPEED : float = 450


var player : Player = null
var push_direction : Vector2 = Vector2(0, 0)


func _ready():
	rotation = snappedf(rotation, PI*0.5)
	if rotation < 0:
		rotation += PI*2
	rotation_degrees = float(int(rotation_degrees) % 360)
	
	if rotation_degrees == 0:
		push_direction = Vector2(1, 0.5)
	if rotation_degrees == 270:
		push_direction = Vector2(-1, 0.5)


func _physics_process(_delta):
	if player:
		player.pulled = true
		if player.grounded:
			player.change_state(player.STATE_TRIP_GROUND)
		player.increase_velocity_vector(push_direction, ACCELERATION, TOP_SPEED)


func _on_body_entered(body):
	if body is Player:
		player = body
		if player.airborne and player.state != player.STATE_TRIP_AIR and player.previous_velocity.y >= 0:
			player.change_state(player.STATE_FALL)
			if abs(player.previous_velocity.y) > player.BONK_THRESHOLD:
				player.velocity.x = abs(player.previous_velocity.y) * push_direction.x * 0.5


func _on_body_exited(body):
	if body is Player:
		player.pulled = false
		player = null
