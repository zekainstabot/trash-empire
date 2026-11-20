extends Node3D

const PLAYER_SCRIPT = preload("res://Scripts/player.gd")
const TRASH_SCRIPT = preload("res://Scripts/trash.gd")

var player: CharacterBody3D
var camera: Camera3D
var camera_pivot: Node3D
var money := 0
var carried := 0
var capacity := 5
var collection_range := 2.5
var upgrade_level := 1
var speed_upgrade_level := 1
var unload_upgrade_level := 1
var unload_timer := 0.0
var upgrade_panel: Panel
var trash_nodes: Array[Node3D] = []
var money_label: Label
var bag_label: Label
var message_label: Label
var joystick_pad: Panel
var joystick_knob: Panel
var joystick_touch := -1
var joystick_max_radius := 58.0
var robot_visual: Node3D
var robot_left_arm: Node3D
var robot_right_arm: Node3D
var robot_left_leg: Node3D
var robot_right_leg: Node3D
var robot_head: Node3D
var robot_anim_time := 0.0

const YARD_LIMIT := 14.5
const SELL_POINT := Vector3(7.5, 0.0, -6.5)

func _ready() -> void:
	_load_game()
	_build_world()
	_build_player()
	_build_trash()
	_build_ui()
	_update_ui()

func _process(delta: float) -> void:
	if is_instance_valid(player) and is_instance_valid(camera_pivot):
		camera_pivot.global_position = player.global_position + Vector3(0, 8.0, 10.5)
	_animate_robot(delta)
	_process_auto_sell(delta)

func _build_world() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.72, 0.78, 0.83)
	env.ambient_light_energy = 0.75
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -32, 0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)

	# Main concrete yard and worn work zones.
	_box("ConcreteYard", Vector3(0, -0.3, 0), Vector3(32, 0.6, 32), Color(0.34, 0.37, 0.35), true)
	_box("RoadLane", Vector3(-8.0, 0.012, 1.0), Vector3(5.0, 0.025, 27.0), Color(0.19, 0.22, 0.22), false)
	for z in range(-11, 13, 4):
		_box("RoadDash", Vector3(-8.0, 0.03, z), Vector3(0.13, 0.025, 1.7), Color(0.88, 0.77, 0.38), false)
	_box("SortingZone", Vector3(7.5, 0.025, -6.5), Vector3(9.0, 0.05, 8.0), Color(0.24, 0.34, 0.30), false)
	_box("PlayerStartZone", Vector3(0, 0.02, 7), Vector3(7, 0.04, 5), Color(0.39, 0.40, 0.35), false)

	# Perimeter walls, fencing, and gate.
	_box("BackWall", Vector3(0, 2.0, -15.5), Vector3(32, 4, 0.5), Color(0.28, 0.32, 0.31), true)
	_box("LeftWall", Vector3(-15.5, 2.0, 0), Vector3(0.5, 4, 32), Color(0.28, 0.32, 0.31), true)
	_box("RightWall", Vector3(15.5, 2.0, 0), Vector3(0.5, 4, 32), Color(0.28, 0.32, 0.31), true)
	for x in range(-14, 15, 2):
		_box("FencePost", Vector3(x, 1.35, 15.0), Vector3(0.16, 2.7, 0.16), Color(0.20, 0.24, 0.24), true)
	_box("FenceRailTop", Vector3(0, 2.45, 15.0), Vector3(30, 0.14, 0.14), Color(0.18, 0.22, 0.22), false)
	_box("FenceRailBottom", Vector3(0, 0.45, 15.0), Vector3(30, 0.14, 0.14), Color(0.18, 0.22, 0.22), false)
	_box("GateLeft", Vector3(-4.2, 1.3, 15.0), Vector3(0.14, 2.6, 0.14), Color(0.82, 0.62, 0.18), false)
	_box("GateRight", Vector3(4.2, 1.3, 15.0), Vector3(0.14, 2.6, 0.14), Color(0.82, 0.62, 0.18), false)

	# Recycling shed with a loading bay.
	_box("ShedBody", Vector3(8.5, 2.0, -12.2), Vector3(11.0, 4.0, 5.0), Color(0.31, 0.38, 0.40), true)
	_box("ShedRoof", Vector3(8.5, 4.15, -12.2), Vector3(11.7, 0.35, 5.7), Color(0.16, 0.21, 0.24), true)
	_box("ShedDoor", Vector3(8.5, 1.55, -9.63), Vector3(4.2, 2.8, 0.12), Color(0.13, 0.18, 0.20), false)
	for x in [6.8, 8.5, 10.2]:
		_box("DoorRib", Vector3(x, 1.55, -9.53), Vector3(0.07, 2.65, 0.08), Color(0.39, 0.45, 0.45), false)
	_box("ShedSign", Vector3(8.5, 3.25, -9.5), Vector3(5.0, 0.65, 0.16), Color(0.08, 0.48, 0.34), false)
	_label_3d("RECYCLING", Vector3(8.5, 3.25, -9.38), 0.42)

	# Conveyor and recycling machine.
	_box("MachineBase", Vector3(7.5, 0.65, -6.5), Vector3(4.4, 1.3, 3.2), Color(0.12, 0.27, 0.34), true)
	_box("MachineBody", Vector3(7.5, 1.65, -6.5), Vector3(3.3, 1.0, 2.5), Color(0.12, 0.48, 0.55), true)
	_box("MachineTop", Vector3(7.5, 2.22, -6.5), Vector3(3.6, 0.18, 2.8), Color(0.23, 0.68, 0.69), false)
	_box("ConveyorFrame", Vector3(4.0, 0.85, -6.5), Vector3(3.0, 0.28, 1.5), Color(0.12, 0.15, 0.16), true)
	_box("ConveyorBelt", Vector3(4.0, 1.03, -6.5), Vector3(2.9, 0.08, 1.35), Color(0.07, 0.09, 0.10), false)
	for x in [2.8, 3.6, 4.4, 5.2]:
		_cylinder("ConveyorRoller", Vector3(x, 0.88, -6.5), 0.12, 1.55, Color(0.48, 0.52, 0.52), true)

	# Sorting bins and industrial props.
	_make_bin(Vector3(12.4, 0, -4.5), Color(0.12, 0.42, 0.78), "PLASTIC")
	_make_bin(Vector3(12.4, 0, -7.7), Color(0.78, 0.56, 0.12), "METAL")
	_make_bin(Vector3(12.4, 0, -10.9), Color(0.18, 0.58, 0.34), "PAPER")
	_make_pallet(Vector3(-11.0, 0, -9.0))
	_make_pallet(Vector3(-11.0, 0, -5.8))
	_make_barrel(Vector3(-12.2, 0, 3.5), Color(0.76, 0.31, 0.16))
	_make_barrel(Vector3(-10.8, 0, 4.1), Color(0.18, 0.43, 0.67))
	_make_tire_stack(Vector3(12.0, 0, 4.5))
	_make_lamp(Vector3(-13.4, 0, -12.5))
	_make_lamp(Vector3(13.4, 0, 10.5))
	_make_tree(Vector3(-13.0, 0, 9.0))
	_make_tree(Vector3(13.0, 0, 1.0))
	_box("SpawnPad", Vector3(0, 0.05, 7), Vector3(4.5, 0.08, 3.5), Color(0.48, 0.48, 0.39), false)
	_label_3d("TRASH EMPIRE", Vector3(0, 3.2, 14.55), 0.65)

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.set_script(PLAYER_SCRIPT)
	player.position = Vector3(0, 0.05, 7)
	player.set("move_speed", 5.0 + float(speed_upgrade_level - 1) * 0.8)
	add_child(player)

	# Compact friendly recycling robot with animated joints.
	robot_visual = Node3D.new()
	robot_visual.name = "RecyclerBot"
	player.add_child(robot_visual)

	_add_robot_box(robot_visual, "Torso", Vector3(0, 1.05, 0), Vector3(0.72, 0.82, 0.48), Color(0.16, 0.30, 0.34))
	_add_robot_box(robot_visual, "ChestPanel", Vector3(0, 1.12, -0.252), Vector3(0.48, 0.42, 0.035), Color(0.08, 0.55, 0.48))
	_add_robot_box(robot_visual, "ChestLight", Vector3(0, 1.12, -0.278), Vector3(0.19, 0.08, 0.025), Color(0.35, 1.0, 0.78))
	_add_robot_box(robot_visual, "Belt", Vector3(0, 0.62, 0), Vector3(0.76, 0.13, 0.5), Color(0.08, 0.13, 0.16))

	robot_head = Node3D.new()
	robot_head.position = Vector3(0, 1.78, 0)
	robot_visual.add_child(robot_head)
	_add_robot_box(robot_head, "HeadShell", Vector3.ZERO, Vector3(0.68, 0.55, 0.52), Color(0.76, 0.84, 0.82))
	_add_robot_box(robot_head, "FaceScreen", Vector3(0, -0.015, -0.273), Vector3(0.53, 0.30, 0.035), Color(0.035, 0.10, 0.14))
	for eye_x in [-0.14, 0.14]:
		_add_robot_sphere(robot_head, "GlowingEye", Vector3(eye_x, 0.025, -0.302), 0.055, Color(0.18, 0.95, 1.0))
	_add_robot_box(robot_head, "Smile", Vector3(0, -0.105, -0.305), Vector3(0.13, 0.018, 0.018), Color(0.35, 1.0, 0.78))
	_add_robot_box(robot_head, "AntennaStem", Vector3(0, 0.34, 0), Vector3(0.055, 0.20, 0.055), Color(0.30, 0.42, 0.44))
	_add_robot_sphere(robot_head, "AntennaGlow", Vector3(0, 0.46, 0), 0.09, Color(0.20, 1.0, 0.65))

	robot_left_arm = _robot_limb(robot_visual, "LeftArm", Vector3(-0.48, 1.30, 0), Color(0.22, 0.43, 0.48))
	robot_right_arm = _robot_limb(robot_visual, "RightArm", Vector3(0.48, 1.30, 0), Color(0.22, 0.43, 0.48))
	robot_left_leg = _robot_leg(robot_visual, "LeftLeg", Vector3(-0.20, 0.52, 0))
	robot_right_leg = _robot_leg(robot_visual, "RightLeg", Vector3(0.20, 0.52, 0))

	var backpack := _add_robot_box(robot_visual, "BatteryPack", Vector3(0, 1.03, 0.34), Vector3(0.55, 0.62, 0.28), Color(0.12, 0.22, 0.26))
	_add_robot_box(robot_visual, "BatteryStripe", Vector3(0, 1.04, 0.495), Vector3(0.34, 0.08, 0.025), Color(0.28, 0.95, 0.67))

	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38
	shape.height = 1.65
	collision.shape = shape
	collision.position.y = 0.85
	player.add_child(collision)

	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraFollow"
	camera_pivot.global_position = player.global_position + Vector3(0, 8.0, 10.5)
	add_child(camera_pivot)
	camera = Camera3D.new()
	camera.position = Vector3.ZERO
	camera.rotation_degrees = Vector3(-30, 0, 0)
	camera.current = true
	camera.fov = 58
	camera_pivot.add_child(camera)
	player.set("camera_pivot", camera_pivot)

	# Short entrance animation when the game starts.
	robot_visual.scale = Vector3(0.15, 0.15, 0.15)
	robot_visual.position.y = -0.45
	var intro := create_tween()
	intro.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	intro.tween_property(robot_visual, "scale", Vector3.ONE, 0.7)
	intro.parallel().tween_property(robot_visual, "position:y", 0.0, 0.7)

func _animate_robot(delta: float) -> void:
	if not is_instance_valid(robot_visual):
		return
	robot_anim_time += delta
	var moving := Vector2(player.velocity.x, player.velocity.z).length() > 0.25
	var stride := sin(robot_anim_time * 10.0) if moving else 0.0
	var bob := absf(stride) * 0.055 if moving else sin(robot_anim_time * 2.2) * 0.025
	robot_visual.position.y = bob
	robot_visual.rotation.z = sin(robot_anim_time * 5.0) * 0.025 if moving else sin(robot_anim_time * 1.5) * 0.012
	robot_left_arm.rotation.x = stride * 0.65
	robot_right_arm.rotation.x = -stride * 0.65
	robot_left_leg.rotation.x = -stride * 0.48
	robot_right_leg.rotation.x = stride * 0.48
	robot_head.rotation.y = sin(robot_anim_time * 1.3) * 0.045

func _add_robot_box(parent: Node3D, part_name: String, pos: Vector3, dimensions: Vector3, color: Color) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = part_name
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	part.mesh = mesh
	part.position = pos
	part.material_override = _mat(color)
	parent.add_child(part)
	return part

func _add_robot_sphere(parent: Node3D, part_name: String, pos: Vector3, radius: float, color: Color) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = part_name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	part.mesh = mesh
	part.position = pos
	part.material_override = _mat(color)
	parent.add_child(part)
	return part

func _robot_limb(parent: Node3D, part_name: String, pos: Vector3, color: Color) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = part_name
	pivot.position = pos
	parent.add_child(pivot)
	_add_robot_box(pivot, "UpperArm", Vector3(0, -0.19, 0), Vector3(0.22, 0.43, 0.24), color)
	_add_robot_sphere(pivot, "Hand", Vector3(0, -0.43, -0.015), 0.14, Color(0.12, 0.22, 0.25))
	return pivot

func _robot_leg(parent: Node3D, part_name: String, pos: Vector3) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = part_name
	pivot.position = pos
	parent.add_child(pivot)
	_add_robot_box(pivot, "Shin", Vector3(0, -0.20, 0), Vector3(0.24, 0.40, 0.25), Color(0.25, 0.36, 0.39))
	_add_robot_box(pivot, "Boot", Vector3(0, -0.42, -0.09), Vector3(0.34, 0.16, 0.43), Color(0.07, 0.12, 0.15))
	return pivot

func _build_trash() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(24):
		var item := Node3D.new()
		item.set_script(TRASH_SCRIPT)
		item.position = _random_trash_position(rng)
		add_child(item)
		trash_nodes.append(item)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var screen := get_viewport().get_visible_rect().size
	var panel := Panel.new()
	panel.position = Vector2(18, 18)
	panel.size = Vector2(245, 100)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.065, 0.075, 0.88)))
	layer.add_child(panel)
	money_label = _label("CASH  $0", Vector2(32, 27), 22, layer)
	bag_label = _label("BAG  0 / 5", Vector2(32, 64), 18, layer)

	message_label = _label("Collect litter around the yard.", Vector2(20, 130), 17, layer)
	message_label.size = Vector2(maxf(280.0, screen.x - 40.0), 48)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	message_label.add_theme_constant_override("shadow_offset_x", 2)
	message_label.add_theme_constant_override("shadow_offset_y", 2)

	var collect := _button("PICK UP", Vector2(-174, -178), Vector2(156, 58), layer)
	_anchor_bottom_right(collect)
	collect.pressed.connect(_collect_nearby)


	# Fixed four-way virtual joystick on the lower-left.
	joystick_pad = Panel.new()
	joystick_pad.position = Vector2(18, -218)
	joystick_pad.size = Vector2(184, 184)
	joystick_pad.anchor_top = 1.0
	joystick_pad.anchor_bottom = 1.0
	joystick_pad.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.055, 0.06, 0.58)))
	layer.add_child(joystick_pad)

	var up_hint := _label("▲", Vector2(79, 8), 20, joystick_pad)
	var down_hint := _label("▼", Vector2(79, 151), 20, joystick_pad)
	var left_hint := _label("◀", Vector2(8, 78), 20, joystick_pad)
	var right_hint := _label("▶", Vector2(151, 78), 20, joystick_pad)
	for arrow in [up_hint, down_hint, left_hint, right_hint]:
		arrow.add_theme_color_override("font_color", Color(0.88, 0.96, 0.92, 0.78))

	joystick_knob = Panel.new()
	joystick_knob.size = Vector2(58, 58)
	joystick_knob.position = (joystick_pad.size - joystick_knob.size) * 0.5
	joystick_knob.add_theme_stylebox_override("panel", _button_style(Color(0.08, 0.48, 0.38, 0.96)))
	joystick_pad.add_child(joystick_knob)

	var upgrades_button := _button("UPGRADES", Vector2(-174, -250), Vector2(156, 58), layer)
	_anchor_bottom_right(upgrades_button)
	upgrades_button.pressed.connect(_toggle_upgrade_panel)

	upgrade_panel = Panel.new()
	upgrade_panel.set_anchors_preset(Control.PRESET_CENTER)
	upgrade_panel.position = Vector2(-170, -170)
	upgrade_panel.size = Vector2(340, 340)
	upgrade_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.075, 0.08, 0.97)))
	upgrade_panel.visible = false
	layer.add_child(upgrade_panel)
	var upgrade_title := _label("UPGRADE STORE", Vector2(24, 20), 24, upgrade_panel)
	var close_upgrades := _button("X", Vector2(282, 14), Vector2(42, 42), upgrade_panel)
	close_upgrades.pressed.connect(_toggle_upgrade_panel)
	var bag_upgrade := _button("BAG CAPACITY +3  |  $%d" % (50 * upgrade_level), Vector2(20, 92), Vector2(300, 58), upgrade_panel)
	bag_upgrade.pressed.connect(_upgrade_bag)
	var movement_upgrade := _button("MOVE SPEED  |  $%d" % (75 * speed_upgrade_level), Vector2(20, 164), Vector2(300, 58), upgrade_panel)
	movement_upgrade.pressed.connect(_upgrade_speed)
	var unload_upgrade := _button("UNLOAD SPEED  |  $%d" % (100 * unload_upgrade_level), Vector2(20, 236), Vector2(300, 58), upgrade_panel)
	unload_upgrade.pressed.connect(_upgrade_unload)

	var hint := _label("DRAG PAD TO MOVE", Vector2(18, -28), 12, layer)
	hint.anchor_top = 1.0
	hint.anchor_bottom = 1.0

func _input(event: InputEvent) -> void:
	if not is_instance_valid(joystick_pad) or not is_instance_valid(player):
		return
	if event is InputEventScreenTouch:
		if event.pressed and joystick_touch == -1 and joystick_pad.get_global_rect().has_point(event.position):
			joystick_touch = event.index
			_update_joystick(event.position)
		elif not event.pressed and event.index == joystick_touch:
			_reset_joystick()
	elif event is InputEventScreenDrag and event.index == joystick_touch:
		_update_joystick(event.position)

func _update_joystick(touch_position: Vector2) -> void:
	var center := joystick_pad.get_global_rect().get_center()
	var offset := (touch_position - center).limit_length(joystick_max_radius)
	var movement := offset / joystick_max_radius
	player.call("set_touch_move", movement)
	joystick_knob.position = (joystick_pad.size - joystick_knob.size) * 0.5 + offset

func _reset_joystick() -> void:
	joystick_touch = -1
	player.call("set_touch_move", Vector2.ZERO)
	joystick_knob.position = (joystick_pad.size - joystick_knob.size) * 0.5

func _collect_nearby() -> void:
	if carried >= capacity:
		_set_message("Bag full! Return to the recycling station.")
		return
	var nearest: Node3D
	var best := collection_range
	for item in trash_nodes:
		if is_instance_valid(item):
			var distance := player.global_position.distance_to(item.global_position)
			if distance < best:
				best = distance
				nearest = item
	if nearest:
		nearest.queue_free()
		trash_nodes.erase(nearest)
		carried += 1
		_update_ui()
		_save_game()
		_set_message("Collected! Keep cleaning the yard.")
	else:
		_set_message("Get closer to a piece of trash.")

func _process_auto_sell(delta: float) -> void:
	if not is_instance_valid(player):
		return
	var inside_zone := player.global_position.distance_to(SELL_POINT) <= 5.0
	if not inside_zone or carried <= 0:
		unload_timer = 0.0
		return
	unload_timer += delta
	var seconds_per_item := maxf(0.25, 1.5 - float(unload_upgrade_level - 1) * 0.2)
	if unload_timer >= seconds_per_item:
		unload_timer = 0.0
		carried -= 1
		money += 10
		_update_ui()
		_save_game()
		_set_message("Recycling... +$10")
		if carried == 0:
			_set_message("Bag emptied! Money added.")
			_spawn_trash(6)

func _toggle_upgrade_panel() -> void:
	if is_instance_valid(upgrade_panel):
		upgrade_panel.visible = not upgrade_panel.visible

func _upgrade_bag() -> void:
	var cost := 50 * upgrade_level
	if money < cost:
		_set_message("You need $%d for the next bag upgrade." % cost)
		return
	money -= cost
	capacity += 3
	upgrade_level += 1
	_update_ui()
	_save_game()
	_set_message("Upgrade purchased! New bag capacity: %d." % capacity)

func _upgrade_speed() -> void:
	var cost := 75 * speed_upgrade_level
	if money < cost:
		_set_message("You need $%d for the speed upgrade." % cost)
		return
	money -= cost
	speed_upgrade_level += 1
	player.set("move_speed", 5.0 + float(speed_upgrade_level - 1) * 0.8)
	_update_ui()
	_save_game()
	_set_message("Movement speed upgraded!")

func _upgrade_unload() -> void:
	var cost := 100 * unload_upgrade_level
	if money < cost:
		_set_message("You need $%d for faster unloading." % cost)
		return
	money -= cost
	unload_upgrade_level += 1
	_update_ui()
	_save_game()
	_set_message("Unloading speed upgraded!")

func _save_game() -> void:
	var save := ConfigFile.new()
	save.set_value("progress", "money", money)
	save.set_value("progress", "carried", carried)
	save.set_value("progress", "capacity", capacity)
	save.set_value("progress", "bag_level", upgrade_level)
	save.set_value("progress", "speed_level", speed_upgrade_level)
	save.set_value("progress", "unload_level", unload_upgrade_level)
	save.save("user://trash_empire.save")

func _load_game() -> void:
	var save := ConfigFile.new()
	if save.load("user://trash_empire.save") != OK:
		return
	money = int(save.get_value("progress", "money", 0))
	carried = int(save.get_value("progress", "carried", 0))
	capacity = int(save.get_value("progress", "capacity", 5))
	upgrade_level = int(save.get_value("progress", "bag_level", 1))
	speed_upgrade_level = int(save.get_value("progress", "speed_level", 1))
	unload_upgrade_level = int(save.get_value("progress", "unload_level", 1))

func _spawn_trash(amount: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(amount):
		var item := Node3D.new()
		item.set_script(TRASH_SCRIPT)
		item.position = _random_trash_position(rng)
		add_child(item)
		trash_nodes.append(item)

func _random_trash_position(rng: RandomNumberGenerator) -> Vector3:
	var point := Vector3(rng.randf_range(-11.5, 11.5), 0.34, rng.randf_range(-10.0, 11.5))
	var attempts := 0
	while point.distance_to(SELL_POINT) < 4.0 and attempts < 10:
		point = Vector3(rng.randf_range(-11.5, 11.5), 0.34, rng.randf_range(-10.0, 11.5))
		attempts += 1
	return point

func _update_ui() -> void:
	money_label.text = "CASH  $%d" % money
	bag_label.text = "BAG  %d / %d" % [carried, capacity]

func _set_message(value: String) -> void:
	message_label.text = value

func _anchor_bottom_right(control: Control) -> void:
	control.anchor_left = 1.0
	control.anchor_right = 1.0
	control.anchor_top = 1.0
	control.anchor_bottom = 1.0

func _box(node_name: String, pos: Vector3, size: Vector3, color: Color, solid: bool) -> void:
	var body: Node3D = StaticBody3D.new() if solid else Node3D.new()
	body.name = node_name
	body.position = pos
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = _mat(color)
	body.add_child(mesh)
	if solid:
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		body.add_child(collision)
	add_child(body)

func _cylinder(node_name: String, pos: Vector3, radius: float, height: float, color: Color, horizontal: bool) -> void:
	var mesh := MeshInstance3D.new()
	var shape := CylinderMesh.new()
	shape.top_radius = radius
	shape.bottom_radius = radius
	shape.height = height
	mesh.mesh = shape
	mesh.position = pos
	mesh.material_override = _mat(color)
	if horizontal:
		mesh.rotation_degrees.z = 90
	add_child(mesh)

func _make_bin(pos: Vector3, color: Color, label_text: String) -> void:
	_box("RecyclingBin", pos + Vector3(0, 0.7, 0), Vector3(1.7, 1.4, 1.7), color, true)
	_box("BinLid", pos + Vector3(0, 1.48, 0), Vector3(1.85, 0.16, 1.85), Color(0.10, 0.14, 0.15), false)
	_label_3d(label_text, pos + Vector3(0, 1.0, 0.88), 0.22)

func _make_pallet(pos: Vector3) -> void:
	for z in [-0.55, 0.0, 0.55]:
		_box("PalletBoard", pos + Vector3(0, 0.12, z), Vector3(2.2, 0.22, 0.28), Color(0.43, 0.29, 0.17), false)
	for x in [-0.75, 0.0, 0.75]:
		_box("PalletSupport", pos + Vector3(x, 0.0, 0), Vector3(0.28, 0.16, 1.45), Color(0.29, 0.20, 0.13), false)
	_box("Crate", pos + Vector3(0, 0.9, 0), Vector3(1.45, 1.4, 1.25), Color(0.56, 0.39, 0.22), true)
	for y in [0.35, 1.35]:
		_box("CrateSlat", pos + Vector3(0, y, 0.64), Vector3(1.5, 0.08, 0.08), Color(0.34, 0.23, 0.14), false)

func _make_barrel(pos: Vector3, color: Color) -> void:
	_cylinder("Barrel", pos + Vector3(0, 0.58, 0), 0.48, 1.16, color, false)
	for y in [0.25, 0.9]:
		_cylinder("BarrelRim", pos + Vector3(0, y, 0), 0.5, 0.07, Color(0.18, 0.20, 0.20), false)

func _make_tire_stack(pos: Vector3) -> void:
	for i in range(3):
		var tire := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = 0.28
		torus.outer_radius = 0.52
		tire.mesh = torus
		tire.position = pos + Vector3(0, 0.38 + i * 0.45, 0)
		tire.rotation_degrees.x = 90
		tire.material_override = _mat(Color(0.055, 0.065, 0.07))
		add_child(tire)

func _make_lamp(pos: Vector3) -> void:
	_cylinder("LampPost", pos + Vector3(0, 2.6, 0), 0.09, 5.2, Color(0.16, 0.19, 0.20), false)
	_box("LampHead", pos + Vector3(0, 5.25, 0), Vector3(0.9, 0.22, 0.55), Color(0.88, 0.82, 0.57), false)
	var light := OmniLight3D.new()
	light.position = pos + Vector3(0, 4.9, 0)
	light.light_color = Color(1.0, 0.82, 0.58)
	light.light_energy = 0.45
	light.omni_range = 7.0
	add_child(light)

func _make_tree(pos: Vector3) -> void:
	_cylinder("TreeTrunk", pos + Vector3(0, 1.0, 0), 0.22, 2.0, Color(0.32, 0.21, 0.13), false)
	var crown := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 1.8
	crown.mesh = sphere
	crown.position = pos + Vector3(0, 2.35, 0)
	crown.material_override = _mat(Color(0.18, 0.36, 0.23))
	add_child(crown)

func _label_3d(value: String, pos: Vector3, font_size: float) -> void:
	var label := Label3D.new()
	label.text = value
	label.position = pos
	label.font_size = int(font_size * 48.0)
	label.pixel_size = 0.01
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color(0.95, 0.98, 0.91)
	add_child(label)

func _panel_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.25, 0.42, 0.37, 0.9)
	return style

func _mat(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	return material

func _label(value: String, pos: Vector2, font_size: int, parent: Node) -> Label:
	var result := Label.new()
	result.text = value
	result.position = pos
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", Color.WHITE)
	parent.add_child(result)
	return result

func _button(value: String, pos: Vector2, size: Vector2, parent: Node) -> Button:
	var result := Button.new()
	result.text = value
	result.position = pos
	result.size = size
	result.add_theme_font_size_override("font_size", 18)
	result.add_theme_color_override("font_color", Color.WHITE)
	result.add_theme_stylebox_override("normal", _button_style(Color(0.08, 0.34, 0.29)))
	result.add_theme_stylebox_override("hover", _button_style(Color(0.12, 0.46, 0.37)))
	result.add_theme_stylebox_override("pressed", _button_style(Color(0.05, 0.24, 0.22)))
	parent.add_child(result)
	return result

func _button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_bottom = 3
	style.border_color = Color(0.04, 0.17, 0.16)
	return style
