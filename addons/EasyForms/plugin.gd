@tool
extends EditorPlugin

var tools:Control
func _enter_tree():
	tools = preload("res://addons/EasyForms/EditorUserInterface/EasyFormsDock.tscn").instantiate()
	add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, tools)
	pass


func _exit_tree():
	remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU, tools)
	tools.free()
	pass
