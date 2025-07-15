# claudiot_tscn.gd
extends "res://maquina_estado.gd"

func _ready():
	# Asignar el estado inicial
	set_estado(EstadoPersonaje.IDLE)
