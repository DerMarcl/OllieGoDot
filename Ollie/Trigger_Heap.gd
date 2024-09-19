extends Area2D

@export var event_to_trigger: String = "" 

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Bonkable")
	if GameManager.is_despawned(name):
		queue_free()


func hit():
	queue_free()  # Destroy the box
	GameManager.mark_as_despawned(name)
	if event_to_trigger != "":
		EventManager.trigger_event(event_to_trigger)
