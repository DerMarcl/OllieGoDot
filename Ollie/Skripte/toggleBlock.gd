extends Node2D

@onready var game_manager = %GameManager
@export var Visible_on = true
@export var toggle_Event = ""
var tilemap_ref = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Store the TileMap reference in the variable
	tilemap_ref = $TileMap
		
	if toggle_Event != "":
		if EventManager.is_event_triggered(toggle_Event):
			Visible_on = not Visible_on 
		else:
			EventManager.connect("event_triggered", self._on_event_triggered)
	else:
		Visible_on = true  # No event, visible by default
	
	statechange()


func _on_event_triggered(triggered_event_name: String):
	if triggered_event_name == toggle_Event:
		Visible_on = not Visible_on
		statechange()
		
func statechange():
	if not Visible_on:
		# Remove the TileMap (deactivate it)
		if tilemap_ref and tilemap_ref.get_parent():
			remove_child(tilemap_ref)
	else:
		# Re-add the TileMap (reactivate it)
		if tilemap_ref and not tilemap_ref.get_parent():
			add_child(tilemap_ref)


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		game_manager.kill_player()
