extends GraphNode

func _ready():
	get_node("vbox/text").set_wrap(true)

func _on_close_request():
	queue_free()

func save_data(node_list):
	node_list.push_back({
		"type": "text",
		"name": get_name(),
		"x": get_offset().x,
		"y": get_offset().y,
		"text": get_node("vbox/text").get_text()
	})

func load_data(data):
	get_node("vbox/text").set_text(data["text"])

func export_data(file, connections, labels):
	file.store_line("func " + get_name() + "(c):")
	var text = get_node("vbox/text").get_text().percent_encode()
	file.store_line("\tadd_message(\"" + text + "\".percent_decode())")
	for conn in connections:
		file.store_line("\t" + conn["to"] + "(c)")
