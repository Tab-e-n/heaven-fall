extends Area2D


@export var disabled : bool = false
@export var level : String = ""
@export var level_end : bool = true
@export var next_scene : String = Global.DEFAULT_SCENE


func _ready():
	if disabled:
		$Portal.texture = preload("res://Sprites/portal_disabled.png")


func _on_body_entered(body):
	if disabled:
		return
	if body is Player:
		body.change_state(Player.STATE_END)
		if not level.is_empty() and level_end:
			if Global.beat_level(level, body.speedrun_timer):
				body.new_best()
		
		Global.current_scene = next_scene
