extends GraphNode

func _on_close_request():
	queue_free()

func save_data(node_list):
	node_list.push_back({
		"type": "script",
		"name": get_name(),
		"x": get_offset().x,
		"y": get_offset().y,
		"name": get_node("vbox/name").get_text()
	})

func load_data(data):
	get_node("vbox/name").set_text(data["name"])

func export_data(file, connections, labels):
	var next = ""
	var name = get_node("vbox/name").get_text().percent_encode()
	for c in connections:
		next = c["to"]
	labels[name] = next
