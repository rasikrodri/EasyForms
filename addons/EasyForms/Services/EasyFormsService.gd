@tool
extends Node

var _positioningService:= preload("res://addons/EasyForms/Services/EasyFormsPositioningService.gd").new()

var PreviewResolution:Vector2i = Vector2i(1280, 720)

var _process_start_time:float

var _speedTestSubscribedNodes:Array[Node] = []

func _ready():
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
		

func ConnectSignals(rowNode:EasyFormsRow)->void:
	var viewport = rowNode.get_viewport()
	var rowSceneTree:SceneTree = rowNode.get_tree()
	var callable = Callable(self, "ViewportReadyDetected").bind([rowSceneTree])
	
	if viewport.is_connected("size_changed", callable): return
	
	viewport.connect("size_changed", callable)
	viewport.connect("ready", callable)
	
	##rowSceneTree.root.get_child(0).connect("ready", Callable(self, "rrr"))
	##rowSceneTree.root.connect("child_exiting_tree", Callable(self, "ChildExitingTree").bind([viewport, rowSceneTree]))
	
	##_sceneRows[rowSceneTree].append(rowSceneTree)
	#
	##Subscribe to scene events 
	##self.connect("child_entered_tree", Callable(self, "ChagedDetectedChildNodeAdded"))
	#
	pass
	
func GetViewport(viewport:Viewport)->Vector2:
	if Engine.is_editor_hint():
		return Vector2(1152, 648)#This is the sice of the subviewport on the editor
	else:
		return Vector2(viewport.size.x, viewport.size.y)
	pass
	
func ViewportReadyDetected(arguments:Array)->void:
	SetProcessStartTime()
	
	_positioningService.UpdateAllInScene(
		arguments[0],
		GetViewport(arguments[0].root.get_viewport())
	)
	
	PrintProcessTotalTime()
	pass
	
func ViewportSizeChangeDetected(arguments:Array)->void:
	SetProcessStartTime()
	
	_positioningService.UpdateAllInScene(
		arguments[0],
		GetViewport(arguments[0].root.get_viewport())
	)
	
	PrintProcessTotalTime()
	pass
	
func ChildExitingTree(child, viewport:Viewport, rowSceneTree:SceneTree)->void:
	_positioningService.UpdateAllInScene(
		rowSceneTree,
		GetViewport(rowSceneTree.root.get_viewport())
	)
	pass
	
func UpdateRowScene(rowNode:EasyFormsRow)->void:	
	_positioningService.UpdateAllInScene(
		rowNode.get_tree(),
		GetViewport(rowNode.get_viewport())
	)
	pass
	
func UpdateCurrentScene(sceneTree:SceneTree)->void:
	SetProcessStartTime()
	
	_positioningService.UpdateAllInScene(
		sceneTree,
		GetViewport(sceneTree.root.get_viewport())
	)
	
	PrintProcessTotalTime()
	pass
		
