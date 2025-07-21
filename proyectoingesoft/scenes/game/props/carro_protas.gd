extends AnimatableBody2D

@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var throttle_sfx : AudioStreamPlayer2D = $ThrottleStreamPlayer

var gerardo_path : String = "res://scenes/game/characters/player/player.tscn"
var susana_path : String = "res://scenes/game/characters/children/susana/susana.tscn"
var claudio_path : String = ""


func _ready() -> void:
	_script_intro()
	
func _script_intro() -> void:		# Primer script en ejecutarse
	_fail_to_turn_on()
	while throttle_sfx.playing:
		await get_tree().process_frame
	_fail_to_turn_on()
	# 

func _fail_to_turn_on() -> void:
	anim_player.play("vibrate")
	throttle_sfx.play()

func _eject_characters() -> void:
	gerardo_path
	
