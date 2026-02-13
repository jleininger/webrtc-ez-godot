extends Node


var online: bool = false

func i_am_server():
	return !online or (multiplayer.multiplayer_peer and multiplayer.is_server())

func get_multiplayer_id() -> int:
	return 1 if !online else multiplayer.get_unique_id()
