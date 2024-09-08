@tool
extends Node

var _easyformsCell := preload("res://addons/EasyForms/Components/EasyFormsCell.gd")
var _positioningService= preload("res://addons/EasyForms/Services/EasyFormsPositioningService.gd")
var _easyFormsRowPositioningService

func CalculateCells(areaAvailable:Rect2, easyFromsRow:EasyFormsRow)->float:
	CreateCells(areaAvailable, easyFromsRow, GetAllowedElements(easyFromsRow))
	
	var back = easyFromsRow.SubRows.back()
	if back != null and back.size() > 0:
		var lastSubRowFirstCell= back[0]
		var lastRowBottomEdgePos:float = lastSubRowFirstCell.Area.position.y + lastSubRowFirstCell.Area.size.y
		return lastRowBottomEdgePos
	else:
		return areaAvailable.position.y
	pass
	
func GetAllowedElements(easyFromsRow:EasyFormsRow)->Array[Node]:
	var allowedElements:Array[Node] = []
	var children = easyFromsRow.get_children()
	for child in children:
		if child is EasyFormsRow or "size" in child:
			allowedElements.append(child)
			
	return allowedElements
	pass
	
#calculate the cells as aligned from the left to right
#we do not want the to p marging to be added when there are subrows, because
#all elements do not fit in the current line/row
#Only the first/main line/row nees to have the top marging applied
func CreateCells(areaAvailable:Rect2i, easyFromsRow:EasyFormsRow, controls:Array[Node], addTopMarginToSubRows:bool = true)->void:
	if addTopMarginToSubRows:
		easyFromsRow.DomainArea = Rect2(areaAvailable.position.x + easyFromsRow.SidesMargin, areaAvailable.position.y + easyFromsRow.TopBottomMargin, areaAvailable.size.x - (easyFromsRow.SidesMargin * 2.0), areaAvailable.size.y - (easyFromsRow.TopBottomMargin * 2.0))
	else:
		easyFromsRow.DomainArea = Rect2(areaAvailable.position.x + easyFromsRow.SidesMargin, areaAvailable.position.y, areaAvailable.size.x - easyFromsRow.SidesMargin, areaAvailable.size.y)
		
	var row:Array = []
	
	var widthAvailable:float = easyFromsRow.DomainArea.size.x
	var maxElementHeigh:float = 0.0
	var lastCellEnd:float = 0.0
	var startingCount:int = controls.size()
	while controls.size() > 0:
		var currElement = controls[0]
		
		if currElement is EasyFormsRow: self.CalculateCells(easyFromsRow.DomainArea, currElement)
		
		#does currElement fits in current available width?
		#if not then create the next sub row
		if controls.size() != startingCount and currElement.size.x + (easyFromsRow.CellsSidesMargin * 2.0) > widthAvailable:
			#start a new row
			var area:Rect2 = Rect2(areaAvailable.position.x, areaAvailable.position.y + maxElementHeigh  + easyFromsRow.SubRowDistance, areaAvailable.size.x, areaAvailable.size.y)
			CreateCells(area, easyFromsRow, controls, false)
			continue
			
		var cell := _easyformsCell.EasyFormCell.new()
		cell.Element = currElement
		
		var startX:float
		var startY:float
		var width:float
		var height:float
		
		if easyFromsRow.ScaleChildrenToDomain == easyFromsRow.ScaleChildrenToDomainWhatDimension.No:
			startX = easyFromsRow.DomainArea.position.x + lastCellEnd
			width = currElement.size.x + easyFromsRow.CellsSidesMargin
			startY = easyFromsRow.DomainArea.position.y
			height = currElement.size.y + easyFromsRow.CellsTopButtMargin
		elif easyFromsRow.ScaleChildrenToDomain == easyFromsRow.ScaleChildrenToDomainWhatDimension.Width:
			startX = easyFromsRow.DomainArea.position.x
			width = easyFromsRow.DomainArea.size.x
			if "size" in cell.Element: cell.Element.size.x = width
			startY = easyFromsRow.DomainArea.position.y
			height = currElement.size.y + easyFromsRow.CellsTopButtMargin
		elif easyFromsRow.ScaleChildrenToDomain == easyFromsRow.ScaleChildrenToDomainWhatDimension.Height:
			startX = easyFromsRow.DomainArea.position.x + lastCellEnd
			width = currElement.size.x + easyFromsRow.CellsSidesMargin
			startY = easyFromsRow.DomainArea.position.y
			height = easyFromsRow.DomainArea.size.y
			if "size" in cell.Element: cell.Element.size.y = height
		elif easyFromsRow.ScaleChildrenToDomain == easyFromsRow.ScaleChildrenToDomainWhatDimension.WidthAndHeight:
			startX = easyFromsRow.DomainArea.position.x
			width = easyFromsRow.DomainArea.size.x
			if "size" in cell.Element: cell.Element.size.x = width
			startY = easyFromsRow.DomainArea.position.y
			height = easyFromsRow.DomainArea.size.y
			if "size" in cell.Element: cell.Element.size.y = height
		else:
			printerr("Invalid ScaleChildrenToDomainWhatDimension " + str(easyFromsRow.ScaleChildrenToDomain))
			
			
			
			
			
		cell.Area = Rect2(startX, startY, width, height)
		row.append(cell)
		controls.remove_at(0)
		
		#save bigest height
		if cell.Area.size.y > maxElementHeigh: maxElementHeigh = cell.Area.size.y
		
		#Update available width for next element		
		widthAvailable -= currElement.size.x + easyFromsRow.CellsSidesMargin
		lastCellEnd += currElement.size.x + easyFromsRow.CellsSidesMargin
			
	#make all cell to have the height of the cell with biguest size y
	ResizeCellsToHeight(row, maxElementHeigh)
	
	#set row size, it will include all sub rows
	var width:float = easyFromsRow.DomainArea.size.x - widthAvailable
	if width > easyFromsRow.size.x: easyFromsRow.size.x = width
	if maxElementHeigh > easyFromsRow.size.y: easyFromsRow.size.y = maxElementHeigh
	
	#inserta t 0 because sub rows will be inserted first
	easyFromsRow.SubRows.insert(0, row)
	pass
	
func ResizeCellsToHeight(row:Array, height:float)->void:
	for cell in row:
		cell.Area.size.y = height
	pass
	
func PositionContorls(easyFormsRow:EasyFormsRow, areaAvailable:Rect2, heightOffset:float = 0, widestRowWidth:float = 0, widestCellPerColumn:Array[float] = [])->void:
	
	if _easyFormsRowPositioningService == null: _easyFormsRowPositioningService = _positioningService.new()
	
	for subRow in easyFormsRow.SubRows:
		if subRow.size() == 0: continue
		
		var widestCellsWidthDifference = GetCellsDifferences(subRow, widestCellPerColumn)
				
		match easyFormsRow.RowHorizontalAlignment:
			EasyFormsRow.HorizontalAlignmentEnum.Left:
				PositionControlsToTheLeft(easyFormsRow, easyFormsRow.CellsContentHorizontalAlignment, subRow, heightOffset, widestRowWidth, widestCellsWidthDifference)
			EasyFormsRow.HorizontalAlignmentEnum.Right:
				PositionControlsToTheRight(easyFormsRow, easyFormsRow.CellsContentHorizontalAlignment, areaAvailable, subRow, heightOffset, widestRowWidth, widestCellsWidthDifference)
			EasyFormsRow.HorizontalAlignmentEnum.Center:
				PositionControlsOnTheCenter(easyFormsRow, easyFormsRow.CellsContentHorizontalAlignment, areaAvailable, subRow, heightOffset, widestRowWidth, widestCellsWidthDifference)
	pass
	
func GetCellsDifferences(subRow:Array, widestCellPerColumn:Array[float])->Array[float]:
	var cellsDifferences:Array[float] = []
	
	var subRowSize:= subRow.size()
	for i in range(widestCellPerColumn.size()):
		if i < subRowSize:
			var cell= subRow[i]
			cellsDifferences.append(widestCellPerColumn[i] - cell.Area.size.x)
		else:
			cellsDifferences.append(widestCellPerColumn[i])
			
	return cellsDifferences
	pass
	
func GetSubRowWidth(subRow:Array)->float:
	var subRowWidth:float
	for cell in subRow:
		subRowWidth += cell.Area.size.x
		
	return subRowWidth
	pass
	
func PositionControlsToTheLeft(easyFormsRow:EasyFormsRow, cellsContentHorizPositioning:EasyFormsRow.CellsContentHorizontalAlignmentEnum, subRow:Array, heightOffset:float, widestRowWidth:float=0, widestCellsWidthDifference:Array[float] = [])->void:
	var widestSubRowWidthDifference:float = widestRowWidth - GetSubRowWidth(subRow)
	
	var subRowWidth:float = GetSubRowWidth(subRow)
	var currSubRowCenter:float = subRowWidth - (subRowWidth / 2.0)
	var widestRowCenter:float = widestRowWidth - (widestRowWidth/2.0)
	var xOffset:float = widestRowCenter - currSubRowCenter
	
	var lastCellDifference:float = 0.0
	var cellIndex:int = 0
	
	var rowAdjusted:Array = []
	var lastCell:=subRow.back()
	for cell in subRow:
		var control:Node = cell.Element
		
		match cellsContentHorizPositioning:
			
			EasyFormsRow.CellsContentHorizontalAlignmentEnum.Left:
				var cellPos := Rect2(
					cell.Area.position.x,
					cell.Area.position.y + heightOffset,
					cell.Area.size.x,
					cell.Area.size.y
				)
				rowAdjusted.append(cellPos)
				var pos := Vector2(
					cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0),
					cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y / 2.0)
				)
				control.position = pos
				
			EasyFormsRow.CellsContentHorizontalAlignmentEnum.Right:
				var cellPos := Rect2(
					cell.Area.position.x  + widestSubRowWidthDifference,
					cell.Area.position.y + heightOffset,
					cell.Area.size.x,
					cell.Area.size.y
				)
				rowAdjusted.append(cellPos)
				var pos = Vector2(
					cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0),
					cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y / 2.0)
				)
				control.position = pos
				
			EasyFormsRow.CellsContentHorizontalAlignmentEnum.Center:
				var cellPos := Rect2(
					cell.Area.position.x   + xOffset,
					cell.Area.position.y + heightOffset,
					cell.Area.size.x,
					cell.Area.size.y
				)
				rowAdjusted.append(cellPos)
				var pos := Vector2(
					cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0),
					cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y / 2.0)
				)
				control.position = pos
				
			EasyFormsRow.CellsContentHorizontalAlignmentEnum.LeftTableLike:
				var cellPos := Rect2(
					cell.Area.position.x + lastCellDifference,
					cell.Area.position.y + heightOffset,
					cell.Area.size.x + widestCellsWidthDifference[cellIndex],
					cell.Area.size.y
				)
				rowAdjusted.append(cellPos)
				var pos := Vector2(
					cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0),
					cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y / 2.0)
				)
				control.position = pos
				
				lastCellDifference += widestCellsWidthDifference[cellIndex]
				cellIndex += 1
				
				#Add empty cells if needed
				if lastCell == cell:
					for i in range(cellIndex, widestCellsWidthDifference.size()):
						var prevCell:Rect2 = rowAdjusted[i - 1]
						var extaCellPos := Rect2(
							prevCell.position.x + prevCell.size.x,
							prevCell.position.y,
							widestCellsWidthDifference[i],
							prevCell.size.y
						)
						rowAdjusted.append(extaCellPos)
				
			EasyFormsRow.CellsContentHorizontalAlignmentEnum.CenterTableLike:
				var cellPos := Rect2(
					cell.Area.position.x + lastCellDifference ,
					cell.Area.position.y + heightOffset,
					cell.Area.size.x + widestCellsWidthDifference[cellIndex],
					cell.Area.size.y
				)
				rowAdjusted.append(cellPos)
				var pos := Vector2(
					cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0) + (widestCellsWidthDifference[cellIndex] / 2.0),
					cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y / 2.0)
				)
				control.position = pos
				
				lastCellDifference += widestCellsWidthDifference[cellIndex]
				cellIndex += 1
				
				#Add empty cells if needed
				if lastCell == cell:
					for i in range(cellIndex, widestCellsWidthDifference.size()):
						var prevCell:Rect2 = rowAdjusted[i - 1]
						var extaCellPos := Rect2(
							prevCell.position.x + prevCell.size.x,
							prevCell.position.y,
							widestCellsWidthDifference[i],
							prevCell.size.y
						)
						rowAdjusted.append(extaCellPos)
				
			EasyFormsRow.CellsContentHorizontalAlignmentEnum.RightTableLike:
				var cellPos := Rect2(
					cell.Area.position.x + lastCellDifference,
					cell.Area.position.y + heightOffset,
					cell.Area.size.x + widestCellsWidthDifference[cellIndex],
					cell.Area.size.y
				)
				rowAdjusted.append(cellPos)
				var pos := Vector2(
					cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0) + widestCellsWidthDifference[cellIndex],
					cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y / 2.0)
				)
				control.position = pos
				
				lastCellDifference += widestCellsWidthDifference[cellIndex]
				cellIndex += 1
				
				#Add empty cells if needed
				if lastCell == cell:
					for i in range(cellIndex, widestCellsWidthDifference.size()):
						var prevCell:Rect2 = rowAdjusted[i - 1]
						var extaCellPos := Rect2(
							prevCell.position.x + prevCell.size.x,
							prevCell.position.y,
							widestCellsWidthDifference[i],
							prevCell.size.y
						)
						rowAdjusted.append(extaCellPos)
			
		
	easyFormsRow.SubRowsAdjusted.append(rowAdjusted)
	pass
	
func PositionControlsToTheRight(easyFormsRow:EasyFormsRow, cellsContentHorizPositioning:EasyFormsRow.CellsContentHorizontalAlignmentEnum, areaAvailable:Rect2, subRow:Array, heightOffset:float, widestRowWidth:float=0, widestCellsWidthDifference:Array[float] = [])->void:
	var lastCell:= subRow.back()
	var distanceToRightEdge:float = (areaAvailable.position.x + areaAvailable.size.x) - (lastCell.Area.position.x + lastCell.Area.size.x)
	distanceToRightEdge -= easyFormsRow.SidesMargin #(easyFormsRow.SidesMargin / 2.0)
	
	var subRowWidth:float = GetSubRowWidth(subRow)
	var offsetToLeft:float = widestRowWidth - subRowWidth
	
	var currSubRowCenter:float = subRowWidth - (subRowWidth / 2.0)
	var widestRowCenter:float = widestRowWidth - (widestRowWidth/2.0)
	var xOffset:float = widestRowCenter - currSubRowCenter
	
	var rowAdjusted:Array = []
	var insertedInReverse:bool
	if easyFormsRow.CellsContentHorizontalAlignment == EasyFormsRow.CellsContentHorizontalAlignmentEnum.Left or \
		easyFormsRow.CellsContentHorizontalAlignment  == EasyFormsRow.CellsContentHorizontalAlignmentEnum.Right or \
		easyFormsRow.CellsContentHorizontalAlignment  == EasyFormsRow.CellsContentHorizontalAlignmentEnum.Center:
		for cell in subRow:
			var control:Node = cell.Element
			
			match cellsContentHorizPositioning:
				EasyFormsRow.CellsContentHorizontalAlignmentEnum.Left:
					var cellPos := Rect2(
					cell.Area.position.x + distanceToRightEdge - offsetToLeft,
					cell.Area.position.y + heightOffset,
					cell.Area.size.x,
					cell.Area.size.y
					)
					rowAdjusted.append(cellPos)
					var pos := Vector2(
						cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0),
						cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y / 2.0)
					)
					control.position = pos
				
				EasyFormsRow.CellsContentHorizontalAlignmentEnum.Right:
					var cellPos := Rect2(
					cell.Area.position.x + distanceToRightEdge,
					cell.Area.position.y + heightOffset,
					cell.Area.size.x,
					cell.Area.size.y
					)
					rowAdjusted.append(cellPos)
					var pos := Vector2(
						cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0),
						cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y / 2.0)
					)
					control.position = pos
					
				EasyFormsRow.CellsContentHorizontalAlignmentEnum.Center:
					var cellPos := Rect2(
						cell.Area.position.x + distanceToRightEdge - xOffset,
						cell.Area.position.y + heightOffset,
						cell.Area.size.x,
						cell.Area.size.y
					)
					rowAdjusted.append(cellPos)
					var pos := Vector2(
						cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0),
						cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y / 2.0)
					)
					control.position = pos
					
	else:
		insertedInReverse = true
		var lastCellDifference:float= 0.0
		var subRowSize:float= subRow.size()
		for i in range(widestCellsWidthDifference.size() - 1, -1, -1):
			
			if i >= subRowSize:
				lastCellDifference += widestCellsWidthDifference[i]
				continue
			
			var cell = subRow[i]
			var control:Node = cell.Element
			
			match cellsContentHorizPositioning:
				EasyFormsRow.CellsContentHorizontalAlignmentEnum.LeftTableLike:
					var cellPos := Rect2(
						cell.Area.position.x + distanceToRightEdge - lastCellDifference - widestCellsWidthDifference[i],
						cell.Area.position.y + heightOffset,
						cell.Area.size.x + widestCellsWidthDifference[i],
						cell.Area.size.y
					)
					rowAdjusted.append(cellPos)
					var pos := Vector2(
						cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0),
						cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y / 2.0)
					)
					control.position = pos
					
					##Add empty cells if needed
					if i == 0:
						for a in range(subRowSize, widestCellsWidthDifference.size()):
							var prevCell:Rect2 = rowAdjusted[0]
							var extaCellPos := Rect2(
								prevCell.position.x + prevCell.size.x,
								prevCell.position.y,
								widestCellsWidthDifference[a],
								prevCell.size.y
							)
							rowAdjusted.insert(0, extaCellPos)
					
				EasyFormsRow.CellsContentHorizontalAlignmentEnum.CenterTableLike:
					var cellPos := Rect2(
						cell.Area.position.x + distanceToRightEdge - lastCellDifference - widestCellsWidthDifference[i],
						cell.Area.position.y + heightOffset,
						cell.Area.size.x + widestCellsWidthDifference[i],
						cell.Area.size.y
					)
					rowAdjusted.append(cellPos)
					var pos := Vector2(
						cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0) + (widestCellsWidthDifference[i] / 2.0),
						cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y /2.0)
					)
					control.position = pos
					
					##Add empty cells if needed
					if i == 0:
						for a in range(subRowSize, widestCellsWidthDifference.size()):
							var prevCell:Rect2 = rowAdjusted[0]
							var extaCellPos := Rect2(
								prevCell.position.x + prevCell.size.x,
								prevCell.position.y,
								widestCellsWidthDifference[a],
								prevCell.size.y
							)
							rowAdjusted.insert(0, extaCellPos)
					
				EasyFormsRow.CellsContentHorizontalAlignmentEnum.RightTableLike:
					var cellPos := Rect2(
						cell.Area.position.x + distanceToRightEdge - lastCellDifference - widestCellsWidthDifference[i],
						cell.Area.position.y + heightOffset,
						cell.Area.size.x + widestCellsWidthDifference[i],
						cell.Area.size.y
					)
					rowAdjusted.append(cellPos)
					var pos := Vector2(
						cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0) + widestCellsWidthDifference[i],
						cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y / 2.0)
					)
					control.position = pos
					
					##Add empty cells if needed
					if i == 0:
						for a in range(subRowSize, widestCellsWidthDifference.size()):
							var prevCell:Rect2 = rowAdjusted[0]
							var extaCellPos := Rect2(
								prevCell.position.x + prevCell.size.x,
								prevCell.position.y,
								widestCellsWidthDifference[a],
								prevCell.size.y
							)
							rowAdjusted.insert(0, extaCellPos)
				
					
					
			lastCellDifference += widestCellsWidthDifference[i]
			
	if insertedInReverse: rowAdjusted.reverse()
	easyFormsRow.SubRowsAdjusted.append(rowAdjusted)
	pass
	
func PositionControlsOnTheCenter(easyFormsRow:EasyFormsRow, cellsContentHorizPositioning:EasyFormsRow.CellsContentHorizontalAlignmentEnum, areaAvailable:Rect2, subRow:Array, heightOffset:float, widestRowWidth:float=0, widestCellsWidthDifference:Array[float] = [])->void:
	var widestRowWidthDifference:float = widestRowWidth - easyFormsRow.size.x
	
	var fisrtCell:= subRow.front()
	var lastCell:= subRow.back()
	
	var totalWidth:float = (areaAvailable.position.x + areaAvailable.size.x)
	var widthCenter:float = totalWidth - (totalWidth / 2.0)
		
	var allCellsSpaceTaken:float = fisrtCell.Area.position.x + (lastCell.Area.position.x +  lastCell.Area.size.x)
	var toAddLeft:float = widthCenter - (allCellsSpaceTaken / 2.0) - (widestRowWidthDifference / 2.0)
	var toAddRight:float = widthCenter - (allCellsSpaceTaken / 2.0) + (widestRowWidthDifference / 2.0)
	var toAddCenter:float = widthCenter - (allCellsSpaceTaken / 2.0)
	
	var cellIndex:int = 0
	var totalDifference:float = 0.0
	for dif in widestCellsWidthDifference:
		totalDifference += dif
	var toAddCenterTable:float = widthCenter - ((allCellsSpaceTaken + totalDifference) / 2.0)
	var lastTotalCellWidthDifference :float = 0.0
	
	var rowAdjusted:Array = []
	for cell in subRow:
		var control:Node = cell.Element
						
		match cellsContentHorizPositioning:
			EasyFormsRow.CellsContentHorizontalAlignmentEnum.Left:
				var cellPos := Rect2(
					cell.Area.position.x + toAddLeft,
					cell.Area.position.y + heightOffset,
					cell.Area.size.x,
					cell.Area.size.y
				)
				rowAdjusted.append(cellPos)
				var pos := Vector2(
					cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0),
					cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y / 2.0)
				)
				control.position = pos
				
			EasyFormsRow.CellsContentHorizontalAlignmentEnum.Right:
				var cellPos := Rect2(
					cell.Area.position.x + toAddRight,
					cell.Area.position.y + heightOffset,
					cell.Area.size.x,
					cell.Area.size.y
				)
				rowAdjusted.append(cellPos)
				var pos := Vector2(
					cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0),
					cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y / 2.0)
				)
				control.position = pos
				
			EasyFormsRow.CellsContentHorizontalAlignmentEnum.Center:
				var cellPos := Rect2(
					cell.Area.position.x + toAddCenter,
					cell.Area.position.y + heightOffset,
					cell.Area.size.x,
					cell.Area.size.y
				)
				rowAdjusted.append(cellPos)
				var pos := Vector2(
					cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0),
					cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y / 2.0)
				)
				control.position = pos
				
			EasyFormsRow.CellsContentHorizontalAlignmentEnum.LeftTableLike:
				var toAddWithCellDifference:float = toAddCenterTable + lastTotalCellWidthDifference
				lastTotalCellWidthDifference += widestCellsWidthDifference[cellIndex]
				
				var cellPos := Rect2(
					cell.Area.position.x + toAddWithCellDifference,
					cell.Area.position.y + heightOffset,
					cell.Area.size.x + widestCellsWidthDifference[cellIndex],
					cell.Area.size.y
				)
				rowAdjusted.append(cellPos)
				var pos := Vector2(
					cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0),
					cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y / 2.0)
				)
				control.position = pos
				cellIndex += 1
				
				#Add empty cells if needed
				if lastCell == cell:
					for i in range(cellIndex, widestCellsWidthDifference.size()):
						var prevCell:Rect2 = rowAdjusted[i - 1]
						var extaCellPos := Rect2(
							prevCell.position.x + prevCell.size.x,
							prevCell.position.y,
							widestCellsWidthDifference[i],
							prevCell.size.y
						)
						rowAdjusted.append(extaCellPos)
				
			EasyFormsRow.CellsContentHorizontalAlignmentEnum.CenterTableLike:
				var toAddWithCellDifference:float = toAddCenterTable + lastTotalCellWidthDifference
				lastTotalCellWidthDifference += widestCellsWidthDifference[cellIndex]
				
				var cellPos := Rect2(
					cell.Area.position.x + toAddWithCellDifference,
					cell.Area.position.y + heightOffset,
					cell.Area.size.x + widestCellsWidthDifference[cellIndex],
					cell.Area.size.y
				)
				rowAdjusted.append(cellPos)
				var pos := Vector2(
					cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0) + (widestCellsWidthDifference[cellIndex] / 2.0),
					cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y / 2.0)
				)
				control.position = pos
				cellIndex += 1
				
				#Add empty cells if needed
				if lastCell == cell:
					for i in range(cellIndex, widestCellsWidthDifference.size()):
						var prevCell:Rect2 = rowAdjusted[i - 1]
						var extaCellPos := Rect2(
							prevCell.position.x + prevCell.size.x,
							prevCell.position.y,
							widestCellsWidthDifference[i],
							prevCell.size.y
						)
						rowAdjusted.append(extaCellPos)
				
			EasyFormsRow.CellsContentHorizontalAlignmentEnum.RightTableLike:
				var toAddWithCellDifference:float = toAddCenterTable + lastTotalCellWidthDifference
				lastTotalCellWidthDifference += widestCellsWidthDifference[cellIndex]
				
				var cellPos := Rect2(
					cell.Area.position.x + toAddWithCellDifference,
					cell.Area.position.y + heightOffset,
					cell.Area.size.x + widestCellsWidthDifference[cellIndex],
					cell.Area.size.y
				)
				rowAdjusted.append(cellPos)
				var pos := Vector2(
					cellPos.position.x + (cell.Area.size.x / 2.0) - (control.size.x / 2.0) + widestCellsWidthDifference[cellIndex],
					cellPos.position.y + (cell.Area.size.y / 2.0) - (control.size.y / 2.0)
				)
				control.position = pos
				cellIndex += 1
				
				#Add empty cells if needed
				if lastCell == cell:
					for i in range(cellIndex, widestCellsWidthDifference.size()):
						var prevCell:Rect2 = rowAdjusted[i - 1]
						var extaCellPos := Rect2(
							prevCell.position.x + prevCell.size.x,
							prevCell.position.y,
							widestCellsWidthDifference[i],
							prevCell.size.y
						)
						rowAdjusted.append(extaCellPos)
				
			
	easyFormsRow.SubRowsAdjusted.append(rowAdjusted)
	#print(easyFormsRow.SubRowsAdjusted.size())
	pass
	
