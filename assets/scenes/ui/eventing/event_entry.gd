extends MarginContainer
var delay : float = 0.0
var selected_input : StringName:
	set(value):
		selected_input = value
		set_target_visible(true)
var selected_target : StringName:
	set(value):
		selected_target = value
		clear_all_outputs()
		scan_outputs()
		set_output_visible(true)
var selected_outputs : StringName

func _ready() -> void:
	set_target_visible(false)
	set_output_visible(false)

	scan_inputs()
	#scan_outputs()
	scan_targets()

func set_output_visible(visibility:bool)->void:
	if visibility:
		%output.show()
		%output_sep.show()
	else:
		%output.hide()
		%output_sep.hide()

func set_target_visible(visibility:bool)->void:
	if visibility:
		%target.show()
		%target_sep.show()
	else:
		%target.hide()
		%target_sep.hide()

func clear_all_outputs()->void:
	var menu : PopupMenu = %output.get_popup()
	for i in menu.item_count:
		menu.remove_item(i)

func set_input_pressed(id:int)->void:
	var menu : PopupMenu = %input.get_popup()
	var text = menu.get_item_text(id)
	%input.text = text
	selected_input = text
	print(GameManager.event_dict[text])

func set_target_pressed(id:int)->void:
	var output_menu : PopupMenu = %output.get_popup()
	var menu : PopupMenu = %target.get_popup()
	var text = menu.get_item_text(id)


	clear_all_outputs()
	%target.text = text
	selected_target = text

func set_output_pressed(id:int)->void:
	var menu : PopupMenu = %output.get_popup()
	var text = menu.get_item_text(id)
	%output.text = text
	selected_outputs = text

func scan_inputs()->void:
	var menu : PopupMenu = %input.get_popup()
	menu.id_pressed.connect(set_input_pressed)
	for i in GameManager.event_dict:
		print(i)
		%input.get_popup().add_item(i)

func scan_targets()->void:
	var menu : PopupMenu = %target.get_popup()
	menu.id_pressed.connect(set_target_pressed)
	for i in GameManager.target_dict:
		print(i)
		%target.get_popup().add_item(i)

func scan_outputs()->void:
	var menu : PopupMenu = %output.get_popup()
	menu.id_pressed.connect(set_output_pressed)
	for i in GameManager.output_dict:
		var group : StringName = GameManager.output_dict.get(i)[0]
		print(GameManager.output_dict.get(i)[0])
		if group == selected_target:
			%output.get_popup().add_item(i)

func get_current_events()->Array:
	return [selected_input,selected_target,selected_outputs]

func load_event_array(event_array:Array)->void:
	var input_popup : PopupMenu = %input.get_popup()
	##Event should be as follows [0 = Input | 1 = Target | 2 = Output]
	selected_input = event_array[0]
	selected_target = event_array[1]
	selected_outputs = event_array[2]

	for i in input_popup.item_count:
		if input_popup.get_item_text(i) == selected_input:
			var text = input_popup.get_item_text(i)
			%input.text = text
			selected_input = text
