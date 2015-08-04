extends GraphNode

func _ready():
	pass

func _on_close_request():
	queue_free()

func save_data(node_list):
	node_list.push_back({
		"type": "option",
		"name": get_name(),
		"x": get_offset().x,
		"y": get_offset().y,
		"title": get_node("vbox/title").get_text(),
		"condition": get_node("vbox/condition").get_text()
	})

func load_data(data):
	get_node("vbox/title").set_text(data["title"])
	get_node("vbox/condition").set_text(data["condition"])

func export_data(file, connections, labels):
	file.store_line("func " + get_name() + "(c):")
	var title = get_node("vbox/title").get_text().percent_encode()
	var condition = get_node("vbox/condition").get_text()
	var next = ""
	for conn in connections:
		next = conn["to"]
	if condition != "":
		file.store_line("\tif " + condition + ":")
		file.store_string("\t")
	file.store_line("\tadd_option(\"" + title + "\".percent_decode(), \"" + next + "\")")
