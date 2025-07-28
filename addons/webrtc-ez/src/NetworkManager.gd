extends Node


@export var players = {}
@export var single_player: bool:
	get():
		return players.size() == 1
@export var online := false

var default_colors = [
	"#FF0000", # Red
	"#008000", # Green
	"#0000FF", # Blue
	"#FFFF00", # Yellow
	"#00FFFF", # Cyan (Aqua)
	"#FF00FF", # Magenta (Fuchsia)
	"#C0C0C0", # Silver
	"#808080", # Gray
	"#800000", # Maroon
	"#808000", # Olive
	"#800080", # Purple
	"#008080", # Teal
	"#000080"  # Navy
]

func add_player(id: int, name: String, cpu_player: bool = false, start_pos: Vector3 = Vector3()):
	players[id] = {
		"id": id,
		"name": name,
		"ball_color": _get_random_color(),
		"start_pos": start_pos,
		"spawned": false,
		"cpu_player": cpu_player
	}
	update_players(players)
	
func _get_random_color() -> String:
	var default_colors_copy = Array(default_colors)
	var used_colors = []
	for player_id in players:
		used_colors.append(players[player_id].ball_color)
		
	for color in used_colors:
		default_colors_copy.erase(color)
		
	if default_colors_copy.is_empty():
		default_colors_copy = Array(default_colors)
		
	return default_colors_copy.pick_random()
	
func remove_player(id: int):
	players.erase(id)
	update_players(players)
	
@rpc("any_peer")
func update_player(id: int, players_update: Dictionary):
	if i_am_server():
		players[id].merge(players_update, true)
		update_player_remote.rpc(id, players[id])
	else:
		update_player.rpc_id(1, id, players_update)
	
@rpc("authority", "call_remote")
func update_player_remote(id: int, players_update: Dictionary):
	if !players.has(id):
		players[id] = {}
	players[id].merge(players_update, true)

func update_players(players: Dictionary):
	if multiplayer.has_multiplayer_peer():
		update_players_networked.rpc(players)

@rpc("authority", "call_remote")
func update_players_networked(players: Dictionary):
	self.players = players

func get_player_info(id: int):
	return self.players[id]

func i_am_server():
	return !online or multiplayer.is_server()

func get_multiplayer_id():
	return 1 if !online else multiplayer.get_unique_id()
