extends "SocketClient.gd"

@export var server_url = 'ws://127.0.0.1:9080'

var rtc_mp: WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()

func _init():
	self.joined_lobby.connect(_joined_lobby)
	self.peer_connected.connect(_peer_connected)
	self.offer_received.connect(_offer_received)
	self.answer_received.connect(_answer_received)
	self.candidate_recieved.connect(_candidate_received)
	
func start(url: String = server_url, lobby: String = "", mesh: bool = true):
	stop()
	super.connect_to_url(url)
	
func stop():
	multiplayer.multiplayer_peer = null
	rtc_mp.close()
	
func full_stop():
	stop()
	super.close()

func _joined_lobby(id: int, use_mesh: bool, lobbyId: String):
	if use_mesh:
		rtc_mp.create_mesh(id)
	elif id == 1:
		rtc_mp.create_server()
	else:
		rtc_mp.create_client(id)
	multiplayer.multiplayer_peer = rtc_mp

func _peer_connected(peer_id: int):
	NetworkManager.single_player = false
	_create_peer(peer_id)
	
func _create_peer(id: int):
	var peer = WebRTCPeerConnection.new()
	peer.initialize({
		"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ]
	})
	peer.session_description_created.connect(_offer_created.bind(id))
	peer.ice_candidate_created.connect(_new_ice_candidate.bind(id))
	rtc_mp.add_peer(peer, id)
	if id < rtc_mp.get_unique_id():
		peer.create_offer()
	
func _offer_created(type, data, id):
	if not rtc_mp.has_peer(id):
		return
		
	rtc_mp.get_peer(id).connection.set_local_description(type, data)
	if type == "offer":
		self.send_offer(id, data)
	else:
		self.send_answer(id, data)

func _new_ice_candidate(mid_name, index_name, sdp_name, id):
	self.send_candidate(id, mid_name, index_name, sdp_name)

func _offer_received(id: int, offer: String):
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("offer", offer)

func _answer_received(id: int, answer: String):
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("answer", answer)
	
func _candidate_received(id: int, mid: String, index: int, sdp: String):
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.add_ice_candidate(mid, index, sdp)
