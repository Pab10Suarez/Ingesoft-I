extends CharacterBody2D
class_name Susana

# --- Constantes ---
const VELOCIDAD_CAMINAR := 1
const DISTANCIA_MINIMA_DE_GERARDO := 20.0
const DISTANCIA_MAXIMA_FREE_ROAM := 200.0
const DISTANCIA_MINIMA_OBJETIVO := 5.0

# --- Estados ---
enum EstadoMovimiento { IDLE, FOLLOWING, FREE_ROAM, OBEYING, SCRIPT }
static var estado_movimiento: EstadoMovimiento = EstadoMovimiento.SCRIPT

# --- Variables de estado ---
static var posicion_objetivo: Vector2

# --- Referencias a Nodos ---
var player : Gerardo
static var sprite : AnimatedSprite2D
@onready var free_roam_timer := $Timer
@onready var decision_timer := $DecisionTimer
@onready var path_follow := $Path2D/PathFollow2D
@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	sprite = $AnimatedSprite2D
	
	
	#free_roam_timer.timeout.connect(_on_free_roam_timer_timeout)
	decision_timer.timeout.connect(_on_decision_timer_timeout)
	GameManager.susana_ref = self
	#cambiar_estado_movimiento(EstadoMovimiento.FOLLOWING)


func _physics_process(delta: float) -> void:
	# --- ¡NUEVO! "CEREBRO" PARA DECIDIR SI VOLVER A SEGUIR ---
	# Comprobamos si no estamos ya siguiendo a Gerardo o en una orden/script
	if estado_movimiento == EstadoMovimiento.FREE_ROAM or estado_movimiento == EstadoMovimiento.IDLE:
		# Si el jugador existe y se está moviendo (su velocidad es mayor que un valor pequeño)
		if player and player.velocity.length() > 1.0:
			print("Gerardo se está moviendo, volviendo a seguir.")
			cambiar_estado_movimiento(EstadoMovimiento.FOLLOWING)
	# -------------------------------------------------------------
	
	# La máquina de estados principal no cambia
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


# ... (El resto de las funciones: actualizar_animacion, hacer_nada, seguir_a_gerardo, etc., se quedan exactamente igual)
# Pega el resto de tus funciones aquí sin cambios.
# Para evitar un bloque de código masivo, solo he mostrado la parte modificada,
# pero el resto del script (obedecer_orden, _input, etc.) debe permanecer.

func actualizar_animacion():
	if velocity.length() > 0.1:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0: sprite.play("walk right")
			else: sprite.play("walk_left")
		else:
			if velocity.y > 0: sprite.play("walk_down")
			else: sprite.play("walk_up")
	elif sprite.is_playing() and estado_movimiento != EstadoMovimiento.SCRIPT: 
			stop_animation()

func hacer_nada():
	velocity = Vector2.ZERO

func seguir_a_gerardo():
	if not player: 
		velocity = Vector2.ZERO 
		return

	nav_agent.target_position = player.global_position
	var distancia = global_position.distance_to(player.global_position)
	if distancia > DISTANCIA_MINIMA_DE_GERARDO:
		decision_timer.stop()
		var direccion = (nav_agent.get_next_path_position() - global_position).normalized()
		move_and_collide(direccion * VELOCIDAD_CAMINAR)
	else:
		if decision_timer.is_stopped():
			decision_timer.start(5.0)
		velocity = Vector2.ZERO

func moverse_en_free_roam():
	if player and global_position.distance_to(player.global_position) > DISTANCIA_MAXIMA_FREE_ROAM:
		cambiar_estado_movimiento(EstadoMovimiento.FOLLOWING)
		return

	var direccion = (posicion_objetivo - global_position).normalized()
	velocity = direccion * VELOCIDAD_CAMINAR
	if global_position.distance_to(posicion_objetivo) < DISTANCIA_MINIMA_OBJETIVO:
		velocity = Vector2.ZERO

func obedecer_orden():
	var direction = Vector2()
	direction = nav_agent.get_next_path_position() - global_position
	direction = direction.normalized() * VELOCIDAD_CAMINAR
	move_and_collide(direction)

	if global_position.distance_to(posicion_objetivo) < DISTANCIA_MINIMA_OBJETIVO:
		cambiar_estado_movimiento(EstadoMovimiento.IDLE)

func seguir_script(delta: float):
	path_follow.progress += VELOCIDAD_CAMINAR * delta
	var direccion = (path_follow.global_position - global_position).normalized()
	velocity = direccion * VELOCIDAD_CAMINAR

func cambiar_estado_movimiento(nuevo_estado: EstadoMovimiento) -> void:
	if estado_movimiento == nuevo_estado: return

	estado_movimiento = nuevo_estado
	print("Susana ha cambiado al estado: ", EstadoMovimiento.keys()[nuevo_estado])
	
	decision_timer.stop()
	free_roam_timer.stop()
	
	if estado_movimiento == EstadoMovimiento.FREE_ROAM:
		free_roam_timer.start(randf_range(3.0, 6.0))
		_on_free_roam_timer_timeout()
		
	if estado_movimiento == EstadoMovimiento.SCRIPT:
		path_follow.progress = 0

func ordenar_ir_a(punto: Vector2):
	#posicion_objetivo = punto
	nav_agent.target_position = punto
	cambiar_estado_movimiento(EstadoMovimiento.OBEYING)

func _on_decision_timer_timeout():
	cambiar_estado_movimiento(EstadoMovimiento.FREE_ROAM)

func _on_free_roam_timer_timeout():
	var radio = 100.0
	posicion_objetivo = global_position + Vector2(randf_range(-radio, radio), randf_range(-radio, radio))
	free_roam_timer.start(randf_range(3.0, 6.0))
func _input(event: InputEvent) -> void:
	# 1. Filtramos por el evento de clic
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		
		# 2. Comprobamos si la tecla de orden para SUSANA (Shift) está presionada
		if Input.is_key_pressed(KEY_SHIFT):
			
			# 3. Si es así, ejecutamos la orden y CONSUMIMOS el input
			var posicion_del_clic = get_global_mouse_position()
			print("Orden recibida para Susana: ", posicion_del_clic)
			ordenar_ir_a(posicion_del_clic)
			
			# Esta línea es CLAVE: solo se ejecuta si la orden era para ella
			get_viewport().set_input_as_handled()

static func loop_walk_up() -> void:
	sprite.play("walk_up")
	
static func stop_animation() -> void:
	sprite.stop()
	sprite.frame = 0

func start_dialogue() -> void:
	print("Start_dialogue llamao")
	$DialogueManager.start_dialogue()
