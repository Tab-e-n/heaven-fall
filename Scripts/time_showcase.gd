extends Label
class_name TimeShowcase


@export var standalone : bool = true
@export var level_showcased : String = ""
var time : float = -1.0


func _ready():
	if standalone:
		show_time(level_showcased)


func show_time(level : String):
	if not level.is_empty() and Global.savefile.has(level):
		if Global.savefile[level][Global.LEVEL_BEATEN]:
			time = Global.savefile[level][Global.LEVEL_TIME]
			if time != -1.0:
				text = "Best: " + Global.float_to_time(time)
			else:
				text = "Best: No time set"
			return true
	text = ""
	return false
