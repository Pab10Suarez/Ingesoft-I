extends CharacterBody2D
class_name Guillermo

# --- Constantes (Personalidad de Guillermo: lento y tímido) ---
const VELOCIDAD_CAMINAR := 30.0
const DISTANCIA_MINIMA_DE_GERARDO := 30.0
const DISTANCIA_MAXIMA_FREE_ROAM := 150.0
const DISTANCIA_MINIMA_OBJETIVO := 5.0

# --- Estados ---
enum EstadoMovimiento { IDLE, FOLLOWING, FREE_ROAM, OBEYING, SCRIPT }
var estado_movimiento: EstadoMovimiento = EstadoMovimiento.IDLE

# --- Variables de estado ---
var posicion_objetivo: Vector2

# --- Referencias a nodos ---
@onready var player := get_tree().get_first_node_in_group("Player")
@onready var sprite := $AnimatedSprite2D
@onready var free_roam_timer := $Timer
@onready var decision_timer := $DecisionTimer
@onready var path_follow := $Path2D/PathFollow2D


func _ready():
	free_roam_timer.timeout.connect(_on_free_roam_timer_timeout)
	decision_timer.timeout.connect(_on_decision_timer_timeout)
	cambiar_estado_movimiento(EstadoMovimiento.FOLLOWING)


func _physics_process(delta: float) -> void:
	# --- ¡CEREBRO AÑADIDO! ---
	# Regla: Si está deambulando o parado, y Gerardo se mueve, vuelve a seguirlo.
	if estado_movimiento == EstadoMovimiento.FREE_ROAM or estado_movimiento == EstadoMovimiento.IDLE:
		if player and player.velocity.length() > 1.0:
			cambiar_estado_movimiento(EstadoMovimiento.FOLLOWING)
	# ----------------------------------------

	match estado_movimiento:
		EstadoMovimiento.IDLE:
			# En el estado IDLE, la velocidad es cero.
			velocity = Vector2.ZERO
		EstadoMovimiento.FOLLOWING:
			seguir_a_gerardo()
		EstadoMovimiento.FREE_ROAM:
			# ¡OJO! Aquí llamabas a "explorar_con_miedo". La he renombrado a un nombre estándar
			# para mantener la consistencia. La lógica interna es la que define la personalidad.
			moverse_en_free_roam()
		EstadoMovimiento.OBEYING:
			obedecer_orden()
		EstadoMovimiento.SCRIPT:
			seguir_script(delta)

	move_and_slide()
	actualizar_animacion()


# --- FUNCIÓN DE ANIMACIÓN CORREGIDA ---
func actualizar_animacion():
	# Asumiendo que las animaciones se llaman "walk_right", etc.
	# ¡Cámbialas aquí si para Guillermo se llaman diferente!
	if velocity.length() > 0.1:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0: sprite.play("walk_right")
			else: sprite.play("walk_left")
		else:
			if velocity.y > 0: sprite.play("walk_down")
			else: sprite.play("walk_up")
	else:
		if sprite.is_playing(): sprite.stop(); sprite.frame = 0


# --- Lógica de movimiento ---

func seguir_a_gerardo():
	if not player: velocity = Vector2.ZERO; return
	
	var distancia = global_position.distance_to(player.global_position)
	if distancia > DISTANCIA_MINIMA_DE_GERARDO:
		decision_timer.stop()
		var direccion = (player.global_position - global_position).normalized()
		velocity = direccion * VELOCIDAD_CAMINAR
	else:
		if decision_timer.is_stopped():
			# Tarda un poco más en aburrirse porque es más tranquilo
			decision_timer.start(6.0) 
		velocity = Vector2.ZERO


func moverse_en_free_roam():
	if player and global_position.distance_to(player.global_position) > DISTANCIA_MAXIMA_FREE_ROAM:
		print("Guillermo se asustó y regresa con Gerardo.")
		cambiar_estado_movimiento(EstadoMovimiento.FOLLOWING)
		return
	
	var direccion = (posicion_objetivo - global_position).normalized()
	velocity = direccion * VELOCIDAD_CAMINAR
	if global_position.distance_to(posicion_objetivo) < DISTANCIA_MINIMA_OBJETIVO:
		velocity = Vector2.ZERO


func obedecer_orden():
	var direccion = (posicion_objetivo - global_position).normalized()
	velocity = direccion * VELOCIDAD_CAMINAR
	if global_position.distance_to(posicion_objetivo) < DISTANCIA_MINIMA_OBJETIVO:
		cambiar_estado_movimiento(EstadoMovimiento.IDLE)


func seguir_script(delta: float):
	path_follow.progress += VELOCIDAD_CAMINAR * delta
	var direccion = (path_follow.global_position - global_position).normalized()
	velocity = direccion * VELOCIDAD_CAMINAR


# --- Cambio de estado ---
func cambiar_estado_movimiento(nuevo_estado: EstadoMovimiento) -> void:
	if estado_movimiento == nuevo_estado: return

	estado_movimiento = nuevo_estado
	print("Guillermo cambió al estado: ", EstadoMovimiento.keys()[nuevo_estado])
	decision_timer.stop()
	free_roam_timer.stop()

	if estado_movimiento == EstadoMovimiento.FREE_ROAM:
		free_roam_timer.start(randf_range(2.0, 4.0))
		_on_free_roam_timer_timeout()
		
	if estado_movimiento == EstadoMovimiento.SCRIPT:
		path_follow.progress = 0


func ordenar_ir_a(punto: Vector2):
	posicion_objetivo = punto
	cambiar_estado_movimiento(EstadoMovimiento.OBEYING)


# --- Eventos internos ---
func _on_decision_timer_timeout():
	print("Guillermo se aburrió y se fue a buscar insectos.")
	cambiar_estado_movimiento(EstadoMovimiento.FREE_ROAM)


func _on_free_roam_timer_timeout():
	# No se aleja mucho porque es tímido
	var radio = 60.0 
	posicion_objetivo = global_position + Vector2(randf_range(-radio, radio), randf_range(-radio, radio))
	free_roam_timer.start(randf_range(2.0, 4.0))


func _input(event: InputEvent):
	# Usa una tecla diferente para las órdenes (ej. Control derecho)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if Input.is_key_pressed(KEY_CTRL): # Cambiado a CTRL para Guillermo
			var pos = get_global_mouse_position()
			# Solo le damos la orden a Guillermo si este input es para él.
			# Esto es solo un ejemplo, podrías necesitar un sistema de selección de personaje más complejo.
			print("Orden recibida para Guillermo: ", pos)
			ordenar_ir_a(pos)
			get_viewport().set_input_as_handled()