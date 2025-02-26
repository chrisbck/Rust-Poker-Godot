extends Node2D
class_name Stack

var amount

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_amount(is_active: bool, amount: int = 0) -> void:
	if is_active:
		show()
		self.amount = amount
	else:
		self.amount = 0
		hide()
	
