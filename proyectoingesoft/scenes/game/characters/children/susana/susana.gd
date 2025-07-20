extends CharacterBody2D
class_name Susana

# --- Constantes ---
const VELOCIDAD_CAMINAR := 35.0
const DISTANCIA_MINIMA_DE_GERARDO := 110.0
const INTENSIDAD_JUEGO := 0.5

# --- Estado emocional y movimiento ---
enum EstadoSusana { NEUTRAL }
enum EstadoMovimiento { IDLE, FOLLOWING_GERARDO, PLAYING }

# --- Variables ---
var estado_emocional: EstadoSusana = EstadoSusana.NEUTRAL
var estado_movimiento: EstadoMovimiento = EstadoMovimiento.IDLE

@onready var player := get_tree().get_first_node_in_group("Player")
@onready var sprite := $AnimatedSprite2D

func _ready() -> void:
	cambiar_estado_emocional(EstadoSusana.NEUTRAL)
	cambiar_estado_movimiento(EstadoMovimiento.FOLLOWING_GERARDO)

func _physics_process(delta: float) -> void:
	match estado_movimiento:
		EstadoMovimiento.IDLE:
			velocity = Vector2.ZERO
		EstadoMovimiento.FOLLOWING_GERARDO:
			seguir_a_player()
		EstadoMovimiento.PLAYING:
			moverse_jugando()
	move_and_slide()

# --- Emoción única: NEUTRAL ---
func cambiar_estado_emocional(nuevo: EstadoSusana) -> void:
	estado_emocional = nuevo
	sprite.play("neutral")

# --- Movimiento lógico del NPC ---
func cambiar_estado_movimiento(nuevo: EstadoMovimiento) -> void:
	estado_movimiento = nuevo

# --- Sigue a Gerardo con distancia ---
func seguir_a_player():
	if not player:
		velocity = Vector2.ZERO
		return
	var distancia = global_position.distance_to(player.global_position)
	if distancia < DISTANCIA_MINIMA_DE_GERARDO:
		velocity = Vector2.ZERO
	else:
		var direccion = (player.global_position - global_position).normalized()
		velocity = direccion * VELOCIDAD_CAMINAR

# --- Movimiento tipo juego ---
func moverse_jugando():
	var ruido := Vector2(randf() - 0.5, randf() - 0.5).normalized()
	velocity = ruido * (VELOCIDAD_CAMINAR * INTENSIDAD_JUEGO)
