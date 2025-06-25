# extends Node

# Este script está pensado para guardar y cargar el progreso del jugador usando Firebase Firestore.
# Por ahora está completamente comentado para que no se ejecute hasta que se integre oficialmente.

# const PLAYER_ID := "jugador_test"  # ID estático. En el futuro se puede usar Firebase Auth.
# const PLAYER_NODE_PATH := "/root/Player"  # Ruta del nodo Player dentro de la escena

# func _ready() -> void:
#     # Conectar señal para recibir datos desde Firebase
#     var firestore = Firebase.Firestore.get_singleton()
#     firestore.connect("document_received", self, "_on_document_received")

# func guardar_progreso(posicion: Vector2, puntaje: int, nivel: int) -> void:
#     # Guarda el estado del jugador en Firestore
#     var firestore = Firebase.Firestore.get_singleton()
#     var datos := {
#         "position": {"x": posicion.x, "y": posicion.y},
#         "score": puntaje,
#         "level": nivel
#     }
#     firestore.set_document("players", PLAYER_ID, datos)
#     print("➡ Progreso guardado en Firebase:", datos)

# func cargar_progreso() -> void:
#     # Solicita los datos del jugador desde Firestore
#     var firestore = Firebase.Firestore.get_singleton()
#     firestore.get_document("players", PLAYER_ID)
#     print("⬅ Solicitando progreso para:", PLAYER_ID)

# func _on_document_received(coleccion: String, documento: String, datos: Dictionary) -> void:
#     # Lógica para aplicar los datos al jugador cuando se reciben desde Firebase
#     if coleccion != "players" or documento != PLAYER_ID:
#         return

#     print("✅ Progreso recibido:", datos)

#     var jugador = get_node_or_null(PLAYER_NODE_PATH)
#     if jugador == null:
#         push_error("⚠ No se encontró el nodo 'Player'")
#         return

#     if datos.has("position"):
#         var pos = datos["position"]
#         jugador.global_position = Vector2(pos.get("x", 0), pos.get("y", 0))

#     jugador.player_score = datos.get("score", 0)
#     jugador.nivel_actual = datos.get("level", 1)
