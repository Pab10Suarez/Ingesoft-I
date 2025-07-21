extends AnimatableBody2D
class_name ParacoMovil

enum STATES {
	RUNNING,
	ON,
	OFF
}

const SPEED : float = 0.5
@export var soldier_scene : Resource = preload("res://scenes/game/characters/enemies/soldier.tscn")
static var current_state = STATES.OFF:
	set(v):
		match v:
			STATES.ON:
				_turn_on()
			STATES.RUNNING:
				_turn_on()
				start_march()
			STATES.OFF:
				_turn_off()
		current_state = v
		
static var anim_player : AnimationPlayer 
static var sfx : AudioStreamPlayer2D

func _ready() -> void:
	#current_state = STATES.RUNNING
	anim_player = $AnimationPlayer
	sfx = $Engine
	
	GameManager.ref_pickup = self
	pass
	
func _physics_process(delta: float) -> void:
	match current_state:
		STATES.RUNNING:
			_running_state_process(delta)
	
static func _turn_on() -> void:
	anim_player.play("engine_on")
	sfx.stop()
	# Sonido de motor

static func start_march() -> void:
	sfx.play(2)
	pass

static func _turn_off() -> void:
	# Sonido de llaves girando
	anim_player.play("RESET")
	
func _running_state_process(delta : float) -> void:
	position += Vector2.UP * SPEED

func _on_stop_detection_area_entered(area: Area2D) -> void:
	if area.is_in_group("VehicleStops"):
		current_state = STATES.ON
	_script_demo()
		
func _script_demo() -> void:
	await get_tree().create_timer(2).timeout
	var guardia_hernan : RigidBody2D = soldier_scene.instantiate()
	var guardia_juanfe : RigidBody2D = soldier_scene.instantiate()
	
	guardia_hernan.paraco_name = "Hernán"
	guardia_hernan.add_to_group("Soldiers")
	guardia_juanfe.paraco_name = "Juanfe"
	guardia_juanfe.add_to_group("Soldiers")
	
	guardia_hernan.global_position = global_position + Vector2(-50, 0)
	guardia_juanfe.global_position = global_position + Vector2(50, 0)
	
	get_tree().root.add_child(guardia_hernan)
	$CarDoor.play(3.5)
	await get_tree().create_timer(1).timeout
	get_tree().root.add_child(guardia_juanfe)
	$CarDoor.play(3.5)
