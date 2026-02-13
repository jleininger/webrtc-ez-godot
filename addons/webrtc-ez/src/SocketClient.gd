extends Node


enum MessageType {
	CONNECTED,
	JOIN_LOBBY,
	LEAVE_LOBBY,
	REMOVE_PLAYER,
	LOBBY_JOINED,
	LOBBY_LEFT,
	PEER_CONNECTED,
	PEER_DISCONNECTED,
	OFFER,
	ANSWER,
	CANDIDATE,
	ERROR,
	PING
}

var ws: WebSocketPeer = WebSocketPeer.new()
var id: int
var online:
	get():
		return ws.get_ready_state() == WebSocketPeer.STATE_OPEN

signal connected(id: int)
signal disconnected()
signal joined_lobby(id: int, use_mesh: bool, lobbyId: String)
signal left_lobby(lobby_id: String)
signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)
signal offer_received(id: int, offer: String)
signal answer_received(id: int, answer: String)
signal candidate_recieved(id: int, mid: String, index: int, sdp: String)
signal error(msg: String)

func connect_to_url(url: String) -> void:
	close()
	ws.connect_to_url(url)
	set_process(true)

func close():
	ws.close()

func _process(_delta):
	ws.poll()
	var state = ws.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while ws.get_available_packet_count():
			parse_message(ws.get_packet())
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = ws.get_close_code()
		var reason = ws.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		disconnected.emit()
		set_process(false) # Stop processing.

func parse_message(packet: PackedByteArray):
	var packet_data = JSON.parse_string(packet.get_string_from_utf8())
	var msg_type = str(packet_data["type"]).to_int()
	var id = str(packet_data["id"]).to_int()
	var data = packet_data["data"]

	if msg_type == MessageType.CONNECTED:
		connected.emit(id)
	elif msg_type == MessageType.LOBBY_JOINED:
		joined_lobby.emit(id, false, data)
	elif msg_type == MessageType.LOBBY_LEFT:
		left_lobby.emit(data)
	elif msg_type == MessageType.PEER_CONNECTED:
		peer_connected.emit(id)
	elif msg_type == MessageType.PEER_DISCONNECTED:
		peer_disconnected.emit(id)
	elif msg_type == MessageType.OFFER:
		offer_received.emit(id, data)
	elif msg_type == MessageType.ANSWER:
		answer_received.emit(id, data)
	elif msg_type == MessageType.CANDIDATE:
		var candidate: PackedStringArray = data.split("\n", false)
		candidate_recieved.emit(id, candidate[0], candidate[1].to_int(), candidate[2])
	elif msg_type == MessageType.ERROR:
		error.emit(data)

func send_message(type: int, id: int, data: String = ""):
	return ws.send_text(JSON.stringify({
		"type": type,
		"id": id,
		"data": data
	}))

func join_lobby(lobbyId: String) -> void:
	send_message(MessageType.JOIN_LOBBY, 0, lobbyId)

func leave_lobby():
	send_message(MessageType.LEAVE_LOBBY, 0)

func remove_from_lobby(lobby_id: String, player_id: int):
	send_message(MessageType.REMOVE_PLAYER, player_id, lobby_id)

func send_offer(id, offer):
	return send_message(MessageType.OFFER, id, offer)

func send_answer(id, answer):
	return send_message(MessageType.ANSWER, id, answer)

func send_candidate(id, mid, index, sdp):
	return send_message(MessageType.CANDIDATE, id, "\n%s\n%d\n%s" % [mid, index, sdp])

func send_ping():
	send_message(MessageType.PING, 0)
