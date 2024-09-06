extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EasyFormsService.SubscribeNodeToProcessTimeTaken(self)
	pass # Replace with function body.

func UpdateMicroSecondsTaken(micosecondsTaken:float)->void:
	%lblMicroseconds.text = str(micosecondsTaken)
	%lblMilliseconds.text = str(micosecondsTaken / 1000.0)
