extends GraphNode

var KEYWORD_COLOR = Color("ffffb3")
var STRING_COLOR = Color("ef6ebe")
var SYMBOL_COLOR = Color("badfff")

func _ready():
	var editor = get_node("vbox/code")
	editor.set_syntax_coloring(true)
	editor.add_keyword_color("if", KEYWORD_COLOR)
	editor.add_keyword_color("for", KEYWORD_COLOR)
	editor.add_keyword_color("var", KEYWORD_COLOR)
	editor.add_keyword_color("true", KEYWORD_COLOR)
	editor.add_keyword_color("false", KEYWORD_COLOR)
	editor.add_keyword_color("null", KEYWORD_COLOR)
	editor.add_color_region("\"", "\"", STRING_COLOR)
	editor.set_symbol_color(SYMBOL_COLOR)

func _on_close_request():
	queue_free()

func save_data(node_list):
	node_list.push_back({
		"type": "script",
		"name": get_name(),
		"x": get_offset().x,
		"y": get_offset().y,
		"code": get_node("vbox/code").get_text()
	})

func load_data(data):
	get_node("vbox/code").set_text(data["code"])

func export_data(file, connections, labels):
	file.store_line("func " + get_name() + "(c):")
	var code = get_node("vbox/code").get_text()
	if code == "":
		code = "\tpass"
	for l in code.split("\n"):
		file.store_line("\t" + l)
	for conn in connections:
		file.store_line("\t" + conn["to"] + "(c)")
