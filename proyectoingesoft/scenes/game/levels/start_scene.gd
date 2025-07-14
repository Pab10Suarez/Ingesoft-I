extends Node2D

func _on_button_pressed() -> void:
	SaveManager.load_save_game()


func _on_button_2_pressed() -> void:
	SaveManager.write_save_game()
	
	
