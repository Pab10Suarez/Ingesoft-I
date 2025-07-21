extends Node

enum Children {
	SUSANA,
	CLAUDIO,
	GUILLERMO
}

var gerardo_ref : Gerardo
var susana_ref : Susana
var claudio_ref : Claudio
var guillermo_ref : Guillermo

var ref_pickup : ParacoMovil

func transition_children_to_following_state() -> void:
	for child in get_tree().get_nodes_in_group("CastChildren"):
		if child.has_method("cambiar_estado_movimiento"):
			child.cambiar_estado_movimiento(child.EstadoMovimiento.FOLLOWING)
			
	print("GM: Niñxs siguen a gerardo")

func gerardo_enters_scene(ref : Gerardo) -> void:
	gerardo_ref = ref
	for child in get_tree().get_nodes_in_group("CastChildren"):
		child.player = ref
			
	print("GM: Niñxs saben donde está gerardo")

func send_kid_to_turn_off_truck(kid : Children) -> void:
	var truck_position : Vector2 = ref_pickup.global_position
	match kid:
		Children.SUSANA:
			susana_ref.ordenar_ir_a(truck_position)
		Children.GUILLERMO:
			guillermo_ref.ordenar_ir_a(truck_position)
			
	
func _input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		send_kid_to_turn_off_truck(Children.SUSANA)
