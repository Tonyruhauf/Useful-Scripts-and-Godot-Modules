extends Node


var network = NetworkedMultiplayerENet.new()
var is_host = false


func create_server():
	var result = network.create_server(12345, 10)  # Start a server on port 12345 with up to 10 clients
	
	if result == OK:
		is_host = true
		network.connect("peer_connected", self, "_on_peer_connected")
		network.connect("peer_disconnected", self, "_on_peer_disconnected")
		get_tree().network_peer = network
		print("Server Created")
	else:
		print("Can't Create Server")
	
	return result


func _on_peer_connected(id):
	print("Peer connected: ", id)


func _on_peer_disconnected(id):
	print("Peer disconnected: ", id)


func connect_to_server(address):
	var result = network.create_client(address, 12345)
	
	if result == OK:
		network.connect("connection_succeeded", self, "_on_connection_succeeded")
		network.connect("connection_failed", self, "_on_connection_failed")
		get_tree().network_peer = network
		print("Client connected")
	else:
		print("Can't create client")
	
	return result


func _on_connection_succeeded():
	print("Connected to server")


func _on_connection_failed():
	print("Failed to connect to server")
