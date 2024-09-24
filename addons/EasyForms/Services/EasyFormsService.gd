@tool
extends Node

var _positioningService:= preload("res://addons/EasyForms/Services/EasyFormsPositioningService.gd").new()

var PreviewResolution:Vector2i = Vector2i(1280, 720)

var _process_start_time:float

var _speedTestSubscribedNodes:Array[Node] = []

func _ready():
	var viewport : Viewport = get_tree().root.get_viewport()
	
	#var callable = Callable(self, "ViewportSizeChangeDetected").bind([rowSceneTree])
	var callable = Callable(self, "ViewportSizeChangeDetected")
	viewport.connect("ready", callable)
	viewport.connect("size_changed", callable)
	#print(viewport)
	
	#get_tree().connect("tree_changed", Callable(self, "OnTreeChanged"))	
	#scene_changed.connect(self, "_on_scene_changed")
	pass
	
func SubscribeNodeToProcessTimeTaken(node:Node)->void:
	_speedTestSubscribedNodes.append(node)
	
func SetProcessStartTime()->void:
	_process_start_time = Time.get_ticks_usec()
	
func PrintProcessTotalTime()->void:
	var end_time = Time.get_ticks_usec()
	var execution_time = end_time - _process_start_time
	for node in _speedTestSubscribedNodes: node.UpdateMicroSecondsTaken(execution_time)
			
func GetViewportSize(viewport:Viewport)->Vector2:
	if Engine.is_editor_hint():
		return Vector2(1152, 648)#This is the sice of the subviewport on the editor
	else:
		return Vector2(viewport.size.x, viewport.size.y)
	pass
		
func ViewportSizeChangeDetected()->void:
	UpdateCurrentScene()
	pass
	
func UpdateCurrentScene()->void:
	SetProcessStartTime()
	
	var sceneTree:SceneTree = get_tree()
	var viewport : Viewport = get_tree().root.get_viewport()
	
	#var viewport:Viewport = sceneTree.root.get_viewport()
	
	#The user will have to make sure that the linked nodes
	#are updated before we update the EasyFormsLinks nodes
	#The user can accomplish this by placing the EasyFormsLinks at 
	#lower tree node of the scene or just at the bottom of the scene tree
	#So that everything before it gets updated
	_positioningService.UpdateEasyForms(sceneTree.root, GetViewportSize(viewport))
		
	PrintProcessTotalTime()
	pass
	
func  _process(delta: float) -> void:
	var sceneTree:SceneTree = get_tree()
	var viewport : Viewport = get_tree().root.get_viewport()
	_positioningService.UpdateEasyFormsLinks(sceneTree.root, GetViewportSize(viewport))
	pass
		
