extends Node
class_name MongoGet


@onready var json = JSON.new()

var api_url
var rc_result
var rc_response_code
var rc_headers
var rc_body
var rc_response

signal request_completed


func setup(new_api_url):
	api_url = new_api_url


func get_document(filter:Dictionary, api_key):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_request_completed)
	
	var url = api_url + "findOne"
	var headers = ["Content-Type: application/json", "Access-Control-Request-Headers: *", "api-key: " + api_key, "Accept: application/ejson"]
	var body = {
		"collection": "TempStorage",
		"database": "GodotServer",
		"dataSource": "Sheepy-Bot-Data",
		"filter": filter
		}
	
	http_request.request(url, headers, HTTPClient.METHOD_POST, json.stringify(body))
	
	await request_completed
	
	http_request.queue_free()
	return {
		"rc_result":rc_result,
		"rc_response_code":rc_response_code,
		"rc_headers":rc_headers,
		"rc_body":rc_body,
		"rc_response":rc_response
	}


func get_documents_in_collection(collection_name:String, api_key):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_request_completed)
	
	var url = api_url + "find"
	var headers = ["Content-Type: application/json", "Access-Control-Request-Headers: *", "api-key: " + api_key, "Accept: application/ejson"]
	var body = {
		"collection": collection_name,
		"database": "GodotServer",
		"dataSource": "Sheepy-Bot-Data",
		"filter": {}
		}
	
	http_request.request(url, headers, HTTPClient.METHOD_POST, json.stringify(body))
	
	await request_completed
	
	http_request.queue_free()
	return {
		"rc_result":rc_result,
		"rc_response_code":rc_response_code,
		"rc_headers":rc_headers,
		"rc_body":rc_body,
		"rc_response":rc_response
	}


func _on_request_completed(result, response_code, headers, body):
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	rc_result = result
	rc_response_code = response_code
	rc_headers = headers
	rc_body = body
	rc_response = response
	
	emit_signal("request_completed")
