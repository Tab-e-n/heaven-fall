extends Area2D


@export var remove_save : bool = false


var collinding_player : bool = false


func _physics_process(delta):
	if remove_save and Global.save_player and collinding_player:
		Global.save_player = false


func _on_body_entered(player):
	if player is Player:
		collinding_player = true
		player.temporary_save_prevention = true
		if remove_save:
			Global.save_player = false
			Global.clear_saved_pos(player.start_pos)
		#print("entered sd: ", Global.save_player)


func _on_body_exited(player):
	if player is Player:
		collinding_player = false
		player.set_deferred("temporary_save_prevention", false)
		if remove_save:
			Global.set_deferred("save_player", player.save_player)
		#print("exited sd: ", Global.save_player)
