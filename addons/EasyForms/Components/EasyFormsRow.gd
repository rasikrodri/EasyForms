#this is equivalent to the Bootstrap row
@tool
@icon("res://addons/EasyForms/Components/row_icon.png")
extends Node2D
class_name EasyFormsRow

var size:Vector2

enum DomainEnum{
	ParentNode,
	Viewport
}
var Domain:DomainEnum = DomainEnum.ParentNode

@export_category("Row Settings")

#This will ignore all other rows in the same parent and place this row as if it the only row in the parent
var _independent:bool = false
@export var Independent:bool = false:
	get:
		return _independent
	set(value):
		_independent = value
		TellServiceToUpdate()

var _scaleChildrenToDomainWidth:bool
@export var ScaleChildrenToDomainWidth:bool:
	get:
		return _scaleChildrenToDomainWidth
	set(value):
		_scaleChildrenToDomainWidth = value
		TellServiceToUpdate()
		
var _scaleChildrenToDomainHeight:bool
@export var ScaleChildrenToDomainHeight:bool:
	get:
		return _scaleChildrenToDomainHeight
	set(value):
		_scaleChildrenToDomainHeight = value
		TellServiceToUpdate()

var _topBottomMargin:float =0.0
@export_range(-10000.0, 10000.0, 1.0) var TopBottomMargin:float = 0.0:
	get:
		return _topBottomMargin
	set(value):
		_topBottomMargin = value
		TellServiceToUpdate()
		
var _sidesMargin:float = 0.0
@export_range(-10000.0, 10000.0, 1.0) var SidesMargin:float = 0.0:
	get:
		return _sidesMargin
	set(value):
		_sidesMargin = value
		TellServiceToUpdate()
		
var _subRowDistance:float = 0.0
@export_range(-10000.0, 10000.0, 1.0) var SubRowDistance:float = 0.0:
	get:
		return _subRowDistance
	set(value):
		_subRowDistance = value
		TellServiceToUpdate()
		
@export_category("Cells Settings")
var _cellsTopButtMargin:float = 0.0
@export_range(-10000.0, 10000.0, 1.0) var CellsTopButtMargin:float = 0.0:
	get:
		return _cellsTopButtMargin
	set(value):
		_cellsTopButtMargin = value
		TellServiceToUpdate()
		
var _cellsSidesMargin:float = 0.0
@export_range(-10000.0, 10000.0, 1.0) var CellsSidesMargin:float = 0.0:
	get:
		return _cellsSidesMargin
	set(value):
		_cellsSidesMargin = value
		TellServiceToUpdate()
		
var _drawRowLines:bool = false
@export var DrawLines:bool = false:
	get:
		return _drawRowLines
	set(value):
		_drawRowLines = value
		TellServiceToUpdate()

var _linesColor:Color = Color.WHITE
@export_color_no_alpha() var LinesColor:Color = Color.WHITE:
	get:
		return _linesColor
	set(value):
		_linesColor = value
		TellServiceToUpdate()
		
var _linesThickness:float = 1.0
@export_range(0.0, 20.0, 0.1) var LinesThickness:float = 1.0:
	get:
		return _linesThickness
	set(value):
		_linesThickness = value
		TellServiceToUpdate()
		
		
		
@export_category("Alignment")

enum VerticalAlignmentEnum{
	Top,
	Center,
	Buttom
}
var _rowVerticalAlignment:VerticalAlignmentEnum = VerticalAlignmentEnum.Center
@export var RowVerticalAlignment:VerticalAlignmentEnum = VerticalAlignmentEnum.Center:
	get:
		return _rowVerticalAlignment
	set(value):
		_rowVerticalAlignment = value
		TellServiceToUpdate()

enum HorizontalAlignmentEnum{
	Left,
	Center,
	Right
}

var _rowHorizontalAlignment:HorizontalAlignmentEnum = HorizontalAlignmentEnum.Center
@export var RowHorizontalAlignment:HorizontalAlignmentEnum = HorizontalAlignmentEnum.Center:
	get:
		return _rowHorizontalAlignment
	set(value):
		_rowHorizontalAlignment = value
		TellServiceToUpdate()
		
		
enum ControlsHorizontalAlignmentEnum{
	Left,
	Center,
	Right,
	LeftTableLike,
	CenterTableLike,
	RightTableLike
}
var _controlsHorizontalAlignment:ControlsHorizontalAlignmentEnum = ControlsHorizontalAlignmentEnum.LeftTableLike
@export var ControlsHorizontalAlignment:ControlsHorizontalAlignmentEnum = ControlsHorizontalAlignmentEnum.LeftTableLike:
	get:
		return _controlsHorizontalAlignment
	set(value):
		_controlsHorizontalAlignment = value
		TellServiceToUpdate()

var SubRows:Array[Array] = []#Before all filters are applyed
var SubRowsAdjusted:Array[Array] = []#After all filters are applyed

var _tableLines:Array[TableLine] = []
class TableLine:
	var Start:Vector2
	var End :Vector2
	var LineColor:Color
	var Thickness:float
	
	func _init(start:Vector2, end:Vector2, color:Color, thickness:float)->void:
		Start = start
		End = end
		LineColor = color
		Thickness = thickness
		pass
		
	pass
	
var _loadingDone:bool = false
func  _ready():
	#self.connect("child_entered_tree", Callable(self, "child_enterd_tree"))
	_loadingDone = true
	
	EasyFormsService.ConnectSignals(self)
	pass
	
func _draw():
	if not _drawRowLines: return
	
	#calculate lines once only after every change,
	#This way the code will run very fast
	if _tableLines.size() == 0:
		CalculateTableLines()
			
	for l in _tableLines:
		l = (l as TableLine)
		draw_line(l.Start, l.End, l.LineColor, l.Thickness)#Left line
	pass

func CalculateTableLines()->void:
	for row in SubRowsAdjusted:
		row = (row as Array)
		
		#***Do not draw each cell's 4 lines
		#To draw more efficiently, we will draw the whole top and buttom line of the row
		#Draw the left side of the row
		#Then add the right sides of each cell
		
		#***Also, to the top an dbuttom lines, add half the line thickness to every side of every line,
		#otherwise the end of the lines will not match squarely
		
		var firstCellArea:Rect2=row.front()
		var lastCellArea:Rect2= row.back()
		
		var halfLineSize:float = _linesThickness / 2.0
		
		#top line
		var line:TableLine = TableLine.new(
			Vector2(
				firstCellArea.position.x - halfLineSize,
				firstCellArea.position.y
			),
			Vector2(
				lastCellArea.position.x + lastCellArea.size.x + halfLineSize,
				lastCellArea.position.y
			),
			_linesColor,
			_linesThickness
		)
		_tableLines.append(line)
		
		#bottom line
		line = TableLine.new(
			Vector2(
				firstCellArea.position.x - halfLineSize,
				firstCellArea.position.y + firstCellArea.size.y
			),
			Vector2(
				lastCellArea.position.x + lastCellArea.size.x + halfLineSize,
				lastCellArea.position.y + lastCellArea.size.y
			),
			_linesColor,
			_linesThickness
		)
		_tableLines.append(line)
		
		#left line
		line = TableLine.new(
			Vector2(
				firstCellArea.position.x,
				firstCellArea.position.y
			),
			Vector2(
				firstCellArea.position.x,
				firstCellArea.position.y + firstCellArea.size.y
			),
			_linesColor,
			_linesThickness
		)
		_tableLines.append(line)
			
		#Now we just add the right line of every cell
		for i in range(row.size()):
			var cell:Rect2 = row[i]
			var rightLine:TableLine = TableLine.new(
				Vector2(
					cell.position.x + cell.size.x,
					cell.position.y
				), 
				Vector2(
					cell.position.x + cell.size.x, 
					cell.position.y + cell.size.y
				), 
				_linesColor, 
				_linesThickness
			)
			_tableLines.append(rightLine)
	pass

func TellServiceToUpdate()->void:
	if _loadingDone: EasyFormsService.UpdateRowScene(self)
	pass
	
func Reset()->void:
	position = Vector2.ZERO
	size = Vector2.ZERO
	SubRows.clear()
	SubRowsAdjusted.clear()
	_tableLines.clear()
	queue_redraw()
	pass
