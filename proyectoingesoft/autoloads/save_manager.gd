extends Node

const SAVE_GAME_PATH : String = "user://save.cfg"	# TODO verificar como hacer que este path quede junto al ejecutable al compilar
const PERSISTENT_NODES_REFERENCE : String = "Persist"
enum LEVELS {
	DEMO_INTRO,
	DEMO_GAMEPLAY,
	DEMO_ENDING
}
const LEVELS_PATH_DICTIONARY : Dictionary[int, String] = {	# TODO probar cómo funciona la carga de niveles acá
	LEVELS.DEMO_INTRO : "res://scenes/game/levels/intro.tscn",
	LEVELS.DEMO_GAMEPLAY : "res://scenes/game/levels/level_one.tscn",
	LEVELS.DEMO_ENDING : ""
}

@export var version := 1

@export var character : Resource
@export var susana : Resource
@export var guillermo : Resource

@export var level := LEVELS.DEMO_GAMEPLAY			## TODO: poner 
@export var death_counter : int = 0

func _ready() -> void:
	add_to_group(PERSISTENT_NODES_REFERENCE)
		
#region Save-Load

func write_save_game() -> void: 
	var config : ConfigFile = ConfigFile.new()
	var nodes : Array[Node] = get_tree().get_nodes_in_group(PERSISTENT_NODES_REFERENCE)
	
	for node in nodes:
		print(node.name, " se guarda")
		node.save_in(config)
	
	var err : Error = config.save(SAVE_GAME_PATH)
	if err != OK:
		print("Error guardando!: ", error_string(err))
	else:
		print("Juego guardado en ", OS.get_data_dir())
		
func load_save_game() -> void:
	var config = ConfigFile.new()

	var err = config.load(SAVE_GAME_PATH)

	if err != OK:
		print("Error leyendo archivo de guardado: ", error_string(err))
		return
	
	var nodes : Array[Node] = get_tree().get_nodes_in_group(PERSISTENT_NODES_REFERENCE)
	for node in nodes:
		node.load_from(config)
		
	print("Juego cargado")

#endregion

#region Funciones de persistencia
func save_in(config_f : ConfigFile) -> void:
	config_f.set_value(name, "level", level)
	config_f.set_value(name, "death_counter", death_counter)
	
func load_from(config_f : ConfigFile) -> void:
	level = config_f.get_value(name, "level")
	death_counter = config_f.get_value(name, "death_counter")
	_load_appropiate_scene()

func _load_appropiate_scene() -> void:
	ResourceLoader.load_threaded_request(LEVELS_PATH_DICTIONARY[level])
	while ResourceLoader.load_threaded_get_status(LEVELS_PATH_DICTIONARY[level]) != ResourceLoader.THREAD_LOAD_LOADED:
		await get_tree().process_frame
	
	var level_to_load : Resource = ResourceLoader.load_threaded_get(LEVELS_PATH_DICTIONARY[level])
	get_tree().change_scene_to_packed(level_to_load)
	

	
#endregion
