extends CharacterBody2D

const SPEED = 200  # Velocidad del jugador

enum PlayerState { NORMAL, CON_LINTERNA, CON_MACHETE }
var state: PlayerState = PlayerState.NORMAL
func get_estado_nombre():
	match state:
		PlayerState.NORMAL:
			return "NORMAL"
		PlayerState.CON_LINTERNA:
			return "CON_LINTERNA"
		PlayerState.CON_MACHETE:
			return "CON_MACHETE"

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
	$Label.text = "Estado: " + get_estado_nombre()