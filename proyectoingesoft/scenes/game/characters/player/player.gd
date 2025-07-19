extends CharacterBody2D

const SPEED = 50

# --- ESTADOS DEL JUGADOR ---
enum PlayerState { NORMAL, CON_LINTERNA, CON_MACHETE }
var state: PlayerState = PlayerState.NORMAL

# --- NODOS HIJOS (Referencias) ---
var animated_sprite: AnimatedSprite2D
var point_light: PointLight2D
var label: Label

# --- VARIABLES DE MOVIMIENTO ---
var last_direction: Vector2 = Vector2.RIGHT

# --- VARIABLES PARA LA LINTERNA ---
@export var linterna_offset := Vector2(25.0, 5.0)

# --- VARIABLES PARA LAS HUELLAS (¡CON EL CAMBIO!) ---
const DISTANCIA_HUELLA = 20#80.0 # ¡MODIFICADO! Más distancia entre cada par de huellas.
const DESPLAZAMIENTO_HUELLA_LATERAL = 0#4.0
const DESPLAZAMIENTO_HUELLA_VERTICAL = 0#12.0
var ultima_posicion_huella: Vector2
var textura_huella_generada: Texture2D


# La función _ready() se ejecuta una vez al inicio.
func _ready():
	animated_sprite = $AnimatedSprite2D
	point_light = $PointLight2D
	label = $Label
	
	ultima_posicion_huella = global_position
	
	point_light.enabled = false
	setup_flashlight_cone()
	
	textura_huella_generada = _crear_textura_huella()


# La función _physics_process(delta) se ejecuta en cada fotograma.
func _physics_process(delta):
	# --- 1. GESTIÓN DEL MOVIMIENTO ---
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"): direction.x += 1
	if Input.is_action_pressed("ui_left"): direction.x -= 1
	if Input.is_action_pressed("ui_down"): direction.y += 1
	if Input.is_action_pressed("ui_up"): direction.y -= 1
	
	direction = direction.normalized()
	velocity = direction * SPEED
	move_and_slide()
	
	# --- 2. GESTIÓN DE ANIMACIONES Y DIRECCIÓN ---
	if direction != Vector2.ZERO:
		last_direction = direction
		if direction.x > 0: animated_sprite.play("derecha")
		elif direction.x < 0: animated_sprite.play("izquierda")
		elif direction.y > 0: animated_sprite.play("abajo")
		elif direction.y < 0: animated_sprite.play("arriba")
		animated_sprite.speed_scale = 1
	else:
		if animated_sprite.is_playing():
			animated_sprite.stop()
			animated_sprite.frame = 0

	# --- 3. GESTIÓN DE LA LINTERNA ---
	if state == PlayerState.CON_LINTERNA:
		point_light.enabled = true
		update_flashlight_direction()
	else:
		point_light.enabled = false
	
	# --- 4. GESTIÓN DE HUELLAS ---
	if velocity.length() > 0:
		if global_position.distance_to(ultima_posicion_huella) > DISTANCIA_HUELLA:
			dejar_huellas_par()
			
	# --- 5. ACTUALIZAR INTERFAZ (UI) ---
	label.text = "Estado: " + get_estado_nombre()


# --- FUNCIONES AUXILIARES ---

func update_flashlight_direction():
	var angle = last_direction.angle()
	point_light.rotation = angle + PI / 2.0
	point_light.position = last_direction * linterna_offset.x + Vector2(0, linterna_offset.y)


func dejar_huellas_par():
	if not textura_huella_generada: return

	var posicion_central = global_position + Vector2(0, DESPLAZAMIENTO_HUELLA_VERTICAL)
	var direccion_lateral = last_direction.orthogonal()

	var pos_derecha = posicion_central + direccion_lateral * DESPLAZAMIENTO_HUELLA_LATERAL
	var pos_izquierda = posicion_central - direccion_lateral * DESPLAZAMIENTO_HUELLA_LATERAL
	
	_crear_una_huella_en(pos_derecha)
	_crear_una_huella_en(pos_izquierda)

	ultima_posicion_huella = global_position


func _crear_una_huella_en(posicion: Vector2):
	var huella = Sprite2D.new()
	huella.texture = textura_huella_generada
	get_parent().add_child(huella)
	
	huella.global_position = posicion
	huella.rotation = last_direction.angle() + PI / 2.0
	
	var tween = create_tween()
	tween.tween_interval(3.0) 
	tween.tween_property(huella, "modulate:a", 0, 1.5)
	tween.tween_callback(huella.queue_free)


func _crear_textura_huella() -> Texture2D:
	var ancho = 6#8
	var alto = 10#14
	var image = Image.create(ancho, alto, false, Image.FORMAT_RGBA8)
	var color_huella = Color(0.3, 0.2, 0.1, 0.6)
	var centro = Vector2(ancho / 2, alto / 2)
	var radio_x = (ancho / 2.0) - 1
	var radio_y = (alto / 2.0) - 1

	for y in range(alto):
		for x in range(ancho):
			var dx = x - centro.x
			var dy = y - centro.y
			if (dx*dx) / (radio_x*radio_x) + (dy*dy) / (radio_y*radio_y) <= 1:
				image.set_pixel(x, y, color_huella)
	
	return ImageTexture.create_from_image(image)


func setup_flashlight_cone():
	var image_size = 256
	var image = Image.create(image_size, image_size, false, Image.FORMAT_RGBA8)
	var center = Vector2(image_size / 2, image_size / 2)
	var cone_length = 120.0
	var cone_angle_degrees = 40.0

	for y in range(image_size):
		for x in range(image_size):
			var pixel_pos = Vector2(x, y)
			var vec_from_center = pixel_pos - center
			
			if vec_from_center.y > 0: continue

			var distance = vec_from_center.length()
			var angle_from_up = rad_to_deg(Vector2.UP.angle_to(vec_from_center))
			var alpha = 0.0

			if abs(angle_from_up) < cone_angle_degrees:
				var distance_fade = 1.0 - smoothstep(0, cone_length, distance)
				var side_fade = 1.0 - smoothstep(cone_angle_degrees * 0.7, cone_angle_degrees, abs(angle_from_up))
				var base_fade = smoothstep(0, 25.0, distance)
				alpha = distance_fade * side_fade * base_fade
				alpha *= 1.0 + (1.0 - (distance / cone_length)) * 0.5

			image.set_pixel(x, y, Color(1, 1, 0.9, clamp(alpha, 0.0, 1.0)))

	var texture = ImageTexture.create_from_image(image)
	point_light.texture = texture
	point_light.energy = 2.0
	point_light.shadow_enabled = true
	point_light.shadow_color = Color(0, 0, 0, 0.6)


func get_estado_nombre():
	match state:
		PlayerState.NORMAL: return "NORMAL"
		PlayerState.CON_LINTERNA: return "CON_LINTERNA"
		PlayerState.CON_MACHETE: return "CON_MACHETE"


# --- FUNCIONES PÚBLICAS PARA CAMBIAR EL ESTADO ---
func pickup_flashlight():
	state = PlayerState.CON_LINTERNA
	print("¡Linterna recogida!")

func reset_state():
	state = PlayerState.NORMAL
	print("Estado normal.")

# Puedes usar _input para pruebas rápidas
func _input(event):
	if event.is_action_pressed("ui_accept"):
		if state == PlayerState.NORMAL:
			pickup_flashlight()
		else:
			reset_state()
