extends Node

##Keeps track of all events and their associated scripts. For example, if onActivated.gd has the input 'onActivate' it will register that function to this dict allowing it to be visible within the eventing UI
var event_dict : Dictionary

##Keeps track of all targets and their associated scripts. For example, if onActivated.gd adds the target 'Self' it will register that function to this dict allowing it to be visible within the eventing UI and calling the function to return itself
var target_dict : Dictionary = {
	&"Self": &"Self",
	&"Player": &"Player"
}

##Keeps track of all outputs and their associated scripts. For example, if onActivated.gd adds the output 'PlaySound' it will register that function to this dict allowing it to be visible within the eventing UI and calling the function to do 'PlaySound'
var output_dict : Dictionary

func _ready() -> void:
	Util.register_output("PlaySound",play_sound,&"Self")

func get_named_object(object_name:String)->Node3D:
	for i in get_tree().get_nodes_in_group(&"named"):
		if i.name == object_name:
			return i
	return null

func play_sound()->void:
	print("Pretend a sound played..")
