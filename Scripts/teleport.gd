extends Area2D


@export var destination : Vector2 = Vector2(0, 0)



func _on_body_entered(body):
	if body is Player:
		body.teleport(destination)
