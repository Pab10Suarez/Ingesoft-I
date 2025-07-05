extends Area2D

func _ready():
    body_entered.connect(_al_entrar_cuerpo)

func _al_entrar_cuerpo(body):
    if body.name == "Player" and body.has_method("recolectar_objeto"):
        body.recolectar_objeto("linterna")
        queue_free()