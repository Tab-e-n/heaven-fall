extends CharacterBody2D
class_name Player


enum {
	STATE_START, STATE_IDLE, STATE_TIPTOE, STATE_HOPSCOTCH,
	STATE_SLIPPING, STATE_AIR, STATE_FALL, STATE_TRIP_GROUND,
	STATE_TRIP_AIR, STATE_COYOTE_TIME, STATE_COYOTE_JUMP, STATE_BONK,
	STATE_END, STATE_CROUCH, STATE_CROUCH_WALK, STATE_SNOW_LAND}

const JUMP_BUFFER_FRAMES : int = 3

const SLOW_SPEED : float = 120
const AIR_SPEED : float = 150
const MID_SPEED : float = 180
const CROUCH_SPEED : float = 150
const SLIP_SPEED : float = 600
const TRIP_SPEED : float = 450
const TERMINAL_VELOCITY : float = 1600

const JUMP_VELOCITY : float = 400
const COYOTE_JUMP_VELOCITY : float = 505
const PERFECT_COYOTE_JUMP_VELOCITY : float = 550
const TRIP_JUMP_VELOCITY : float = 325
const TRIP_BOOST_VELOCITY : float = 50
const FALL_JUMP_VELOCITY : float = 350
const DIVE_VERTICAL_BOOST : float = 225
const FALL_BOUNCE_VELOCITY : float = 300

const GROUND_ACCELERATION : float = 20
const AIR_ACCELERATION : float = 8
const SLIP_ACCELERATION : float = 5
const TRIP_DECCELERATION : float = 6
const BONK_DECCELERATION : float = 7
const FALL_ACCELERATION : float = 2
const SNOW_DECCELERATION : float = 15
const GRAVITY_DOWN : float = 20
const GRAVITY_DOWN_SPRINT : float = 25
const GRAVITY_UP : float = 16

const STOP_SLIDING_VEL : float = 40
const BONK_THRESHOLD : float = 180
const FALL_THRESHOLD : float = 666
const TRIP_TO_FALL_THRESHOLD : float = 800
const DIVE_BOOST_PENALTY_THRESHOLD : float = -100
const COYOTE_TO_AIR_THRESHOLD : float = -110

const TIME_TILL_IDLE : float = 0.6
const COYOTE_TIME : float = 0.5
const PERFECT_COYOTE_THRESHOLD : float = 0.2

const SNOW_STUN_TIME : float = 1.0
const SNOW_SLOWDOWN : float = 0.5

const PAUSE_STATES : PackedInt32Array = [STATE_END, STATE_START]
const GROUND_STATES : PackedInt32Array = [STATE_IDLE, STATE_TIPTOE, STATE_HOPSCOTCH, STATE_SLIPPING, STATE_TRIP_GROUND, STATE_CROUCH, STATE_CROUCH_WALK]
const AIR_STATES : PackedInt32Array = [STATE_AIR, STATE_FALL, STATE_TRIP_AIR, STATE_COYOTE_TIME, STATE_COYOTE_JUMP]
const NO_TURN_STATES : PackedInt32Array = [STATE_FALL, STATE_TRIP_GROUND, STATE_TRIP_AIR, STATE_BONK, STATE_SNOW_LAND]
const TRIP_STATES : PackedInt32Array = [STATE_TRIP_AIR, STATE_TRIP_GROUND]
const SMALL_HITBOX : PackedInt32Array = [STATE_FALL, STATE_TRIP_GROUND, STATE_TRIP_AIR, STATE_CROUCH, STATE_CROUCH_WALK]
const SAVEFILE_SAVEABLE_STATES : PackedInt32Array = [STATE_IDLE, STATE_TIPTOE, STATE_HOPSCOTCH, STATE_CROUCH, STATE_CROUCH_WALK]

# When the player lets go of the arrow keys, the state stops
const CAN_STOP_STATE : PackedInt32Array = [STATE_TIPTOE, STATE_HOPSCOTCH, STATE_CROUCH, STATE_CROUCH_WALK]
# When the player slows down enough, the state stops
const CAN_STOP_WHEN_SLOW : PackedInt32Array = [STATE_SLIPPING, STATE_TRIP_GROUND, STATE_BONK]

# Player can jump in this state
const CAN_INITIATE_JUMP : PackedInt32Array = [STATE_IDLE, STATE_TIPTOE]
# Player starts slipping when trying to jump
const CAN_INITIATE_SLIP : PackedInt32Array = [STATE_HOPSCOTCH]
# Player trips when trying to jump
const CAN_INITIATE_TRIP : PackedInt32Array = [STATE_SLIPPING, STATE_TRIP_GROUND]
# Can use the dive move in this state
const CAN_INITIATE_DIVE : PackedInt32Array = [STATE_AIR]
# Can jump out of this state, but will go into STATE_FALL
const CAN_INITIATE_FALL : PackedInt32Array = [STATE_BONK]
# Can a grounded state change into the STATE_TRIP_GROUND when down pressed
const CAN_INITIATE_SLIDE : PackedInt32Array = [STATE_HOPSCOTCH, STATE_SLIPPING, STATE_BONK]

# This state can transition into tiptoe
const CAN_TIPTOE : PackedInt32Array = [STATE_IDLE, STATE_HOPSCOTCH, STATE_CROUCH, STATE_CROUCH_WALK]
# This state can transition into hopscotch
const CAN_HOPSCOTCH : PackedInt32Array = [STATE_IDLE, STATE_TIPTOE, STATE_HOPSCOTCH]
const CAN_CROUCH : PackedInt32Array = [STATE_IDLE, STATE_TIPTOE, STATE_TRIP_GROUND]
const CAN_CROUCH_WALK : PackedInt32Array = [STATE_IDLE, STATE_TIPTOE, STATE_CROUCH, STATE_CROUCH_WALK]
# Player goes to STATE_AIR when going of the edge
const CAN_SMOOTH_AIR_TRANSITION : PackedInt32Array = [STATE_IDLE, STATE_TIPTOE]
# Player goes to STATE_TRIP_AIR when going of the edge
const CAUSES_TRIP_ON_LEDGE : PackedInt32Array = [STATE_SLIPPING, STATE_CROUCH, STATE_CROUCH_WALK]
# Player goes to STATE_FALL when going of the edge
const CAUSES_FALL_ON_LEDGE : PackedInt32Array = [STATE_TRIP_GROUND, STATE_BONK]
# Player lands with full control
const CAN_LAND_IDLE : PackedInt32Array = [STATE_AIR, STATE_COYOTE_JUMP]

# If player touches a wall, they bounce off of it and go to STATE_FALL
const CAUSES_HARD_BONK_ON_WALL : PackedInt32Array = [STATE_TRIP_AIR, STATE_FALL, STATE_COYOTE_TIME]
# If player touches a wall, they bounce off of it and go to STATE_BONK
const CAUSES_BONK_WALL_AT_SPEED : PackedInt32Array = [STATE_TRIP_GROUND, STATE_SLIPPING]


const PLAYER_SIZE_FOR_BONK_EFFECT : Vector2 = Vector2(32, 32)

const TRIP_START_ANIM_STATES : PackedInt32Array = [STATE_SLIPPING, STATE_AIR]


@onready var Sprite : Sprite2D = $Player
@onready var Anim : AnimationPlayer = $Player/Anim
@onready var up_key_jump : bool = Global.save_check("up_key_jump")

@export var save_player : bool = true
@export var reload_penalty : float = 1.0

var temporary_save_prevention : bool = false

var BonkEffect : PackedScene = preload("res://Objects/bonk_effect.tscn")
var CalloutEffect : PackedScene = preload("res://Objects/callout.tscn")

var start_pos : Vector2 = Vector2(0, 0)

var state : int = STATE_START
var jump_buffer : int = 0
var sprint : bool = false
var dive : bool = false
var jump : bool = false
var up_pressed : bool = false
var down_pressed : bool = false
var fall_jump : bool = false
var jump_buffer_reset = true

var hitbox_change : int = 0

var turn_character : bool = true
var grounded : bool = true
var airborne : bool = false
var on_wall : bool = false
var bumped_wall : bool = false
var bounce_when_falling : bool = false
var pulled : bool = false

var stun_timer : float = .0
var movement_mult : float = 1.0

var idle_time : float = .0
var direction : float = .0
var facing : float = -1.0

var coyote_time : float = .0
var previous_velocity : Vector2 = Vector2(0, 0)
var fall_rotation : float = .0

var raycast_hit : Vector2 = Vector2(0, 0)

var speedrun_timer : float = -1


func _ready():
	start_pos = global_position
	GameCamera.player = self
	if save_player:
		#Global.saved_player_pos = start_pos
		#Global.saved_player_timer = speedrun_timer
		Global.current_scene = get_tree().current_scene.scene_file_path
		Global.save_player = true
		#print("player ready: ", Global.save_player)


func _physics_process(delta):
	#print("Start: ", state)
	
	if hitbox_change:
		if hitbox_change == 1:
			$collision_normal.set_deferred("disabled", true)
		else:
			$collision_small.set_deferred("disabled", true)
		hitbox_change = 0
	
	var paused : bool = state in PAUSE_STATES
	
	if not paused:
		if speedrun_timer >= 0:
			speedrun_timer += delta
		
		if jump_buffer > -JUMP_BUFFER_FRAMES:
			jump_buffer -= 1
	
		# INPUT
		player_input(delta)
		
		jump = jump_buffer > 0
		fall_jump = jump_buffer > -JUMP_BUFFER_FRAMES
		jump_buffer_reset = true
		
		# STATE TRANSITIONS
		state_transitions(delta)
		
		if jump_buffer_reset:
			jump_buffer = -JUMP_BUFFER_FRAMES
	
	if state in SAVEFILE_SAVEABLE_STATES and save_player and not temporary_save_prevention:
		Global.saved_player_pos = global_position
		Global.saved_player_timer = speedrun_timer
	
	if not paused:
		# STATE MOVEMENT
		move_player(delta)
		
		# ANIMATIONS
		animate(delta)
	if paused:
		if state == STATE_START and Input.is_action_just_pressed("reset"):
			start_playing()
	
	#print("End: ", state)


func input_is_jump_just_pressed() -> bool:
	if up_key_jump:
		return Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("up_jump")
	else:
		return Input.is_action_just_pressed("jump")


func input_is_up_pressed() -> bool:
	if up_key_jump:
		return Input.is_action_pressed("up")
	else:
		return Input.is_action_pressed("up") or Input.is_action_pressed("up_jump")


func player_input(_delta):
	if Input.is_action_just_pressed("reset"):
		restart()
	
	direction = Input.get_axis("left", "right")
	
	sprint = Input.is_action_pressed("sprint")
	dive = Input.is_action_just_pressed("down")
	
	up_pressed = input_is_up_pressed()
	down_pressed = Input.is_action_pressed("down")
	
	if input_is_jump_just_pressed():
		jump_buffer = JUMP_BUFFER_FRAMES
	
	if turn_character and direction != 0:
		facing = direction


func state_transitions(delta):
	if stun_timer > 0.0:
		stun_timer -= delta
		if stun_timer <= 0.0:
			change_state(STATE_IDLE)
			idle_time = TIME_TILL_IDLE
		if state == STATE_SNOW_LAND and jump:
			velocity.y = -FALL_JUMP_VELOCITY
			change_state(STATE_FALL)
		return
	
	# Player has left a floor and is now in the air
	if grounded and not is_on_floor():
		if state == STATE_HOPSCOTCH:
			change_state(STATE_COYOTE_TIME)
		elif state in CAUSES_TRIP_ON_LEDGE:
			change_state(STATE_TRIP_AIR)
		elif state in CAUSES_FALL_ON_LEDGE:
			change_state(STATE_FALL)
		elif state in CAN_SMOOTH_AIR_TRANSITION:
			change_state(STATE_AIR)
	
	# Player has landed on a floor
	if airborne and is_on_floor():
		if state in CAN_LAND_IDLE:
			if down_pressed:
				change_state(STATE_CROUCH)
			else:
				change_state(STATE_IDLE)
				idle_time = TIME_TILL_IDLE
		
		if state == STATE_FALL:
			if bounce_when_falling:
				bounce_when_falling = false
				
				var bounce = abs(previous_velocity.y * 0.333)
				if bounce > FALL_BOUNCE_VELOCITY:
					velocity.y = -bounce
				else:
					velocity.y = -FALL_BOUNCE_VELOCITY
				
				if fall_jump:
					velocity.y -= FALL_JUMP_VELOCITY - FALL_BOUNCE_VELOCITY * 0.6
					spawn_bonk_effect(Vector2(0.0, 1.0), true)
				
				spawn_bonk_effect(Vector2(0.0, 1.0))
			else:
				change_state(STATE_TRIP_GROUND)
		
		if state == STATE_TRIP_AIR:
			change_state(STATE_TRIP_GROUND)
	
	if is_on_wall() and not on_wall and not bumped_wall:
		bumped_wall = true
	else:
		bumped_wall = false
	
	on_wall = is_on_wall()
	
	if grounded:
		if sprint and state in CAN_HOPSCOTCH:
			change_state(STATE_HOPSCOTCH)
		elif direction != 0:
			if (down_pressed or state == STATE_CROUCH) and state in CAN_CROUCH_WALK:
				change_state(STATE_CROUCH_WALK)
			elif not sprint and state in CAN_TIPTOE:
				change_state(STATE_TIPTOE)
		else:
			if state in CAN_STOP_STATE:
				if down_pressed:
					change_state(STATE_CROUCH)
				else:
					change_state(STATE_IDLE)
		
		if bumped_wall:
			if state in CAUSES_BONK_WALL_AT_SPEED and abs(previous_velocity.x) > BONK_THRESHOLD:
				velocity.x = -previous_velocity.x
				change_state(STATE_BONK)
				spawn_bonk_effect(Vector2(facing, 0))
		elif state in CAN_STOP_WHEN_SLOW and abs(velocity.x) < STOP_SLIDING_VEL and not pulled:
			if (down_pressed or should_be_small_hitbox()) and state in CAN_CROUCH:
				change_state(STATE_CROUCH)
			else:
				change_state(STATE_IDLE)
		
		if jump:
			if state in CAN_INITIATE_JUMP:
				velocity.y = -JUMP_VELOCITY
				change_state(STATE_AIR)
			elif state in CAN_INITIATE_SLIP:
				change_state(STATE_SLIPPING)
			elif state in CAN_INITIATE_TRIP:
				velocity.y = -TRIP_JUMP_VELOCITY
				velocity.x += direction * TRIP_BOOST_VELOCITY
				if direction != 0:
					facing = direction
				change_state(STATE_TRIP_AIR)
			elif state in CAN_INITIATE_FALL:
				velocity.y = -FALL_JUMP_VELOCITY
				change_state(STATE_FALL)
			else:
				jump_buffer_reset = false
		
		if dive:
			if state in CAN_CROUCH:
				change_state(STATE_CROUCH)
			elif state in CAN_INITIATE_SLIDE:
				change_state(STATE_TRIP_GROUND)
				velocity.x += facing * TRIP_BOOST_VELOCITY
	
	elif airborne:
		if coyote_time > 0.0:
			coyote_time -= delta
			if coyote_time <= 0:
				change_state(STATE_FALL)
		if state == STATE_COYOTE_JUMP and velocity.y >= COYOTE_TO_AIR_THRESHOLD:
			change_state(STATE_AIR)
		
		if state in TRIP_STATES:
			if velocity.y > TRIP_TO_FALL_THRESHOLD:
				change_state(STATE_FALL)
		else:
			if velocity.y > FALL_THRESHOLD:
				change_state(STATE_FALL)
		
		if bumped_wall:
			if state in CAUSES_HARD_BONK_ON_WALL:
				change_state(STATE_FALL)
				
				facing = sign(get_wall_normal().x)
				if abs(previous_velocity.x) > SLOW_SPEED:
					velocity.x = -previous_velocity.x
				else:
					velocity.x = facing * SLOW_SPEED
				
				if fall_jump:
					velocity.y = -FALL_JUMP_VELOCITY
					spawn_bonk_effect(Vector2(-facing, 0.0), true)
				
				spawn_bonk_effect(Vector2(-facing, 0.0))
		
		if jump:
			if state == STATE_COYOTE_TIME:
				velocity.x = 0.0
				#print(coyote_time)
				if coyote_time < PERFECT_COYOTE_THRESHOLD:
					velocity.y = -PERFECT_COYOTE_JUMP_VELOCITY
					spawn_bonk_effect(Vector2(0.0, 1.0))
				else:
					velocity.y = -COYOTE_JUMP_VELOCITY
				change_state(STATE_COYOTE_JUMP)
			else:
				jump_buffer_reset = false
		
		if dive:
			if state in CAN_INITIATE_DIVE:
				#print(velocity.y, " ", velocity.y < DIVE_BOOST_PENALTY_THRESHOLD)
				change_state(STATE_TRIP_AIR)
				velocity.x = facing * MID_SPEED
				if velocity.y < DIVE_BOOST_PENALTY_THRESHOLD:
					var percent : float = (velocity.y - DIVE_BOOST_PENALTY_THRESHOLD) / (-JUMP_VELOCITY - DIVE_BOOST_PENALTY_THRESHOLD)
					var penalty : float = (1 - .75 * percent)
					velocity.y -= DIVE_VERTICAL_BOOST * penalty
				else:
					velocity.y -= DIVE_VERTICAL_BOOST


func move_player(_delta):
	
	match(state):
		STATE_IDLE, STATE_CROUCH:
			velocity.x = decrease_velocity(velocity.x, GROUND_ACCELERATION)
		STATE_TIPTOE:
			velocity.x = change_velocity(velocity.x, GROUND_ACCELERATION, SLOW_SPEED)
			velocity.x = cap_velocity(velocity.x, SLOW_SPEED * movement_mult, sign(velocity.x))
		STATE_HOPSCOTCH:
			velocity.x = change_velocity(velocity.x, GROUND_ACCELERATION, MID_SPEED)
			velocity.x = cap_velocity(velocity.x, MID_SPEED * movement_mult, sign(velocity.x))
		STATE_CROUCH_WALK:
			velocity.x = change_velocity(velocity.x, GROUND_ACCELERATION, CROUCH_SPEED)
			velocity.x = cap_velocity(velocity.x, CROUCH_SPEED * movement_mult, sign(velocity.x))
		STATE_SLIPPING:
			velocity.x = change_velocity(velocity.x, SLIP_ACCELERATION, SLIP_SPEED)
			#print(velocity.x)
		STATE_TRIP_GROUND:
			velocity.x = decrease_velocity(velocity.x, TRIP_DECCELERATION)
			velocity.x = increase_velocity(velocity.x, TRIP_DECCELERATION * 0.5, TRIP_SPEED)
		STATE_AIR:
			velocity.x = increase_velocity(velocity.x, AIR_ACCELERATION, AIR_SPEED)
			if bumped_wall:
				velocity.x = -previous_velocity.x * 0.75
		STATE_TRIP_AIR:
			velocity.x = increase_velocity(velocity.x, TRIP_DECCELERATION * 0.1, TRIP_SPEED)
		STATE_COYOTE_JUMP:
			velocity.x = increase_velocity(velocity.x, AIR_ACCELERATION, SLOW_SPEED)
		STATE_COYOTE_TIME:
			velocity.x = decrease_velocity(velocity.x, AIR_ACCELERATION)
		STATE_FALL:
			velocity.x = increase_velocity(velocity.x, FALL_ACCELERATION, SLOW_SPEED)
			if velocity.y > 500:
				bounce_when_falling = true
		STATE_BONK:
			velocity.x = decrease_velocity(velocity.x, BONK_DECCELERATION)
		STATE_SNOW_LAND:
			velocity.x = decrease_velocity(velocity.x, SNOW_DECCELERATION)
	
	if pulled:
		pass
	elif coyote_time > 0.0:
		velocity.y = 0.0
	elif airborne:
		if velocity.y < 0.0:
			velocity.y = increase_velocity_with_direction(1.0, velocity.y, GRAVITY_UP, TERMINAL_VELOCITY)
		else:
			if sprint:
				velocity.y = increase_velocity_with_direction(1.0, velocity.y, GRAVITY_DOWN_SPRINT, TERMINAL_VELOCITY)
			else:
				velocity.y = increase_velocity_with_direction(1.0, velocity.y, GRAVITY_DOWN, TERMINAL_VELOCITY)
	elif grounded:
		velocity.y = 1.0
	
	previous_velocity = velocity
	
	move_and_slide()
	
	set_deferred("movement_mult", 1.0)


func animate(delta):
	Sprite.flip_h = facing == 1
	
	match(state):
		STATE_IDLE:
			if up_pressed:
				Anim.play("Pray")
			elif idle_time >= TIME_TILL_IDLE:
				Anim.play("Stand")
			else:
				idle_time += delta
		STATE_TIPTOE:
			Anim.play("Tiptoe")
		STATE_HOPSCOTCH:
			Anim.play("Hopscotch")
			if direction == 0:
				Anim.stop()
		STATE_SLIPPING:
			Anim.play("Slipping")
		STATE_AIR:
			if velocity.y > 0.0 and sprint:
				Anim.play("JumpDown")
			else:
				Anim.play("Jump")
		STATE_FALL:
			Anim.play("Fall")
			#fall_rotation += PI * 0.03 * facing
			#if fall_rotation > 2*PI:
				#fall_rotation -= 2*PI
			#Sprite.rotation = snapped(fall_rotation, 0.166 * PI)
		STATE_TRIP_GROUND:
			if Anim.current_animation != "TripStart":
				Anim.play("Trip")
		STATE_TRIP_AIR:
			if Anim.current_animation != "TripStart":
				Anim.play("TripAir")
		STATE_COYOTE_TIME:
			if coyote_time < PERFECT_COYOTE_THRESHOLD:
				Anim.play("PerfectCoyote")
			else:
				Anim.play("Hopscotch")
		STATE_COYOTE_JUMP:
			Anim.play("CoyoteJump")
		STATE_BONK:
			Anim.play("Bonk")
		STATE_CROUCH:
			Anim.play("Crouch")
		STATE_CROUCH_WALK:
			Anim.play("CrouchWalk")
	
	
	
	$snow.emitting = movement_mult < 1.0 and velocity.x != 0


func raycast(start : Vector2, end : Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters2D.create(start, end)
	query.exclude = [self]
	query.collision_mask = 0b1111_1101
	var result = space_state.intersect_ray(query)
	if result:
		raycast_hit = result.position
		#print("Hit at point: ", result.position)
		return true
	return false


func should_be_small_hitbox() -> bool:
	return raycast(global_position + Vector2(0, -32), global_position + Vector2(0, -56))


func change_state(new_state : int):
	if state == new_state:
		return
	if state in SMALL_HITBOX and not new_state in SMALL_HITBOX:
		if should_be_small_hitbox():
			if grounded and new_state in AIR_STATES:
				change_state(STATE_TRIP_AIR)
			return
	
	match(new_state):
		STATE_IDLE:
			idle_time = 0
		STATE_TIPTOE:
			velocity.x = cap_velocity(velocity.x, SLOW_SPEED)
		STATE_SLIPPING:
			velocity.x = facing * MID_SPEED
	
	var new_hitbox_small : bool = new_state in SMALL_HITBOX
	var old_hitbox_small : bool = state in SMALL_HITBOX
	
	if new_hitbox_small and not old_hitbox_small:
		hitbox_change = 1
		$collision_small.set_deferred("disabled", false)
	if not new_hitbox_small and old_hitbox_small:
		hitbox_change = 2
		$collision_normal.set_deferred("disabled", false)
	
	turn_character = not new_state in NO_TURN_STATES
	
	if new_state in GROUND_STATES:
		grounded = true
		airborne = false
	if new_state in AIR_STATES:
		airborne = true
		grounded = false
	
	if new_state == STATE_COYOTE_TIME:
		coyote_time = COYOTE_TIME
	else:
		coyote_time = 0.0
	
	bounce_when_falling = false
	
	on_wall = false
	
	stun_timer = 0.0
	
	Sprite.rotation = 0
	
	if new_state == STATE_IDLE:
		if state in TRIP_STATES:
			Anim.play("TripGetUp")
		else:
			Anim.stop()
		if state == STATE_SLIPPING:
			idle_time = TIME_TILL_IDLE - 0.2
	if new_state in TRIP_STATES:
		if state in TRIP_START_ANIM_STATES:
			Anim.play("TripStart")
	if new_state == STATE_END:
		Anim.play("Win")
		Global.clear_saved_pos(start_pos)
		#print("won: ", Global.save_player)
	if new_state == STATE_SNOW_LAND:
		Anim.play("SnowLand")
		stun_timer = SNOW_STUN_TIME
	
	state = new_state
	#print(state)


func change_velocity(vel : float, acceleration : float, top_speed : float) -> float:
	if direction == 0:
		vel = decrease_velocity(vel, acceleration)
	else:
		vel = increase_velocity(vel, acceleration, top_speed * movement_mult)
	
	return vel


func increase_velocity(vel : float, acceleration : float, top_speed : float) -> float:
	return increase_velocity_with_direction(direction, vel, acceleration, top_speed)


func increase_velocity_with_direction(dir : float, vel : float, acceleration : float, top_speed : float):
	if dir == 0:
		return vel
	if abs(vel) >= top_speed and dir == sign(vel):
		return vel
	
	vel += dir * acceleration
	
	vel = cap_velocity(vel, top_speed, dir)
	
	return vel


func increase_velocity_vector(dir : Vector2, acceleration : float, top_speed : float):
	velocity.x = increase_velocity_with_direction(dir.x, velocity.x, acceleration, top_speed)
	velocity.y = increase_velocity_with_direction(dir.y, velocity.y, acceleration, top_speed)


func cap_velocity(vel : float, top_speed : float, dir : float = 0.0) -> float:
	
	if abs(vel) > top_speed and (dir == 0.0 or dir == sign(vel)):
		vel = sign(vel) * top_speed
	
	return vel


func decrease_velocity(vel : float, decceleration : float) -> float:
	if vel == 0:
		return vel
	
	var start_sign : float = sign(vel)
	
	vel -= sign(vel) * decceleration
	
	if sign(vel) != start_sign:
		vel = 0
	
	return vel


func decrease_velocity_vector(acceleration : float, axis_x : bool = true, axis_y : bool = true):
	if axis_x:
		velocity.x = decrease_velocity(velocity.x, acceleration)
	if axis_y:
		velocity.y = decrease_velocity(velocity.y, acceleration)


func spawn_bonk_effect(dir : Vector2, extra : bool = false):
	var new_bonk : Node2D = BonkEffect.instantiate()
	new_bonk.direction = dir
	new_bonk.position = position
	new_bonk.player_size = PLAYER_SIZE_FOR_BONK_EFFECT
	new_bonk.extra = extra
	get_tree().current_scene.add_child(new_bonk)


func spawn_callout(text : String, color_preset : int):
	var new_call : Node2D = CalloutEffect.instantiate()
	new_call.global_position = global_position - Vector2(0, 64)
	new_call.text = text
	new_call.color_preset = color_preset
	get_tree().current_scene.add_child(new_call)


func start_playing():
	#print("start ", Global.use_saved_pos)
	if Global.use_saved_pos:
		#print(Global.saved_player_timer, " ", Global.saved_player_pos)
		teleport(Global.saved_player_pos)
		
		#print(Global.saved_player_timer)
		speedrun_timer = Global.saved_player_timer
		if speedrun_timer >= 0.0:
			speedrun_timer += reload_penalty
			spawn_callout("+" + String.num(snapped(reload_penalty, 0.1)) + "s Penalty", Callout.COLOR_PRESET.BAD)
		
		Global.set_deferred("use_saved_pos", false)
	else:
		restart()


func restart():
	#print("restart")
	Global.clear_saved_pos(start_pos)
	if save_player:
		Global.save_player = true
	#print("reset: ", Global.save_player)
	speedrun_timer = -1.0
	teleport(start_pos)


func teleport(destination : Vector2):
	global_position = destination
	velocity = Vector2(0, 0)
	if should_be_small_hitbox():
		change_state(STATE_TRIP_AIR)
	else:
		change_state(STATE_AIR)


func new_best():
	spawn_callout("NEW BEST!", Callout.COLOR_PRESET.CELEBRATION)


func scene_change():
	Global.change_scene()
