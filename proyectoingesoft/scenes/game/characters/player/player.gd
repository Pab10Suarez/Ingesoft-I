extends CharacterBody2D

const SPEED = 200  # Velocidad del jugador

enum PlayerState { NORMAL, CON_LINTERNA, CON_MACHETE }
var state: PlayerState = PlayerState.NORMAL
var animated_sprite: AnimatedSprite2D

func get_estado_nombre():
	match state:
		PlayerState.NORMAL:
			return "NORMAL"
		PlayerState.CON_LINTERNA:
			return "CON_LINTERNA"
		PlayerState.CON_MACHETE:
			return "CON_MACHETE"

func _ready():
	animated_sprite = $AnimatedSprite2D  # Referencia al nodo AnimatedSprite2D

func _physics_process(delta):
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	direction = direction.normalized()
	velocity = direction * SPEED
	move_and_slide()

	# Cambiar animación según el movimiento
	if direction != Vector2.ZERO:
		if direction.x > 0:
			animated_sprite.play("derecha")  # Animación de correr hacia la derecha
		elif direction.x < 0:
			animated_sprite.play("izquierda")  # Animación de correr hacia la izquierda
		elif direction.y > 0:
			animated_sprite.play("abajo")  # Animación de caminar hacia abajo
		elif direction.y < 0:
			animated_sprite.play("arriba")  # Animación de caminar hacia arriba
	else:
		animated_sprite.play("reposo")  # Animación cuando está parado

	$Label.text = "Estado: " + get_estado_nombre()
