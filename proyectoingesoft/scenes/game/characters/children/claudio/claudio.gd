xtends CharacterBody2D

const VELOCIDAD_CAMINAR := 35.0
const DISTANCIA_MINIMA_DE_PLAYER := 120.0
const INTENSIDAD_JUEGO := 0.6

enum EstadoGuillermo { NEUTRAL, SUFRIENDO }
enum EstadoMovimiento { IDLE, FOLLOWING_PLAYER, PLAYING }

var estado_emocional: EstadoGuillermo = EstadoGuillermo.NEUTRAL
var estado_movimiento: EstadoMovimiento = EstadoMovimiento.IDLE
@onready var player := get_tree().get_first_node_in_group("Player")
@onready var sprite := $AnimatedSprite2D

func _ready():
    cambiar_estado_emocional(EstadoGuillermo.NEUTRAL)
    cambiar_estado_movimiento(EstadoMovimiento.FOLLOWING_PLAYER)

func _physics_process(delta):
    match estado_movimiento:
        EstadoMovimiento.IDLE: velocity = Vector2.ZERO
        EstadoMovimiento.FOLLOWING_PLAYER: seguir_player()
        EstadoMovimiento.PLAYING: jugar_solo()
    move_and_slide()

func cambiar_estado_emocional(nuevo: EstadoGuillermo):
    estado_emocional = nuevo
    match nuevo:
        EstadoGuillermo.NEUTRAL: sprite.play("neutral")
        EstadoGuillermo.SUFRIENDO: sprite.play("sufriendo")

func cambiar_estado_movimiento(nuevo: EstadoMovimiento): estado_movimiento = nuevo

func seguir_player():
    if not player:
        velocity = Vector2.ZERO
        return
    var distancia = global_position.distance_to(player.global_position)
    velocity = (player.global_position - global_position).normalized() * VELOCIDAD_CAMINAR if distancia >= DISTANCIA_MINIMA_DE_PLAYER else Vector2.ZERO

func jugar_solo():
    var ruido = Vector2(randf() - 0.5, randf() - 0.5).normalized()
    velocity = ruido * VELOCIDAD_CAMINAR * INTENSIDAD_JUEGO
