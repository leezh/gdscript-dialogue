extends Control

var editor
var current = null
var hscroll
var vscroll

func _ready():
	OS.set_low_processor_usage_mode(true)
	editor = get_node("editor")
	editor.set_right_disconnects(true)
	# TODO: Find a more elegant way to do this
	for c in editor.get_children():
		if not c extends GraphNode:
			hscroll = c.get_node("_h_scroll")
			vscroll = c.get_node("_v_scroll")
	var save = get_node("save")
	save.set_access(save.ACCESS_FILESYSTEM)
	save.set_mode(save.MODE_SAVE_FILE)
	save.add_filter("*.json;JavaScript Object Notation")
	var open = get_node("open")
	open.set_access(open.ACCESS_FILESYSTEM)
	open.set_mode(open.MODE_OPEN_FILE)
	open.add_filter("*.json;JavaScript Object Notation")
	var exprt = get_node("export")
	exprt.set_access(exprt.ACCESS_FILESYSTEM)
	exprt.set_mode(exprt.MODE_SAVE_FILE)
	exprt.add_filter("*.gd;Godot Script")
	var file_menu = get_node("panel/toolbar/file").get_popup()
	file_menu.connect("item_pressed", self, "_on_menu_item")
	file_menu.add_item("Open")
	file_menu.add_item("Save")
	file_menu.add_item("Save As")
	file_menu.add_item("Export")
	file_menu.add_separator()
	file_menu.add_item("Quit")
	add_node("label").get_node("vbox/name").set_text("start")

func _on_menu_item(id):
	if id == 0:
		get_node("open").popup()
	elif id == 1:
		if current == null:
			get_node("save").popup()
		else:
			save_data(current)
	elif id == 2:
		get_node("save").popup()
	elif id == 3:
		get_node("export").popup()
	elif id == 4:
		get_tree().quit()

func _on_connection_request(from, from_slot, to, to_slot):
	var from_node = editor.get_node(from)
	if from_node.get_slot_type_right(from_slot) == 0:
		for x in editor.get_connection_list():
			if x["from"] == from and x["from_port"] == from_slot:
				editor.disconnect_node(from, from_slot, x["to"], x["to_port"])
	editor.connect_node(from, from_slot, to, to_slot)

func _on_disconnection_request(from, from_slot, to, to_slot):
	editor.disconnect_node(from, from_slot, to, to_slot)

func add_node(type):
	var node = load("res://nodes/" + type + ".scn").instance()
	var offset = Vector2(hscroll.get_val(), vscroll.get_val())
	var i = 1
	while editor.get_node("node" + str(i)) != null:
		i += 1
	node.set_name("node" + str(i))
	editor.add_child(node)
	node.set_offset(offset + (editor.get_size() - node.get_size()) / 2)
	return node

func save_data(path):
	var node_list = []
	for c in editor.get_children():
		if c extends GraphNode:
			c.save_data(node_list)
	var data = {
		"nodes": node_list,
		"connections": editor.get_connection_list()
	}
	var file = File.new()
	file.open(path, file.WRITE)
	file.store_string(data.to_json())
	file.close()

func load_data(path):
	var file = File.new()
	file.open(path, file.READ)
	if not file.is_open():
		return
	for c in editor.get_children():
		if c extends GraphNode:
			c.free()
	var data = {}
	data.parse_json(file.get_as_text())
	file.close()
	for x in data["nodes"]:
		var node = load("res://nodes/" + x["type"] + ".scn").instance()
		node.set_name(x["name"])
		node.load_data(x)
		editor.add_child(node)
		node.set_offset(Vector2(x["x"], x["y"]))
	for x in data["connections"]:
		editor.connect_node(x["from"], x["from_port"], x["to"], x["to_port"])

func export_data(path):
	var labels = {}
	var file = File.new()
	file.open(path, file.WRITE)
	file.store_line("var data = {}")
	for node in editor.get_children():
		if node extends GraphNode:
			var connections = []
			for conn in editor.get_connection_list():
				if node.get_name() == conn["from"]:
					connections.push_back(conn)
			node.export_data(file, connections, labels)
	var first_label = true
	file.store_line("var labels = {")
	for l in labels:
		if not first_label:
			file.store_line(",")
		file.store_string("\t\"" + l + "\".percent_decode(): \"" + labels[l] + "\"")
		first_label = false
	file.store_line("")
	file.store_line("}")
