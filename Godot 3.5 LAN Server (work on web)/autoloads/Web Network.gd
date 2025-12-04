extends Node


var server = WebSocketServer.new()
var client = WebSocketClient.new()

var is_host = false


func create_server():
	var result = server.listen(12345, PoolStringArray(), true);
	
	if result == OK:
		is_host = true
		server.connect("peer_connected", self, "_on_peer_connected")
		server.connect("peer_disconnected", self, "_on_peer_disconnected")
		get_tree().set_network_peer(server);
		print("Server Created")
	else:
		print("Can't Create Server")
	
	return result


func _process(delta):
	if is_host:
		if server.is_listening():
			server.poll()
	else:
		if (client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED || client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING):
			client.poll();


func _on_peer_connected(id):
	print("Peer connected: ", id)


func _on_peer_disconnected(id):
	print("Peer disconnected: ", id)


func connect_to_server(address):
	var url = "ws://127.0.0.1:" + str(12345) # You use "ws://" at the beginning of the address for WebSocket connections
	var result = client.connect_to_url(url, PoolStringArray(), true);
	
	if result == OK:
		client.connect("connection_succeeded", self, "_on_connection_succeeded")
		client.connect("connection_failed", self, "_on_connection_failed")
		get_tree().set_network_peer(client);
		print("Client connected")
	else:
		print("Can't create client")
	
	return result


func _on_connection_succeeded():
	print("Connected to server")


func _on_connection_failed():
	print("Failed to connect to server")
