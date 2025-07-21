extends CharacterBody2D
class_name Claudio

# --- Constantes (con personalidad propia) ---
const VELOCIDAD_CAMINAR := 55.0 # Un poco más rápido que Susana
const DISTANCIA_MINIMA_DE_GERARDO := 60.0
const DISTANCIA_MAXIMA_FREE_ROAM := 220.0
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
@onready var decision_timer := $DecisionTimer
@onready var path_follow := $Path2D/PathFollow2D


func _ready() -> void:
	free_roam_timer.timeout.connect(_on_free_roam_timer_timeout)
	decision_timer.timeout.connect(_on_decision_timer_timeout)
	cambiar_estado_movimiento(EstadoMovimiento.FOLLOWING)


func _physics_process(delta: float) -> void:
	# --- ¡CEREBRO CORREGIDO Y AÑADIDO! ---
	# Regla: Si está deambulando o parado, y Gerardo se mueve, vuelve a seguirlo.
	if estado_movimiento == EstadoMovimiento.FREE_ROAM or estado_movimiento == EstadoMovimiento.IDLE:
		if player and player.velocity.length() > 1.0:
			cambiar_estado_movimiento(EstadoMovimiento.FOLLOWING)
	# ----------------------------------------
			
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
	# (Esta función estaba perfecta, sin cambios)
	if velocity.length() > 0.1:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0: sprite.play("walk_right")
			else: sprite.play("walk_left")
		else:
			if velocity.y > 0: sprite.play("walk_down")
			else: sprite.play("walk_up")
	else:
		if sprite.is_playing(): sprite.stop(); sprite.frame = 0


func hacer_nada():
	velocity = Vector2.ZERO


# --- FUNCIÓN CORREGIDA ---
func seguir_a_gerardo():
	if not player: velocity = Vector2.ZERO; return

	var distancia = global_position.distance_to(player.global_position)
	if distancia > DISTANCIA_MINIMA_DE_GERARDO:
		# ¡CORREGIDO! Usamos el nombre correcto de la variable.
		decision_timer.stop() 
		var direccion = (player.global_position - global_position).normalized()
		velocity = direccion * VELOCIDAD_CAMINAR
	else:
		if decision_timer.is_stopped():
			# Se aburre un poco más rápido que Susana
			decision_timer.start(4.0) 
		velocity = Vector2.ZERO


func moverse_en_free_roam():
	if player and global_position.distance_to(player.global_position) > DISTANCIA_MAXIMA_FREE_ROAM:
		print("Claudio se alejó mucho de Gerardo. Volviendo a seguir.")
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


func cambiar_estado_movimiento(nuevo_estado: EstadoMovimiento) -> void:
	if estado_movimiento == nuevo_estado: return
	estado_movimiento = nuevo_estado
	print("Claudio cambió a: ", EstadoMovimiento.keys()[nuevo_estado])
	decision_timer.stop()
	free_roam_timer.stop()

	if estado_movimiento == EstadoMovimiento.FREE_ROAM:
		free_roam_timer.start(randf_range(2.5, 5.0))
		_on_free_roam_timer_timeout()

	if estado_movimiento == EstadoMovimiento.SCRIPT:
		path_follow.progress = 0


func ordenar_ir_a(punto: Vector2):
	posicion_objetivo = punto
	cambiar_estado_movimiento(EstadoMovimiento.OBEYING)


func _on_decision_timer_timeout():
	print("Claudio se aburrió. Explorando por su cuenta.")
	cambiar_estado_movimiento(EstadoMovimiento.FREE_ROAM)


func _on_free_roam_timer_timeout():
	# Deambula un poco menos lejos que Susana
	var radio = 90.0 
	posicion_objetivo = global_position + Vector2(randf_range(-radio, radio), randf_range(-radio, radio))
	free_roam_timer.start(randf_range(3.0, 6.0))


func _input(event: InputEvent) -> void:
	# Usa una tecla diferente para no dar la orden a todos a la vez
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if Input.is_key_pressed(KEY_ALT): 
			var posicion_del_clic = get_global_mouse_position()
			ordenar_ir_a(posicion_del_clic)
			get_viewport().set_input_as_handled()