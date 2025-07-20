extends CharacterBody2D
class_name Susana

# --- Constantes ---
const VELOCIDAD_CAMINAR := 40.0
const DISTANCIA_MINIMA_DE_GERARDO := 40.0
const DISTANCIA_MAXIMA_FREE_ROAM := 200.0 # NUEVO: Distancia máxima antes de volver a seguir
const DISTANCIA_MINIMA_OBJETIVO := 5.0

# --- Estados ---
enum EstadoMovimiento { IDLE, FOLLOWING, FREE_ROAM, OBEYING, SCRIPT }
var estado_movimiento: EstadoMovimiento = EstadoMovimiento.IDLE

# --- Variables de estado ---
var posicion_objetivo: Vector2

# --- Referencias a Nodos ---
@onready var player := get_tree().get_first_node_in_group("Player")
@onready var sprite := $AnimatedSprite2D
@onready var free_roam_timer := $Timer
@onready var decision_timer := $DecisionTimer # NUEVO: Referencia al nuevo timer
@onready var path_follow := $Path2D/PathFollow2D


func _ready() -> void:
	free_roam_timer.timeout.connect(_on_free_roam_timer_timeout)
	decision_timer.timeout.connect(_on_decision_timer_timeout) # NUEVO: Conectamos la señal
	
	cambiar_estado_movimiento(EstadoMovimiento.FOLLOWING)


func _physics_process(delta: float) -> void:
	match estado_movimiento:
		EstadoMovimiento.IDLE:
			hacer_nada()
		EstadoMovimiento.FOLLOWING:
			seguir_a_gerardo()
		EstadoMovimiento.FREE_ROAM:
			moverse_en_free_roam()
		EstadoMovimiento.OBEYING:
			obedecer_orden()
		EstadoMovimiento.SCRIPT:
			seguir_script(delta)
			
	move_and_slide()
	actualizar_animacion()


func actualizar_animacion():
	# ... (esta función no cambia)
	if velocity.length() > 0.1:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0: sprite.play("walk right")
			else: sprite.play("walk_left")
		else:
			if velocity.y > 0: sprite.play("walk_down")
			else: sprite.play("walk_up")
	else:
		if sprite.is_playing(): sprite.stop(); sprite.frame = 0


# --- LÓGICA DE CADA ESTADO (CON MODIFICACIONES) ---

func hacer_nada():
	velocity = Vector2.ZERO

func seguir_a_gerardo():
	if not player: velocity = Vector2.ZERO; return
		
	var distancia = global_position.distance_to(player.global_position)
	if distancia > DISTANCIA_MINIMA_DE_GERARDO:
		# MODIFICADO: Si se está moviendo, nos aseguramos de que el timer de decisión esté parado.
		decision_timer.stop()
		var direccion = (player.global_position - global_position).normalized()
		velocity = direccion * VELOCIDAD_CAMINAR
	else:
		# MODIFICADO: Si está cerca y quieto, iniciamos el contador para ver si se aburre.
		if decision_timer.is_stopped():
			decision_timer.start(5.0) # Esperará 5 segundos antes de decidir deambular
		velocity = Vector2.ZERO

func moverse_en_free_roam():
	# NUEVO: Comprobamos si el jugador se ha alejado demasiado.
	if player and global_position.distance_to(player.global_position) > DISTANCIA_MAXIMA_FREE_ROAM:
		print("Gerardo está muy lejos, volviendo a seguir.")
		cambiar_estado_movimiento(EstadoMovimiento.FOLLOWING)
		return # Salimos de la función para que el cambio de estado se aplique en el siguiente fotograma

	# El resto de la lógica de deambular no cambia
	var direccion = (posicion_objetivo - global_position).normalized()
	velocity = direccion * VELOCIDAD_CAMINAR
	if global_position.distance_to(posicion_objetivo) < DISTANCIA_MINIMA_OBJETIVO:
		velocity = Vector2.ZERO

func obedecer_orden():
	# ... (esta función no cambia)
	var direccion = (posicion_objetivo - global_position).normalized()
	velocity = direccion * VELOCIDAD_CAMINAR
	if global_position.distance_to(posicion_objetivo) < DISTANCIA_MINIMA_OBJETIVO:
		cambiar_estado_movimiento(EstadoMovimiento.IDLE)

func seguir_script(delta: float):
	# ... (esta función no cambia)
	path_follow.progress += VELOCIDAD_CAMINAR * delta
	var direccion = (path_follow.global_position - global_position).normalized()
	velocity = direccion * VELOCIDAD_CAMINAR


# --- FUNCIONES PARA CAMBIAR DE ESTADO (Sin cambios) ---
func cambiar_estado_movimiento(nuevo_estado: EstadoMovimiento) -> void:
	if estado_movimiento == nuevo_estado: return # No cambiamos si ya estamos en ese estado

	estado_movimiento = nuevo_estado
	print("Susana ha cambiado al estado: ", EstadoMovimiento.keys()[nuevo_estado])
	
	# Paramos todos los timers por defecto para evitar comportamientos extraños
	decision_timer.stop()
	free_roam_timer.stop()
	
	if estado_movimiento == EstadoMovimiento.FREE_ROAM:
		free_roam_timer.start(randf_range(3.0, 6.0))
		_on_free_roam_timer_timeout()
		
	if estado_movimiento == EstadoMovimiento.SCRIPT:
		path_follow.progress = 0

func ordenar_ir_a(punto: Vector2):
	posicion_objetivo = punto
	cambiar_estado_movimiento(EstadoMovimiento.OBEYING)


# --- FUNCIONES INTERNAS Y SEÑALES ---

# NUEVO: Esta función se activa cuando Susana ha estado quieta cerca de Gerardo por un tiempo.
func _on_decision_timer_timeout():
	print("Susana se aburrió y empezará a deambular.")
	cambiar_estado_movimiento(EstadoMovimiento.FREE_ROAM)

func _on_free_roam_timer_timeout():
	# ... (esta función no cambia)
	var radio = 100.0
	posicion_objetivo = global_position + Vector2(randf_range(-radio, radio), randf_range(-radio, radio))
	free_roam_timer.start(randf_range(3.0, 6.0))
func _input(event: InputEvent) -> void:
	# Comprobamos si la entrada es un clic izquierdo del ratón que se acaba de presionar.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		

		if Input.is_key_pressed(KEY_SHIFT):
			
			# Obtenemos la posición del clic en coordenadas globales.
			var posicion_del_clic = get_global_mouse_position()
			
			print("Orden recibida (desde el input de Susana) para ir a: ", posicion_del_clic)
			
			# Llamamos a la propia función de Susana para que se mueva.
			ordenar_ir_a(posicion_del_clic)
			
			# Marcamos el evento como manejado para que otros nodos no reaccionen a este clic.
			get_viewport().set_input_as_handled()