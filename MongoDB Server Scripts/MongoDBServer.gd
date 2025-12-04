extends Node
class_name MongoDBServer

@onready var mongodb_manager = MongoDBManager.new()

var default_parameters = {
	"can_die": true,
	"inactive_time_until_death": 3600
}
var lastKnownData = null
var current_server_id = "0"

signal mongodb_server_ready
signal data_changed


func _ready():
	add_child(mongodb_manager)
	
	await delete_dead_servers()
	await check_for_data_updates()
	emit_signal("mongodb_server_ready")


func delete_server(server_id:String):
	await mongodb_manager.delete_document({"server_id":server_id})
	
	if current_server_id == server_id: current_server_id = "0"


func create_server(server_name:String, custom_data = {}, server_parameters = default_parameters):
	var server_id = await generate_new_ID()
	var server_data = {
		"document_name":server_name,
		"server_id":server_id,
		"server_parameters":server_parameters,
		"last_interaction":Time.get_datetime_string_from_system(true)
	}
	server_data.merge(custom_data)
	
	await mongodb_manager.create_document(server_data)
	
	current_server_id = server_id
	return server_id


func set_data_on_server(server_id:String, data_name, new_value):
	on_interaction_with_server(server_id)
	
	await mongodb_manager.set_data_on_document({"server_id":server_id}, data_name, new_value)


func get_data_on_server(server_id:String, data_name):
	on_interaction_with_server(server_id)
	
	return await mongodb_manager.get_data_on_document({"server_id":server_id}, data_name)


func server_exist(server_id):
	return await mongodb_manager.document_exist({"server_id":server_id})


func check_for_data_updates():
	var mongo_get = MongoGet.new()
	add_child(mongo_get)
	mongo_get.setup(mongodb_manager.api_url)
	
	if current_server_id != "0":
		var request_complete = await mongo_get.get_document({"server_id":current_server_id}, mongodb_manager.API_KEY)
		
		if request_complete.rc_response_code == 200:
			var new_data = request_complete.rc_response.document
			
			if new_data != lastKnownData:
				lastKnownData = new_data
				
				emit_signal("data_changed", new_data)
			
			check_for_data_updates()
		else:
			print("Error: HTTP Status Code " + str(request_complete.rc_response_code))
			
			await get_tree().create_timer(5).timeout
			
			check_for_data_updates()
	else:
		await get_tree().create_timer(5).timeout
		
		check_for_data_updates()


func delete_dead_servers():
	var servers_list = await mongodb_manager.get_documents_in_collection("TempStorage")
	
	if not servers_list.documents.is_empty():
		for server in servers_list.documents:
			var server_parameters = str_to_var(server.server_parameters)
			
			if server_parameters.can_die:
				var last_interaction = Time.get_unix_time_from_datetime_string(server.last_interaction)
				var current_time = Time.get_unix_time_from_datetime_string(Time.get_datetime_string_from_system(true))
				var elapsed_time_since_last_interaction = current_time - last_interaction
				
				if elapsed_time_since_last_interaction >= server_parameters.inactive_time_until_death:
					await delete_server(server.server_id)


func generate_new_ID():
	var ID = randi_range(1, 9999)
	
	while await server_exist(ID):
		ID = randi_range(1, 9999)
	
	return str(ID)


func on_interaction_with_server(server_id:String):
	var mongodb_manager_2 = MongoDBManager.new()
	add_child(mongodb_manager_2)
	
	await mongodb_manager_2.set_data_on_document({"server_id":server_id}, "last_interaction", Time.get_datetime_string_from_system(true))
	
	mongodb_manager_2.queue_free()


func connect_to_server(server_id:String):
	print("Connected to server: " + server_id)
	current_server_id = server_id
