 susana.tscn
extends "res://maquina_estado.gd"  # Extiende de la máquina de estados

func _ready():
	# Inicializa el estado de Susana
	set_estado(EstadoPersonaje.IDLE)  # Susana comienza en estado inactivo
