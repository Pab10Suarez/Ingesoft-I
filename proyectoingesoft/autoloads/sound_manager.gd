extends Node
func lerp_pitch(audio_stream : AudioStreamPlayer2D, origin : float, destination : float, time : float = 0) -> void:
	audio_stream.pitch_scale = lerpf(origin, destination, time)
	await get_tree().process_frame
	if time < 1:
		lerp_pitch(audio_stream, origin, destination, time + 0.2)

func get_voice_locutor() -> void:
	# Ésto devolverá el PATH del SFX de habla de cada personaje
	pass

# TODO encontrar valores que funcionen mejor
func get_pitch_for_vowel_locution(vowel : String) -> float:
	match vowel.to_lower():
		"y":
			return 3
		"i":
			return 3
		"e":
			return 2.5
		"a":
			return 2
		"o":
			return 1.5
		"u":
			return 1.0
		
	assert(false, "Error: SoundManager no recibió una vocal")
	return -1

# TODO Adecuar para ajustar tono a partir del mood y no con "¡" y "?"
func set_pitch_for_entonation_locution(entonation : String, stream_player : AudioStreamPlayer2D) -> void:
	match entonation:
		"¡":
			stream_player.volume_db += 5
		"?":
			stream_player.pitch_scale += 0.5
