@tool
extends Area2D


@export var direction : int = 1
@export var next_scene : String = ""
@export var transition_name : String = ""
@export var carry_over_state : bool = true


func _ready():
	if not Engine.is_editor_hint():
		$hint.visible = false
		if Global.transitioning_levels:
			#if Global.debug:
				#print(transition_name, " ",  Global.transition_name == transition_name)
			if Global.transition_name == transition_name:
				Global.transitioning_levels = false
				call_deferred("prepare_player")


func _physics_process(_delta):
	if not Engine.is_editor_hint():
		pass
	else:
		$hint.position.x = direction * 48


func _on_body_entered(body):
	if body is Player:
		body.transitioning_save_state(body.global_position.y - global_position.y)
		
		if carry_over_state:
			Global.transitioning_levels = true
		Global.transition_name = transition_name
		
		Global.call_deferred("change_scene", "res://Levels/" + next_scene + ".tscn")
		


func prepare_player():
	GameCamera.player.transition_reset(global_position + Vector2(32 * direction, 0))
