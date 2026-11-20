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
var equipment_upgrade_level := 1
var technology_upgrade_level := 1
var spawn_upgrade_level := 1
var auto_pickup_level := 0
var auto_pickup_timer := 0.0
var recycling_bonus := 1.0
var skill_buttons: Array[Button] = []
var skill_branch_panels: Array[PanelContainer] = []
var unload_timer := 0.0
var upgrade_panel: Panel
var bag_upgrade_button: Button
var movement_upgrade_button: Button
var unload_upgrade_button: Button
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
var conveyor_time := 0.0
var conveyor_rollers: Array[MeshInstance3D] = []
var conveyor_slats: Array[Node3D] = []
var conveyor_item_count := 0
var yard_stage := 1
var expansion_gates: Array[Node3D] = []
var expansion_world_button: Node3D
var refill_world_button: Node3D

const YARD_LIMIT := 14.5
const SELL_POINT := Vector3(1.35, 0.0, -6.5)

func _ready() -> void:
	_load_game()
	_build_world()
	_apply_unlocked_districts()
	_build_player()
	_build_trash()
	_build_ui()
	_update_ui()

func _process(delta: float) -> void:
	if is_instance_valid(player) and is_instance_valid(camera_pivot):
		camera_pivot.global_position = player.global_position + Vector3(0, 8.0, 10.5)
	_animate_robot(delta)
	_animate_conveyor(delta)
	_process_auto_sell(delta)
	_process_auto_pickup(delta)

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
	_box("PlayerStartZone", Vector3(0, 0.02, 7), Vector3(7, 0.04, 5), Color(0.39, 0.40, 0.35), false)

	# Perimeter walls, fencing, and gate.
	_box("BackWall", Vector3(0, 2.0, -15.5), Vector3(32, 4, 0.5), Color(0.28, 0.32, 0.31), true)
	_box("LeftWall", Vector3(-15.5, 2.0, 0), Vector3(0.5, 4, 32), Color(0.28, 0.32, 0.31), true)
	_box("RightWallNorth", Vector3(15.5, 2.0, -9.0), Vector3(0.5, 4, 14.0), Color(0.28, 0.32, 0.31), true)
	_box("RightWallSouth", Vector3(15.5, 2.0, 9.0), Vector3(0.5, 4, 14.0), Color(0.28, 0.32, 0.31), true)
	var first_gate := _box("ExpansionGateOne", Vector3(15.5, 1.5, 0), Vector3(0.5, 3.0, 4.0), Color(0.82, 0.55, 0.12), true)
	expansion_gates.append(first_gate)
	_box("DistrictTwoGround", Vector3(32, -0.3, 0), Vector3(32, 0.6, 32), Color(0.29, 0.34, 0.32), true)
	_box("DistrictTwoOuterWallNorth", Vector3(47.5, 2.0, -9.0), Vector3(0.5, 4, 14.0), Color(0.28, 0.32, 0.31), true)
	_box("DistrictTwoOuterWallSouth", Vector3(47.5, 2.0, 9.0), Vector3(0.5, 4, 14.0), Color(0.28, 0.32, 0.31), true)
	_box("DistrictTwoBackWall", Vector3(32, 2.0, -15.5), Vector3(32, 4, 0.5), Color(0.28, 0.32, 0.31), true)
	_box("DistrictTwoFrontFence", Vector3(32, 1.5, 15.5), Vector3(32, 3, 0.18), Color(0.20, 0.24, 0.24), true)
	_box("DistrictThreeGround", Vector3(64, -0.3, 0), Vector3(32, 0.6, 32), Color(0.32, 0.34, 0.29), true)
	_box("DistrictThreeOuterWall", Vector3(79.5, 2.0, 0), Vector3(0.5, 4, 32), Color(0.28, 0.32, 0.31), true)
	_box("DistrictThreeBackWall", Vector3(64, 2.0, -15.5), Vector3(32, 4, 0.5), Color(0.28, 0.32, 0.31), true)
	_box("DistrictThreeFrontFence", Vector3(64, 1.5, 15.5), Vector3(32, 3, 0.18), Color(0.20, 0.24, 0.24), true)
	var second_gate := _box("ExpansionGateTwo", Vector3(47.5, 1.5, 0), Vector3(0.5, 3.0, 4.0), Color(0.82, 0.55, 0.12), true)
	expansion_gates.append(second_gate)
	_box("DistrictTwoSign", Vector3(32, 2.2, -13.5), Vector3(5.0, 1.0, 0.18), Color(0.08, 0.38, 0.31), false)
	_label_3d("DISTRICT 2", Vector3(32, 2.2, -13.35), 0.35)
	_box("DistrictThreeSign", Vector3(64, 2.2, -13.5), Vector3(5.0, 1.0, 0.18), Color(0.42, 0.30, 0.10), false)
	_label_3d("DISTRICT 3", Vector3(64, 2.2, -13.35), 0.35)
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

	# Clearly marked unloading pad directly in front of the conveyor intake.
	_box("UnloadPad", Vector3(1.35, 0.018, -6.5), Vector3(3.5, 0.035, 3.2), Color(0.95, 0.66, 0.12), false)
	_box("UnloadBorderFront", Vector3(1.35, 0.045, -8.12), Vector3(3.55, 0.045, 0.12), Color(1.0, 0.88, 0.28), false)
	_box("UnloadBorderBack", Vector3(1.35, 0.045, -4.88), Vector3(3.55, 0.045, 0.12), Color(1.0, 0.88, 0.28), false)
	_box("UnloadBorderLeft", Vector3(-0.43, 0.045, -6.5), Vector3(0.12, 0.045, 3.2), Color(1.0, 0.88, 0.28), false)
	_box("UnloadBorderRight", Vector3(3.13, 0.045, -6.5), Vector3(0.12, 0.045, 3.2), Color(1.0, 0.88, 0.28), false)
	_label_3d("UNLOAD HERE", Vector3(1.35, 0.12, -7.45), 0.28)

	# Conveyor and recycling machine.
	# Industrial recycling press: layered steel housing, feed hopper and control panel.
	_box("MachineBase", Vector3(7.5, 0.65, -6.5), Vector3(4.4, 1.3, 3.2), Color(0.075, 0.12, 0.15), true)
	_box("MachineLowerTrim", Vector3(7.5, 1.18, -6.5), Vector3(4.25, 0.12, 3.05), Color(0.88, 0.53, 0.12), false)
	_box("MachineBody", Vector3(7.5, 1.72, -6.5), Vector3(3.3, 1.0, 2.5), Color(0.10, 0.38, 0.43), true)
	_box("MachineTop", Vector3(7.5, 2.25, -6.5), Vector3(3.65, 0.18, 2.85), Color(0.18, 0.55, 0.57), false)
	_box("PressFrontDoor", Vector3(7.5, 1.72, -5.22), Vector3(1.8, 0.62, 0.08), Color(0.055, 0.16, 0.19), false)
	_box("PressWindow", Vector3(7.5, 1.78, -5.16), Vector3(0.92, 0.28, 0.035), Color(0.12, 0.75, 0.72), false)
	_box("HopperRear", Vector3(7.5, 2.85, -7.35), Vector3(2.35, 0.16, 1.55), Color(0.23, 0.29, 0.30), false)
	var hopper_left := _box("HopperLeft", Vector3(6.35, 2.62, -6.65), Vector3(0.14, 0.75, 1.55), Color(0.38, 0.44, 0.43), false)
	hopper_left.rotation_degrees.z = -18
	var hopper_right := _box("HopperRight", Vector3(8.65, 2.62, -6.65), Vector3(0.14, 0.75, 1.55), Color(0.38, 0.44, 0.43), false)
	hopper_right.rotation_degrees.z = 18
	_box("ControlPanel", Vector3(9.18, 1.95, -5.17), Vector3(0.72, 0.78, 0.16), Color(0.045, 0.09, 0.11), false)
	_box("ControlScreen", Vector3(9.18, 2.06, -5.075), Vector3(0.48, 0.28, 0.035), Color(0.12, 0.82, 0.66), false)
	for i in range(3):
		_cylinder("ControlButton", Vector3(8.98 + i * 0.20, 1.72, -5.06), 0.055, 0.035, [Color(0.85, 0.18, 0.12), Color(0.92, 0.68, 0.12), Color(0.18, 0.78, 0.38)][i], false)
	for x in [6.0, 9.0]:
		for z in [-7.65, -5.35]:
			_cylinder("MachineBolt", Vector3(x, 1.75, z), 0.055, 0.035, Color(0.68, 0.73, 0.72), false)
	_box("ConveyorFrame", Vector3(4.0, 0.85, -6.5), Vector3(3.0, 0.28, 1.5), Color(0.09, 0.12, 0.13), true)
	_box("ConveyorBelt", Vector3(4.0, 1.03, -6.5), Vector3(2.9, 0.08, 1.35), Color(0.035, 0.05, 0.055), false)
	for z in [-7.22, -5.78]:
		_box("ConveyorSideRail", Vector3(4.0, 1.25, z), Vector3(3.0, 0.42, 0.10), Color(0.48, 0.53, 0.51), false)
	for x in [2.75, 5.25]:
		for z in [-7.05, -5.95]:
			var support := _box("ConveyorLeg", Vector3(x, 0.43, z), Vector3(0.12, 0.82, 0.12), Color(0.22, 0.27, 0.28), true)
			var foot := _box("ConveyorFoot", Vector3(x, 0.06, z), Vector3(0.38, 0.10, 0.30), Color(0.12, 0.16, 0.17), false)
	for x in [2.8, 3.6, 4.4, 5.2]:
		var roller := _cylinder("ConveyorRoller", Vector3(x, 0.88, -6.5), 0.12, 1.55, Color(0.48, 0.52, 0.52), true)
		conveyor_rollers.append(roller)
	for i in range(8):
		var slat := _box("MovingBeltSlat", Vector3(2.65 + i * 0.38, 1.09, -6.5), Vector3(0.10, 0.025, 1.22), Color(0.30, 0.38, 0.39), false)
		conveyor_slats.append(slat)

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

	expansion_world_button = _create_world_action_button("ExpansionPurchase", "OPEN DISTRICT 2  $500", Vector3(15.0, 0.0, 2.6), Vector3(2.8, 1.25, 0.35), Callable(self, "_buy_next_stage"), Color(0.88, 0.56, 0.12))
	_refresh_expansion_world_button()
	refill_world_button = _create_world_action_button("TrashRefillButton", "REFILL TRASH", Vector3(10.2, 0.0, -4.25), Vector3(1.9, 0.9, 0.35), Callable(self, "_refill_first_district"), Color(0.10, 0.58, 0.40))

func _create_world_action_button(node_name: String, title: String, world_position: Vector3, dimensions: Vector3, action: Callable, color: Color) -> Node3D:
	var root := Node3D.new()
	root.name = node_name
	root.position = world_position
	add_child(root)

	var base := MeshInstance3D.new()
	var base_mesh := BoxMesh.new()
	base_mesh.size = dimensions + Vector3(0.28, 0.22, 0.18)
	base.mesh = base_mesh
	base.position.y = dimensions.y * 0.5
	base.material_override = _mat(Color(0.055, 0.085, 0.09))
	root.add_child(base)

	var face := MeshInstance3D.new()
	var face_mesh := BoxMesh.new()
	face_mesh.size = dimensions
	face.mesh = face_mesh
	face.position.y = dimensions.y * 0.5 + 0.06
	face.material_override = _mat(color)
	root.add_child(face)

	var area := Area3D.new()
	area.name = "WorldButtonArea"
	area.position.y = dimensions.y * 0.5 + 0.06
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = dimensions + Vector3(0.12, 0.12, 0.25)
	collision.shape = shape
	area.add_child(collision)
	root.add_child(area)

	var label := Label3D.new()
	label.name = "WorldButtonLabel"
	label.text = title
	label.position = Vector3(0, dimensions.y * 0.5 + 0.07, dimensions.z * 0.5 + 0.02)
	label.font_size = 30
	label.pixel_size = 0.006
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color.WHITE
	root.add_child(label)

	area.input_event.connect(_on_world_action_input.bind(action))
	return root

func _on_world_action_input(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_index: int, action: Callable) -> void:
	if event is InputEventScreenTouch and event.pressed:
		action.call()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		action.call()

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

	var collect := _button("PICK UP", Vector2(-124, -150), Vector2(104, 104), layer)
	_anchor_bottom_right(collect)
	collect.add_theme_stylebox_override("normal", _circle_button_style(Color(0.08, 0.34, 0.29, 0.58)))
	collect.add_theme_stylebox_override("hover", _circle_button_style(Color(0.12, 0.46, 0.37, 0.68)))
	collect.add_theme_stylebox_override("pressed", _circle_button_style(Color(0.05, 0.24, 0.22, 0.76)))
	collect.add_theme_color_override("font_color", Color(1, 1, 1, 0.88))
	collect.add_theme_font_size_override("font_size", 16)
	collect.pressed.connect(_collect_nearby)


	# Fixed four-way virtual joystick on the lower-left, with a translucent touch surface.
	joystick_pad = Panel.new()
	joystick_pad.position = Vector2(18, -218)
	joystick_pad.size = Vector2(184, 184)
	joystick_pad.anchor_top = 1.0
	joystick_pad.anchor_bottom = 1.0
	joystick_pad.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.055, 0.06, 0.25)))
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
	joystick_knob.add_theme_stylebox_override("panel", _button_style(Color(0.08, 0.48, 0.38, 0.58)))
	joystick_pad.add_child(joystick_knob)

	var upgrades_button := _button("SKILL TREE", Vector2(-174, 24), Vector2(156, 58), layer)
	upgrades_button.anchor_left = 1.0
	upgrades_button.anchor_right = 1.0
	upgrades_button.pressed.connect(_toggle_upgrade_panel)

	upgrade_panel = Panel.new()
	upgrade_panel.set_anchors_preset(Control.PRESET_CENTER)
	upgrade_panel.position = Vector2(-175, -270)
	upgrade_panel.size = Vector2(350, 540)
	upgrade_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.055, 0.065, 0.98)))
	upgrade_panel.visible = false
	layer.add_child(upgrade_panel)

	_label("SKILL TREE", Vector2(20, 14), 25, upgrade_panel)
	_label("Unlock stronger skills branch by branch", Vector2(20, 47), 12, upgrade_panel)
	var close_upgrades := _button("X", Vector2(294, 12), Vector2(40, 40), upgrade_panel)
	close_upgrades.pressed.connect(_toggle_upgrade_panel)

	var skill_scroll := ScrollContainer.new()
	skill_scroll.position = Vector2(14, 82)
	skill_scroll.size = Vector2(322, 440)
	skill_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	upgrade_panel.add_child(skill_scroll)
	var skill_list := VBoxContainer.new()
	skill_list.custom_minimum_size = Vector2(300, 0)
	skill_list.add_theme_constant_override("separation", 10)
	skill_scroll.add_child(skill_list)

	_add_skill_branch(skill_list, "01  CAPACITY", "Bigger bag • +3 trash per level", "BAG CAPACITY", Callable(self, "_upgrade_bag"))
	_add_skill_branch(skill_list, "02  SPEED", "Move faster around the yard", "MOVEMENT SPEED", Callable(self, "_upgrade_speed"))
	_add_skill_branch(skill_list, "03  RECYCLING", "Unload trash faster", "UNLOAD SPEED", Callable(self, "_upgrade_unload"))
	_add_skill_branch(skill_list, "04  PICKUP RANGE", "Reach litter farther away • +0.75m per level", "PICKUP RANGE", Callable(self, "_upgrade_equipment"))
	_add_skill_branch(skill_list, "05  TECHNOLOGY", "Earn more cash from every item", "RECYCLING VALUE", Callable(self, "_upgrade_technology"))
	_add_skill_branch(skill_list, "06  TRASH SUPPLY", "More litter appears each time you pull to refill", "REFILL CAPACITY", Callable(self, "_upgrade_spawn"))
	_add_skill_branch(skill_list, "07  AUTO PICKUP", "Automatically collect nearby litter while you move", "AUTO COLLECT", Callable(self, "_upgrade_auto_pickup"))
	_refresh_upgrade_prices()

	var hint := _label("DRAG PAD TO MOVE", Vector2(18, -28), 12, layer)
	hint.anchor_top = 1.0
	hint.anchor_bottom = 1.0

func _add_skill_branch(parent: VBoxContainer, branch_title: String, description: String, skill_name: String, action: Callable) -> void:
	var branch := PanelContainer.new()
	branch.custom_minimum_size = Vector2(296, 126)
	branch.add_theme_stylebox_override("panel", _panel_style(Color(0.055, 0.105, 0.11, 0.98)))
	parent.add_child(branch)
	skill_branch_panels.append(branch)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 4)
	branch.add_child(content)
	var heading := Label.new()
	heading.text = branch_title
	heading.add_theme_font_size_override("font_size", 15)
	heading.add_theme_color_override("font_color", Color(0.48, 0.95, 0.75))
	content.add_child(heading)
	var detail := Label.new()
	detail.text = description
	detail.add_theme_font_size_override("font_size", 11)
	detail.add_theme_color_override("font_color", Color(0.78, 0.86, 0.84))
	content.add_child(detail)
	var node_button := Button.new()
	node_button.custom_minimum_size = Vector2(276, 48)
	node_button.text = skill_name
	node_button.add_theme_font_size_override("font_size", 13)
	node_button.add_theme_color_override("font_color", Color.WHITE)
	node_button.add_theme_stylebox_override("normal", _button_style(Color(0.08, 0.34, 0.29)))
	node_button.add_theme_stylebox_override("hover", _button_style(Color(0.12, 0.46, 0.37)))
	node_button.add_theme_stylebox_override("pressed", _button_style(Color(0.05, 0.24, 0.22)))
	node_button.pressed.connect(action)
	content.add_child(node_button)
	skill_buttons.append(node_button)

func _input(event: InputEvent) -> void:
	if not is_instance_valid(player):
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if is_instance_valid(joystick_pad) and joystick_touch == -1 and joystick_pad.get_global_rect().has_point(event.position):
				joystick_touch = event.index
				_update_joystick(event.position)
		elif event.index == joystick_touch:
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

func _process_auto_pickup(delta: float) -> void:
	if auto_pickup_level <= 0 or not is_instance_valid(player) or carried >= capacity:
		auto_pickup_timer = 0.0
		return
	auto_pickup_timer += delta
	var interval := maxf(0.35, 1.5 - float(auto_pickup_level - 1) * 0.15)
	if auto_pickup_timer < interval:
		return
	auto_pickup_timer = 0.0
	_collect_nearby()

func _process_auto_sell(delta: float) -> void:
	if not is_instance_valid(player):
		return
	var inside_zone := player.global_position.distance_to(SELL_POINT) <= 2.35
	if not inside_zone or carried <= 0:
		unload_timer = 0.0
		return
	unload_timer += delta
	var seconds_per_item := maxf(0.25, 1.5 - float(unload_upgrade_level - 1) * 0.2)
	if unload_timer >= seconds_per_item:
		unload_timer = 0.0
		carried -= 1
		_spawn_conveyor_item()
		money += int(round(10.0 * recycling_bonus))
		_update_ui()
		_save_game()
		_set_message("Conveyor recycling... +$%d" % int(round(10.0 * recycling_bonus)))
		if carried == 0:
			_set_message("Bag emptied! Money added.")

func _toggle_upgrade_panel() -> void:
	if is_instance_valid(upgrade_panel):
		upgrade_panel.visible = not upgrade_panel.visible

func _upgrade_bag() -> void:
	var cost := _upgrade_cost(50, upgrade_level)
	if money < cost:
		_set_message("You need $%d for the next bag upgrade." % cost)
		return
	money -= cost
	capacity += 3
	upgrade_level += 1
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Upgrade purchased! New bag capacity: %d." % capacity)

func _upgrade_speed() -> void:
	var cost := _upgrade_cost(75, speed_upgrade_level)
	if money < cost:
		_set_message("You need $%d for the speed upgrade." % cost)
		return
	money -= cost
	speed_upgrade_level += 1
	player.set("move_speed", 5.0 + float(speed_upgrade_level - 1) * 0.8)
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Movement speed upgraded!")

func _upgrade_unload() -> void:
	var cost := _upgrade_cost(100, unload_upgrade_level)
	if money < cost:
		_set_message("You need $%d for faster unloading." % cost)
		return
	money -= cost
	unload_upgrade_level += 1
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Unloading speed upgraded!")

func _upgrade_equipment() -> void:
	var cost := _upgrade_cost(125, equipment_upgrade_level)
	if money < cost:
		_set_message("You need $%d for the magnet upgrade." % cost)
		return
	money -= cost
	equipment_upgrade_level += 1
	collection_range = 2.5 + float(equipment_upgrade_level - 1) * 0.75
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Magnet range increased!")

func _upgrade_technology() -> void:
	var cost := _upgrade_cost(150, technology_upgrade_level)
	if money < cost:
		_set_message("You need $%d for the technology upgrade." % cost)
		return
	money -= cost
	technology_upgrade_level += 1
	recycling_bonus = 1.0 + float(technology_upgrade_level - 1) * 0.15
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Recycling value increased!")

func _upgrade_cost(base_cost: int, level: int) -> int:
	# Each upgrade category compounds its own price by 25% per purchase.
	return int(ceil(float(base_cost) * pow(1.25, float(level - 1))))

func _refresh_upgrade_prices() -> void:
	if skill_buttons.size() < 7 or skill_branch_panels.size() < 7:
		return
	# Show only the first skill at the beginning. Each purchase reveals the next branch.
	var unlocked := [
		true,
		upgrade_level > 1,
		speed_upgrade_level > 1,
		unload_upgrade_level > 1,
		equipment_upgrade_level > 1,
		technology_upgrade_level > 1,
		spawn_upgrade_level > 1
	]
	for i in range(skill_branch_panels.size()):
		skill_branch_panels[i].visible = unlocked[i]
	skill_buttons[0].text = "BAG CAPACITY +3  |  LV %d  |  $%d" % [upgrade_level, _upgrade_cost(50, upgrade_level)]
	skill_buttons[1].text = "MOVE SPEED  |  LV %d  |  $%d" % [speed_upgrade_level, _upgrade_cost(75, speed_upgrade_level)]
	skill_buttons[2].text = "UNLOAD SPEED  |  LV %d  |  $%d" % [unload_upgrade_level, _upgrade_cost(100, unload_upgrade_level)]
	skill_buttons[3].text = "PICKUP RANGE +0.75M  |  LV %d  |  $%d" % [equipment_upgrade_level, _upgrade_cost(125, equipment_upgrade_level)]
	skill_buttons[4].text = "RECYCLING VALUE  |  LV %d  |  $%d" % [technology_upgrade_level, _upgrade_cost(150, technology_upgrade_level)]
	skill_buttons[5].text = "TRASH PER REFILL +6  |  LV %d  |  $%d" % [spawn_upgrade_level, _upgrade_cost(175, spawn_upgrade_level)]
	skill_buttons[6].text = "AUTO PICKUP  |  LV %d  |  $%d" % [auto_pickup_level, _upgrade_cost(250, auto_pickup_level + 1)]

func _upgrade_spawn() -> void:
	var cost := _upgrade_cost(175, spawn_upgrade_level)
	if money < cost:
		_set_message("You need $%d for the trash supply upgrade." % cost)
		return
	money -= cost
	spawn_upgrade_level += 1
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Trash supply upgraded! +6 trash on every manual refill.")

func _upgrade_auto_pickup() -> void:
	var cost := _upgrade_cost(250, auto_pickup_level + 1)
	if money < cost:
		_set_message("You need $%d for automatic pickup." % cost)
		return
	money -= cost
	auto_pickup_level += 1
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	if auto_pickup_level == 1:
		_set_message("Auto pickup unlocked! Nearby litter is collected automatically.")
	else:
		_set_message("Auto pickup upgraded! Collection is faster.")

func _apply_unlocked_districts() -> void:
	for index in range(mini(yard_stage - 1, expansion_gates.size())):
		var gate := expansion_gates[index]
		if is_instance_valid(gate):
			gate.queue_free()

func _buy_next_stage() -> void:
	if yard_stage >= 3:
		_set_message("All districts unlocked!")
		return
	var cost := 500 if yard_stage == 1 else 1800
	if money < cost:
		_set_message("You need $%d to unlock the next district." % cost)
		return
	money -= cost
	yard_stage += 1
	var gate_index := yard_stage - 2
	if gate_index >= 0 and gate_index < expansion_gates.size():
		var gate := expansion_gates[gate_index]
		if is_instance_valid(gate):
			gate.queue_free()
	_spawn_trash(18 if yard_stage == 2 else 24)
	_update_ui()
	_refresh_expansion_world_button()
	_save_game()
	_set_message("DISTRICT %d UNLOCKED!" % yard_stage)

func _refresh_expansion_world_button() -> void:
	if not is_instance_valid(expansion_world_button):
		return
	if yard_stage >= 3:
		expansion_world_button.visible = false
		return
	expansion_world_button.visible = true
	if yard_stage == 1:
		expansion_world_button.position = Vector3(15.0, 0.0, 2.6)
		_expansion_button_label("OPEN DISTRICT 2  $500")
	else:
		expansion_world_button.position = Vector3(47.0, 0.0, 2.6)
		_expansion_button_label("OPEN DISTRICT 3  $1800")

func _expansion_button_label(value: String) -> void:
	var label := expansion_world_button.get_node_or_null("WorldButtonLabel") as Label3D
	if is_instance_valid(label):
		label.text = value

func _save_game() -> void:
	var save := ConfigFile.new()
	save.set_value("progress", "money", money)
	save.set_value("progress", "carried", carried)
	save.set_value("progress", "capacity", capacity)
	save.set_value("progress", "bag_level", upgrade_level)
	save.set_value("progress", "speed_level", speed_upgrade_level)
	save.set_value("progress", "unload_level", unload_upgrade_level)
	save.set_value("progress", "equipment_level", equipment_upgrade_level)
	save.set_value("progress", "technology_level", technology_upgrade_level)
	save.set_value("progress", "spawn_level", spawn_upgrade_level)
	save.set_value("progress", "auto_pickup_level", auto_pickup_level)
	save.set_value("progress", "yard_stage", yard_stage)
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
	equipment_upgrade_level = int(save.get_value("progress", "equipment_level", 1))
	technology_upgrade_level = int(save.get_value("progress", "technology_level", 1))
	spawn_upgrade_level = int(save.get_value("progress", "spawn_level", 1))
	auto_pickup_level = int(save.get_value("progress", "auto_pickup_level", 0))
	yard_stage = clampi(int(save.get_value("progress", "yard_stage", 1)), 1, 3)
	collection_range = 2.5 + float(equipment_upgrade_level - 1) * 0.75
	recycling_bonus = 1.0 + float(technology_upgrade_level - 1) * 0.15

func _spawn_trash(amount: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(amount):
		var item := Node3D.new()
		item.set_script(TRASH_SCRIPT)
		item.position = _random_trash_position(rng)
		add_child(item)
		trash_nodes.append(item)

func _refill_first_district() -> void:
	var existing_first_district := 0
	for item in trash_nodes:
		if is_instance_valid(item) and item.global_position.x >= -15.0 and item.global_position.x <= 15.0:
			existing_first_district += 1
	var refill_target := 24 + (spawn_upgrade_level - 1) * 6
	var amount := maxi(0, refill_target - existing_first_district)
	if amount == 0:
		_set_message("First district is already full of trash!")
		return
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(amount):
		var item := Node3D.new()
		item.set_script(TRASH_SCRIPT)
		item.position = Vector3(rng.randf_range(-11.5, 11.5), 0.34, rng.randf_range(-10.0, 11.5))
		if item.position.distance_to(SELL_POINT) < 4.0:
			item.position.z = 10.5
		add_child(item)
		trash_nodes.append(item)
	_update_ui()
	_set_message("First district refilled! %d new trash pieces spawned." % amount)

func _random_trash_position(rng: RandomNumberGenerator) -> Vector3:
	var max_x := 11.5
	if yard_stage == 2:
		max_x = 43.5
	elif yard_stage >= 3:
		max_x = 75.5
	var point := Vector3(rng.randf_range(-11.5, max_x), 0.34, rng.randf_range(-10.0, 11.5))
	var attempts := 0
	while (point.distance_to(SELL_POINT) < 4.0 or (point.x > 15.0 and point.x < 19.0) or (point.x > 47.0 and point.x < 51.0)) and attempts < 20:
		point = Vector3(rng.randf_range(-11.5, max_x), 0.34, rng.randf_range(-10.0, 11.5))
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

func _box(node_name: String, pos: Vector3, size: Vector3, color: Color, solid: bool) -> Node3D:
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
	return body

func _cylinder(node_name: String, pos: Vector3, radius: float, height: float, color: Color, horizontal: bool) -> MeshInstance3D:
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
	return mesh

func _animate_conveyor(delta: float) -> void:
	conveyor_time += delta
	for roller in conveyor_rollers:
		if is_instance_valid(roller):
			roller.rotate_x(delta * 5.0)
	for i in range(conveyor_slats.size()):
		var slat := conveyor_slats[i]
		if is_instance_valid(slat):
			var x := 2.65 + fposmod(float(i) * 0.38 + conveyor_time * 1.15, 3.04)
			slat.position.x = x

func _spawn_conveyor_item() -> void:
	var item := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.34, 0.20, 0.30)
	item.mesh = mesh
	item.position = Vector3(2.55, 1.24, -6.5 + randf_range(-0.32, 0.32))
	item.rotation = Vector3(randf_range(-0.25, 0.25), randf_range(0.0, TAU), randf_range(-0.2, 0.2))
	item.material_override = _mat([Color(0.20, 0.62, 0.78), Color(0.82, 0.66, 0.30), Color(0.35, 0.68, 0.38)][randi_range(0, 2)])
	add_child(item)
	var travel := create_tween()
	travel.set_trans(Tween.TRANS_LINEAR)
	travel.tween_property(item, "position", Vector3(5.35, 1.25, item.position.z), 1.35)
	travel.parallel().tween_property(item, "rotation:y", item.rotation.y + TAU, 1.35)
	travel.tween_callback(item.queue_free)

func _make_bin(pos: Vector3, color: Color, label_text: String) -> void:
	# Wheeled commercial recycling container with sloped lid, molded ribs and handle.
	_box("BinBody", pos + Vector3(0, 0.72, 0), Vector3(1.42, 1.42, 1.35), color, true)
	_box("BinFrontPanel", pos + Vector3(0, 0.83, -0.69), Vector3(1.12, 0.86, 0.045), color.lightened(0.12), false)
	for x in [-0.52, -0.26, 0.0, 0.26, 0.52]:
		_box("BinMoldedRib", pos + Vector3(x, 0.72, -0.725), Vector3(0.035, 1.05, 0.035), color.darkened(0.18), false)
	var lid := _box("BinLid", pos + Vector3(0, 1.48, 0.02), Vector3(1.58, 0.18, 1.48), Color(0.075, 0.11, 0.12), false)
	lid.rotation_degrees.x = -4
	_box("BinLidGrip", pos + Vector3(0, 1.60, -0.48), Vector3(0.55, 0.09, 0.16), Color(0.18, 0.22, 0.22), false)
	for x in [-0.53, 0.53]:
		_cylinder("BinWheel", pos + Vector3(x, 0.20, 0.57), 0.23, 0.16, Color(0.035, 0.045, 0.05), true)
		_cylinder("BinAxleCap", pos + Vector3(x, 0.20, 0.48), 0.075, 0.18, Color(0.48, 0.52, 0.50), true)
	_box("BinLabelPlate", pos + Vector3(0, 1.02, -0.755), Vector3(0.88, 0.30, 0.035), Color(0.035, 0.08, 0.09), false)
	_label_3d(label_text, pos + Vector3(0, 1.02, -0.79), 0.18)

func _make_pallet(pos: Vector3) -> void:
	for z in [-0.55, 0.0, 0.55]:
		_box("PalletDeckBoard", pos + Vector3(0, 0.14, z), Vector3(2.2, 0.20, 0.30), Color(0.48, 0.32, 0.18), false)
	for x in [-0.75, 0.0, 0.75]:
		_box("PalletBlock", pos + Vector3(x, 0.0, 0), Vector3(0.30, 0.18, 1.45), Color(0.30, 0.21, 0.14), false)
	_box("Crate", pos + Vector3(0, 0.9, 0), Vector3(1.45, 1.4, 1.25), Color(0.52, 0.35, 0.19), true)
	for y in [0.30, 0.68, 1.06, 1.44]:
		_box("CrateFrontSlat", pos + Vector3(0, y, 0.64), Vector3(1.48, 0.07, 0.07), Color(0.34, 0.23, 0.14), false)
	for x in [-0.68, 0.68]:
		_box("CrateCornerBrace", pos + Vector3(x, 0.9, 0.68), Vector3(0.09, 1.38, 0.08), Color(0.27, 0.19, 0.12), false)
	_box("CrateMetalLabel", pos + Vector3(0, 0.92, 0.70), Vector3(0.46, 0.24, 0.035), Color(0.16, 0.20, 0.19), false)

func _make_barrel(pos: Vector3, color: Color) -> void:
	_cylinder("BarrelBody", pos + Vector3(0, 0.60, 0), 0.47, 1.20, color, false)
	_cylinder("BarrelTop", pos + Vector3(0, 1.22, 0), 0.45, 0.055, Color(0.24, 0.28, 0.28), false)
	for y in [0.22, 0.48, 0.88, 1.08]:
		_cylinder("BarrelReinforcementRing", pos + Vector3(0, y, 0), 0.495, 0.055, Color(0.20, 0.24, 0.24), false)
	_cylinder("BarrelCap", pos + Vector3(0.18, 1.27, 0.08), 0.09, 0.035, Color(0.72, 0.75, 0.70), false)
	_cylinder("BarrelPlug", pos + Vector3(-0.16, 1.27, -0.08), 0.065, 0.035, Color(0.12, 0.16, 0.17), false)
	_box("BarrelHazardStripe", pos + Vector3(0, 0.68, -0.475), Vector3(0.48, 0.13, 0.025), Color(0.95, 0.76, 0.16), false)

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

func _circle_button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 44
	style.corner_radius_top_right = 44
	style.corner_radius_bottom_left = 44
	style.corner_radius_bottom_right = 44
	style.border_width_bottom = 3
	style.border_color = Color(0.04, 0.17, 0.16)
	return style

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
