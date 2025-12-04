extends Node2D





func _on_HostButton_pressed():
	var result = WebNetwork.create_server()
	
	if result == OK:
		$HostButton.hide()
		$JoinButton.hide()
		$Test.sync_to_server()


func _on_JoinButton_pressed():
	var ip = get_ip()
	var result = WebNetwork.connect_to_server(ip)
	
	if result == OK:
		$HostButton.hide()
		$JoinButton.hide()
		$Test.sync_to_server()


func get_ip():
	var ip_address
	
	if OS.get_name() == "Windows":
		ip_address = IP.get_local_addresses()[3]
	elif OS.get_name() == "Android":
		ip_address = IP.get_local_addresses()[0]
	else:
		ip_address = IP.get_local_addresses()[3]
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") and not ip.ends_with(".1"):
			ip_address = ip
	
	return ip_address
