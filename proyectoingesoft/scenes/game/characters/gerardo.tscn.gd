# gerardo.tscn
extends "res://maquina_estado.gd"  # Extiende de la máquina de estados

func _ready():
	# Inicializa el estado de Gerardo
	set_estado(EstadoPersonaje.IDLE)  # Gerardo comienza en estado inactivo
