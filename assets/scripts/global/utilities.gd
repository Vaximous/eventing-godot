extends Node

func register_event(script_name:String, event:Callable)->void:
	GameManager.event_dict.get_or_add(script_name,event)

func register_target(script_name:String, get_target_func:Variant)->void:
	GameManager.target_dict.get_or_add(script_name,get_target_func)

func register_output(script_name:String, output_func:Callable, target_group : StringName)->void:
	GameManager.output_dict.get_or_add(script_name,[target_group,output_func])

func create_events_ui(object:Node3D)->MarginContainer:
	var ui = load("res://assets/scenes/ui/eventing/eventing_ui.tscn").instantiate()
	ui.eventing_object = object
	return ui

func create_properties_ui(object:Node3D)->MarginContainer:
	var ui = load("res://assets/scenes/ui/properties/properties_ui.tscn").instantiate()
	ui.current_edited_object = object
	return ui

func process_event(delay:float, object:Variant,victim:Variant,event:StringName,binds : Array)->void:
	var called_event

	if GameManager.event_dict.get(event):
		called_event = GameManager.event_dict.get(event)
	elif GameManager.output_dict.get(event):
		called_event = GameManager.output_dict.get(event)

	if !called_event:return

	if called_event is Array:
		called_event = called_event[1]

	if delay > 0:
		await get_tree().create_timer(delay).timeout

	var arg_count = called_event.get_argument_count()
	#print("Arg: %s | Count: %s" %[called_event,arg_count])
	match  arg_count:
		0:
			called_event.call()
		1:
			called_event.call(object)
		2:
			called_event.call(object,victim)
		3:
			called_event.call(object,victim,binds)
