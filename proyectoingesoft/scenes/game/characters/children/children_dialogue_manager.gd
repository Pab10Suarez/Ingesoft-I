extends Node

var progreso : int = 0

@export_enum("Susana", "Guillermo") var character : String
const DEMO_DIALOGUES : String = "res://assets/dialogue/cast_dialogues.dialogue"

func _ready() -> void:
	if character == null:
		character = get_parent().name

func start_dialogue() -> void:
	if SaveManager.level != SaveManager.LEVELS.DEMO_GAMEPLAY:
		return
	
	match progreso:
		0:
			DialogueManager.show_dialogue_balloon(load(DEMO_DIALOGUES), character + "ApagaCarro")
			progreso += 1
			
