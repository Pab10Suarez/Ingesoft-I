extends CharacterBody2D
class_name Guillermo

# --- Constantes ---
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
	match estado_movimiento:
		EstadoMovimiento.IDLE:
			velocity = Vector2.ZERO
		EstadoMovimiento.FOLLOWING:
			seguir_a_gerardo()
		EstadoMovimiento.FREE_ROAM:
			explorar_con_miedo()
		EstadoMovimiento.OBEYING:
			obedecer_orden()
		EstadoMovimiento.SCRIPT:
			seguir_script(delta)

	move_and_slide()
	actualizar_animacion()

func actualizar_animacion():
	if velocity.length() > 0.1:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0: sprite.play("caminar_derecha")
			else: sprite.play("caminar_izquierda")
		else:
			if velocity.y > 0: sprite.play("caminar_abajo")
			else: sprite.play("caminar_arriba")
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
			decision_timer.start(4.0)
		velocity = Vector2.ZERO

func explorar_con_miedo():
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
	var radio = 60.0
	posicion_objetivo = global_position + Vector2(randf_range(-radio, radio), randf_range(-radio, radio))
	free_roam_timer.start(randf_range(2.0, 4.0))

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if Input.is_key_pressed(KEY_ALT):
			var pos = get_global_mouse_position()
			print("Orden recibida para Guillermo: ", pos)
			ordenar_ir_a(pos)
			get_viewport().set_input_as_handled()
