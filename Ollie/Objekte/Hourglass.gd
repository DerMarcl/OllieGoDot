extends Area2D
@export var Hourglass_number : int = 0
@onready var game_manager = %GameManager
@onready var hourglass_1 = $"../UI/Hourglasses/Hourglass1"
@onready var hourglass_2 = $"../UI/Hourglasses/Hourglass2"
@onready var hourglass_3 = $"../UI/Hourglasses/Hourglass3"


func _on_body_entered(body):
	if (body.name == "Ollie"):
		HourglassShown()
		GameManager.mark_as_despawned(name)
		queue_free()

	if (body.name == "DinoRider"):
		HourglassShown()
		GameManager.Hourglass_shown
		queue_free()

func HourglassShown():
	Hourglass_number = Hourglass_number
	if (Hourglass_number == 1):
		hourglass_1.show()
	if (Hourglass_number == 2):
		hourglass_2.show()
	if (Hourglass_number == 3):
		hourglass_3.show()
