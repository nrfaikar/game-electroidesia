extends Node

var current_scene = null

# Current game data
var data
var is_interrupted = false
var _story_path = "game/stories/stories.dat"
var _levelup_path = "game/characters/level_up.dat"

# References
var initial_data = {
	# TODO: handle multiple player character
	player = {
		name = "Player",
		character = "res://game/characters/player/naru/Naru.tscn",
		position = [0, 0, 0],
		rotation = [0, 0, 0],
		statistics = {
			level = 1,
			hit_point = 0,
			mana_point = 0,
			experience_point = 0
		}
	},
	map = "res://game/maps/initial_map/InitialMap.tscn",
	story = 1,
	gold = 0
}
var opposite_direction = {
	"North" : "South",
	"South" : "North",
	"East"  : "West",
	"West"  : "East"
}
var stories_reference
var levelups_reference

func _ready() -> void:
	var root = get_node("/root")
	current_scene = root.get_child(root.get_child_count() -1)
	
	# Load level_up.dat file
	var f = File.new()
	f.open(_levelup_path, File.READ)
	levelups_reference = parse_json(f.get_as_text())
	f.close()
	
	# Load stories.dat file
	f = File.new()
	f.open(_story_path, File.READ)
	stories_reference = parse_json(f.get_as_text())
	f.close()

func start_game(create_new: bool) -> void:
	if create_new:
		# Reset player current data
		data = initial_data.duplicate()
		
		# Go to main character selection scene
		goto_scene("res://gui/screens/select_main_character/SelectMainCharacter.tscn")
	else:
		# Load saved data
		# TODO: add save function
		
		# Start game
		goto_scene("res://game/Adventure.tscn")

func goto_map(scene_path: String, enter_direction: String) -> void:
	var adventure_node = get_node("/root/Adventure")
	
	# Change map scene
	var previous_scene_path = data["map"]
	data["map"] = scene_path
	adventure_node.reload_map()
	
	# Reset player position
	#----- Find match spawn point
	var entrances_node = adventure_node.get_node("Map").get_child(0).get_node("Entrances")
	var spawn_position
	for entrance in entrances_node.get_children():
		if entrance.go_to_scene == previous_scene_path and opposite_direction[entrance.enter_direction] == enter_direction:
			spawn_position = entrance.get_spawn_position()
			break
	#----- Change player position to spawn_position
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		player.global_transform.origin = spawn_position

func goto_scene(path: String) -> void:
	var loader = ResourceLoader.load_interactive(path)
	
	current_scene.queue_free()
	
	var time_max = 100 # msec
	while OS.get_ticks_msec() < OS.get_ticks_msec() + time_max:
		var err = loader.poll()
		if err == ERR_FILE_EOF: # load finished
			current_scene = loader.get_resource().instance()
			get_node("/root").call_deferred("add_child", current_scene)
			loader = null
			break
		elif err == OK:
			continue
		else: # error during loading
			loader = null
			break

func tell_story():
	get_node("/root/Adventure/HUD").show_dialogues(stories_reference[str(data["story"])])
	data["story"] += 1

func syncro_names():
	stories_reference = parse_json(to_json(stories_reference).replace("Naru", data["player"]["name"]))

func set_player_name(name) -> void:
	data["player"]["name"] = name
	syncro_names()

func get_player_character() -> String:
	return data["player"]["character"]

func set_player_character(character) -> void:
	data["player"]["character"] = character

func get_map() -> String:
	return data["map"]