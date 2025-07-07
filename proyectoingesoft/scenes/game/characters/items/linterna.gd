extends Area2D

@export var item_type: String = "linterna"

func _on_body_entered(body):
	if body is CharacterBody2D:
		if item_type == "linterna":
			body.state = body.PlayerState.CON_LINTERNA
			print("Linterna recogida, nuevo estado:", body.state)
		queue_free()
