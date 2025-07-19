extends RigidBody2D
class_name Paraco

@export_enum("Hernán", "Juanfe") var paraco_name : String

const SPEED : float = 0.7

@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D

enum STATES{
	PERSECUTION,
	SCRIPT,
	IDLE
}

@export var  current_state : int = STATES.IDLE:
	set(v):
		if v == STATES.PERSECUTION:
			_enter_persecution_state()
			
		current_state = v

func _ready() -> void:
	current_state = STATES.PERSECUTION # debug

func _physics_process(delta: float) -> void:
	match current_state:
		STATES.PERSECUTION:
			_persecution_state_process(delta)
	
func _enter_persecution_state() -> void:
	pass
	
func _persecution_state_process(delta : float) -> void:
	var direction = Vector3()
	nav_agent.target_position = get_tree().get_first_node_in_group("Player").global_position
	
	direction = nav_agent.get_next_path_position() - global_position
	direction = direction.normalized() * SPEED
	
	move_and_collide(direction)
	
