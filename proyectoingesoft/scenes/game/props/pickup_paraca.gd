extends AnimatableBody2D

enum STATES {
	RUNNING,
	ON,
	OFF
}

const SPEED : float = 0.5
@export var current_state = STATES.OFF:
	set(v):
		match v:
			STATES.ON:
				_turn_on()
			STATES.RUNNING:
				_turn_on()
			STATES.OFF:
				_turn_off()
		current_state = v
		
@onready var anim_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	current_state = STATES.RUNNING
	
func _physics_process(delta: float) -> void:
	match current_state:
		STATES.RUNNING:
			_running_state_process(delta)
	
func _turn_on() -> void:
	anim_player.play("engine_on")
	# Sonido de motor

func _running_state_process(delta : float) -> void:
	position += Vector2.UP * SPEED

func _turn_off() -> void:
	# Sonido de llaves girando
	anim_player.play("RESET")


func _on_stop_detection_area_entered(area: Area2D) -> void:
	if area.is_in_group("VehicleStops"):
		current_state = STATES.ON
