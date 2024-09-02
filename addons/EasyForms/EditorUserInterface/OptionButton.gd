@tool
extends OptionButton

var _scenesSelectedSceneSettings:Dictionary = {}

var _lastSceneName:String
var _causeUpdate:bool = true

var loaded:bool
func _ready():
	loaded = true
	
	EditorInterface.get_selection().connect("selection_changed",  Callable(self, "SelectionChanged").bind())
	pass

#In here it explains how to connect to scene
#https://forum.godotengine.org/t/editor-plugin-scene-change/52895/4

func SelectionChanged()->void:
	#Make sure that it is the active scene that changed not the nodes selection in current active scene
	var editedScene:Node = EditorInterface.get_edited_scene_root()
	if editedScene.name == _lastSceneName: return
	
	
	_lastSceneName = editedScene.name
	if not _lastSceneName in _scenesSelectedSceneSettings:
		_scenesSelectedSceneSettings[_lastSceneName] = EasyFormsService.PreviewResolution
	
	
	_causeUpdate = false
	var index = GetIdexOfItem(_scenesSelectedSceneSettings[editedScene.name])
	select(index)
	_causeUpdate = true
	pass
	
func GetIdexOfItem(resolution:Vector2i)->int:
	for i in range(item_count):
		var item:Vector2i = GetResolutionFromSelectedItem(i)
		if item.x == resolution.x and item.y == resolution.y:
			return i
	
	return 0
	pass

func _on_item_selected(index:int)->void:
	if not loaded or not _causeUpdate: return
	
	var testResolution = GetResolutionFromSelectedItem(index)
	if testResolution.x > 0 and testResolution.y > 0:
		var editedScene:Node = EditorInterface.get_edited_scene_root()
		_scenesSelectedSceneSettings[editedScene.name] = testResolution
		EasyFormsService.PreviewResolution = testResolution
		EasyFormsService.UpdateCurrentScene(editedScene.get_tree())
		
	pass
	

	
func StoreSceneEditorSettings(scenNode:Node, testResolution:Vector2i)->void:
	if not scenNode.name in _scenesSelectedSceneSettings:
		_scenesSelectedSceneSettings[scenNode.name] = Vector2i.ZERO
		
	_scenesSelectedSceneSettings[scenNode.name] = testResolution
	pass
	
func GetResolutionFromSelectedItem(index:int=-1)->Vector2i:
	var resolutionAsText:String
	if index > -1:
		resolutionAsText = self.get_item_text(index)
	else:
		resolutionAsText = self.get_item_text(self.get_selected_id())
		
	if not resolutionAsText.contains("x"): return Vector2i(0,0)
	
	var text:PackedStringArray = resolutionAsText.strip_edges().replace("x", "").split(" ", false)
	return Vector2i(int(text[0]), int(text[1]))
	pass
