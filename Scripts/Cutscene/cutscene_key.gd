extends Node
class_name CutsceneKey


# Specifies the camera that should be used.
# If set to a positive number, uses a camera of the same id.
# If set to 0, uses the camera the player is inside of.
# If set to -1, keeps the previous camera.
@export var cutscene_cam_id : int = -1
# Will stop the processing of keys and wait for player input.
@export var wait_for_player_input : bool = true
# If set to a positive number, makes the cutscene pause for that amount of time, and then triggers the next key.
# If it equals zero, the next key is trigger immediately.
@export var wait : float = 0
