extends CharacterBody2D
class_name Guillermo

const VELOCIDAD_CAMINAR := 30.0
const DISTANCIA_MINIMA_DE_GERARDO := 130.0

enum EstadoGuillermo {
    NEUTRAL,
    SUFRIENDO
}

var estado_actual: EstadoGuillermo = EstadoGuillermo.NEUTRAL
@onready var gerardo := get_tree().get_first_node_in_group("Player")
@onready var sprite := $AnimatedSprite2D

func _ready() -> void:
    cambiar_estado(EstadoGuillermo.NEUTRAL)

func _physics_process(delta: float) -> void:
    if gerardo:
        seguir_a_gerardo_con_distancia()

func cambiar_estado(nuevo_estado: EstadoGuillermo) -> void:
    if nuevo_estado != estado_actual:
        estado_actual = nuevo_estado
        actualizar_animacion()

func seguir_a_gerardo_con_distancia() -> void:
    var distancia := global_position.distance_to(gerardo.global_position)
    if distancia < DISTANCIA_MINIMA_DE_GERARDO:
        velocity = Vector2.ZERO
    else:
        var direccion := (gerardo.global_position - global_position).normalized()
        velocity = direccion * VELOCIDAD_CAMINAR
    move_and_slide()

func actualizar_animacion():
    match estado_actual:
        EstadoGuillermo.NEUTRAL:
            sprite.play("neutral")
        EstadoGuillermo.SUFRIENDO:
            sprite.play("sufriendo")
