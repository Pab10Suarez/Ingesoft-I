extends Area2D

@export var item_type: String = "machete"

func _on_body_entered(body):
	if body is CharacterBody2D:
		if item_type == "machete":
			body.state = body.PlayerState.CON_MACHETE
			print("Machete recogido, nuevo estado:", body.state)
		queue_free()
