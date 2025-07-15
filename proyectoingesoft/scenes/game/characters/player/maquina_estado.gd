# maquina_estado.gd
extends Node

# Definir la enumeración de los estados
enum EstadoPersonaje {
	IDLE,                # El personaje está inactivo
	FOLLOWING_GERARDO,   # El personaje sigue a Gerardo
	PLAYING              # El personaje está jugando
}

var estado_actual: EstadoPersonaje = EstadoPersonaje.IDLE

# Función para cambiar el estado
func set_estado(nuevo_estado: EstadoPersonaje):
	if nuevo_estado != estado_actual:
		estado_actual = nuevo_estado
		ejecutar_acciones()  # Llama a la acción correspondiente cuando cambia el estado

# Acción que ocurre cuando se cambia el estado
func ejecutar_acciones():
	match estado_actual:
		EstadoPersonaje.IDLE:
			print("El personaje está inactivo.")
		EstadoPersonaje.FOLLOWING_GERARDO:
			print("El personaje está siguiendo a Gerardo.")
		EstadoPersonaje.PLAYING:
			print("El personaje está jugando.")

