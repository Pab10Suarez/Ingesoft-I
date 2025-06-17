extends Node

func get_voice_locutor() -> void:
	# Ésto devolverá el PATH del SFX de habla de cada personaje
	pass

# TODO encontrar valores que funcionen mejor
func get_pitch_for_vowel_locution(vowel : String) -> float:
	match vowel.to_lower():
		"y":
			return 2.5
		"i":
			return 2.5
		"e":
			return 2
		"a":
			return 1.5
		"o":
			return 1
		"u":
			return 0.5
		
	assert(false, "Error: SoundManager no recibió una vocal")
	return -1

# TODO terminar la detección de entonación
func set_pitch_for_entonation_locution(entonation : String, stream_player : AudioStreamPlayer2D) -> void:
	match entonation:
		"!":
			stream_player.volume_db += 1
