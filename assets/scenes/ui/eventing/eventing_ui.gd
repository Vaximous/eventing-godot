extends MarginContainer
var eventing_object : Node3D
var event_entry_scene : PackedScene = load("res://assets/scenes/ui/eventing/event_entry.tscn")
var curr_events : Array = []

func _ready() -> void:
	clear_events()
	load_events()

func clear_events()->void:
	for i in get_tree().get_nodes_in_group(&"%s_events"%eventing_object.name):
		i.queue_free()

func add_event_entry()->Control:
	var loaded_entry = event_entry_scene.instantiate()
	%event_entries.add_child(loaded_entry)
	loaded_entry.add_to_group(&"%s_events"%eventing_object.name)
	return loaded_entry

func subtract_from_curr_events(index:int)->Array:
	curr_events.remove_at(index)
	return curr_events

func add_to_curr_events(value:Array)->Array:
	curr_events.append(value)
	return curr_events

func load_events()->void:
	if !eventing_object: return

	if eventing_object.has_meta(&"events"):
		curr_events = eventing_object.get_meta(&"events")

	if !curr_events.is_empty():
		for i in curr_events.size():
			var entry = add_event_entry()
			entry.set_meta(&'id',i)
			entry.load_event_array(curr_events[i])
			entry.tree_exited.connect(subtract_from_curr_events.bind(entry.get_meta(&'id')))

func get_current_event_entries()->Array:
	return get_tree().get_nodes_in_group(&"%s_events"%eventing_object.name)

func get_event_count()->int:
	return get_current_event_entries().size()

func apply_to_object()->void:
	for i in get_current_event_entries():
		add_to_curr_events(i.get_current_events())

	eventing_object.set_meta(&"events", curr_events)

	queue_free()
