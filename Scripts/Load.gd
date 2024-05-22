extends Node2D


func _ready():
	Global.return_to_last_level_position.call_deferred()
