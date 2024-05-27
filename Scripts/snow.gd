extends Area2D


const LOWEST_GROUND_POS : float = 24
const HIGHEST_GROUND_POS : float = -16


var player : Player = null


func _physics_process(_delta):
	if player:
		player.set_deferred("movement_mult", Player.SNOW_SLOWDOWN) 
		if player.state == Player.STATE_SLIPPING:
			player.change_state(Player.STATE_SNOW_LAND)


func _on_body_entered(body):
	if body is Player:
		$ground.position.y = body.global_position.y - global_position.y
		if $ground.position.y < HIGHEST_GROUND_POS:
			$ground.position.y = HIGHEST_GROUND_POS
		if $ground.position.y > LOWEST_GROUND_POS:
			$ground.position.y = LOWEST_GROUND_POS
		
		if body.velocity.y > Player.SNOW_LAND_THRESHOLD: 
			#print(body.velocity.y)
			if body.state == Player.STATE_FALL or body.state in Player.TRIP_STATES:
				body.change_state(Player.STATE_SNOW_LAND)


func _on_body_exited(body):
	if body is Player:
		$ground.position.y = LOWEST_GROUND_POS


func _on_slowdown_body_entered(body):
	if body is Player:
		player = body
		#if abs(body.velocity.x) > Player.SLOW_SPEED * Player.SNOW_SLOWDOWN:
			#body.velocity.x = 0


func _on_slowdown_body_exited(body):
	if body is Player:
		player = null
