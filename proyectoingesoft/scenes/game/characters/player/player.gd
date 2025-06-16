extends CharacterBody2D
class_name Player

# Éste script hace parte de un "nodo", el nodo tiene tipo CharacterBody2D, si pones F1 puedes ver la documentación
# Para probar el movimiento del jugador, puedes darle a F6 y ejecutar ésta escena aislada del resto del juego

func _ready() -> void:
	# Ésta función se llama cuando el "nodo" entra a la escena
	# Un buen recurso para entender ésta funcion es https://kidscancode.org/godot_recipes/3.x/basics/tree_ready_order/index.html
	pass

func _physics_process(delta: float) -> void:
	# Ésta función se llama cada frame de física, es ideal para indicar movimiento ya que no depende del framerate del juego en un PC en específico
	# Para tratar los inputs del teclado, puedes utilizar los InputEvents que configuré (Proyecto -> Configuración del proyecto -> Mapa de entrada)
	# Un buen recurso para entender ésta función es https://www.reddit.com/r/godot/comments/bhptsm/process_physics_process_and_physics_frames/
	pass
	
