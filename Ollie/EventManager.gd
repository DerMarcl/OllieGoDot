extends Node

# A dictionary to store the state of events by name
var event_states = {}

func trigger_event(event_name: String):
	print("Event triggered: ", event_name)
	event_states[event_name] = true
	emit_signal("event_triggered", event_name)

func is_event_triggered(event_name: String) -> bool:
	# Returns whether the event has been triggered
	return event_states.get(event_name, false)

# Signal to notify objects when an event is triggered
signal event_triggered(event_name)
