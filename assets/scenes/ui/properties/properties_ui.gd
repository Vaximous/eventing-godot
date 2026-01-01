extends MarginContainer
var current_edited_object : Node3D
@onready var event_button : Button = $PanelContainer/ScrollContainer/VBoxContainer/CenterContainer2/CenterContainer/events

func initialize()->void:
	if !current_edited_object: return
	%properties_label.text = "%s - Properties" %current_edited_object.name

func apply()->void:
	if !current_edited_object: return

	if %name_text.text != "":
		current_edited_object.name = %name_text.text
		current_edited_object.add_to_group(&"named")

	queue_free()
