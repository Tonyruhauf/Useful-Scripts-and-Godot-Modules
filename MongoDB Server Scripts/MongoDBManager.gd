extends Node
class_name MongoDBManager


@onready var json = JSON.new()

const API_KEY = ""
# CONSIDER USING SECURE FILE TO STORE API KEY !!!

var api_url = "https://us-east-2.aws.data.mongodb-api.com/app/data-czsvf/endpoint/data/v1/action/"  # Replace with your API URL


func get_document(filter:Dictionary):
	var mongo_get = MongoGet.new()
	add_child(mongo_get)
	mongo_get.setup(api_url)
	
	var request_complete = await mongo_get.get_document(filter, API_KEY)
	mongo_get.queue_free()
	
	if request_complete.rc_response_code == 200:
		assert(request_complete.rc_response.document != null, "document with filter '" + str(filter) + "' does not exist")
		
		return request_complete.rc_response.document
	else:
		return null


func get_documents_in_collection(collection_name:String):
	var mongo_get = MongoGet.new()
	add_child(mongo_get)
	mongo_get.setup(api_url)
	
	var request_complete = await mongo_get.get_documents_in_collection(collection_name, API_KEY)
	mongo_get.queue_free()
	
	if request_complete.rc_response_code == 200:
		return request_complete.rc_response
	else:
		return null


func get_data_on_document(filter:Dictionary, data_name):
	var mongo_get = MongoGet.new()
	add_child(mongo_get)
	mongo_get.setup(api_url)
	
	var request_complete = await mongo_get.get_document(filter, API_KEY)
	mongo_get.queue_free()
	
	if request_complete.rc_response_code == 200:
		assert(request_complete.rc_response.document != null, "document with filter '" + str(filter) + "' does not exist")
		assert(request_complete.rc_response.document.has(data_name), "data '" + data_name + "' does not exist")
		assert(str_to_var(request_complete.rc_response.document[data_name]) != null, "could't find value type of " + data_name)
		
		return str_to_var(request_complete.rc_response.document[data_name])
	else:
		return null


func set_data_on_document(filter:Dictionary, data_name, new_value):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_request_completed)
	
	var url = api_url + "updateOne"
	var headers = ["Content-Type: application/json", "Access-Control-Request-Headers: *", "api-key: " + API_KEY, "Accept: application/ejson"]
	var update
	
	if new_value is String:
		update = {"$set":{data_name:new_value}}
	else:
		update = {"$set":{data_name:var_to_str(new_value)}}
	
	var body = {
		"collection": "TempStorage",
		"database": "GodotServer",
		"dataSource": "Sheepy-Bot-Data",
		"filter": filter,
		"update": update
		}
	
	if new_value is Color:
		body.update["$set"][data_name] = "Color" + var_to_str(new_value)
	
	http_request.request(url, headers, HTTPClient.METHOD_POST, json.stringify(body))
	
	await http_request.request_completed
	
	http_request.queue_free()


func create_document(document_data:Dictionary):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_request_completed)
	
	var url = api_url + "insertOne"
	var headers = ["Content-Type: application/json", "Access-Control-Request-Headers: *", "api-key: " + API_KEY, "Accept: application/ejson"]
	
	for key in document_data.keys():
		var value = document_data[key]
		
		if not value is String:
			document_data[key] = var_to_str(value)
	
	var body = {
		"collection": "TempStorage",
		"database": "GodotServer",
		"dataSource": "Sheepy-Bot-Data",
		"document": document_data
		}
	
	http_request.request(url, headers, HTTPClient.METHOD_POST, json.stringify(body))
	
	await http_request.request_completed
	
	http_request.queue_free()


func delete_document(filter:Dictionary):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_request_completed)
	
	var url = api_url + "deleteOne"
	var headers = ["Content-Type: application/json", "Access-Control-Request-Headers: *", "api-key: " + API_KEY, "Accept: application/ejson"]
	var body = {
		"collection": "TempStorage",
		"database": "GodotServer",
		"dataSource": "Sheepy-Bot-Data",
		"filter": filter
		}
	
	http_request.request(url, headers, HTTPClient.METHOD_POST, json.stringify(body))
	
	await http_request.request_completed
	
	http_request.queue_free()


func document_exist(filter:Dictionary):
	var mongo_get = MongoGet.new()
	add_child(mongo_get)
	mongo_get.setup(api_url)
	
	var request_complete = await mongo_get.get_document(filter, API_KEY)
	mongo_get.queue_free()
	
	assert(request_complete.rc_response_code == 200, "request error")
	
	return request_complete.rc_response.document != null


func _on_request_completed(result, response_code, headers, body):
	pass
#	json.parse(body.get_string_from_utf8())
#	var response = json.get_data()
#
#	print(response)
