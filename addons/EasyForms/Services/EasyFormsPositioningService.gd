@tool
extends Node

var _easyFormsRowService:= preload("res://addons/EasyForms/Services/EasyFormsRowService.gd").new()

var viewportKey:String = "Viewport"

func UpdateAllInScene(sceneTree:SceneTree, viewportSize:Vector2)->void:
	#var viewport:Viewport = sceneTree.root.get_viewport()
	
	var allEasyFormRowsDic:Dictionary = {}
	CompileMainRows(sceneTree.root, allEasyFormRowsDic)
	ValidateCompiledEasyFormRows(allEasyFormRowsDic)
		
	for arr in allEasyFormRowsDic.values():
		CalculateRowsInArea(arr as Array[EasyFormsRow], viewportSize)
	pass

func ValidateCompiledEasyFormRows(allEasyFormRowsDic:Dictionary)->void:
	for parentNode in allEasyFormRowsDic.keys():
		
		if not "size" in parentNode:
			if Engine.is_editor_hint():
				print("Using viewport as the domain for all the EasyFormRows that are a child of '" + parentNode.name + "', because node '"  + parentNode.name + "' does not have a 'size' property.")
			
		if parentNode is EasyFormsRow:
			for childEasyRow in allEasyFormRowsDic[parentNode]:
				if Engine.is_editor_hint():
					printerr(childEasyRow.name + " child of " + parentNode.name + ". EasyFormRow as a child of another EasyFormRow is not supperted!")
		
			allEasyFormRowsDic.erase(parentNode)
	
	pass
	
func CompileMainRows(parentNode:Node, allEasyFormRowsDic:Dictionary)->void:
	for child in parentNode.get_children():
		if child is EasyFormsRow:
			if not allEasyFormRowsDic.has(parentNode):
				var arr:Array[EasyFormsRow] = []
				allEasyFormRowsDic[parentNode] = arr
			allEasyFormRowsDic[parentNode].append(child)
			
		CompileMainRows(child, allEasyFormRowsDic)
	pass
	
func CalculateRowsInArea(rows:Array[EasyFormsRow], viewportAreaSize:Vector2)->void:
	var rowsByDomain:Dictionary = GetRowsByDomains(rows)
	var lastRowBottomEdgePosDictionary:Dictionary = {}
	
	for rowDomainKey in rowsByDomain.keys():
		lastRowBottomEdgePosDictionary[rowDomainKey] = 0.0
	
	var domainKeys:Array = rowsByDomain.keys() as Array
	var domainValues:Array = rowsByDomain.values()
	for i in range(rowsByDomain.size()):
		
		var domainKey:String = domainKeys[i]
		var easyRows:Array = domainValues[i]
		easyRows = easyRows as Array[EasyFormsRow]
		
		CalculateRowsCells(easyRows, lastRowBottomEdgePosDictionary, domainKey, viewportAreaSize)
	
	for domainRows in rowsByDomain.values():
		var widestRowWidth:float = GetWidthOfWidestRow(domainRows)
		var widestCellPerColumn:Array[float] = GetWidestCellPerColumn(domainRows)
		
		##This will fix, for when aligning Table Like, cells to be in subrows or not
		#AdjustSubrowsToFitWhenTableLike(domainRows, widestCellPerColumn)
		
		SetPositions(domainRows, viewportAreaSize, widestRowWidth, widestCellPerColumn, lastRowBottomEdgePosDictionary)
	pass
	
#func AdjustSubrowsToFitWhenTableLike(domainRows:Array, widestCellPerColumn:Array[float])->void:
	#var totalWidth:float = 0.0
	#for val in widestCellPerColumn: totalWidth += val
	#
	#for easyFormsRow in domainRows:
		#if totalWidth > easysFormRow.size.x:
			#for subrow in easyFormsRow.SubRows:
				##Get the width of the subrow
				##If subrow is bigger, move the last cell to the next subrow,
				##And repeat until there is only 1 cell left in the current row
				##or all cell fit within domain
				#
				##Then do the same with the next subrows
	#pass
	
func CalculateRowsCells(easyRows:Array, lastRowBottomEdgePosDictionary:Dictionary, domainKey:String, viewportAreaSize:Vector2)->void:
	for easyFormsRow in easyRows:
			
		easyFormsRow = (easyFormsRow as EasyFormsRow)
		easyFormsRow.Reset()
		
		var availableAreaSize:Vector2 = GetAvailableArea(domainKey, viewportAreaSize, easyFormsRow.get_parent())
			
		var lastRowBottomEdgePos:float
		if easyFormsRow.Independent:
			lastRowBottomEdgePos = 0.0
		else:
			lastRowBottomEdgePos = lastRowBottomEdgePosDictionary[domainKey]
		
		var areaAvailable:Rect2  = Rect2(
			0.0,
			lastRowBottomEdgePos,
			availableAreaSize.x,
			availableAreaSize.y
		)
		if easyFormsRow.Independent:
			_easyFormsRowService.CalculateCells(areaAvailable, easyFormsRow)
		else:
			lastRowBottomEdgePosDictionary[domainKey] = _easyFormsRowService.CalculateCells(areaAvailable, easyFormsRow)
	pass
	
func GetAvailableArea(domainKey:String, viewportAreaSize:Vector2, parent:Node)->Vector2:
	if domainKey == viewportKey or parent is Viewport:
		return viewportAreaSize
	elif parent.size.x == 0 and parent.size.y == 0:
		return viewportAreaSize
	else:
		return parent.size
	pass
	
func GetRowsByDomains(easyFormRows:Array[EasyFormsRow])->Dictionary:
	var rowsByDomains:Dictionary = {}
	var keyToAsignToo:String
	for easyFormsRow in easyFormRows:
		
		var parentNode:Node = easyFormsRow.get_parent()
		if parentNode is Viewport:
			keyToAsignToo = viewportKey
			easyFormsRow.Domain = EasyFormsRow.DomainEnum.Viewport
		elif "size" in parentNode:
			keyToAsignToo = str(parentNode)
			easyFormsRow.Domain = EasyFormsRow.DomainEnum.ParentNode
		else:
			keyToAsignToo = viewportKey
			easyFormsRow.Domain = EasyFormsRow.DomainEnum.Viewport
				
		#print("Choosing " + keyToAsignToo + " as domain for positoning " + easyFormsRow.name)
		if not rowsByDomains.has(keyToAsignToo): rowsByDomains[keyToAsignToo] = []
		rowsByDomains[keyToAsignToo].append(easyFormsRow)
	return rowsByDomains
	pass
		
func SetPositions(mainRows:Array, viewportAreaSize:Vector2, widestRowWidth:float, widestCellPerColumn:Array[float], lastRowBottomEdgePosDictionary:Dictionary = {})->void:
	for easyFormsRow in mainRows:
		
		easyFormsRow = (easyFormsRow as EasyFormsRow)
		
		var lastRowBottomEdgePos:float
		
		var availableAreaSize:Vector2
		var parentNode:Node = easyFormsRow.get_parent()
		if easyFormsRow.Domain == EasyFormsRow.DomainEnum.ParentNode:
			availableAreaSize = parentNode.size
			if not easyFormsRow.Independent:
				lastRowBottomEdgePos = lastRowBottomEdgePosDictionary[str(parentNode)]
				
		else:
			availableAreaSize = viewportAreaSize
			if not easyFormsRow.Independent:
				lastRowBottomEdgePos = lastRowBottomEdgePosDictionary[viewportKey]
		
		var heightOffset:float = GetHeightOffset(easyFormsRow, availableAreaSize, lastRowBottomEdgePos)
		
		
		var areaAvailable:Rect2 = Rect2(
			easyFormsRow.SidesMargin,
			0.0,#Not used
			availableAreaSize.x - easyFormsRow.SidesMargin,
			availableAreaSize.y
		)
		
		if easyFormsRow.Independent:
			_easyFormsRowService.PositionContorls(easyFormsRow, areaAvailable, heightOffset, easyFormsRow.size.x, GetEasyFormsRowCellsSizes(easyFormsRow))
		else:
			_easyFormsRowService.PositionContorls(easyFormsRow, areaAvailable, heightOffset, widestRowWidth, widestCellPerColumn)
	pass
	
func GetHeightOffset(easyFormsRow:EasyFormsRow, availableAreaSize:Vector2, lastRowBottomEdgePos:float)->float:
	var veritcalOffsetForCenter:float
	#Only center vertically if the content is smaller than the height of the viewport
	if lastRowBottomEdgePos < availableAreaSize.y:
		veritcalOffsetForCenter = (availableAreaSize.y - lastRowBottomEdgePos) / 2.0
		
	var veritcalOffsetForBottom:float = availableAreaSize.y - lastRowBottomEdgePos
	
	if easyFormsRow.Independent:
		match easyFormsRow.RowVerticalAlignment:
			EasyFormsRow.VerticalAlignmentEnum.Top:
				return 0.0 #+ easyFormsRow.TopButtomMargin
				
			EasyFormsRow.VerticalAlignmentEnum.Center:
				#Only center vertically if the content is smaller than the height of the viewport
				return (availableAreaSize.y / 2.0) - (easyFormsRow.size.y / 2.0)
					
			EasyFormsRow.VerticalAlignmentEnum.Buttom:
				return availableAreaSize.y - easyFormsRow.size.y - (easyFormsRow.TopBottomMargin * 2.0) #easyFormsRow.size.y #- easyFormsRow.TopButtomMargin
	else:
		match easyFormsRow.RowVerticalAlignment:
			EasyFormsRow.VerticalAlignmentEnum.Top:
				return 0.0
				
			EasyFormsRow.VerticalAlignmentEnum.Center:
				#Only center vertically if the content is smaller than the height of the viewport
				return veritcalOffsetForCenter - easyFormsRow.TopBottomMargin
					
			EasyFormsRow.VerticalAlignmentEnum.Buttom:
				return veritcalOffsetForBottom - easyFormsRow.TopBottomMargin
				
	printerr("Unable to calculate Height offset fo node " + easyFormsRow.name)
	return 0.0
	pass
	
func GetEasyFormsRowCellsSizes(easyFormsRow:EasyFormsRow)->Array[float]:
	var allCellsSizes:Array[float] = []
	for i in range(easyFormsRow.SubRows.size()):
		var subRow:= easyFormsRow.SubRows[i] as Array
		for c in range(subRow.size()):
			allCellsSizes.append(subRow[c].Area.size.x)
			
	return allCellsSizes
	pass
	
func GetWidthOfWidestRow(rows:Array)->float:
	rows = rows as Array[EasyFormsRow]
	var widestRowWidth:float
	for row in rows:
		
		if row.Independent == true: continue
		
		if widestRowWidth < row.size.x: widestRowWidth = row.size.x
			
	return widestRowWidth
	pass
	
func GetWidestCellPerColumn(rows:Array)->Array[float]:
	rows = rows as Array[EasyFormsRow]
	var widetsCellsWidth:Array[float] = []
	for row in rows:
		
		if row.Independent == true: continue
		
		for i in range(row.SubRows.size()):
			var subRow:= row.SubRows[i] as Array
						
			for c in range(subRow.size()):
				var cell= subRow[c]
				#cell.Area.size.x
				if c > widetsCellsWidth.size() - 1:
					widetsCellsWidth.append(cell.Area.size.x)
				else:
					if widetsCellsWidth[c] < cell.Area.size.x: widetsCellsWidth[c] = cell.Area.size.x
			
			
			
	return widetsCellsWidth
	pass
