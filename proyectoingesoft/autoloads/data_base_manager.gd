extends Node

# URL de la API de PostgREST
# Esta es la URL donde se realiza la solicitud para insertar datos
# var api_url = "https://postgrest-api-87ek.onrender.com"

# Creamos un nodo HTTPRequest para realizar la solicitud HTTP
# var request = HTTPRequest.new()

# func _ready():
	# Añadimos el nodo HTTPRequest como hijo del nodo actual
	# add_child(request)
	
	# Crear los datos del jugador a insertar
	# var jugador_data = {
		# "jugador_nombre": "Juan Pérez",  # Nombre del jugador
		# "feedback": "Buen rendimiento",  # Feedback sobre el rendimiento del jugador
		# "plataforma": "PC",  # Plataforma desde donde juega el jugador
		# "idioma_sistema": "Español",  # Idioma del sistema del jugador
		# "progresion_fk": 1,  # Asumimos que hay una progresión con ID 1
		# "ultima_sesion": 1   # Asumimos que hay una sesión con ID 1
	# }

	# Convertimos los datos a formato JSON para poder enviarlos
	# var json_data = JSON.stringify(jugador_data)
	
	# Verificamos si la conversión a JSON fue exitosa
	# if json_data == "":
		# print("Error: Los datos no se pudieron convertir a JSON.")
		# return
	
	# Cabeceras HTTP que indican que estamos enviando datos en formato JSON
	# var headers = ["Content-Type: application/json"]

	# Conectar el evento de finalización de la solicitud HTTP
	# request.connect("request_completed", Callable(self, "_on_request_completed"))
	
	# Realizamos la solicitud POST para insertar el jugador
	# var error = request.request(api_url + "/Jugador", headers, HTTPClient.METHOD_POST, json_data)  # Usamos HTTPClient.METHOD_POST
	
	# Verificamos si ocurrió un error al realizar la solicitud
	# if error != OK:
		# print("Error al realizar la solicitud HTTP.")
		# return

# Este es el método que se ejecuta cuando la solicitud HTTP se completa
# Recibe la respuesta de la solicitud: código de respuesta, cabeceras y cuerpo
# func _on_request_completed(_result, _response_code, _headers, _body):
	# Imprimir el código de respuesta para entender si fue exitoso o no
	# print("Código de respuesta: ", _response_code)
	
	# Si la solicitud fue exitosa (código 201), mostramos un mensaje de éxito
	# if _response_code == 201:
		# print("Jugador insertado exitosamente!")
	# else:
		# Si no fue exitoso, mostramos el código de respuesta y el cuerpo de la respuesta
		# print("Error al insertar el jugador. Código de respuesta: ", _response_code)
		# Convertimos el cuerpo de la respuesta de bytes a texto para que sea legible
		# print("Cuerpo de la respuesta: ", _body.get_string_from_utf8())

#     jugador.nivel_actual = datos.get("level", 1)
