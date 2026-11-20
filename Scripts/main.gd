extends Node3D

const PLAYER_SCRIPT = preload("res://Scripts/player.gd")
const TRASH_SCRIPT = preload("res://Scripts/trash.gd")

var player: CharacterBody3D
var camera: Camera3D
var camera_pivot: Node3D
var money := 0.0
var carried := 0
var capacity := 4
var collection_range := 2.0
var upgrade_level := 1
var speed_upgrade_level := 1
var unload_upgrade_level := 1
var equipment_upgrade_level := 1
var technology_upgrade_level := 1
var trash_value_upgrade_level := 1
var spawn_upgrade_level := 1
var auto_pickup_level := 0
var luck_upgrade_level := 1
var magnet_power_level := 1
var drone_level := 0
var drone_timer := 0.0
var helper_drones: Array[Node3D] = []
var auto_pickup_timer := 0.0
var recycling_bonus := 1.0
var skill_buttons: Array[Button] = []
var skill_branch_panels: Array[PanelContainer] = []
var skill_node_data: Array[Dictionary] = []
var skill_scroll_container: ScrollContainer
var skill_map: Control
var skill_zoom := 1.0
var skill_drag_touch := -1
var skill_touch_points: Dictionary = {}
var skill_pinch_distance := 0.0
var skill_scroll_velocity := 0.0
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
var magnet_tool: Node3D
var robot_left_leg: Node3D
var robot_right_leg: Node3D
var robot_head: Node3D
var robot_anim_time := 0.0
var conveyor_time := 0.0
var conveyor_rollers: Array[MeshInstance3D] = []
var conveyor_slats: Array[Node3D] = []
var conveyor_item_count := 0
var factory_stage := 1
var factory_built_stage := 1
var factory_visual_root: Node3D
var factory_upgrade_button: Node3D
var yard_stage := 1
var expansion_gates: Array[Node3D] = []
var expansion_world_button: Node3D
var expansion_zone_blocked := false
var refill_world_button: Node3D
var main_menu_panel: Control
var main_menu_open := true
var new_game_button: Button

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
	if main_menu_open:
		return
	_process_skill_scroll(delta)
	_process_expansion_zone()
	if is_instance_valid(player) and is_instance_valid(camera_pivot):
		camera_pivot.global_position = player.global_position + Vector3(0, 8.0, 10.5)
	_animate_robot(delta)
	_animate_conveyor(delta)
	_process_auto_sell(delta)
	_process_auto_pickup(delta)
	_process_helper_drones(delta)

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
	_box("DistrictTwoGround", Vector3(32, -0.3, 0), Vector3(32, 0.6, 32), Color(0.20, 0.43, 0.22), true)
	_box("DistrictTwoGrassPatch", Vector3(32, 0.012, 0), Vector3(29.5, 0.025, 28.5), Color(0.25, 0.50, 0.22), false)
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
	for z in [-7.18, -5.82]:
		_box("ConveyorSideRail", Vector3(4.0, 1.19, z), Vector3(2.78, 0.28, 0.08), Color(0.20, 0.27, 0.28), false)
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
	_make_tree(Vector3(-13.0, 0, 1.0))
	_box("SpawnPad", Vector3(0, 0.05, 7), Vector3(4.5, 0.08, 3.5), Color(0.48, 0.48, 0.39), false)
	_label_3d("TRASH EMPIRE", Vector3(0, 3.2, 14.55), 0.65)

	_create_expansion_zone()
	_refresh_expansion_world_button()
	refill_world_button = _create_gear_refill_button(Vector3(10.2, 0.0, -4.25), Callable(self, "_refill_first_district"))
	factory_upgrade_button = _create_world_action_button("FactoryExpansionButton", "EXPAND FACTORY", Vector3(13.0, 0.0, 7.0), Vector3(2.8, 0.5, 1.25), Callable(self, "_upgrade_factory"), Color(0.12, 0.55, 0.38))
	_build_factory_expansion()
	_refresh_factory_upgrade_button()

func _upgrade_factory() -> void:
	if factory_stage >= 4:
		_set_message("Factory production line is fully upgraded!")
		return
	var costs := [0.0, 15.0, 45.0, 120.0]
	var cost: float = costs[factory_stage]
	if money < cost:
		_set_message("You need $%.1f to add the next factory machine." % cost)
		return
	money -= cost
	factory_stage += 1
	_build_factory_expansion()
	_refresh_factory_upgrade_button()
	_update_ui()
	_save_game()
	var names := ["", "", "SHREDDER", "GRANULATOR", "CONSUMER GOODS LINE"]
	_set_message("Factory expanded! %s connected to the conveyor." % names[factory_stage])

func _refresh_factory_upgrade_button() -> void:
	if not is_instance_valid(factory_upgrade_button):
		return
	var label := factory_upgrade_button.get_node_or_null("WorldButtonLabel") as Label3D
	if not is_instance_valid(label):
		return
	if factory_stage >= 4:
		label.text = "FACTORY MAX\nGOODS LINE"
	else:
		var costs := [0.0, 15.0, 45.0, 120.0]
		var names := ["", "", "ADD SHREDDER", "ADD GRANULATOR", "ADD GOODS LINE"]
		label.text = "%s\n$%.0f" % [names[factory_stage + 1], costs[factory_stage]]

func _build_factory_expansion() -> void:
	if not is_instance_valid(factory_visual_root):
		factory_visual_root = Node3D.new()
		factory_visual_root.name = "FactoryExpansionVisuals"
		add_child(factory_visual_root)
	for stage in range(factory_built_stage + 1, factory_stage + 1):
		var first_new_child := get_child_count()
		_build_factory_module(stage)
		var start_z := -5.15 if stage == 2 else (1.05 if stage == 3 else 6.55)
		var end_z := -2.05 if stage == 2 else (3.45 if stage == 3 else 8.95)
		_build_factory_link(start_z, end_z)
		var new_nodes: Array[Node] = []
		for child_index in range(first_new_child, get_child_count()):
			new_nodes.append(get_child(child_index))
		for new_node in new_nodes:
			remove_child(new_node)
			factory_visual_root.add_child(new_node)
		factory_built_stage = stage

func _build_factory_module(stage: int) -> void:
	var z_positions := [0.0, 0.0, -0.5, 5.0, 10.5]
	var z: float = z_positions[stage]
	var colors := [Color.WHITE, Color.WHITE, Color(0.82, 0.48, 0.16), Color(0.20, 0.56, 0.72), Color(0.18, 0.62, 0.39)]
	var accent: Color = colors[stage]
	_box("FactoryModule%dBase" % stage, Vector3(7.5, 0.42, z), Vector3(4.2, 0.84, 3.2), Color(0.055, 0.09, 0.11), true)
	_box("FactoryModule%dBody" % stage, Vector3(7.5, 1.55, z), Vector3(3.35, 1.55, 2.65), accent.darkened(0.35), true)
	_box("FactoryModule%dTop" % stage, Vector3(7.5, 2.42, z), Vector3(3.7, 0.18, 2.95), accent, false)
	_box("FactoryModule%dFront" % stage, Vector3(7.5, 1.48, z - 1.34), Vector3(1.65, 0.78, 0.07), Color(0.035, 0.075, 0.085), false)
	_box("FactoryModule%dWindow" % stage, Vector3(7.5, 1.58, z - 1.39), Vector3(0.85, 0.34, 0.035), accent.lightened(0.45), false)
	for x in [6.0, 9.0]:
		_cylinder("FactoryModule%dVent" % stage, Vector3(x, 1.62, z), 0.24, 0.18, Color(0.24, 0.30, 0.31), false)
	if stage == 2:
		_label_3d("INDUSTRIAL SHREDDER", Vector3(7.5, 3.0, z), 0.24)
		for x in [7.0, 8.0]:
			_cylinder("ShredderRoller", Vector3(x, 1.62, z - 0.62), 0.32, 0.72, Color(0.66, 0.72, 0.69), true)
	elif stage == 3:
		_label_3d("PLASTIC GRANULATOR", Vector3(7.5, 3.0, z), 0.24)
		_box("GranulatorHopper", Vector3(7.5, 2.95, z - 0.15), Vector3(2.1, 0.65, 1.45), Color(0.32, 0.39, 0.40), false)
		_box("GranulatorOutlet", Vector3(7.5, 0.95, z + 1.38), Vector3(1.2, 0.65, 0.42), accent.lightened(0.2), false)
	else:
		_label_3d("CONSUMER GOODS FACTORY", Vector3(7.5, 3.0, z), 0.22)
		_box("ProductChute", Vector3(7.5, 0.95, z + 1.48), Vector3(1.8, 0.42, 0.72), Color(0.28, 0.34, 0.34), false)
		for x in [6.25, 8.75]:
			_box("ProductCrate", Vector3(x, 0.48, z + 1.65), Vector3(0.72, 0.82, 0.72), accent.lightened(0.12), false)
	_box("FactoryModule%dStatus" % stage, Vector3(9.25, 2.0, z - 0.75), Vector3(0.42, 0.42, 0.10), Color(0.10, 0.95, 0.56), false)

func _build_factory_link(start_z: float, end_z: float) -> void:
	var middle := (start_z + end_z) * 0.5
	var length := absf(end_z - start_z)
	_box("FactoryConveyorFrame", Vector3(7.5, 0.78, middle), Vector3(1.75, 0.28, length), Color(0.07, 0.11, 0.12), true)
	_box("FactoryConveyorBelt", Vector3(7.5, 0.96, middle), Vector3(1.48, 0.07, maxf(0.2, length - 0.12)), Color(0.025, 0.04, 0.045), false)
	for x in [6.68, 8.32]:
		_box("FactoryConveyorRail", Vector3(x, 1.18, middle), Vector3(0.10, 0.40, length), Color(0.48, 0.54, 0.52), false)
	for i in range(maxi(2, int(length / 0.65))):
		var z := start_z + (end_z - start_z) * float(i) / float(maxi(1, int(length / 0.65) - 1))
		var roller := _cylinder("FactoryConveyorRoller", Vector3(7.5, 0.83, z), 0.095, 1.52, Color(0.55, 0.60, 0.58), true)
		conveyor_rollers.append(roller)

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

func _create_gear_refill_button(world_position: Vector3, action: Callable) -> Node3D:
	# Industrial pull lever: a fixed floor mount and a long hinged rod with a grip.
	var root := Node3D.new()
	root.name = "TrashRespawnPullLever"
	root.position = world_position
	add_child(root)

	var base := MeshInstance3D.new()
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.72
	base_mesh.bottom_radius = 0.82
	base_mesh.height = 0.28
	base_mesh.radial_segments = 32
	base.mesh = base_mesh
	base.position.y = 0.14
	base.material_override = _mat(Color(0.12, 0.18, 0.19))
	root.add_child(base)

	var collar := MeshInstance3D.new()
	var collar_mesh := CylinderMesh.new()
	collar_mesh.top_radius = 0.30
	collar_mesh.bottom_radius = 0.36
	collar_mesh.height = 0.30
	collar_mesh.radial_segments = 24
	collar.mesh = collar_mesh
	collar.position = Vector3(0, 0.39, 0)
	collar.material_override = _mat(Color(0.72, 0.55, 0.20))
	root.add_child(collar)

	var pivot := Node3D.new()
	pivot.name = "LeverHinge"
	pivot.position = Vector3(0, 0.46, 0)
	root.add_child(pivot)

	var rod := MeshInstance3D.new()
	var rod_mesh := CylinderMesh.new()
	rod_mesh.top_radius = 0.075
	rod_mesh.bottom_radius = 0.095
	rod_mesh.height = 1.55
	rod_mesh.radial_segments = 16
	rod.mesh = rod_mesh
	rod.position.y = 0.76
	rod.material_override = _mat(Color(0.62, 0.68, 0.68))
	pivot.add_child(rod)

	var grip := MeshInstance3D.new()
	var grip_mesh := SphereMesh.new()
	grip_mesh.radius = 0.23
	grip_mesh.height = 0.46
	grip.mesh = grip_mesh
	grip.position = Vector3(0, 1.56, 0)
	grip.material_override = _mat(Color(0.86, 0.20, 0.12))
	pivot.add_child(grip)

	var grip_cap := MeshInstance3D.new()
	var cap_mesh := CylinderMesh.new()
	cap_mesh.top_radius = 0.16
	cap_mesh.bottom_radius = 0.16
	cap_mesh.height = 0.10
	cap_mesh.radial_segments = 20
	grip_cap.mesh = cap_mesh
	grip_cap.position = Vector3(0, 1.56, 0)
	grip_cap.material_override = _mat(Color(0.98, 0.66, 0.20))
	pivot.add_child(grip_cap)

	var label := Label3D.new()
	label.text = "PULL TO RESPAWN"
	label.position = Vector3(0, 2.20, 0)
	label.font_size = 26
	label.pixel_size = 0.006
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color(1.0, 0.90, 0.58)
	root.add_child(label)

	var area := Area3D.new()
	area.name = "PullLeverArea"
	area.position = Vector3(0, 1.55, 0)
	var collision := CollisionShape3D.new()
	var hit_shape := SphereShape3D.new()
	hit_shape.radius = 1.35
	collision.shape = hit_shape
	area.add_child(collision)
	root.add_child(area)
	area.input_event.connect(_on_pull_lever_input.bind(action, pivot))
	return root

func _on_pull_lever_input(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_index: int, action: Callable, pivot: Node3D) -> void:
	var activated: bool = (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	if not activated or not is_instance_valid(pivot):
		return
	if pivot.has_meta("pulling") and bool(pivot.get_meta("pulling")):
		return
	pivot.set_meta("pulling", true)
	var pull := create_tween()
	pull.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	pull.tween_property(pivot, "rotation_degrees:z", -58.0, 0.24)
	pull.tween_callback(action)
	pull.tween_interval(0.12)
	pull.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	pull.tween_property(pivot, "rotation_degrees:z", 0.0, 0.62)
	pull.tween_callback(func() -> void: pivot.set_meta("pulling", false))

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
	player.set("move_speed", 4.5 + float(speed_upgrade_level - 1) * 0.75)
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
	magnet_tool = Node3D.new()
	magnet_tool.name = "UnlockedHandMagnet"
	magnet_tool.position = Vector3(0.0, -0.56, -0.08)
	robot_right_arm.add_child(magnet_tool)
	_add_robot_box(magnet_tool, "MagnetCore", Vector3(0, -0.02, 0), Vector3(0.30, 0.12, 0.16), Color(0.16, 0.22, 0.27))
	_add_robot_box(magnet_tool, "MagnetLeftPole", Vector3(-0.12, -0.14, 0), Vector3(0.10, 0.22, 0.16), Color(0.88, 0.20, 0.18))
	_add_robot_box(magnet_tool, "MagnetRightPole", Vector3(0.12, -0.14, 0), Vector3(0.10, 0.22, 0.16), Color(0.18, 0.42, 0.92))
	_add_robot_box(magnet_tool, "MagnetGrip", Vector3(0, 0.10, 0), Vector3(0.12, 0.10, 0.18), Color(0.65, 0.72, 0.73))
	magnet_tool.visible = magnet_power_level > 1
	robot_left_leg = _robot_leg(robot_visual, "LeftLeg", Vector3(-0.20, 0.52, 0))
	robot_right_leg = _robot_leg(robot_visual, "RightLeg", Vector3(0.20, 0.52, 0))
	_build_helper_drones()

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
	robot_right_arm.rotation.x = -stride * 0.65 - (0.18 if auto_pickup_level > 0 else 0.0)
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
		item.position = Vector3(rng.randf_range(-11.5, 11.5), 0.34, rng.randf_range(-10.0, 11.5))
		add_child(item)
		trash_nodes.append(item)
	if yard_stage >= 2:
		_spawn_district_two_trash(48)

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

	# Full-screen skill tree overlay, sized to the device viewport.
	upgrade_panel = Panel.new()
	upgrade_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	upgrade_panel.offset_left = 0
	upgrade_panel.offset_top = 0
	upgrade_panel.offset_right = 0
	upgrade_panel.offset_bottom = 0
	upgrade_panel.z_index = 10
	upgrade_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.055, 0.065, 0.995)))
	upgrade_panel.visible = false
	layer.add_child(upgrade_panel)

	_label("SKILL TREE", Vector2(20, 14), 25, upgrade_panel)
	_label("Unlock stronger skills branch by branch", Vector2(20, 47), 12, upgrade_panel)
	var close_upgrades := _button("X", Vector2(-58, 12), Vector2(44, 44), upgrade_panel)
	close_upgrades.anchor_left = 1.0
	close_upgrades.anchor_right = 1.0
	close_upgrades.pressed.connect(_toggle_upgrade_panel)

	skill_scroll_container = ScrollContainer.new()
	var skill_scroll := skill_scroll_container
	skill_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	skill_scroll.offset_left = 14
	skill_scroll.offset_top = 82
	skill_scroll.offset_right = -14
	skill_scroll.offset_bottom = -14
	skill_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	skill_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	skill_scroll.scroll_deadzone = 8
	skill_scroll.scroll_vertical_custom_step = 42
	upgrade_panel.add_child(skill_scroll)
	skill_map = Control.new()
	skill_map.name = "SkillGalaxyMap"
	skill_map.custom_minimum_size = Vector2(3400, 3400)
	skill_map.size = Vector2(3400, 3400)
	skill_scroll.add_child(skill_map)
	_build_skill_tree(skill_map)
	var zoom_out := _button("−", Vector2(-166, 66), Vector2(42, 42), upgrade_panel)
	zoom_out.anchor_left = 1.0
	zoom_out.anchor_right = 1.0
	zoom_out.pressed.connect(func() -> void: _set_skill_zoom(skill_zoom - 0.15))
	var zoom_in := _button("+", Vector2(-116, 66), Vector2(42, 42), upgrade_panel)
	zoom_in.anchor_left = 1.0
	zoom_in.anchor_right = 1.0
	zoom_in.pressed.connect(func() -> void: _set_skill_zoom(skill_zoom + 0.15))
	var zoom_label := _label("ZOOM", Vector2(-218, 76), 10, upgrade_panel)
	zoom_label.anchor_left = 1.0
	zoom_label.anchor_right = 1.0
	# Open the tree focused on its central capacity core.
	skill_scroll.set_deferred("scroll_horizontal", 1400)
	skill_scroll.set_deferred("scroll_vertical", 1300)
	var hint := _label("DRAG PAD TO MOVE", Vector2(18, -28), 12, layer)
	hint.anchor_top = 1.0
	hint.anchor_bottom = 1.0
	_build_main_menu(layer, screen)


func _build_main_menu(layer: CanvasLayer, screen: Vector2) -> void:
	# Polished mobile game front menu with a translucent industrial backdrop.
	main_menu_panel = Control.new()
	main_menu_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_menu_panel.z_index = 50
	main_menu_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	layer.add_child(main_menu_panel)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.025, 0.045, 0.055, 0.94)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_menu_panel.add_child(shade)
	var accent := ColorRect.new()
	accent.position = Vector2(screen.x * 0.08, screen.y * 0.19)
	accent.size = Vector2(8, screen.y * 0.34)
	accent.color = Color(0.22, 0.82, 0.57)
	main_menu_panel.add_child(accent)
	var title := Label.new()
	title.text = "TRASH\\nEMPIRE"
	title.position = Vector2(screen.x * 0.12, screen.y * 0.17)
	title.size = Vector2(screen.x * 0.82, screen.y * 0.24)
	title.add_theme_font_size_override("font_size", int(screen.y * 0.065))
	title.add_theme_color_override("font_color", Color(0.92, 0.98, 0.95))
	title.add_theme_color_override("font_shadow_color", Color(0,0,0,0.5))
	title.add_theme_constant_override("shadow_offset_x", 3)
	title.add_theme_constant_override("shadow_offset_y", 4)
	main_menu_panel.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "BUILD YOUR RECYCLING BUSINESS"
	subtitle.position = Vector2(screen.x * 0.12, screen.y * 0.40)
	subtitle.size = Vector2(screen.x * 0.8, 36)
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", Color(0.48, 0.83, 0.70))
	main_menu_panel.add_child(subtitle)
	var button_width := screen.x * 0.76
	var button_height := 66.0
	var button_x := screen.x * 0.12
	var play := _button("▶   PLAY", Vector2(button_x, screen.y * 0.47), Vector2(button_width, button_height), main_menu_panel)
	play.add_theme_font_size_override("font_size", 24)
	play.add_theme_stylebox_override("normal", _button_style(Color(0.12, 0.62, 0.43)))
	play.add_theme_stylebox_override("hover", _button_style(Color(0.16, 0.72, 0.51)))
	play.pressed.connect(_close_main_menu)
	new_game_button = _button("NEW", Vector2(button_x, screen.y * 0.47 + 84), Vector2(button_width, 58), main_menu_panel)
	new_game_button.add_theme_stylebox_override("normal", _button_style(Color(0.18, 0.32, 0.30)))
	new_game_button.pressed.connect(_confirm_new_game)
	var exit_button := _button("EXIT GAME", Vector2(button_x, screen.y * 0.47 + 158), Vector2(button_width, 52), main_menu_panel)
	exit_button.add_theme_stylebox_override("normal", _button_style(Color(0.19, 0.25, 0.26)))
	exit_button.pressed.connect(_confirm_exit_game)
	var footer := Label.new()
	footer.text = "RECYCLE • UPGRADE • EXPAND"
	footer.position = Vector2(button_x, screen.y * 0.65)
	footer.size = Vector2(button_width, 28)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 12)
	footer.add_theme_color_override("font_color", Color(0.48, 0.58, 0.57))
	main_menu_panel.add_child(footer)
	# Keep the gameplay HUD behind the menu but hide it until play is selected.
	for child in layer.get_children():
		if child != main_menu_panel:
			child.visible = false


func _confirm_exit_game() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "EXIT TRASH EMPIRE?"
	dialog.dialog_text = "Are you sure you want to leave the factory?"
	dialog.ok_button_text = "EXIT"
	dialog.cancel_button_text = "CANCEL"
	dialog.confirmed.connect(func() -> void: get_tree().quit())
	add_child(dialog)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.close_requested.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(420, 190))

func _confirm_new_game() -> void:
	var confirm_panel := Panel.new()
	confirm_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	confirm_panel.position = Vector2(-150, -110)
	confirm_panel.size = Vector2(300, 220)
	confirm_panel.z_index = 100
	confirm_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.07, 0.12, 0.13, 1.0)))
	main_menu_panel.add_child(confirm_panel)
	var message := Label.new()
	message.text = "DELETE CURRENT WORLD?\\nAll progress will be lost."
	message.position = Vector2(18, 24)
	message.size = Vector2(264, 80)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 18)
	confirm_panel.add_child(message)
	var cancel := _button("CANCEL", Vector2(15, 135), Vector2(125, 52), confirm_panel)
	cancel.pressed.connect(confirm_panel.queue_free)
	var erase := _button("NEW", Vector2(160, 135), Vector2(125, 52), confirm_panel)
	erase.add_theme_stylebox_override("normal", _button_style(Color(0.65, 0.22, 0.18)))
	erase.pressed.connect(func() -> void:
		confirm_panel.queue_free()
		_start_new_world()
	)

func _start_new_world() -> void:
	money = 0
	carried = 0
	capacity = 4
	upgrade_level = 1
	speed_upgrade_level = 1
	unload_upgrade_level = 1
	equipment_upgrade_level = 1
	technology_upgrade_level = 1
	trash_value_upgrade_level = 1
	spawn_upgrade_level = 1
	auto_pickup_level = 0
	luck_upgrade_level = 1
	magnet_power_level = 1
	drone_level = 0
	drone_timer = 0.0
	_refresh_helper_drone_visibility()
	auto_pickup_timer = 0.0
	recycling_bonus = 1.0
	collection_range = 2.0
	yard_stage = 1
	factory_stage = 1
	factory_built_stage = 1
	if is_instance_valid(factory_visual_root):
		for factory_child in factory_visual_root.get_children():
			factory_visual_root.remove_child(factory_child)
			factory_child.queue_free()
	unload_timer = 0.0
	player.set("move_speed", 4.5)
	for item in trash_nodes:
		if is_instance_valid(item): item.queue_free()
	trash_nodes.clear()
	_apply_unlocked_districts()
	_build_trash()
	_update_ui()
	_refresh_upgrade_prices()
	_refresh_expansion_world_button()
	_refresh_factory_upgrade_button()
	_save_game()
	_set_message("NEW WORLD STARTED!")
	_close_main_menu()

func _close_main_menu() -> void:
	# Explicitly activate gameplay and reveal every HUD/world overlay hidden by the title menu.
	main_menu_open = false
	set_process(true)
	set_physics_process(true)
	if is_instance_valid(main_menu_panel):
		main_menu_panel.hide()
		main_menu_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var ui_layer := main_menu_panel.get_parent()
		if is_instance_valid(ui_layer):
			for child in ui_layer.get_children():
				if child != main_menu_panel:
					child.show()
	if is_instance_valid(player):
		player.set_process(true)
		player.set_physics_process(true)
	_update_ui()


func _build_skill_tree(parent: Control) -> void:
	# Circular skill galaxy: each branch occupies its own radial lane.
	var center := Vector2(1700, 1700)
	var node_size := Vector2(150, 88)
	var branch_defs := [
		{"branch":"speed","title":"SPEED","depth":1,"angle":210.0},
		{"branch":"range","title":"PICKUP RANGE","depth":1,"angle":270.0},
		{"branch":"unload","title":"RECYCLING","depth":1,"angle":330.0},
		{"branch":"technology","title":"TECHNOLOGY","depth":2,"angle":210.0},
		{"branch":"supply","title":"TRASH SUPPLY","depth":2,"angle":270.0},
		{"branch":"auto","title":"AUTO PICKUP","depth":2,"angle":330.0},
		{"branch":"value","title":"TRASH VALUE","depth":3,"angle":210.0},
		{"branch":"luck","title":"LUCKY FINDS","depth":3,"angle":270.0},
		{"branch":"magnet_power","title":"MAGNET POWER","depth":3,"angle":330.0},
		{"branch":"drones","title":"HELPER DRONES","depth":4,"angle":270.0}
	]
	var positions: Dictionary = {}
	# The core capacity skill sits in the middle of the galaxy.
	for level in range(1, 4):
		positions["capacity_%d" % level] = center + Vector2(0, float(level - 3) * 120.0)
	# Place every other skill along a clean radial lane.
	for branch_data in branch_defs:
		var direction := Vector2.from_angle(deg_to_rad(float(branch_data.angle)))
		var base_radius := 360.0 + (int(branch_data.depth) - 1) * 300.0
		for level in range(1, 4):
			var radius := base_radius + float(level - 1) * 105.0
			positions["%s_%d" % [branch_data.branch, level]] = center + direction * radius
	# Faint orbital guides make the circular layout easy to read.
	for radius in [360.0, 660.0, 960.0, 1260.0]:
		_add_skill_orbit(parent, center, radius)
	# Draw all dependency lines before the buttons so they stay behind the nodes.
	for level in range(1, 3):
		_add_skill_connection(parent, positions["capacity_%d" % level], positions["capacity_%d" % (level + 1)])
	for branch_data in branch_defs:
		var branch := String(branch_data.branch)
		for level in range(1, 3):
			_add_skill_connection(parent, positions["%s_%d" % [branch, level]], positions["%s_%d" % [branch, level + 1]])
	var dependencies := [
		["capacity_3", "speed_1"], ["capacity_3", "range_1"], ["capacity_3", "unload_1"],
		["speed_3", "technology_1"], ["technology_3", "value_1"],
		["range_3", "supply_1"], ["supply_3", "luck_1"],
		["unload_3", "auto_1"], ["auto_3", "magnet_power_1"],
		["luck_3", "drones_1"]
	]
	for dependency in dependencies:
		_add_skill_connection(parent, positions[dependency[0]], positions[dependency[1]])
	# Add circular skill nodes.
	var all_nodes := [{"branch":"capacity","title":"CAPACITY"}]
	for branch_data in branch_defs:
		all_nodes.append({"branch":String(branch_data.branch),"title":String(branch_data.title)})
	for node_data in all_nodes:
		var branch := String(node_data.branch)
		for level in range(1, 4):
			var button := Button.new()
			var point: Vector2 = positions["%s_%d" % [branch, level]]
			button.position = point - node_size * 0.5
			button.size = node_size
			button.custom_minimum_size = node_size
			button.add_theme_font_size_override("font_size", 11)
			button.add_theme_color_override("font_color", Color(0.95, 0.98, 0.96))
			button.add_theme_color_override("font_hover_color", Color.WHITE)
			button.add_theme_color_override("font_disabled_color", Color(0.68, 0.74, 0.72))
			button.focus_mode = Control.FOCUS_NONE
			button.pressed.connect(_purchase_skill_node.bind(branch, level))
			parent.add_child(button)
			skill_node_data.append({"button":button,"branch":branch,"level":level,"title":String(node_data.title)})
	# A small glowing core marker anchors the circular map.
	var core := Label.new()
	core.text = "✦  SKILL CORE  ✦"
	core.position = center + Vector2(-72, 92)
	core.size = Vector2(144, 28)
	core.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	core.add_theme_font_size_override("font_size", 11)
	core.add_theme_color_override("font_color", Color(0.42, 0.92, 0.72))
	parent.add_child(core)
	_refresh_upgrade_prices()

func _add_skill_orbit(parent: Control, center: Vector2, radius: float) -> void:
	var orbit := Line2D.new()
	orbit.width = 2.0
	orbit.default_color = Color(0.22, 0.55, 0.48, 0.22)
	orbit.antialiased = true
	for step in range(97):
		var angle := TAU * float(step) / 96.0
		orbit.add_point(center + Vector2(cos(angle), sin(angle)) * radius)
	parent.add_child(orbit)

func _skill_branch_color(branch: String) -> Color:
	match branch:
		"capacity": return Color(0.12, 0.62, 0.48)
		"speed": return Color(0.20, 0.52, 0.88)
		"range": return Color(0.65, 0.48, 0.90)
		"unload": return Color(0.88, 0.57, 0.18)
		"technology": return Color(0.18, 0.68, 0.78)
		"supply": return Color(0.72, 0.48, 0.24)
		"auto": return Color(0.30, 0.72, 0.38)
		"luck": return Color(0.92, 0.72, 0.20)
		"magnet_power": return Color(0.20, 0.78, 0.88)
		"drones": return Color(0.65, 0.78, 0.30)
	return Color(0.25, 0.45, 0.42)

func _skill_icon(branch: String) -> String:
	match branch:
		"capacity": return "🎒"
		"speed": return "⚡"
		"range": return "🧤"
		"unload": return "♻"
		"technology": return "⚙"
		"value": return "💰"
		"supply": return "🗑"
		"auto": return "🧲"
		"luck": return "🍀"
		"magnet_power": return "🧲"
		"drones": return "🚁"
	return "◆"

func _skill_node_style(color: Color, locked := false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 5
	style.border_color = color.lightened(0.48) if not locked else Color(0.20, 0.27, 0.28)
	style.shadow_color = Color(0, 0, 0, 0.42)
	style.shadow_size = 8
	style.content_margin_left = 7
	style.content_margin_right = 7
	style.content_margin_top = 7
	style.content_margin_bottom = 9
	return style

func _add_skill_connection(parent: Control, from_point: Vector2, to_point: Vector2) -> void:
	var line := Line2D.new()
	line.width = 5.0
	line.default_color = Color(0.28, 0.78, 0.62, 0.9)
	line.antialiased = true
	line.add_point(from_point)
	line.add_point(to_point)
	parent.add_child(line)

func _skill_level(branch: String) -> int:
	match branch:
		"capacity": return upgrade_level - 1
		"speed": return speed_upgrade_level - 1
		"unload": return unload_upgrade_level - 1
		"range": return equipment_upgrade_level - 1
		"technology": return technology_upgrade_level - 1
		"value": return trash_value_upgrade_level - 1
		"supply": return spawn_upgrade_level - 1
		"auto": return auto_pickup_level
		"luck": return luck_upgrade_level - 1
		"magnet_power": return magnet_power_level - 1
		"drones": return drone_level
	return 0

func _skill_branch_unlocked(branch: String) -> bool:
	match branch:
		"capacity": return true
		"speed", "range", "unload": return upgrade_level >= 4
		"technology": return speed_upgrade_level >= 4
		"value": return technology_upgrade_level >= 4
		"supply": return equipment_upgrade_level >= 4
		"auto": return unload_upgrade_level >= 4
		"luck": return spawn_upgrade_level >= 4
		"magnet_power": return auto_pickup_level >= 3
		"drones": return luck_upgrade_level >= 2
	return false

func _purchase_skill_node(branch: String, level: int) -> void:
	if not _skill_branch_unlocked(branch):
		_set_message("This skill path is still locked. Upgrade its connected path first.")
		return
	if level != _skill_level(branch) + 1 or level > 3:
		_set_message("Unlock the connected previous skill level first.")
		return
	match branch:
		"capacity": _upgrade_bag()
		"speed": _upgrade_speed()
		"unload": _upgrade_unload()
		"range": _upgrade_equipment()
		"technology": _upgrade_technology()
		"value": _upgrade_trash_value()
		"supply": _upgrade_spawn()
		"auto": _upgrade_auto_pickup()
		"luck": _upgrade_luck()
		"magnet_power": _upgrade_magnet_power()
		"drones": _upgrade_drones()

func _refresh_upgrade_prices() -> void:
	for node in skill_node_data:
		var branch := String(node.branch)
		var level := int(node.level)
		var current := _skill_level(branch)
		var available := _skill_branch_unlocked(branch) and level == current + 1 and level <= 3
		var owned := current >= level
		var button := node.button as Button
		var accent := _skill_branch_color(branch)
		var icon := _skill_icon(branch)
		if owned:
			button.text = "%s  %s\nLEVEL %d\n✓  INSTALLED" % [icon, node.title, level]
			button.disabled = true
			button.add_theme_stylebox_override("normal", _skill_node_style(Color(0.055, 0.29, 0.22)))
			button.add_theme_stylebox_override("hover", _skill_node_style(Color(0.07, 0.35, 0.26)))
		elif available:
			var base_cost: float = float({"capacity":4.0,"speed":8.0,"unload":6.0,"range":9.0,"technology":18.0,"value":24.0,"supply":14.0,"auto":30.0,"luck":20.0,"magnet_power":28.0,"drones":35.0}.get(branch, 4.0))
			var price_level := level
			button.text = "%s  %s\nLEVEL %d\n$%.0f  •  UNLOCK" % [icon, node.title, level, _upgrade_cost(base_cost, price_level)]
			button.disabled = false
			button.add_theme_stylebox_override("normal", _skill_node_style(accent.darkened(0.55)))
			button.add_theme_stylebox_override("hover", _skill_node_style(accent.darkened(0.35)))
			button.add_theme_stylebox_override("pressed", _skill_node_style(accent.darkened(0.68)))
		else:
			button.text = "🔒  %s\nLEVEL %d\nLOCKED" % [node.title, level]
			button.disabled = true
			button.add_theme_stylebox_override("normal", _skill_node_style(Color(0.075, 0.095, 0.105), true))

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_confirm_exit_game()

func _input(event: InputEvent) -> void:
	if main_menu_open:
		return
	# Skill tree: one-finger drag, two-finger pinch zoom and smooth momentum.
	if upgrade_panel != null and upgrade_panel.visible and is_instance_valid(skill_scroll_container):
		var scroll_rect := skill_scroll_container.get_global_rect()
		if event is InputEventScreenTouch:
			if event.pressed and scroll_rect.has_point(event.position):
				skill_touch_points[event.index] = event.position
				if skill_touch_points.size() == 1:
					skill_drag_touch = event.index
					skill_scroll_velocity = 0.0
				elif skill_touch_points.size() == 2:
					var points: Array = skill_touch_points.values()
					skill_pinch_distance = points[0].distance_to(points[1])
					skill_drag_touch = -1
				get_viewport().set_input_as_handled()
			elif not event.pressed:
				skill_touch_points.erase(event.index)
				if event.index == skill_drag_touch:
					skill_drag_touch = -1
				if skill_touch_points.size() == 1:
					var remaining_index = skill_touch_points.keys()[0]
					skill_drag_touch = int(remaining_index)
				else:
					skill_pinch_distance = 0.0
				get_viewport().set_input_as_handled()
		elif event is InputEventScreenDrag:
			if skill_touch_points.has(event.index):
				skill_touch_points[event.index] = event.position
				if skill_touch_points.size() >= 2:
					var points: Array = skill_touch_points.values()
					var distance: float = points[0].distance_to(points[1])
					if skill_pinch_distance > 0.0:
						_set_skill_zoom(skill_zoom * (distance / skill_pinch_distance))
					skill_pinch_distance = distance
					skill_drag_touch = -1
				elif event.index == skill_drag_touch:
					skill_scroll_velocity = -event.relative.y * 18.0
					skill_scroll_container.scroll_vertical = maxi(0, skill_scroll_container.scroll_vertical - int(event.relative.y))
				get_viewport().set_input_as_handled()
		return
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

func _process_skill_scroll(delta: float) -> void:
	if skill_drag_touch != -1 or not is_instance_valid(skill_scroll_container):
		return
	if absf(skill_scroll_velocity) < 4.0:
		skill_scroll_velocity = 0.0
		return
	var max_scroll := maxi(0, int(skill_scroll_container.get_v_scroll_bar().max_value - skill_scroll_container.get_v_scroll_bar().page))
	var next_scroll := clampi(skill_scroll_container.scroll_vertical + int(skill_scroll_velocity * delta), 0, max_scroll)
	skill_scroll_container.scroll_vertical = next_scroll
	if next_scroll == 0 or next_scroll == max_scroll:
		skill_scroll_velocity = 0.0
	else:
		skill_scroll_velocity *= exp(-3.2 * delta)

func _set_skill_zoom(value: float) -> void:
	if not is_instance_valid(skill_map) or not is_instance_valid(skill_scroll_container):
		return
	var old_zoom := skill_zoom
	skill_zoom = clampf(value, 0.55, 1.65)
	if is_equal_approx(old_zoom, skill_zoom):
		return
	var view_center := Vector2(skill_scroll_container.scroll_horizontal, skill_scroll_container.scroll_vertical) + skill_scroll_container.size * 0.5
	var map_center := view_center / old_zoom
	skill_map.scale = Vector2.ONE * skill_zoom
	skill_map.custom_minimum_size = Vector2(3400.0, 3400.0) * skill_zoom
	skill_map.size = skill_map.custom_minimum_size
	await get_tree().process_frame
	skill_scroll_container.scroll_horizontal = clampi(int(map_center.x * skill_zoom - skill_scroll_container.size.x * 0.5), 0, int(skill_scroll_container.get_h_scroll_bar().max_value - skill_scroll_container.get_h_scroll_bar().page))
	skill_scroll_container.scroll_vertical = clampi(int(map_center.y * skill_zoom - skill_scroll_container.size.y * 0.5), 0, int(skill_scroll_container.get_v_scroll_bar().max_value - skill_scroll_container.get_v_scroll_bar().page))

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
		if carried >= capacity:
			_set_message("BACKPACK FULL! Return to the recycling station.")
		else:
			_set_message("Collected! Keep cleaning the yard.")
	else:
		_set_message("Get closer to a piece of trash.")

func _process_auto_pickup(delta: float) -> void:
	if auto_pickup_level <= 0 or not is_instance_valid(player) or carried >= capacity:
		auto_pickup_timer = 0.0
		return

	# A visible magnet effect: nearby litter glides toward the player before collection.
	var magnet_range := collection_range + 1.2 + float(auto_pickup_level - 1) * 0.85 + float(magnet_power_level - 1) * 0.7
	var pull_speed := 2.8 + float(auto_pickup_level - 1) * 0.65 + float(magnet_power_level - 1) * 1.1
	for item in trash_nodes:
		if not is_instance_valid(item):
			continue
		var distance := player.global_position.distance_to(item.global_position)
		if distance <= magnet_range and distance > 0.85:
			var target := player.global_position + Vector3(0.0, 0.25, 0.0)
			item.global_position = item.global_position.move_toward(target, pull_speed * delta)

	auto_pickup_timer += delta
	var interval := maxf(0.18, 0.72 - float(auto_pickup_level - 1) * 0.12)
	if auto_pickup_timer < interval:
		return
	auto_pickup_timer = 0.0

	# Higher levels collect several nearby pieces per pulse instead of only one.
	var collect_limit := mini(1 + int(floor(float(auto_pickup_level) / 2.0)), 5)
	var collected := 0
	while collected < collect_limit and carried < capacity:
		var nearest: Node3D
		var best_distance := collection_range + 1.0 + float(auto_pickup_level - 1) * 0.55
		for item in trash_nodes:
			if not is_instance_valid(item):
				continue
			var distance := player.global_position.distance_to(item.global_position)
			if distance < best_distance:
				best_distance = distance
				nearest = item
		if nearest == null:
			break
		nearest.queue_free()
		trash_nodes.erase(nearest)
		carried += 1
		collected += 1

	if collected > 0:
		_update_ui()
		_save_game()
		_set_message("AUTO MAGNET  +%d" % collected)
	if carried >= capacity:
		_set_message("Bag full! Return to the recycling station.")

func _build_helper_drones() -> void:
	helper_drones.clear()
	for i in range(3):
		var drone := Node3D.new()
		drone.name = "HelperDrone%d" % (i + 1)
		player.add_child(drone)
		_add_robot_box(drone, "DroneBody", Vector3.ZERO, Vector3(0.34, 0.20, 0.30), Color(0.70, 0.78, 0.78))
		_add_robot_box(drone, "DroneFront", Vector3(0, -0.015, -0.16), Vector3(0.20, 0.10, 0.035), Color(0.12, 0.82, 0.68))
		_add_robot_sphere(drone, "DroneEye", Vector3(0, 0.02, -0.19), 0.045, Color(0.35, 1.0, 0.78))
		for side in [-1.0, 1.0]:
			_add_robot_box(drone, "DroneRotorArm", Vector3(side * 0.27, 0.04, 0), Vector3(0.25, 0.035, 0.06), Color(0.25, 0.32, 0.34))
			_add_robot_sphere(drone, "DroneRotor", Vector3(side * 0.40, 0.10, 0), 0.10, Color(0.16, 0.22, 0.24))
		drone.visible = i < drone_level
		helper_drones.append(drone)

func _refresh_helper_drone_visibility() -> void:
	for i in range(helper_drones.size()):
		if is_instance_valid(helper_drones[i]):
			helper_drones[i].visible = i < drone_level

func _process_helper_drones(delta: float) -> void:
	if drone_level <= 0 or not is_instance_valid(player):
		return
	drone_timer += delta
	for i in range(helper_drones.size()):
		var drone := helper_drones[i]
		if not is_instance_valid(drone) or not drone.visible:
			continue
		var angle := robot_anim_time * 1.25 + float(i) * TAU / float(maxi(drone_level, 1))
		drone.position = Vector3(cos(angle) * 1.35, 2.25 + sin(robot_anim_time * 3.0 + float(i)) * 0.10, sin(angle) * 1.15)
		drone.rotation.y = -angle
	var interval := maxf(0.75, 3.2 - float(drone_level - 1) * 0.65)
	if drone_timer < interval or carried >= capacity:
		return
	drone_timer = 0.0
	var collected := 0
	for i in range(drone_level):
		if carried >= capacity:
			break
		var nearest: Node3D
		var best_distance := 5.0 + float(drone_level - 1) * 2.0
		for item in trash_nodes:
			if not is_instance_valid(item):
				continue
			var distance := player.global_position.distance_to(item.global_position)
			if distance < best_distance:
				best_distance = distance
				nearest = item
		if nearest == null:
			break
		nearest.queue_free()
		trash_nodes.erase(nearest)
		carried += 1
		collected += 1
	if collected > 0:
		_update_ui()
		_save_game()
		_set_message("HELPER DRONES  +%d" % collected)

func _process_auto_sell(delta: float) -> void:
	if not is_instance_valid(player):
		return
	var inside_zone := player.global_position.distance_to(SELL_POINT) <= 2.35
	if not inside_zone or carried <= 0:
		unload_timer = 0.0
		return
	unload_timer += delta
	var seconds_per_item := maxf(0.35, 1.8 - float(unload_upgrade_level - 1) * 0.18)
	if unload_timer >= seconds_per_item:
		unload_timer = 0.0
		carried -= 1
		_spawn_conveyor_item()
		var factory_multipliers := [1.0, 1.5, 2.25, 3.5]
		var factory_multiplier: float = factory_multipliers[clampi(factory_stage - 1, 0, 3)]
		var item_value := 0.1 * recycling_bonus * factory_multiplier * (1.0 + float(trash_value_upgrade_level - 1) * 0.25)
		if randf() < float(luck_upgrade_level - 1) * 0.10:
			item_value *= 2.0
		money += item_value
		_update_ui()
		_save_game()
		_set_message("Conveyor recycling... +$%.2f" % item_value)
		if carried == 0:
			_set_message("Bag emptied! Money added.")

func _toggle_upgrade_panel() -> void:
	if is_instance_valid(upgrade_panel):
		upgrade_panel.visible = not upgrade_panel.visible

func _upgrade_bag() -> void:
	var cost := _upgrade_cost(4.0, upgrade_level)
	if money < cost:
		_set_message("You need $%.1f for the next bag upgrade." % cost)
		return
	money -= cost
	capacity += 3
	upgrade_level += 1
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Upgrade purchased! New bag capacity: %d." % capacity)

func _upgrade_speed() -> void:
	var cost := _upgrade_cost(8.0, speed_upgrade_level)
	if money < cost:
		_set_message("You need $%.1f for the speed upgrade." % cost)
		return
	money -= cost
	speed_upgrade_level += 1
	player.set("move_speed", 4.5 + float(speed_upgrade_level - 1) * 0.75)
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Movement speed upgraded!")

func _upgrade_unload() -> void:
	var cost := _upgrade_cost(6.0, unload_upgrade_level)
	if money < cost:
		_set_message("You need $%.1f for faster unloading." % cost)
		return
	money -= cost
	unload_upgrade_level += 1
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Unloading speed upgraded!")

func _upgrade_equipment() -> void:
	var cost := _upgrade_cost(9.0, equipment_upgrade_level)
	if money < cost:
		_set_message("You need $%.1f for the magnet upgrade." % cost)
		return
	money -= cost
	equipment_upgrade_level += 1
	collection_range = 2.0 + float(equipment_upgrade_level - 1) * 0.65
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Magnet range increased!")

func _upgrade_technology() -> void:
	var cost := _upgrade_cost(18.0, technology_upgrade_level)
	if money < cost:
		_set_message("You need $%.1f for the technology upgrade." % cost)
		return
	money -= cost
	technology_upgrade_level += 1
	recycling_bonus = 1.0 + float(technology_upgrade_level - 1) * 0.15
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Recycling value increased!")

func _upgrade_luck() -> void:
	var cost := _upgrade_cost(20.0, luck_upgrade_level)
	if money < cost:
		_set_message("You need $%.1f for the lucky finds upgrade." % cost)
		return
	money -= cost
	luck_upgrade_level += 1
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Lucky finds chance increased by 10%!")

func _upgrade_drones() -> void:
	var cost := _upgrade_cost(35.0, drone_level + 1)
	if money < cost:
		_set_message("You need $%.1f for helper drones." % cost)
		return
	money -= cost
	drone_level += 1
	_refresh_helper_drone_visibility()
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Helper drone upgraded! %d drone(s) now collect trash automatically." % drone_level)

func _upgrade_magnet_power() -> void:
	var cost := _upgrade_cost(28.0, magnet_power_level)
	if money < cost:
		_set_message("You need $%.1f for magnet power." % cost)
		return
	money -= cost
	magnet_power_level += 1
	if is_instance_valid(magnet_tool):
		magnet_tool.visible = true
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Magnet pull power increased!")

func _upgrade_trash_value() -> void:
	var cost := _upgrade_cost(24.0, trash_value_upgrade_level)
	if money < cost:
		_set_message("You need $%.1f for the trash value upgrade." % cost)
		return
	money -= cost
	trash_value_upgrade_level += 1
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Trash sale value increased by 25%!")

func _upgrade_cost(base_cost: float, level: int) -> float:
	# Stronger effects cost more; each successive level scales by 55%.
	return ceil(base_cost * pow(1.55, float(level - 1)))

func _upgrade_spawn() -> void:
	var cost := _upgrade_cost(14.0, spawn_upgrade_level)
	if money < cost:
		_set_message("You need $%.1f for the trash supply upgrade." % cost)
		return
	money -= cost
	spawn_upgrade_level += 1
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Trash supply upgraded! +6 trash on every manual refill.")

func _upgrade_auto_pickup() -> void:
	var cost := _upgrade_cost(30.0, auto_pickup_level + 1)
	if money < cost:
		_set_message("You need $%.1f for automatic pickup." % cost)
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

func _create_expansion_zone() -> void:
	var zone := Node3D.new()
	zone.name = "DistrictUnlockZone"
	zone.position = Vector3(13.15, 0.0, 0.0)
	add_child(zone)
	var base := MeshInstance3D.new()
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 1.55
	base_mesh.bottom_radius = 1.70
	base_mesh.height = 0.12
	base_mesh.radial_segments = 48
	base.mesh = base_mesh
	base.position.y = 0.07
	base.material_override = _mat(Color(0.10, 0.28, 0.24))
	zone.add_child(base)
	var pad := MeshInstance3D.new()
	var pad_mesh := CylinderMesh.new()
	pad_mesh.top_radius = 1.30
	pad_mesh.bottom_radius = 1.30
	pad_mesh.height = 0.06
	pad_mesh.radial_segments = 48
	pad.mesh = pad_mesh
	pad.position.y = 0.15
	pad.material_override = _mat(Color(0.20, 0.78, 0.43))
	zone.add_child(pad)
	var ring := MeshInstance3D.new()
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 1.36
	ring_mesh.outer_radius = 1.48
	ring_mesh.rings = 48
	ring.mesh = ring_mesh
	ring.position.y = 0.20
	ring.material_override = _mat(Color(0.95, 0.76, 0.20))
	zone.add_child(ring)
	var label := Label3D.new()
	label.name = "UnlockZoneLabel"
	label.text = "STEP HERE\nUNLOCK DISTRICT 2\n$80"
	label.position = Vector3(0, 2.2, 0)
	label.font_size = 34
	label.pixel_size = 0.006
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color(1.0, 0.96, 0.78)
	zone.add_child(label)

func _process_expansion_zone() -> void:
	if not is_instance_valid(player) or yard_stage >= 3:
		expansion_zone_blocked = false
		return
	var target_x := 13.15 if yard_stage == 1 else 45.15
	var distance := Vector2(player.global_position.x - target_x, player.global_position.z).length()
	if distance > 2.7:
		expansion_zone_blocked = false
		return
	if expansion_zone_blocked:
		return
	expansion_zone_blocked = true
	_buy_next_stage()

func _buy_next_stage() -> void:
	if yard_stage >= 3:
		_set_message("All districts unlocked!")
		return
	var cost := 80.0 if yard_stage == 1 else 250.0
	if money < cost:
		_set_message("You need $%.0f to unlock the next district." % cost)
		return
	money -= cost
	yard_stage += 1
	var gate_index := yard_stage - 2
	if gate_index >= 0 and gate_index < expansion_gates.size():
		var gate := expansion_gates[gate_index]
		if is_instance_valid(gate):
			gate.queue_free()
	if yard_stage == 2:
		_spawn_district_two_trash(48)
	else:
		_spawn_trash(24)
	_update_ui()
	_refresh_expansion_world_button()
	_save_game()
	_set_message("DISTRICT %d UNLOCKED!" % yard_stage)

func _refresh_expansion_world_button() -> void:
	var zone := get_node_or_null("DistrictUnlockZone") as Node3D
	if not is_instance_valid(zone):
		return
	zone.visible = yard_stage < 3
	if yard_stage == 1:
		zone.position = Vector3(13.15, 0.0, 0.0)
		var label := zone.get_node_or_null("UnlockZoneLabel") as Label3D
		if is_instance_valid(label):
			label.text = "STEP HERE\nUNLOCK DISTRICT 2\n$80"
	else:
		zone.position = Vector3(45.15, 0.0, 0.0)
		var label := zone.get_node_or_null("UnlockZoneLabel") as Label3D
		if is_instance_valid(label):
			label.text = "STEP HERE\nUNLOCK DISTRICT 3\n$250"
	expansion_zone_blocked = false

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
	save.set_value("progress", "trash_value_level", trash_value_upgrade_level)
	save.set_value("progress", "spawn_level", spawn_upgrade_level)
	save.set_value("progress", "auto_pickup_level", auto_pickup_level)
	save.set_value("progress", "luck_level", luck_upgrade_level)
	save.set_value("progress", "magnet_power_level", magnet_power_level)
	save.set_value("progress", "drone_level", drone_level)
	save.set_value("progress", "yard_stage", yard_stage)
	save.set_value("progress", "factory_stage", factory_stage)
	save.save("user://trash_empire.save")

func _load_game() -> void:
	var save := ConfigFile.new()
	if save.load("user://trash_empire.save") != OK:
		return
	money = float(save.get_value("progress", "money", 0.0))
	carried = int(save.get_value("progress", "carried", 0))
	capacity = int(save.get_value("progress", "capacity", 4))
	upgrade_level = int(save.get_value("progress", "bag_level", 1))
	speed_upgrade_level = int(save.get_value("progress", "speed_level", 1))
	unload_upgrade_level = int(save.get_value("progress", "unload_level", 1))
	equipment_upgrade_level = int(save.get_value("progress", "equipment_level", 1))
	technology_upgrade_level = int(save.get_value("progress", "technology_level", 1))
	trash_value_upgrade_level = int(save.get_value("progress", "trash_value_level", 1))
	spawn_upgrade_level = int(save.get_value("progress", "spawn_level", 1))
	auto_pickup_level = int(save.get_value("progress", "auto_pickup_level", 0))
	luck_upgrade_level = int(save.get_value("progress", "luck_level", 1))
	magnet_power_level = int(save.get_value("progress", "magnet_power_level", 1))
	drone_level = clampi(int(save.get_value("progress", "drone_level", 0)), 0, 3)
	yard_stage = clampi(int(save.get_value("progress", "yard_stage", 1)), 1, 3)
	factory_stage = clampi(int(save.get_value("progress", "factory_stage", 1)), 1, 4)
	collection_range = 2.0 + float(equipment_upgrade_level - 1) * 0.65
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

func _spawn_district_two_trash(amount: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(amount):
		var item := Node3D.new()
		item.set_script(TRASH_SCRIPT)
		var angle := rng.randf_range(0.0, TAU)
		var radius := sqrt(rng.randf()) * 9.5
		item.position = Vector3(32.0 + cos(angle) * radius, 0.34 + rng.randf_range(0.0, 0.12), sin(angle) * radius)
		add_child(item)
		trash_nodes.append(item)

func _refill_first_district() -> void:
	var existing_first_district := 0
	for item in trash_nodes:
		if is_instance_valid(item) and item.global_position.x >= -15.0 and item.global_position.x <= 15.0:
			existing_first_district += 1
	var refill_target := 18 + (spawn_upgrade_level - 1) * 4
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
	money_label.text = "CASH  $%.1f" % money
	bag_label.text = "BACKPACK  %d / %d" % [carried, capacity]
	var is_full := carried >= capacity
	var bag_color := Color(1.0, 0.20, 0.16) if is_full else Color(0.88, 0.96, 0.92)
	bag_label.add_theme_color_override("font_color", bag_color)
	bag_label.add_theme_color_override("font_outline_color", Color(0.20, 0.015, 0.01) if is_full else Color(0.015, 0.035, 0.03))
	bag_label.add_theme_constant_override("outline_size", 5 if is_full else 2)
	if is_full:
		bag_label.text += "  FULL!"

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
	# Reuse the detailed bottle/can/cup/wrapper models instead of sending a plain cube.
	var item := Node3D.new()
	item.name = "ConveyorRecyclingItem"
	item.set_script(TRASH_SCRIPT)
	item.position = Vector3(2.55, 1.22, -6.5 + randf_range(-0.32, 0.32))
	item.scale = Vector3.ONE * 0.72
	add_child(item)
	var travel := create_tween()
	travel.set_trans(Tween.TRANS_SINE)
	travel.set_ease(Tween.EASE_IN_OUT)
	travel.tween_property(item, "position", Vector3(5.35, 1.25, item.position.z), 1.0)
	travel.parallel().tween_property(item, "rotation:y", item.rotation.y + TAU, 1.0)
	travel.tween_property(item, "position", Vector3(7.5, 1.25, -6.5), 0.55)
	travel.tween_property(item, "position", Vector3(7.5, 1.25, -5.0), 0.45)
	if factory_stage >= 2:
		travel.tween_property(item, "position", Vector3(7.5, 1.25, -2.0), 0.9)
	if factory_stage >= 3:
		travel.tween_property(item, "position", Vector3(7.5, 1.25, 3.45), 1.1)
	if factory_stage >= 4:
		travel.tween_property(item, "position", Vector3(7.5, 1.25, 8.95), 1.1)
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
