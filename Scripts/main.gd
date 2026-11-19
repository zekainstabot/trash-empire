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
var trash_nodes: Array[Node3D] = []
var money_label: Label
var bag_label: Label
var message_label: Label
var joystick_center := Vector2.ZERO
var joystick_touch := -1

const YARD_LIMIT := 14.5
const SELL_POINT := Vector3(7.5, 0.0, -6.5)

func _ready() -> void:
	_load_game()
	_build_world()
	_build_player()
	_build_trash()
	_build_ui()
	_update_ui()

func _process(_delta: float) -> void:
	if is_instance_valid(player) and is_instance_valid(camera_pivot):
		camera_pivot.global_position = player.global_position + Vector3(0, 5.4, 8.5)

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

	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.38
	capsule.height = 1.65
	body.mesh = capsule
	body.position.y = 0.85
	body.material_override = _mat(Color(0.92, 0.48, 0.13))
	player.add_child(body)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.23
	head_mesh.height = 0.46
	head.mesh = head_mesh
	head.position = Vector3(0, 1.82, 0)
	head.material_override = _mat(Color(0.76, 0.55, 0.39))
	player.add_child(head)

	var helmet := MeshInstance3D.new()
	var helmet_mesh := SphereMesh.new()
	helmet_mesh.radius = 0.27
	helmet_mesh.height = 0.22
	helmet.mesh = helmet_mesh
	helmet.position = Vector3(0, 2.04, 0)
	helmet.material_override = _mat(Color(0.96, 0.77, 0.12))
	player.add_child(helmet)

	var backpack := MeshInstance3D.new()
	var pack_mesh := BoxMesh.new()
	pack_mesh.size = Vector3(0.58, 0.68, 0.32)
	backpack.mesh = pack_mesh
	backpack.position = Vector3(0, 1.0, 0.34)
	backpack.material_override = _mat(Color(0.12, 0.27, 0.31))
	player.add_child(backpack)

	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38
	shape.height = 1.65
	collision.shape = shape
	collision.position.y = 0.85
	player.add_child(collision)

	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraFollow"
	camera_pivot.global_position = player.global_position + Vector3(0, 5.4, 8.5)
	add_child(camera_pivot)
	camera = Camera3D.new()
	camera.position = Vector3.ZERO
	camera.rotation_degrees = Vector3(22, 0, 0)
	camera.current = true
	camera.fov = 68
	camera_pivot.add_child(camera)
	player.set("camera_pivot", camera_pivot)

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

	var panel := Panel.new()
	panel.position = Vector2(18, 18)
	panel.size = Vector2(285, 104)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.065, 0.075, 0.88)))
	layer.add_child(panel)
	money_label = _label("CASH  $0", Vector2(34, 28), 24, layer)
	bag_label = _label("BAG  0 / 5", Vector2(34, 66), 19, layer)

	message_label = _label("Collect litter around the yard.", Vector2(325, 24), 18, layer)
	message_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	message_label.add_theme_constant_override("shadow_offset_x", 2)
	message_label.add_theme_constant_override("shadow_offset_y", 2)

	var collect := _button("PICK UP", Vector2(-184, -154), Vector2(164, 62), layer)
	_anchor_bottom_right(collect)
	collect.pressed.connect(_collect_nearby)

	var sell := _button("SELL LOAD", Vector2(-184, -82), Vector2(164, 62), layer)
	_anchor_bottom_right(sell)
	sell.pressed.connect(_sell_trash)

	var upgrade := _button("BAG +3  $50", Vector2(18, -82), Vector2(190, 58), layer)
	upgrade.anchor_top = 1.0
	upgrade.anchor_bottom = 1.0
	upgrade.pressed.connect(_upgrade_bag)

	var speed_upgrade := _button("SPEED +  $75", Vector2(18, -150), Vector2(190, 58), layer)
	speed_upgrade.anchor_top = 1.0
	speed_upgrade.anchor_bottom = 1.0
	speed_upgrade.pressed.connect(_upgrade_speed)

	var hint := _label("DRAG LEFT SIDE TO MOVE  •  WASD / ARROWS", Vector2(20, -36), 14, layer)
	hint.anchor_top = 1.0
	hint.anchor_bottom = 1.0

func _input(event: InputEvent) -> void:
	var screen_size := get_viewport().get_visible_rect().size
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x < screen_size.x * 0.55 and event.position.y < screen_size.y - 125 and joystick_touch == -1:
			joystick_touch = event.index
			joystick_center = event.position
		elif not event.pressed and event.index == joystick_touch:
			joystick_touch = -1
			player.call("set_touch_move", Vector2.ZERO)
	elif event is InputEventScreenDrag and event.index == joystick_touch:
		var movement := ((event.position - joystick_center) / 75.0).limit_length(1.0)
		player.call("set_touch_move", movement)

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

func _sell_trash() -> void:
	if player.global_position.distance_to(SELL_POINT) > 5.0:
		_set_message("Take your bag to the green recycling station.")
		return
	if carried == 0:
		_set_message("Your bag is empty.")
		return
	var earned := carried * 10
	money += earned
	carried = 0
	_update_ui()
	_save_game()
	_set_message("Load recycled! You earned $%d." % earned)
	_spawn_trash(6)

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

func _save_game() -> void:
	var save := ConfigFile.new()
	save.set_value("progress", "money", money)
	save.set_value("progress", "carried", carried)
	save.set_value("progress", "capacity", capacity)
	save.set_value("progress", "bag_level", upgrade_level)
	save.set_value("progress", "speed_level", speed_upgrade_level)
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

func _label(value: String, pos: Vector2, font_size: int, parent: Control) -> Label:
	var result := Label.new()
	result.text = value
	result.position = pos
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", Color.WHITE)
	parent.add_child(result)
	return result

func _button(value: String, pos: Vector2, size: Vector2, parent: Control) -> Button:
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
