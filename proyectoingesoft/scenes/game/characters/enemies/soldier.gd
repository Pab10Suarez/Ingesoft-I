extends RigidBody2D
class_name Paraco

@export_enum("Hernán", "Juanfe") var paraco_name : String

const SPEED : float = 0.7

@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
@onready var anim_sprite : AnimatedSprite2D = $AnimatedSprite2D

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
	current_state = STATES.SCRIPT #debug
	_assign_script()

func _physics_process(delta: float) -> void:
	match current_state:
		STATES.PERSECUTION:
			_persecution_state_process(delta)
		STATES.SCRIPT:
			_script_state_process(delta)
	
#region Entrance-Exit states
func _enter_persecution_state() -> void:
	pass
#endregion

#region State Processes
func _persecution_state_process(delta : float) -> void:
	var direction = Vector3()
	nav_agent.target_position = get_tree().get_first_node_in_group("Player").global_position
	
	_move_towards_target()

func _script_state_process(delta : float) -> void:
	if nav_agent.target_position == null:
		return
	elif global_position.distance_squared_to(nav_agent.target_position) < 100:
		return
	
	_move_towards_target()
	

#endregion

#region Character Scripts
func _assign_script() -> void:
	match paraco_name:
		"Hernán":
			_script_hernan()
		"Juanfe":
			_script_juanfe()
		_:
			assert(false, "Nombre no reconocido de paraco")

func _script_juanfe() -> void:
	nav_agent.target_position = get_tree().get_first_node_in_group("Soldiers").global_position #+ Vector2(-50, -40) # Hernán es el primero
	await nav_agent.navigation_finished
	DialogueManager.show_dialogue_balloon(load("res://assets/dialogue/juanfe_dialogue_1.dialogue"), "ParacosP1")
	await DialogueManager.dialogue_ended
	while get_tree().get_nodes_in_group("Footprints").size() == 0:
		await get_tree().process_frame
	nav_agent.target_position = get_tree().get_first_node_in_group("Footprints").global_position
	await nav_agent.navigation_finished
	DialogueManager.show_dialogue_balloon(load("res://assets/dialogue/juanfe_dialogue_1.dialogue"), "ParacosP2")
	
func _script_hernan() -> void:
	pass
	
#endregion

#region Movement
func _move_towards_target() -> void:
	var direction = Vector3()
	direction = nav_agent.get_next_path_position() - global_position
	direction = direction.normalized() * SPEED
	
	if direction.length_squared() < 0.2:
		anim_sprite.stop()
		return
		
	anim_sprite.play("walk_right")
	anim_sprite.flip_h = direction.x < 0
	move_and_collide(direction)
#endregion
