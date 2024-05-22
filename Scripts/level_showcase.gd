extends Node2D


@export var level : String = ""
@export_enum("Starter", "Easy", "Medium", "Hard", "Extreme", "Devilish") var difficulty : int = 0


func _ready():
	$name.text = level
	$time.show_time(level)
	
	var diff : Sprite2D = $diff as Sprite2D
	diff.region_rect.size.x = difficulty * 16
