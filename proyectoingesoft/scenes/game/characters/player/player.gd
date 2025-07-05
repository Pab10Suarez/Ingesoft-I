extends CharacterBody2D

enum Estados { NORMAL, CON_LINTERNA, CON_MACHETE }

@export var velocidad = 300
var estado_actual = Estados.NORMAL

func _physics_process(delta):
    var direccion = Vector2.ZERO
    
    if Input.is_action_pressed("ui_right"):
        direccion.x += 1
    if Input.is_action_pressed("ui_left"):
        direccion.x -= 1
    if Input.is_action_pressed("ui_down"):
        direccion.y += 1
    if Input.is_action_pressed("ui_up"):
        direccion.y -= 1

    if direccion.length() > 0:
        direccion = direccion.normalized()
    
    velocity = direccion * velocidad
    move_and_slide()

func recolectar_objeto(tipo_objeto):
    match tipo_objeto:
        "linterna":
            estado_actual = Estados.CON_LINTERNA
            $Sprite2D.modulate = Color.YELLOW
            print("¡Linterna recolectada!")
            
        "machete":
            estado_actual = Estados.CON_MACHETE
            $Sprite2D.modulate = Color.RED
            print("¡Machete recolectado!")