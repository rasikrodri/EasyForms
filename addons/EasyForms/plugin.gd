@tool
extends EditorPlugin

var tools:Control
#var easyFormsService = preload("res://addons/EasyForms/Services/EasyFormsService.gd").new()
func _enter_tree():
	tools = preload("res://addons/EasyForms/EditorUserInterface/EasyFormsDock.tscn").instantiate()
	add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, tools)
	
	add_autoload_singleton("EasyFormsService", "res://addons/EasyForms/Services/EasyFormsService.gd")
	#Engine.register_singleton("EasyFormsService", easyFormsService)
	pass


func _exit_tree():
	remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU, tools)
	tools.free()
	
	remove_autoload_singleton("EasyFormsService")
	#Engine.unregister_singleton("EasyFormsService")
	pass
