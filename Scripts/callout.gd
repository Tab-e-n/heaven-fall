extends Node2D
class_name Callout


enum COLOR_PRESET {NEUTRAL, GOOD, BAD, CELEBRATION}

const colors : Array = [
	[Color("e7eff0"), Color("526a84"), Color("263444")],
	[Color("64f599"), Color("106e64"), Color("032614")],
	[Color("f46568"), Color("6d1024"), Color("250306")],
	[Color("f4c870"), Color("976323"), Color("473418")],
]


@export var text : String = "Nice!"

@export var color_preset : int = COLOR_PRESET.NEUTRAL


func _ready():
	var label : Label = $text as Label
	label.text = text
	label.add_theme_color_override("font_color", colors[color_preset][0])
	label.add_theme_color_override("font_shadow_color", colors[color_preset][1])
	label.add_theme_color_override("font_outiline_color", colors[color_preset][2])
