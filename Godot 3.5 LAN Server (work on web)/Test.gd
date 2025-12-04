extends Node2D


var id = -1


func sync_to_server():
	id = get_tree().get_network_unique_id()
	set_network_master(id)
	rpc_config("sync_position", MultiplayerAPI.RPC_MODE_REMOTESYNC)


func _process(delta):
	if id != -1:
		if WebNetwork.is_host:
			global_position = get_global_mouse_position()
			rpc("sync_position", global_position)


remote func sync_position(new_position):
	global_position = new_position
