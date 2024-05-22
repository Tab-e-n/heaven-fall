extends Node2D


@export var direction : Vector2 = Vector2(0, 1)
@export var player_size : Vector2 = Vector2(32, 32)
@export var extra : bool = false


func _ready():
	#print((direction.angle() + .5*PI) / PI * 180)
	rotation = direction.angle() - .5 * PI
	position.y -= .5 * player_size.y
	position += direction * .5 * player_size
	
	if extra:
		$anim.play("extra")
