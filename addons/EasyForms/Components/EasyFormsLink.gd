#The only purpose of this node is to link a side of it children to a side of another Node2D
#For example it can link the buttom of a control to the top of another controll
@tool
@icon("res://addons/EasyForms/Components/chainlink.png")
extends Node2D
class_name EasyFormsLink

@export_category("Top")

var _linkTopTo:Node
var _topLinkageActive:bool = false
@export var TopLinkageActive:bool = false:
	get:
		return _topLinkageActive
	set(val):
		_topLinkageActive = val
		TellServiceToUpdate()
		
var _topMargin:float = 0.0
@export var TopMargin:float = 0.0:
	get:
		return _topMargin
	set(val):
		_topMargin = val
		TellServiceToUpdate()

@export var LinkTopTo:Node:
	get:
		return _linkTopTo
	set(node):
		if node == null:
			_linkTopTo = node
			return
			
		if not ValidateAssignedNode(node):return
		_linkTopTo = node
		TellServiceToUpdate()

@export_category("Buttom")

var _bottomLinkageActive:bool = false
@export var BottomLinkageActive:bool = false:
	get:
		return _bottomLinkageActive
	set(val):
		_bottomLinkageActive = val
		TellServiceToUpdate()

var _bottomMargin:float = 0.0
@export var BottomMargin:float = 0.0:
	get:
		return _bottomMargin
	set(val):
		_bottomMargin = val
		TellServiceToUpdate()

var _linkBottomTo:Node
@export var LinkBottomTo:Node:
	get:
		return _linkBottomTo
	set(node):
		if node == null:
			_linkBottomTo = node
			return
			
		if not ValidateAssignedNode(node):return
		_linkBottomTo = node
		TellServiceToUpdate()
		
@export_category("Buttom")

var _leftLinkageActive:bool = false
@export var LeftLinkageActive:bool = false:
	get:
		return _leftLinkageActive
	set(val):
		_leftLinkageActive = val
		TellServiceToUpdate()
		
var _leftMargin:float = 0.0
@export var LeftMargin:float = 0.0:
	get:
		return _leftMargin
	set(val):
		_leftMargin = val
		TellServiceToUpdate()

var _linkLeftTo:Node
@export var LinkLeftTo:Node:
	get:
		return _linkLeftTo
	set(node):
		if node == null:
			_linkLeftTo = node
			return
			
		if not ValidateAssignedNode(node):return
		_linkLeftTo = node
		TellServiceToUpdate()
		
@export_category("Buttom")

var _rightLinkageActive:bool = false
@export var RightLinkageActive:bool = false:
	get:
		return _rightLinkageActive
	set(val):
		_rightLinkageActive = val
		TellServiceToUpdate()
		
var _rightMargin:float = 0.0
@export var RightMargin:float = 0.0:
	get:
		return _rightMargin
	set(val):
		_rightMargin = val
		TellServiceToUpdate()

var _linkRightTo:Node
@export var LinkRightTo:Node:
	get:
		return _linkRightTo
	set(node):
		if node == null:
			_linkRightTo = node
			return
			
		if not ValidateAssignedNode(node):return
		_linkRightTo = node
		TellServiceToUpdate()

var _loadingDone:bool = false
func  _ready():
	_loadingDone = true
	
func ValidateAssignedNode(node:Node)->bool:
	if not "size" in node:
		printerr("The node must have a size property")
		return false
	if not "position" in node:
		printerr("The node must have a position property")
		return false
				
	return true
	
func TellServiceToUpdate()->void:
	if _loadingDone: EasyFormsService.UpdateCurrentScene()
	pass
	
func UpdateChildren()->void:
	var viewportSize : Vector2 = EasyFormsService.GetViewport(get_tree().root.get_viewport())
	#var camera := viewport.get_camera_2d()
	
	#In here we need to deal with global positions
	for child in get_children():
		if "size" not in child or "position" not in child: return
		
		if TopLinkageActive and _linkTopTo != null:
			child.global_position.y = _linkTopTo.global_position.y + _linkTopTo.size.y + _topMargin
		elif TopLinkageActive:
			child.global_position.y = 0.0 + _topMargin
			
		if BottomLinkageActive and _linkBottomTo != null:
			child.size.y = _linkBottomTo.global_position.y - child.global_position.y - _bottomMargin
		elif BottomLinkageActive:
			print(1)
			child.size.y = viewportSize.y - child.global_position.y - _bottomMargin
			
		if LeftLinkageActive and _linkLeftTo != null:
			child.global_position.x = _linkLeftTo.global_position.x + _linkLeftTo.size.x + _leftMargin
		elif LeftLinkageActive:
			child.global_position.x = 0.0 + _leftMargin
			
		if RightLinkageActive and _linkRightTo != null:
			child.size.x = _linkRightTo.global_position.x - child.global_position.x - _rightMargin
		elif RightLinkageActive:
			child.size.x = viewportSize.x - child.global_position.x - _rightMargin
	pass
	
