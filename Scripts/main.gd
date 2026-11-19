extends Node3D

const PLAYER_SCRIPT = preload("res://Scripts/player.gd")
const TRASH_SCRIPT = preload("res://Scripts/trash.gd")

var player: CharacterBody3D
var camera: Camera3D
var money := 0
var carried := 0
var capacity := 5
var collection_range := 2.4
var upgrade_level := 1
var trash_nodes: Array[Node3D] = []
var money_label: Label
var bag_label: Label
var message_label: Label
var joystick_center := Vector2.ZERO
var joystick_touch := -1
var joystick_value := Vector2.ZERO

func _ready() -> void:
	_build_world()
	_build_player()
	_build_trash()
	_build_ui()
	_update_ui()

func _build_world() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.7, 0.76, 0.82)
	env.ambient_light_energy = 0.8
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -25, 0)
	sun.light_energy = 1.2
	add_child(sun)
	_box("Ground", Vector3(0, -0.25, 0), Vector3(32, 0.5, 32), Color(0.25, 0.31, 0.27), true)
	_box("BackWall", Vector3(0, 2, -15.5), Vector3(32, 4, 0.5), Color(0.35, 0.39, 0.37), true)
	_box("LeftWall", Vector3(-15.5, 2, 0), Vector3(0.5, 4, 32), Color(0.35, 0.39, 0.37), true)
	_box("RightWall", Vector3(15.5, 2, 0), Vector3(0.5, 4, 32), Color(0.35, 0.39, 0.37), true)
	_box("RecyclePlatform", Vector3(8, 0.15, -7), Vector3(5, 0.3, 4), Color(0.12, 0.48, 0.34), true)
	_box("Machine", Vector3(8, 1.2, -7), Vector3(2.2, 2.1, 2.2), Color(0.16, 0.48, 0.72), true)
	_box("MachineTop", Vector3(8, 2.35, -7), Vector3(2.4, 0.25, 2.4), Color(0.25, 0.7, 0.85), false)
	_box("SpawnPad", Vector3(0, 0.03, 5), Vector3(5, 0.06, 4), Color(0.35, 0.39, 0.33), false)

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.set_script(PLAYER_SCRIPT)
	player.position = Vector3(0, 1, 5)
	player.move_speed = 5.0
	add_child(player)
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.42
	capsule.height = 1.8
	var visual := MeshInstance3D.new()
	visual.mesh = capsule
	visual.position.y = 0.9
	visual.material_override = _mat(Color(0.95, 0.62, 0.18))
	player.add_child(visual)
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.42
	shape.height = 1.8
	collision.shape = shape
	collision.position.y = 0.9
	player.add_child(collision)
	var pivot := Node3D.new()
	pivot.position = Vector3(0, 5.5, 8)
	player.add_child(pivot)
	camera = Camera3D.new()
	camera.position = Vector3(0, 0, 0)
	camera.rotation_degrees = Vector3(-22, 0, 0)
	camera.current = true
	pivot.add_child(camera)
	player.camera_pivot = pivot

func _build_trash() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(18):
		var item := Node3D.new()
		item.set_script(TRASH_SCRIPT)
		item.position = Vector3(rng.randf_range(-11, 11), 0.35, rng.randf_range(-10, 10))
		if item.position.distance_to(Vector3(8, 0, -7)) < 4.0:
			item.position.x -= 5.0
		add_child(item)
		trash_nodes.append(item)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := ColorRect.new()
	panel.color = Color(0.04, 0.07, 0.08, 0.78)
	panel.position = Vector2(16, 16)
	panel.size = Vector2(310, 112)
	layer.add_child(panel)
	money_label = _label("Money: $0", Vector2(30, 25), 24, layer)
	bag_label = _label("Bag: 0 / 5", Vector2(30, 62), 20, layer)
	message_label = _label("Collect trash and sell it at the green station.", Vector2(340, 24), 18, layer)
	var collect := _button("COLLECT", Vector2(-190, -115), Vector2(160, 64), layer)
	collect.anchor_left = 1.0
	collect.anchor_right = 1.0
	collect.anchor_top = 1.0
	collect.anchor_bottom = 1.0
	collect.pressed.connect(_collect_nearby)
	var sell := _button("SELL", Vector2(-190, -40), Vector2(160, 64), layer)
	sell.anchor_left = 1.0
	sell.anchor_right = 1.0
	sell.anchor_top = 1.0
	sell.anchor_bottom = 1.0
	sell.pressed.connect(_sell_trash)
	var upgrade := _button("UPGRADE BAG  $50", Vector2(16, -88), Vector2(220, 58), layer)
	upgrade.anchor_top = 1.0
	upgrade.anchor_bottom = 1.0
	upgrade.pressed.connect(_upgrade_bag)
	var joystick_hint := _label("TOUCH LEFT SIDE TO MOVE  •  WASD ON PC", Vector2(20, -42), 14, layer)
	joystick_hint.anchor_top = 1.0
	joystick_hint.anchor_bottom = 1.0

func _input(event: InputEvent) -> void:
	var screen_size := get_viewport().get_visible_rect().size
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x < screen_size.x * 0.55 and joystick_touch == -1:
			joystick_touch = event.index
			joystick_center = event.position
			joystick_value = Vector2.ZERO
		elif not event.pressed and event.index == joystick_touch:
			joystick_touch = -1
			joystick_value = Vector2.ZERO
			player.set_touch_move(Vector2.ZERO)
	elif event is InputEventScreenDrag and event.index == joystick_touch:
		joystick_value = ((event.position - joystick_center) / 70.0).limit_length(1.0)
		player.set_touch_move(joystick_value)

func _collect_nearby() -> void:
	if carried >= capacity:
		_set_message("Your bag is full. Sell your trash first.")
		return
	var nearest: Node3D
	var best := collection_range
	for item in trash_nodes:
		if is_instance_valid(item) and item.visible:
			var distance := player.global_position.distance_to(item.global_position)
			if distance < best:
				best = distance
				nearest = item
	if nearest:
		nearest.queue_free()
		trash_nodes.erase(nearest)
		carried += 1
		_update_ui()
		_set_message("Trash collected! +1")
	else:
		_set_message("Move closer to a piece of trash.")

func _sell_trash() -> void:
	if player.global_position.distance_to(Vector3(8, 0, -7)) > 4.2:
		_set_message("Go to the green recycling station to sell.")
		return
	if carried == 0:
		_set_message("Your bag is empty.")
		return
	var earned := carried * 10
	money += earned
	carried = 0
	_update_ui()
	_set_message("Sold! You earned $%d." % earned)
	_spawn_trash(5)

func _upgrade_bag() -> void:
	var cost := 50 * upgrade_level
	if money < cost:
		_set_message("You need $%d for the next upgrade." % cost)
		return
	money -= cost
	capacity += 3
	upgrade_level += 1
	_update_ui()
	_set_message("Bag upgraded! Capacity is now %d." % capacity)

func _spawn_trash(amount: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(amount):
		var item := Node3D.new()
		item.set_script(TRASH_SCRIPT)
		item.position = Vector3(rng.randf_range(-11, 11), 0.35, rng.randf_range(-10, 10))
		add_child(item)
		trash_nodes.append(item)

func _update_ui() -> void:
	money_label.text = "Money: $%d" % money
	bag_label.text = "Bag: %d / %d" % [carried, capacity]

func _set_message(value: String) -> void:
	message_label.text = value

func _box(node_name: String, pos: Vector3, size: Vector3, color: Color, solid: bool) -> void:
	var body := StaticBody3D.new() if solid else Node3D.new()
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
	result.add_theme_font_size_override("font_size", 19)
	parent.add_child(result)
	return result
