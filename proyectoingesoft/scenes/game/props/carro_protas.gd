extends AnimatableBody2D

@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var throttle_sfx : AudioStreamPlayer2D = $ThrottleStreamPlayer

var gerardo_path : String = "res://scenes/game/characters/player/player.tscn"
var susana_path : String = "res://scenes/game/characters/children/susana/susana.tscn"
var claudio_path : String = "res://scenes/game/characters/children/claudio/claudio.tscn"
var guillermo_path : String = "res://scenes/game/characters/children/guillermo/guillermo.tscn"


func _ready() -> void:
	_script_intro()
	
func _script_intro() -> void:		# Primer script en ejecutarse
	_fail_to_turn_on()
	while throttle_sfx.playing:
		await get_tree().process_frame
	_fail_to_turn_on()
	
	
	_eject_characters()

func _fail_to_turn_on() -> void:
	anim_player.play("vibrate")
	throttle_sfx.play()
	
func _rest() -> void:
	anim_player.play("RESET")

func _eject_characters() -> void:
	var gerardo : CharacterBody2D = load(gerardo_path).instantiate()
	var guillermo : CharacterBody2D = load(guillermo_path).instantiate()
	
	gerardo.global_position = global_position + Vector2(-50, 30)
	guillermo.global_position = global_position + Vector2(-50, 60)
	
	get_tree().root.add_child(gerardo)
	get_tree().root.add_child(guillermo)
	
