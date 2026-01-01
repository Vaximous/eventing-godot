class_name FreeLookCamera extends Camera3D
@onready var desktop_hud : Control = $DesktopHud
var is_in_menu : bool = false

@export var freecam : bool = true:
	set(value):
		freecam = value
		if value:
			%CharacterBody3D.process_mode = Node.PROCESS_MODE_DISABLED
			%RigidBody3D.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			_direction = Vector3.ZERO
			%CharacterBody3D.velocity = Vector3.ZERO
			%CharacterBody3D.global_position = global_position
			%CharacterBody3D.process_mode = Node.PROCESS_MODE_INHERIT
			$CharacterBody3D.add_collision_exception_with(%RigidBody3D)
			%RigidBody3D.process_mode = Node.PROCESS_MODE_DISABLED

# Modifier keys' speed multiplier
const SHIFT_MULTIPLIER = 2.5
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER

const WALK_SHIFT_MULTIPLIER = 8
const WALK_MULT = 5


@export_range(0.0, 1.0) var sensitivity = 0.25

# Mouse state
var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0

# Movement state
var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 30
var _deceleration = -10
var _vel_multiplier = 4

# Keyboard state
var _w = false
var _s = false
var _a = false
var _d = false
var _q = false
var _e = false
var _shift = false
var _alt = false

func _ready() -> void:
	initialize()

func initialize()->void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	%CharacterBody3D.global_position = global_position

func _input(event):
	# Receives mouse motion
	if event is InputEventMouseMotion:
		_mouse_position = event.relative

	# Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if Input.mouse_mode == Input.MouseMode.MOUSE_MODE_CAPTURED:
					activate_object()

			MOUSE_BUTTON_RIGHT:
				create_properties_panel()
				#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)

			MOUSE_BUTTON_WHEEL_UP: # Increases max velocity
				if freecam:
					_vel_multiplier = clamp(_vel_multiplier * 1.1, 0.2, 20)
			MOUSE_BUTTON_WHEEL_DOWN: # Decereases max velocity
				if freecam:
					_vel_multiplier = clamp(_vel_multiplier / 1.1, 0.2, 20)


	if event is InputEventKey:
		match event.keycode:
			KEY_SHIFT:
				_shift = event.pressed
			KEY_ESCAPE:
				if is_in_menu:
					hide_mouse()
			KEY_BACKSPACE:
				pass
			KEY_SPACE:
				jump()
			KEY_V:
				if event.is_pressed():
					freecam = !freecam
			KEY_W:
				_w = event.pressed
			KEY_S:
				_s = event.pressed
			KEY_A:
				_a = event.pressed
			KEY_D:
				_d = event.pressed
			KEY_Q:
				_q = event.pressed
			KEY_E:
				_e = event.pressed

# Updates mouselook and movement every frame
func _process(delta):
	_update_mouselook()
	_update_movement(delta)
	%Camera3D.rotation = rotation
	%Camera3D.position = position

# Updates camera movement
func _update_movement(delta):
	# Computes desired direction from key states
	_direction = Vector3((_d as float) - (_a as float),
						(_e as float) - (_q as float),
						(_s as float) - (_w as float))

	# Computes the change in velocity due to desired direction and "drag"
	# The "drag" is a constant acceleration on the camera to bring it's velocity to 0
	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * _vel_multiplier * delta

	# Compute modifiers' speed multiplier
	var speed_multi = 1
	if _shift and freecam: speed_multi *= SHIFT_MULTIPLIER
	if _alt and freecam: speed_multi *= ALT_MULTIPLIER

	if _shift and !freecam: speed_multi *= WALK_SHIFT_MULTIPLIER
	if !_shift and !freecam: speed_multi *= WALK_MULT

	# Checks if we should bother translating the camera
	if freecam:
		if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
			# Sets the velocity to 0 to prevent jittering due to imperfect deceleration
			_velocity = Vector3.ZERO
		else:
			# Clamps speed to stay within maximum value (_vel_multiplier)
			_velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
			_velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
			_velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier)

			translate(_velocity * delta * speed_multi)
		%RigidBody3D.global_position = global_position
	else:
		if _direction == Vector3.ZERO and offset.length_squared() > %CharacterBody3D.velocity.length_squared():
			%CharacterBody3D.velocity = Vector3.ZERO
		else:
			_direction.y = 0
			if !%CharacterBody3D.is_on_floor():
				%CharacterBody3D.velocity.y += %CharacterBody3D.get_gravity().y * delta
			_vel_multiplier = speed_multi
			%CharacterBody3D.velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier) * speed_multi
			%CharacterBody3D.velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier) * speed_multi
			%CharacterBody3D.velocity = %CharacterBody3D.velocity.rotated(Vector3.UP,rotation.y)

		global_position = lerp(global_position,$%camera_position.global_position,24*delta)

		%CharacterBody3D.move_and_slide()
# Updates mouse look
func _update_mouselook():
	# Only rotates mouse if the mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sensitivity
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		_mouse_position = Vector2(0, 0)

		# Prevents looking up/down too far
		pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
		_total_pitch += pitch

		rotate_y(deg_to_rad(-yaw))
		%CharacterBody3D.rotate_y(deg_to_rad(-yaw))
		rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))

func jump()->void:
	if !freecam and %CharacterBody3D.is_on_floor():
		%CharacterBody3D.velocity.y += 4

func is_character_cast_colliding()->bool:
	return %character_cast.is_colliding()

func hide_mouse()->void:
	is_in_menu = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func create_event_panel()->void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var property = Util.create_events_ui(%player_cast.get_collider())
	is_in_menu = true
	add_child(property)
	#property.position = get_viewport().get_visible_rect().size/2

func create_properties_panel()->void:
	if is_in_menu: return
	if !%player_cast.is_colliding(): return

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var property = Util.create_properties_ui(%player_cast.get_collider())
	is_in_menu = true
	add_child(property)
	property.initialize()
	property.tree_exited.connect(hide_mouse)
	property.event_button.pressed.connect(create_event_panel)
	property.position = get_viewport().get_visible_rect().size/2

func activate_object()->void:
	if !%player_cast.is_colliding(): return
	var object = %player_cast.get_collider()

	if object.has_meta(&"events"):
		for i in object.get_meta(&"events"):
			var input = i[0]
			var target = i[1]
			var output = i[2]
			#print("Event - Pre Check: %s|%s|%s" %[input,target,output])

			match target:
				&"Self":
					target = object
				&"Player":
					target = self

			#print("Event: %s|%s|%s" %[input,target,output])

			if input == &"onActivate":
				#print(i[0])
				Util.process_event(0,input,target,output,[])
