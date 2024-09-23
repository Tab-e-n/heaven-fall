extends CharacterBody2D
class_name Pickup


@export var gravity : float = 10


var is_carried : bool = false
var on_wall : bool = false
var previous_velocity : Vector2 = Vector2(0, 0)


func _ready():
	pass


func _physics_process(_delta):
	if is_carried:
		while_carried()
	else:
		while_free()


func apply_gravity():
	velocity.y += gravity


func bounce_off_wall():
	if is_on_wall() and not on_wall:
		velocity.x = -previous_velocity.x

func pickup_on_wall():
	on_wall = is_on_wall()


func move_pickup():
	previous_velocity = velocity
	move_and_slide()


func while_carried():
	pass
	#velocity.y = 0


func while_free():
	apply_gravity()
	bounce_off_wall()
	pickup_on_wall()
	if is_on_floor():
		velocity.x -= sign(velocity.x) * 10
	move_pickup()
