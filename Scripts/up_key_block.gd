extends Node2D


func _on_player_check_body_entered(body):
	if not body is Player:
		return
	
	Global.savefile["up_key_jump"] = not Global.save_check("up_key_jump")
	var up_key : bool = Global.save_check("up_key_jump")
	
	$up_jump.visible = up_key
	$space_jump.visible = not up_key
	body.up_key_jump = up_key
