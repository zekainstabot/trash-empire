extends Node3D

const PLAYER_SCRIPT = preload("res://Scripts/player.gd")
const TRASH_SCRIPT = preload("res://Scripts/trash.gd")

var player: CharacterBody3D
var camera: Camera3D
var camera_pivot: Node3D
var money := 0.0
var carried := 0 # occupied backpack slots
var carried_bulky := 0 # bulky items occupying two slots each
var capacity := 4
var collection_range := 2.0
var upgrade_level := 1
var speed_upgrade_level := 1
var unload_upgrade_level := 1
var equipment_upgrade_level := 1
var technology_upgrade_level := 1
var trash_value_upgrade_level := 1
var spawn_upgrade_level := 1
var respawn_level := 0
var respawn_timer := 0.0
var auto_pickup_level := 0
var bulk_pickup_level := 0
var luck_upgrade_level := 1
var rare_drop_upgrade_level := 0
var magnet_power_level := 1
var suction_level := 0
var suction_tool: Node3D
var suction_target: Node3D
var suction_scan_timer := 0.0
var suction_pull_timer := 0.0
var drone_level := 0
var ground_robot_level := 0
var ground_collector: Node3D
var ground_collector_timer := 0.0
var sorting_bins: Array[Node3D] = []
var sorting_robots: Array[Node3D] = []
var sorting_robot_levels: Array = [0, 0, 0, 0]
var sorting_bin_counts: Array = [0, 0, 0, 0]
var sorting_area_root: Node3D
var sorting_bin_positions: Array[Vector3] = [Vector3(26, 0, -20), Vector3(58, 0, 20), Vector3(90, 0, -20), Vector3(151, 0, 20)]
var sorting_pad_positions: Array[Vector3] = [Vector3(26, 0, -16), Vector3(58, 0, 16), Vector3(90, 0, -16), Vector3(151, 0, 16)]
var sorting_station_colors: Array[Color] = [Color(0.12, 0.42, 0.88), Color(0.88, 0.76, 0.22), Color(0.48, 0.52, 0.55), Color(0.15, 0.68, 0.42)]
var sorting_station_names: Array[String] = ["PLASTIC", "PAPER", "METAL", "GLASS"]
var sorting_station_categories: Array[String] = ["plastic", "paper", "metal", "glass"]
var drone_timer := 0.0
var helper_drones: Array[Node3D] = []
var auto_pickup_timer := 0.0
var auto_pickup_scan_timer := 0.0
var auto_pickup_target: Node3D
var recycling_bonus := 1.0
var skill_buttons: Array[Button] = []
var skill_branch_panels: Array[PanelContainer] = []
var skill_node_data: Array[Dictionary] = []
var skill_connection_data: Array[Dictionary] = []
var skill_scroll_container: ScrollContainer
var skill_map: Control
var skill_zoom := 1.0
var skill_drag_touch := -1
var skill_touch_points: Dictionary = {}
var skill_pinch_distance := 0.0
var skill_scroll_velocity := Vector2.ZERO
var skill_scroll_target := 0.0
var skill_scroll_smoothing := false
var skill_scroll_tween: Tween
var skill_touch_last_position := Vector2.ZERO
var skill_touch_moved := false
var collection_tool_extension := 0.0
var unload_timer := 0.0
var upgrade_panel: Panel
var bag_upgrade_button: Button
var movement_upgrade_button: Button
var unload_upgrade_button: Button
var trash_nodes: Array[Node3D] = []
var final_zone_cleaned := 0
var total_trash_collected := 0
var replenishment_threshold := 500
var final_zone_label: Label
const FINAL_ZONE_TARGET := 60000
const FINAL_LANDFILL_CLUSTERS := [
	Vector2(-6.0, -22.0), Vector2(8.0, 18.0), Vector2(22.0, -14.0),
	Vector2(38.0, 8.0), Vector2(54.0, -23.0), Vector2(70.0, 18.0),
	Vector2(86.0, -8.0), Vector2(102.0, 23.0), Vector2(119.0, -21.0),
	Vector2(135.0, 10.0), Vector2(151.0, -12.0), Vector2(166.0, 22.0),
	Vector2(178.0, -20.0), Vector2(190.0, 7.0), Vector2(199.0, 24.0)
]
var money_label: Label
var bag_label: Label
var message_label: Label
var mission_label: Label
var tutorial_mission_stage := 0
var joystick_pad: Panel
var joystick_knob: Panel
var joystick_touch := -1
var gameplay_touch_points: Dictionary = {}
var gameplay_pinch_distance := 0.0
var gameplay_pinch_fov := 58.0
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
var factory_build_zones_root: Node3D
var factory_build_label: Label3D
var factory_build_paid := 0.0
var factory_build_save_timer := 0.0
var mega_factory_built_count := 1
var factory_row_input_stock: Array[int] = [0, 0, 0, 0, 0]
var factory_row_product_stock: Array[int] = [0, 0, 0, 0, 0]
var factory_production_timer := 0.0
var waste_tank_inventory := 0
const WASTE_TANK_CAPACITY := 300
var mega_factory_build_paid := 0.0
var mega_factory_build_timer := 0.0
var mega_factory_machine_labels: Array[Label3D] = []
var factory_shipping_timer := 0.0
var factory_shipping_busy := false
var factory_shipping_row := 0
var factory_shipping_trucks: Array[Node3D] = []
var waste_tank_built := false
var waste_tank_root: Node3D
var waste_tank_build_label: Label3D
var waste_feed_timer := 0.0
var waste_feed_busy := false
var waste_feed_line_index := 0
var factory_upgrade_button: Node3D
var yard_stage := 1
var expansion_gates: Array[Node3D] = []
var expansion_world_button: Node3D
var expansion_zone_blocked := false
var district_build_active := false
var district_build_paid := 0.0
var district_build_save_timer := 0.0
var district_no_money_notified := false
var payment_active := false
var active_upgrade_branch := ""
var teddy_stock_values: Array[float] = []
var shipping_active := false
var truck_dispatch_timer := 0.0
var dispatch_trucks_remaining := 0
var dispatch_upgrade_level := 0
var fleet_upgrade_level := 0
var truck_capacity_upgrade_level := 0
var packaging_upgrade_level := 0
var delivery_trucks: Array[Node3D] = []
var city_truck: Node3D
var city_trucks: Array[Node3D] = []
var sorting_robot_upgrade_level := 0
var conveyor_speed_upgrade_level := 0
var repair_robot_level := 0
var machine_broken := false
var machine_work_timer := 0.0
var machine_repair_timer := 0.0
var city_fleet_upgrade_level := 0
var city_trash_reserved := 0
var city_truck_phase := 3
var city_truck_timer := 0.0
var city_truck_upgrade_level := 0
var city_truck_start := Vector3(-7.2, 0.0, 33.0)
var city_truck_dump := Vector3(124.8, 0.0, 0.0)
var refill_world_button: Node3D
var main_menu_panel: Control
var main_menu_open := true
var new_game_button: Button
var main_menu_play_button: Button
var skill_tree_built := false
var world_initialized := false
var city_pedestrians: Array[Dictionary] = []
var pedestrian_clock := 0.0

const YARD_LIMIT := 14.5
const SELL_POINT := Vector3(1.35, 0.0, -6.5)

func _ready() -> void:
	# Always activate a camera on the very first frame. The gameplay camera
	# is created later when PLAY is pressed; without this boot camera some
	# Android devices show only the viewport clear color and no menu.
	camera = Camera3D.new()
	camera.name = "BootCamera"
	camera.position = Vector3(0.0, 12.0, 24.0)
	camera.rotation_degrees = Vector3(-22.0, 0.0, 0.0)
	camera.current = true
	camera.near = 0.05
	camera.far = 250.0
	add_child(camera)

	# Build the lightweight title UI before creating the 3D world.
	main_menu_open = true
	_load_game()
	_build_ui()
	_update_ui()
	if is_instance_valid(main_menu_panel):
		main_menu_panel.show()
	set_process(true)
	set_physics_process(true)

func _process(delta: float) -> void:
	if main_menu_open:
		return
	_process_upgrade_scroll_smoothing(delta)
	_process_expansion_zone(delta)
	_process_mega_factory_build(delta)
	_process_factory_row_shipping(delta)
	_process_waste_feed_conveyor(delta)
	_process_factory_production(delta)
	if is_instance_valid(player) and player.global_position.y < -3.0:
		_recover_player()
	if is_instance_valid(player) and is_instance_valid(camera_pivot):
		camera_pivot.global_position = player.global_position + Vector3(0, 8.0, 10.5)
	_animate_robot(delta)
	_animate_conveyor(delta)
	_process_machine_maintenance(delta)
	_process_auto_sell(delta)
	_process_teddy_shipping(delta)
	_process_auto_pickup(delta)
	_process_vacuum_suction(delta)
	_process_helper_drones(delta)
	_process_ground_collector(delta)
	_process_sorting_robots(delta)
	_process_trash_respawn(delta)
	_animate_city_pedestrians(delta)

func _build_world() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky_resource := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.16, 0.38, 0.68)
	sky_material.sky_horizon_color = Color(0.72, 0.82, 0.92)
	sky_material.ground_bottom_color = Color(0.20, 0.24, 0.25)
	sky_material.ground_horizon_color = Color(0.55, 0.61, 0.63)
	sky_material.sun_angle_max = 18.0
	sky_material.use_debanding = true
	sky_resource.sky_material = sky_material
	env.sky = sky_resource
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.72, 0.77, 0.82)
	env.ambient_light_energy = 0.92
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.08
	env.tonemap_white = 5.0
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -32, 0)
	sun.light_energy = 1.28
	sun.shadow_enabled = true
	sun.shadow_bias = 0.035
	sun.directional_shadow_max_distance = 75.0
	add_child(sun)

	# Main concrete yard and worn work zones.
	_box("ConcreteYard", Vector3(0, -0.3, 0), Vector3(32, 0.6, 72), Color(0.34, 0.37, 0.35), true)
	_box("RoadLane", Vector3(-8.0, 0.012, 1.0), Vector3(5.0, 0.025, 70.0), Color(0.19, 0.22, 0.22), false)
	for z in range(-11, 13, 4):
		_box("RoadDash", Vector3(-8.0, 0.03, z), Vector3(0.13, 0.025, 1.7), Color(0.88, 0.77, 0.38), false)
	_build_city_dump_area()
	# Endgame landfill: a continuous, walkable extension of the city.
	_box("FinalCleanupGround", Vector3(160, -0.3, 0), Vector3(96, 0.6, 72), Color(0.30, 0.32, 0.27), true)
	_box("FinalCleanupWorkPad", Vector3(160, 0.018, 0), Vector3(90, 0.035, 62), Color(0.28, 0.30, 0.26), false)
	_box("FinalZoneAccessRoad", Vector3(122, 0.025, 0), Vector3(28, 0.05, 8.0), Color(0.14, 0.17, 0.18), false)
	_box("FinalZoneRoadCenterLine", Vector3(122, 0.055, 0), Vector3(26, 0.012, 0.13), Color(0.91, 0.78, 0.43), false)
	_box("FinalZoneEntryApron", Vector3(135, 0.045, 0), Vector3(8, 0.08, 15), Color(0.34, 0.35, 0.30), false)
	_box("FinalZoneSignPost", Vector3(119, 2.0, -7.0), Vector3(0.22, 4.0, 0.22), Color(0.22, 0.25, 0.24), false)
	_box("FinalZoneSignBoard", Vector3(119, 3.35, -7.0), Vector3(9.5, 1.8, 0.28), Color(0.08, 0.27, 0.25), false)
	_label_3d("RECYCLING FACTORY", Vector3(119, 3.45, -6.82), 0.42)
	for marker_x in range(118, 207, 8):
		_box("FinalZoneBoundaryMarker", Vector3(float(marker_x), 0.04, -34.0), Vector3(0.7, 0.08, 0.7), Color(0.88, 0.62, 0.12), false)
		_box("FinalZoneBoundaryMarker", Vector3(float(marker_x), 0.04, 34.0), Vector3(0.7, 0.08, 0.7), Color(0.88, 0.62, 0.12), false)
	_box("PlayerStartZone", Vector3(0, 0.02, 7), Vector3(7, 0.04, 5), Color(0.39, 0.40, 0.35), false)

	# Perimeter walls, fencing, and gate.
	_box("BackWall", Vector3(0, 2.0, -35.5), Vector3(32, 4, 0.5), Color(0.28, 0.32, 0.31), true)
	_box("LeftWall", Vector3(-15.5, 2.0, 0), Vector3(0.5, 4, 72), Color(0.28, 0.32, 0.31), true)
	_box("DistrictTwoGround", Vector3(32, -0.3, 0), Vector3(32, 0.6, 72), Color(0.20, 0.43, 0.22), true)
	_box("DistrictTwoGrassPatch", Vector3(32, 0.012, 0), Vector3(29.5, 0.025, 60.0), Color(0.25, 0.50, 0.22), false)
	_box("DistrictThreeGround", Vector3(64, -0.3, 0), Vector3(32, 0.6, 72), Color(0.32, 0.34, 0.29), true)
	# Open the east edge into a boulevard leading to the new market quarter.
	_box("DistrictFourGround", Vector3(96, -0.3, 0), Vector3(32, 0.6, 72), Color(0.29, 0.34, 0.30), true)
	_box("DistrictFourGrassPatch", Vector3(96, 0.012, 0), Vector3(29.5, 0.025, 60.0), Color(0.27, 0.43, 0.25), false)
	# Wide service gateway into the new city recycling factory.
	_box("DistrictFourOuterWallNorth", Vector3(111.5, 2.0, -22.0), Vector3(0.5, 4.0, 28.0), Color(0.28, 0.32, 0.31), true)
	_box("DistrictFourOuterWallSouth", Vector3(111.5, 2.0, 22.0), Vector3(0.5, 4.0, 28.0), Color(0.28, 0.32, 0.31), true)
	for gate_z in [-8.0, 8.0]:
		_box("LandfillGatePillar", Vector3(111.5, 2.1, gate_z), Vector3(0.8, 4.2, 0.8), Color(0.20, 0.26, 0.25), true)
		_box("LandfillGateCap", Vector3(111.5, 4.25, gate_z), Vector3(1.1, 0.22, 1.1), Color(0.83, 0.62, 0.19), false)
	_box("LandfillGateHeader", Vector3(111.5, 4.15, 0), Vector3(0.45, 0.28, 15.5), Color(0.14, 0.22, 0.21), false)
	_label_3d("RECYCLING FACTORY", Vector3(113.0, 4.65, 0), 0.34)
	for x in range(-14, 15, 2):
		# Keep a wide, player-accessible entrance aligned with the road.
		if x >= -12 and x <= -4:
			continue
		_box("FencePost", Vector3(x, 1.35, 35.0), Vector3(0.16, 2.7, 0.16), Color(0.20, 0.24, 0.24), true)
	# Wide 8-metre opening: both the player and municipal trucks can enter freely.
	for rail_y in [2.45, 0.45]:
		_box("FenceRailServiceLeft", Vector3(-13.5, rail_y, 35.0), Vector3(3.0, 0.14, 0.14), Color(0.18, 0.22, 0.22), false)
		_box("FenceRailServiceRight", Vector3(5.5, rail_y, 35.0), Vector3(19.0, 0.14, 0.14), Color(0.18, 0.22, 0.22), false)
	_box("GateLeft", Vector3(-12.0, 1.3, 35.0), Vector3(0.14, 2.6, 0.14), Color(0.82, 0.62, 0.18), false)
	_box("GateRight", Vector3(-4.0, 1.3, 35.0), Vector3(0.14, 2.6, 0.14), Color(0.82, 0.62, 0.18), false)
	_add_invisible_barrier("MainFrontSafety", Vector3(0, 1.0, 36.0), Vector3(32, 2.0, 0.5))

	# Residential building: moved to the quiet west edge, away from the factory line.
	_build_apartment_block()

	# Clearly marked unloading pad directly in front of the conveyor intake.
	_box("UnloadPad", Vector3(1.35, 0.018, -6.5), Vector3(3.5, 0.035, 3.2), Color(0.95, 0.66, 0.12), false)
	_box("UnloadBorderFront", Vector3(1.35, 0.045, -8.12), Vector3(3.55, 0.045, 0.12), Color(1.0, 0.88, 0.28), false)
	_box("UnloadBorderBack", Vector3(1.35, 0.045, -4.88), Vector3(3.55, 0.045, 0.12), Color(1.0, 0.88, 0.28), false)
	_box("UnloadBorderLeft", Vector3(-0.43, 0.045, -6.5), Vector3(0.12, 0.045, 3.2), Color(1.0, 0.88, 0.28), false)
	_box("UnloadBorderRight", Vector3(3.13, 0.045, -6.5), Vector3(0.12, 0.045, 3.2), Color(1.0, 0.88, 0.28), false)
	_label_3d("UNLOAD HERE", Vector3(1.35, 0.12, -7.45), 0.28)

	# The old central-city processing line was removed; recycling equipment is in the dedicated factory district.

	# Ordinary neighborhood waste bins, distributed around the streets.
	_make_street_bin(Vector3(-14.2, 0, -17.0), Color(0.20, 0.29, 0.27))
	_make_street_bin(Vector3(13.8, 0, 8.5), Color(0.28, 0.34, 0.32))
	_make_street_bin(Vector3(29.0, 0, -15.5), Color(0.22, 0.30, 0.36))
	_make_barrel(Vector3(-13.25, 0, 4.0), Color(0.76, 0.31, 0.16))
	_make_barrel(Vector3(-13.25, 0, 6.0), Color(0.18, 0.43, 0.67))
	_make_tire_stack(Vector3(12.0, 0, 4.5))
	_make_lamp(Vector3(-13.4, 0, -12.5))
	_make_lamp(Vector3(13.4, 0, 10.5))
	_make_tree(Vector3(-13.0, 0, 9.0))
	_make_tree(Vector3(-13.0, 0, 1.0))
	_box("SpawnPad", Vector3(0, 0.05, 7), Vector3(4.5, 0.08, 3.5), Color(0.48, 0.48, 0.39), false)
	_label_3d("TRASH EMPIRE", Vector3(0, 3.2, 34.5), 0.65)
	_build_first_district_details()
	_build_yard_environment_details()
	_build_industrial_set_dressing()
	_build_random_residential_blocks()
	_build_connected_city_streets()
	_build_city_polish()
	_build_city_life_details()
	_build_city_pedestrians()
	_build_recycling_mega_factory()
	_build_commercial_district()
	_build_sorting_district()
	_build_ad_billboards()

	refill_world_button = _create_gear_refill_button(Vector3(0.0, 2.0, -35.20), Callable(self, "_refill_first_district"))
	refill_world_button.rotation_degrees.y = 90.0
	# Central-city factory machines are intentionally removed.


func _build_sorting_district() -> void:
	# Distribute four recycling stations through the existing playable city.
	sorting_area_root = Node3D.new()
	sorting_area_root.name = "CitySortingStations"
	add_child(sorting_area_root)
	sorting_bins.clear()
	sorting_robots.clear()
	for i in range(4):
		var pad_pos: Vector3 = sorting_pad_positions[i]
		var color: Color = sorting_station_colors[i]
		# Empty marked compartment: the player walks onto it to build the bin + robot.
		_box("SortingStationPad", pad_pos + Vector3(0, 0.035, 0), Vector3(4.2, 0.07, 3.8), Color(0.10, 0.14, 0.15), false)
		_box("SortingStationPadBorder", pad_pos + Vector3(0, 0.08, 0), Vector3(3.85, 0.025, 3.45), color, false)
		_box("SortingStationFootprint", pad_pos + Vector3(0, 0.095, 0), Vector3(3.55, 0.025, 3.15), color.darkened(0.68), false)
		_label_3d("STEP HERE\\nBUILD %s" % sorting_station_names[i], pad_pos + Vector3(0, 1.9, -0.3), 0.24)
		var trigger := Area3D.new()
		trigger.name = "BuildSortingStation_%s" % sorting_station_categories[i]
		trigger.position = pad_pos + Vector3(0, 0.9, 0)
		trigger.set_meta("station_index", i)
		var trigger_shape := CollisionShape3D.new()
		var trigger_box := BoxShape3D.new()
		trigger_box.size = Vector3(3.6, 2.0, 3.2)
		trigger_shape.shape = trigger_box
		trigger.add_child(trigger_shape)
		trigger.body_entered.connect(_on_sorting_station_entered.bind(i))
		sorting_area_root.add_child(trigger)
		var robot := _make_sorting_robot(i, color)
		sorting_area_root.add_child(robot)
		robot.global_position = sorting_pad_positions[i] + Vector3(0, 0, 1.7)
		robot.visible = false
		sorting_robots.append(robot)
		sorting_bins.append(null)
		if sorting_robot_levels[i] > 0:
			_spawn_sorting_station(i)
	_refresh_sorting_district()


func _on_sorting_station_entered(body: Node3D, station_index: int) -> void:
	if body != player or station_index < 0 or station_index >= 4:
		return
	_build_sorting_station(station_index)


func _build_sorting_station(station_index: int) -> void:
	if station_index < 0 or station_index >= 4 or sorting_robot_levels[station_index] > 0:
		return
	const BUILD_COST := 45.0
	if money < BUILD_COST:
		_set_message("You need 45 ZC to build this recycling station.")
		return
	money -= BUILD_COST
	sorting_robot_levels[station_index] = 1
	_spawn_sorting_station(station_index)
	_refresh_sorting_district()
	_update_ui()
	_save_game()
	_set_message("%s bin and its dedicated sorting robot are now built!" % sorting_station_names[station_index])


func _spawn_sorting_station(station_index: int) -> void:
	if station_index < 0 or station_index >= 4:
		return
	var bin_pos: Vector3 = sorting_bin_positions[station_index]
	_make_bin(bin_pos, sorting_station_colors[station_index], sorting_station_names[station_index])
	var bin_root := Node3D.new()
	bin_root.name = "BuiltSortingBin_%s" % sorting_station_categories[station_index]
	bin_root.position = bin_pos
	sorting_area_root.add_child(bin_root)
	var counter := Label3D.new()
	counter.name = "SortingCounter"
	counter.text = "%d ITEMS" % sorting_bin_counts[station_index]
	counter.position = Vector3(0, 2.05, 0)
	counter.font_size = 24
	counter.pixel_size = 0.006
	counter.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bin_root.add_child(counter)
	sorting_bins[station_index] = bin_root
	var robot := sorting_robots[station_index]
	if is_instance_valid(robot):
		robot.visible = true
		robot.global_position = sorting_pad_positions[station_index] + Vector3(0, 0, 1.7)
		robot.set_meta("mode", "idle")


func _make_sorting_robot(category_index: int, robot_color: Color) -> Node3D:
	var robot := Node3D.new()
	robot.name = "SortingRobot_%d" % category_index
	_add_robot_box(robot, "SortingRobotBody", Vector3(0, 0.68, 0), Vector3(0.95, 0.72, 0.82), robot_color)
	_add_robot_box(robot, "SortingRobotTop", Vector3(0, 1.13, 0.02), Vector3(0.62, 0.20, 0.58), Color(0.16, 0.22, 0.24))
	_add_robot_sphere(robot, "SortingRobotHead", Vector3(0, 1.48, -0.08), 0.31, Color(0.68, 0.76, 0.76))
	_add_robot_box(robot, "SortingRobotVisor", Vector3(0, 1.48, -0.36), Vector3(0.40, 0.16, 0.035), Color(0.10, 0.92, 0.78))
	_add_robot_box(robot, "SortingRobotFrontCollector", Vector3(0, 0.40, -0.62), Vector3(0.82, 0.16, 0.38), Color(0.75, 0.80, 0.77))
	for side in [-1.0, 1.0]:
		for z in [-0.28, 0.28]:
			var wheel := MeshInstance3D.new()
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.22
			wheel_mesh.bottom_radius = 0.22
			wheel_mesh.height = 0.14
			wheel.mesh = wheel_mesh
			wheel.position = Vector3(side * 0.52, 0.25, z)
			wheel.rotation_degrees.z = 90
			wheel.material_override = _mat(Color(0.045, 0.055, 0.06))
			robot.add_child(wheel)
	robot.set_meta("category_index", category_index)
	robot.set_meta("target", null)
	robot.set_meta("cargo", null)
	robot.set_meta("mode", "idle")
	robot.set_meta("scan_timer", 0.0)
	return robot


func _refresh_sorting_district() -> void:
	for i in range(mini(4, sorting_robots.size())):
		if is_instance_valid(sorting_robots[i]):
			sorting_robots[i].visible = sorting_robot_levels[i] > 0
	for i in range(mini(4, sorting_bins.size())):
		if is_instance_valid(sorting_bins[i]):
			var counter := sorting_bins[i].get_node_or_null("SortingCounter") as Label3D
			if is_instance_valid(counter):
				counter.text = "%d ITEMS" % sorting_bin_counts[i]
func _process_sorting_robots(delta: float) -> void:
	if sorting_robots.is_empty():
		return
	var category_names := ["plastic", "paper", "metal", "glass"]
	var bin_positions := sorting_bin_positions
	for i in range(mini(4, sorting_robots.size())):
		if sorting_robot_levels[i] <= 0:
			continue
		var robot := sorting_robots[i]
		if not is_instance_valid(robot) or not robot.visible:
			continue
		var mode := String(robot.get_meta("mode", "idle"))
		var target := robot.get_meta("target") as Node3D
		if mode == "return":
			var drop_point: Vector3 = bin_positions[i] + Vector3(0, 0.9, 1.25)
			robot.global_position = robot.global_position.move_toward(drop_point, _sorting_robot_speed() * delta)
			if robot.global_position.distance_to(drop_point) < 0.55:
				var cargo := robot.get_meta("cargo") as Node3D
				if is_instance_valid(cargo):
					cargo.queue_free()
					robot.set_meta("cargo", null)
					sorting_bin_counts[i] += 1
					money += _sorting_robot_item_reward()
					_refresh_sorting_district()
					_update_ui()
					_save_game()
				robot.set_meta("mode", "idle")
			continue
		if not is_instance_valid(target) or not trash_nodes.has(target):
			robot.set_meta("target", null)
			target = null
			var cooldown := float(robot.get_meta("scan_timer", 0.0)) - delta
			if cooldown <= 0.0:
				robot.set_meta("scan_timer", 0.65)
				var best_distance := 22.0 + float(sorting_robot_upgrade_level) * 5.0
				for item in trash_nodes:
					if not is_instance_valid(item) or item.get_meta("drone_reserved", -1) != -1:
						continue
					if String(item.get_meta("recycle_category", "")) != category_names[i]:
						continue
					var p := item.global_position
					var distance := robot.global_position.distance_to(p)
					if distance < best_distance:
						best_distance = distance
						target = item
				if is_instance_valid(target):
					target.set_meta("drone_reserved", -30 - i)
					robot.set_meta("target", target)
			else:
				robot.set_meta("scan_timer", cooldown)
		if not is_instance_valid(target):
			var idle_point: Vector3 = sorting_pad_positions[i] + Vector3(0, 0, 1.7)
			robot.global_position = robot.global_position.move_toward(idle_point, _sorting_robot_speed() * 0.43 * delta)
			continue
		var destination := target.global_position + Vector3(0, 0.55, 0)
		robot.global_position = robot.global_position.move_toward(destination, _sorting_robot_speed() * delta)
		if robot.global_position.distance_to(destination) <= 0.65:
			_register_final_cleanup_pickup(target)
			var keep_transform := target.global_transform
			target.reparent(robot)
			target.global_transform = keep_transform
			target.position = Vector3(0, 1.85, -0.55)
			robot.set_meta("cargo", target)
			robot.set_meta("target", null)
			trash_nodes.erase(target)
			robot.set_meta("mode", "return")


func _spawn_sorting_district_trash(amount: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(amount):
		var item := Node3D.new()
		item.set_script(TRASH_SCRIPT)
		item.position = Vector3(rng.randf_range(224.0, 276.0), 0.05, rng.randf_range(-25.0, 25.0))
		add_child(item)
		trash_nodes.append(item)


func _build_connected_city_streets() -> void:
	# Replace the removed district boundary walls with a continuous street grid.
	# All road surfaces are decorative and non-colliding; the city stays walkable.
	var asphalt := Color(0.14, 0.17, 0.18)
	var curb := Color(0.53, 0.54, 0.50)
	var sidewalk := Color(0.47, 0.48, 0.44)
	# Two continuous cross-town streets run through the former front/back wall lines.
	for street_z in [-29.0, 29.0]:
		_box("CrossTownStreet", Vector3(48.0, 0.022, street_z), Vector3(119.0, 0.045, 5.8), asphalt, false)
		_box("CrossTownSidewalk", Vector3(48.0, 0.055, street_z - 3.55), Vector3(119.0, 0.11, 1.25), sidewalk, false)
		_box("CrossTownSidewalk", Vector3(48.0, 0.055, street_z + 3.55), Vector3(119.0, 0.11, 1.25), sidewalk, false)
		for dash_x in range(-8, 109, 8):
			_box("CrossTownRoadMarking", Vector3(float(dash_x), 0.052, street_z), Vector3(3.0, 0.012, 0.12), Color(0.88, 0.81, 0.62), false)
	# Side streets join the central avenue to both cross-town roads, creating real alleys.
	for street_x in [16.0, 48.0, 80.0, 104.0]:
		_box("NeighborhoodConnectorRoad", Vector3(street_x, 0.025, 0.0), Vector3(5.2, 0.05, 62.0), asphalt, false)
		for edge_x in [street_x - 3.0, street_x + 3.0]:
			_box("ConnectorCurb", Vector3(edge_x, 0.075, 0.0), Vector3(0.18, 0.15, 62.0), curb, false)
		for dash_z in range(-25, 26, 8):
			_box("ConnectorRoadMarking", Vector3(street_x, 0.055, float(dash_z)), Vector3(0.12, 0.012, 3.0), Color(0.88, 0.81, 0.62), false)
	# Small paved junction aprons blend the intersections into the existing avenues.
	for street_x in [16.0, 48.0, 80.0, 104.0]:
		for street_z in [-29.0, 0.0, 29.0]:
			_box("StreetJunctionApron", Vector3(street_x, 0.031, street_z), Vector3(7.2, 0.055, 7.2), asphalt, false)
	# Restore grounded street furniture at the former wall lines instead of leaving wall-mounted pieces suspended.
	for lamp in [Vector3(8.0, 0.0, -25.0), Vector3(40.0, 0.0, -25.0), Vector3(72.0, 0.0, -25.0), Vector3(104.0, 0.0, -25.0), Vector3(24.0, 0.0, 25.0), Vector3(56.0, 0.0, 25.0), Vector3(88.0, 0.0, 25.0)]:
		_make_lamp(lamp)


func _build_random_residential_blocks() -> void:
	# Streets and alleys are laid out first; buildings occupy reserved lots
	# beside them, never on the vehicle lanes or the district entrances.
	for district_x in [32.0, 64.0]:
		_box("NeighborhoodMainRoad", Vector3(district_x, 0.018, 0.0), Vector3(31.0, 0.035, 5.2), Color(0.13, 0.16, 0.17), false)
		_box("NeighborhoodSidewalkNorth", Vector3(district_x, 0.045, -3.45), Vector3(31.0, 0.07, 1.45), Color(0.48, 0.49, 0.44), false)
		_box("NeighborhoodSidewalkSouth", Vector3(district_x, 0.045, 3.45), Vector3(31.0, 0.07, 1.45), Color(0.48, 0.49, 0.44), false)
		for lane_x in ([26.0, 38.0] if district_x < 48.0 else [58.0, 70.0]):
			_box("NeighborhoodAlley", Vector3(lane_x, 0.019, 0.0), Vector3(3.6, 0.037, 25.0), Color(0.17, 0.20, 0.20), false)
			for side_z in [-12.8, 12.8]:
				_box("AlleyCurb", Vector3(lane_x + 2.0, 0.055, side_z), Vector3(0.12, 0.11, 3.0), Color(0.58, 0.59, 0.53), false)
		# Short dashed center markings, purely visual and non-blocking.
		for mark_x in range(int(district_x - 13), int(district_x + 14), 4):
			_box("NeighborhoodRoadMarking", Vector3(float(mark_x), 0.045, 0.0), Vector3(1.8, 0.012, 0.10), Color(0.88, 0.80, 0.57), false)

	var lots: Array[Vector3] = [
		Vector3(21.0, 0.0, -24.0), Vector3(32.0, 0.0, -24.0),
		Vector3(43.0, 0.0, -24.0), Vector3(21.0, 0.0, 24.0),
		Vector3(32.0, 0.0, 24.0), Vector3(43.0, 0.0, 24.0),
		Vector3(53.0, 0.0, -24.0), Vector3(64.0, 0.0, -24.0),
		Vector3(75.0, 0.0, -24.0), Vector3(53.0, 0.0, 24.0),
		Vector3(64.0, 0.0, 24.0), Vector3(75.0, 0.0, 24.0)
	]
	lots.shuffle()
	for i in range(8):
		var lot: Vector3 = lots[i]
		_build_decorative_residence(lot, i % 3 == 1, i + 1)

	# Trees line the sidewalks and green pockets, clear of all road surfaces.
	for tree_pos in [
		Vector3(18.5, 0.0, -5.6), Vector3(24.0, 0.0, 5.6),
		Vector3(34.5, 0.0, -5.6), Vector3(40.5, 0.0, 5.6),
		Vector3(50.5, 0.0, -5.6), Vector3(56.0, 0.0, 5.6),
		Vector3(66.5, 0.0, -5.6), Vector3(72.5, 0.0, 5.6)
	]:
		_build_neighborhood_tree(tree_pos)
	for lamp_pos in [Vector3(29.0, 0.0, -4.7), Vector3(45.0, 0.0, 4.7), Vector3(61.0, 0.0, -4.7), Vector3(77.0, 0.0, 4.7)]:
		_make_lamp(lamp_pos)
	_build_neighborhood_furniture()


func _build_neighborhood_furniture() -> void:
	# Low planters, benches and hydrants make the residential streets feel lived-in.
	# All pieces are decorative so they never obstruct player or truck movement.
	for item in [
		{"x": 20.0, "z": -14.0}, {"x": 37.0, "z": 14.0},
		{"x": 54.0, "z": -14.0}, {"x": 71.0, "z": 14.0}
	]:
		var p := Vector3(float(item.x), 0.0, float(item.z))
		_box("StreetPlanter", p + Vector3(0, 0.22, 0), Vector3(2.2, 0.44, 0.85), Color(0.30, 0.32, 0.29), false)
		_box("StreetPlanterSoil", p + Vector3(0, 0.46, 0), Vector3(2.02, 0.08, 0.68), Color(0.22, 0.16, 0.11), false)
		for shrub_x in [-0.62, 0.0, 0.62]:
			var shrub := MeshInstance3D.new()
			var shrub_mesh := SphereMesh.new()
			shrub_mesh.radius = 0.34
			shrub_mesh.height = 0.62
			shrub.mesh = shrub_mesh
			shrub.position = p + Vector3(shrub_x, 0.78, 0)
			shrub.material_override = _mat(Color(0.16, 0.34, 0.19))
			add_child(shrub)

	for bench_pos in [Vector3(27.0, 0.0, 5.0), Vector3(43.0, 0.0, -5.0), Vector3(59.0, 0.0, 5.0), Vector3(75.0, 0.0, -5.0)]:
		_box("ParkBenchSeat", bench_pos + Vector3(0, 0.52, 0), Vector3(1.65, 0.14, 0.48), Color(0.42, 0.27, 0.16), false)
		_box("ParkBenchBack", bench_pos + Vector3(0, 0.92, -0.20), Vector3(1.65, 0.62, 0.12), Color(0.35, 0.22, 0.14), false)
		for leg_x in [-0.58, 0.58]:
			_box("ParkBenchLeg", bench_pos + Vector3(leg_x, 0.26, 0), Vector3(0.10, 0.52, 0.34), Color(0.16, 0.19, 0.19), false)

	for hydrant_pos in [Vector3(23.0, 0.0, -5.0), Vector3(39.0, 0.0, 5.0), Vector3(55.0, 0.0, -5.0), Vector3(71.0, 0.0, 5.0)]:
		_cylinder("StreetHydrantBase", hydrant_pos + Vector3(0, 0.20, 0), 0.20, 0.40, Color(0.72, 0.18, 0.12), false)
		_cylinder("StreetHydrantBody", hydrant_pos + Vector3(0, 0.52, 0), 0.13, 0.48, Color(0.82, 0.22, 0.15), false)
		_cylinder("StreetHydrantCap", hydrant_pos + Vector3(0, 0.80, 0), 0.18, 0.12, Color(0.88, 0.72, 0.28), false)
		_cylinder("StreetHydrantOutlet", hydrant_pos + Vector3(0.20, 0.52, 0), 0.09, 0.20, Color(0.82, 0.22, 0.15), false)


func _build_decorative_residence(center: Vector3, apartment: bool, index: int) -> void:
	var width := 3.9 if apartment else 3.2
	var depth := 3.8 if apartment else 3.4
	var height := 4.2 if apartment else 2.8
	var wall_color: Color = [Color(0.72, 0.61, 0.47), Color(0.66, 0.70, 0.66), Color(0.72, 0.69, 0.58), Color(0.61, 0.67, 0.70)][index % 4]
	# Solid foundations and walls make buildings physical obstacles.
	_box("ResidentialBase", center + Vector3(0, 0.12, 0), Vector3(width + 0.35, 0.24, depth + 0.35), Color(0.30, 0.32, 0.30), true)
	_box("ResidentialWalls", center + Vector3(0, height * 0.5, 0), Vector3(width, height, depth), wall_color, true)
	_box("ResidentialRoof", center + Vector3(0, height + 0.12, 0), Vector3(width + 0.25, 0.24, depth + 0.25), Color(0.20, 0.25, 0.26), true)
	_box("ResidentialFrontDoor", center + Vector3(0, 0.82, depth * 0.5 + 0.035), Vector3(0.68, 1.55, 0.07), Color(0.30, 0.20, 0.14), false)
	_add_wall_plaque("ResidentialDoorPlaque", "HOME %02d" % index, center + Vector3(0, 1.88, depth * 0.5 + 0.09), Vector2(0.92, 0.28), Color(0.12, 0.20, 0.20), Color(0.88, 0.72, 0.43), 20)
	for window_x in [-width * 0.28, width * 0.28]:
		for floor_y in ([1.05, 2.85] if apartment else [1.35]):
			_box("ResidentialWindowFrame", center + Vector3(window_x, floor_y, depth * 0.5 + 0.045), Vector3(0.78, 0.82, 0.07), Color(0.15, 0.22, 0.24), false)
			_box("ResidentialWindowGlass", center + Vector3(window_x, floor_y, depth * 0.5 + 0.09), Vector3(0.62, 0.66, 0.035), Color(0.30, 0.56, 0.64), false)
	if apartment:
		_box("ResidentialBalcony", center + Vector3(0, 2.05, depth * 0.5 + 0.38), Vector3(width * 0.72, 0.12, 0.72), Color(0.38, 0.42, 0.41), false)
		_box("ResidentialBalconyRail", center + Vector3(0, 2.42, depth * 0.5 + 0.72), Vector3(width * 0.72, 0.55, 0.06), Color(0.16, 0.22, 0.23), false)
	# Architectural depth: corner pilasters, projecting sills, rainwater downpipes and roof fascia.
	for side_x in [-1.0, 1.0]:
		_box("ResidenceCornerPilaster", center + Vector3(side_x * (width * 0.5 - 0.09), height * 0.5, depth * 0.5 + 0.055), Vector3(0.16, height, 0.12), wall_color.darkened(0.12), false)
		_box("ResidenceWindowSill", center + Vector3(side_x * width * 0.28, 0.88 if apartment else 1.0, depth * 0.5 + 0.13), Vector3(0.94, 0.10, 0.22), Color(0.48, 0.49, 0.46), false)
	_box("ResidenceRoofFascia", center + Vector3(0, height + 0.02, depth * 0.5 + 0.08), Vector3(width + 0.32, 0.16, 0.18), Color(0.25, 0.29, 0.29), false)
	for side_x in [-1.0, 1.0]:
		_cylinder("ResidenceRainPipe", center + Vector3(side_x * (width * 0.5 + 0.035), height * 0.5, depth * 0.5 + 0.12), 0.055, height, Color(0.25, 0.30, 0.30), false)
	for window_x in [-width * 0.28, width * 0.28]:
		_box("ResidenceWindowAwning", center + Vector3(window_x, (1.52 if apartment else 1.82), depth * 0.5 + 0.20), Vector3(0.98, 0.10, 0.38), Color(0.32, 0.39, 0.38), false)
	_box("ResidenceEntryCanopy", center + Vector3(0, 1.70, depth * 0.5 + 0.32), Vector3(1.15, 0.12, 0.62), Color(0.20, 0.31, 0.31), false)
	_box("ResidentialRoofVent", center + Vector3(width * 0.28, height + 0.42, -depth * 0.22), Vector3(0.48, 0.42, 0.48), Color(0.39, 0.43, 0.42), false)


func _build_neighborhood_tree(pos: Vector3) -> void:
	# Trunk collision is limited to a narrow cylinder-sized footprint.
	_cylinder("NeighborhoodTreeTrunk", pos + Vector3(0, 1.0, 0), 0.20, 2.0, Color(0.32, 0.21, 0.13), false)
	_add_invisible_barrier("NeighborhoodTreeTrunkCollision", pos + Vector3(0, 1.0, 0), Vector3(0.38, 2.0, 0.38))
	var crown := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 1.8
	crown.mesh = sphere
	crown.position = pos + Vector3(0, 2.45, 0)
	crown.scale = Vector3(1.25, 1.1, 1.25)
	crown.material_override = _mat(Color(0.18, 0.36, 0.23))
	add_child(crown)
	# Irregular secondary foliage clusters avoid the single-ball tree silhouette.
	for offset in [Vector3(-0.62, 0.10, 0.12), Vector3(0.58, 0.02, -0.18), Vector3(0.05, 0.38, 0.56)]:
		var foliage := MeshInstance3D.new()
		var foliage_mesh := SphereMesh.new()
		foliage_mesh.radius = 0.62
		foliage_mesh.height = 1.12
		foliage.mesh = foliage_mesh
		foliage.position = pos + Vector3(0, 2.42, 0) + offset
		foliage.scale = Vector3(1.0, 0.92, 1.08)
		foliage.material_override = _mat(Color(0.15, 0.31, 0.19))
		add_child(foliage)

func _build_yard_environment_details() -> void:
	# Subtle concrete panel joints make the yard read as a real industrial site.
	for z in [-16.0, -12.0, -2.0, 2.0, 14.0]:
		_box("YardConcreteJoint", Vector3(1.0, 0.008, z), Vector3(27.0, 0.012, 0.035), Color(0.27, 0.30, 0.29), false)
	for x in [-14.0, -1.0, 4.0, 10.0, 14.0]:
		_box("YardConcreteJoint", Vector3(x, 0.009, 1.0), Vector3(0.035, 0.012, 34.0), Color(0.27, 0.30, 0.29), false)

	# Clearly defined equipment staging / forklift parking area beside the factory.
	_box("EquipmentStagingPad", Vector3(11.7, 0.025, -15.0), Vector3(5.2, 0.035, 5.0), Color(0.29, 0.32, 0.31), false)
	for x in [9.15, 14.25]:
		_box("StagingBayLine", Vector3(x, 0.052, -15.0), Vector3(0.07, 0.018, 4.6), Color(0.82, 0.68, 0.34), false)
	_box("StagingBayBackLine", Vector3(11.7, 0.052, -17.28), Vector3(5.1, 0.018, 0.07), Color(0.82, 0.68, 0.34), false)
	_label_3d("EQUIPMENT BAY", Vector3(11.7, 0.10, -15.8), 0.18)

	# Realistic timber pallets and a restrained stack of sorted material.
	for pallet_x in [10.0, 12.0]:
		_box("TimberPalletBase", Vector3(pallet_x, 0.16, -12.8), Vector3(1.35, 0.20, 1.0), Color(0.37, 0.25, 0.15), false)
		for slat_x in [-0.48, -0.16, 0.16, 0.48]:
			_box("PalletTopSlat", Vector3(pallet_x + slat_x, 0.28, -12.8), Vector3(0.12, 0.055, 0.94), Color(0.49, 0.34, 0.21), false)
	_box("SortedMaterialStack", Vector3(12.0, 0.62, -12.8), Vector3(1.05, 0.62, 0.72), Color(0.35, 0.43, 0.40), false)
	_box("MaterialStackStrap", Vector3(12.0, 0.64, -12.42), Vector3(0.10, 0.72, 0.035), Color(0.72, 0.61, 0.36), false)

	# Low safety bollards protect the machine zone without narrowing the walking path.
	for z in [-10.0, -3.0]:
		_cylinder("FactorySafetyBollard", Vector3(10.35, 0.48, z), 0.12, 0.96, Color(0.74, 0.55, 0.20), false)
		_cylinder("FactoryBollardCap", Vector3(10.35, 0.98, z), 0.13, 0.08, Color(0.16, 0.20, 0.20), false)

	# Distant warehouse silhouettes add depth beyond the perimeter wall.
	_box("DistantWarehouseA", Vector3(-10.0, 4.8, -42.0), Vector3(11.0, 9.6, 1.0), Color(0.25, 0.31, 0.33), false)
	_box("DistantWarehouseRoofA", Vector3(-10.0, 9.65, -42.0), Vector3(11.5, 0.28, 1.2), Color(0.16, 0.21, 0.23), false)
	_box("DistantWarehouseB", Vector3(5.5, 3.8, -43.0), Vector3(12.0, 7.6, 1.0), Color(0.31, 0.34, 0.33), false)
	_box("DistantWarehouseRoofB", Vector3(5.5, 7.68, -43.0), Vector3(12.5, 0.25, 1.2), Color(0.18, 0.23, 0.24), false)
	for x in [-13.5, -10.0, -6.5, 2.0, 5.5, 9.0]:
		_box("DistantWarehouseWindow", Vector3(x, 4.6, -41.43), Vector3(1.25, 1.15, 0.035), Color(0.22, 0.40, 0.46), false)
	_cylinder("DistantVentStack", Vector3(12.0, 5.0, -42.5), 0.42, 10.0, Color(0.28, 0.32, 0.32), false)
	_cylinder("DistantVentCap", Vector3(12.0, 10.05, -42.5), 0.58, 0.20, Color(0.17, 0.21, 0.22), false)

	# Soft industrial haze helps separate the foreground from the distant skyline.
	var world_env := get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_env != null and world_env.environment != null:
		world_env.environment.fog_enabled = true
		world_env.environment.fog_light_color = Color(0.63, 0.70, 0.75)
		world_env.environment.fog_density = 0.0018


func _build_industrial_set_dressing() -> void:
	# A compact maintenance and loading corner along the quiet rear-right edge.
	# Every added prop is decorative/non-colliding and stays clear of the machine line.
	_box("MaintenanceApron", Vector3(11.5, 0.025, -25.0), Vector3(6.2, 0.05, 7.0), Color(0.27, 0.30, 0.29), false)
	for x in [8.55, 14.45]:
		_box("MaintenanceBayYellowEdge", Vector3(x, 0.055, -25.0), Vector3(0.09, 0.02, 6.4), Color(0.83, 0.65, 0.23), false)
	for z in [-28.15, -21.85]:
		_box("MaintenanceBayYellowEdge", Vector3(11.5, 0.055, z), Vector3(5.9, 0.02, 0.09), Color(0.83, 0.65, 0.23), false)

	# Steel service cabinet with vents, access door and status lamps.
	_box("MaintenanceCabinetBase", Vector3(13.0, 0.18, -26.5), Vector3(1.65, 0.28, 1.0), Color(0.12, 0.16, 0.17), false)
	_box("MaintenanceCabinet", Vector3(13.0, 1.05, -26.5), Vector3(1.5, 1.55, 0.88), Color(0.34, 0.40, 0.39), false)
	_box("MaintenanceCabinetDoor", Vector3(13.0, 1.05, -26.04), Vector3(1.28, 1.30, 0.035), Color(0.25, 0.31, 0.31), false)
	_box("MaintenanceCabinetHandle", Vector3(13.48, 1.05, -25.99), Vector3(0.055, 0.34, 0.06), Color(0.72, 0.73, 0.66), false)
	for vent_y in [0.62, 0.76, 0.90, 1.04]:
		_box("MaintenanceCabinetVent", Vector3(12.72, vent_y, -25.995), Vector3(0.32, 0.035, 0.025), Color(0.10, 0.14, 0.15), false)
	for lamp_x in [12.72, 12.94, 13.16]:
		_cylinder("MaintenanceStatusLamp", Vector3(lamp_x, 1.72, -25.99), 0.055, 0.035, Color(0.20, 0.72, 0.39), false)

	# Palletized spare parts and two rugged shipping crates.
	_box("SparePartsPallet", Vector3(9.75, 0.15, -26.4), Vector3(1.75, 0.20, 1.35), Color(0.40, 0.28, 0.17), false)
	for slat_x in [-0.62, -0.20, 0.22, 0.64]:
		_box("SparePartsPalletSlat", Vector3(9.75 + slat_x, 0.27, -26.4), Vector3(0.12, 0.055, 1.22), Color(0.53, 0.37, 0.22), false)
	_box("ShippingCrateLower", Vector3(9.45, 0.72, -26.4), Vector3(1.05, 0.82, 0.95), Color(0.48, 0.34, 0.22), false)
	_box("ShippingCrateUpper", Vector3(10.25, 0.61, -26.4), Vector3(0.62, 0.60, 0.72), Color(0.39, 0.31, 0.23), false)
	for crate_x in [9.45, 10.25]:
		_box("CrateReinforcementBand", Vector3(crate_x, 0.74, -25.91), Vector3(0.82, 0.07, 0.035), Color(0.22, 0.25, 0.24), false)

	# Hose reel and a low workbench give the corner a clear maintenance purpose.
	_box("WorkshopBenchTop", Vector3(11.55, 0.88, -22.8), Vector3(2.5, 0.16, 0.72), Color(0.31, 0.35, 0.34), false)
	for leg_x in [10.55, 12.55]:
		_box("WorkshopBenchLeg", Vector3(leg_x, 0.43, -22.8), Vector3(0.12, 0.78, 0.58), Color(0.16, 0.20, 0.21), false)
	_box("WorkshopToolBox", Vector3(11.1, 1.12, -22.8), Vector3(0.62, 0.32, 0.48), Color(0.72, 0.34, 0.17), false)
	_box("WorkshopToolBoxLid", Vector3(11.1, 1.30, -22.8), Vector3(0.66, 0.06, 0.52), Color(0.18, 0.23, 0.24), false)
	_cylinder("HoseReelOuter", Vector3(12.35, 1.15, -22.8), 0.48, 0.16, Color(0.16, 0.22, 0.22), false)
	_cylinder("HoseReelInner", Vector3(12.35, 1.15, -22.70), 0.29, 0.18, Color(0.72, 0.38, 0.16), false)

	# Wall-mounted exhaust grille and service pipes add depth to the rear wall.
	_box("RearWallExhaustFrame", Vector3(11.6, 2.45, -35.18), Vector3(2.0, 1.45, 0.12), Color(0.16, 0.21, 0.22), false)
	_box("RearWallExhaustGrille", Vector3(11.6, 2.45, -35.09), Vector3(1.72, 1.18, 0.055), Color(0.34, 0.40, 0.40), false)
	for vent_y in [2.02, 2.20, 2.38, 2.56, 2.74, 2.92]:
		_box("RearWallExhaustSlat", Vector3(11.6, vent_y, -35.045), Vector3(1.58, 0.055, 0.025), Color(0.12, 0.17, 0.18), false)
	for pipe_y in [1.05, 1.42]:
		_box("RearWallServicePipe", Vector3(7.2, pipe_y, -35.12), Vector3(5.8, 0.09, 0.09), Color(0.42, 0.48, 0.46), false)
	for bracket_x in [4.8, 6.8, 8.8, 10.8]:
		_box("RearWallPipeBracket", Vector3(bracket_x, 1.24, -35.04), Vector3(0.10, 0.62, 0.12), Color(0.19, 0.24, 0.24), false)

	# Small grated drain and a subtle service access cover in the apron.
	_box("MaintenanceDrainFrame", Vector3(11.5, 0.061, -24.4), Vector3(1.25, 0.025, 0.72), Color(0.13, 0.17, 0.17), false)
	for grate_x in range(0, 6):
		_box("MaintenanceDrainSlot", Vector3(11.02 + float(grate_x) * 0.19, 0.079, -24.4), Vector3(0.055, 0.012, 0.60), Color(0.52, 0.55, 0.51), false)
	_box("ServiceAccessCover", Vector3(13.45, 0.061, -23.65), Vector3(0.82, 0.025, 0.82), Color(0.22, 0.26, 0.25), false)
	for edge in [-0.28, 0.0, 0.28]:
		_box("ServiceAccessCoverRib", Vector3(13.45 + edge, 0.079, -23.65), Vector3(0.035, 0.012, 0.68), Color(0.48, 0.51, 0.48), false)


func _build_apartment_block() -> void:
	# Compact three-storey apartment block with a clear residential silhouette.
	var center := Vector3(-12.8, 0.0, -10.4)
	_box("ApartmentFoundation", center + Vector3(0, 0.18, 0), Vector3(4.9, 0.36, 5.4), Color(0.23, 0.27, 0.28), true)
	_box("ApartmentMainFacade", center + Vector3(0, 2.45, 0), Vector3(4.55, 4.55, 5.05), Color(0.72, 0.66, 0.53), true)
	_box("ApartmentRoofSlab", center + Vector3(0, 4.82, 0), Vector3(4.95, 0.24, 5.48), Color(0.16, 0.21, 0.23), true)
	_box("ApartmentRoofParapetFront", center + Vector3(0, 5.12, 2.58), Vector3(4.9, 0.42, 0.16), Color(0.27, 0.32, 0.33), false)
	_box("ApartmentRoofParapetBack", center + Vector3(0, 5.12, -2.58), Vector3(4.9, 0.42, 0.16), Color(0.27, 0.32, 0.33), false)
	_box("ApartmentRoofParapetLeft", center + Vector3(-2.42, 5.12, 0), Vector3(0.16, 0.42, 5.1), Color(0.27, 0.32, 0.33), false)
	_box("ApartmentRoofParapetRight", center + Vector3(2.42, 5.12, 0), Vector3(0.16, 0.42, 5.1), Color(0.27, 0.32, 0.33), false)
	# Three floors of windows, trim and balconies facing the main yard.
	for floor in range(3):
		var y := 0.95 + float(floor) * 1.42
		_box("ApartmentFloorBand", center + Vector3(0, y + 0.58, 2.57), Vector3(4.58, 0.10, 0.08), Color(0.88, 0.81, 0.66), false)
		for x in [-1.35, 0.0, 1.35]:
			_box("ApartmentWindowFrame", center + Vector3(x, y, 2.57), Vector3(0.82, 0.88, 0.10), Color(0.19, 0.27, 0.30), false)
			_box("ApartmentWindowGlass", center + Vector3(x, y, 2.635), Vector3(0.65, 0.70, 0.035), Color(0.30, 0.57, 0.66), false)
			_box("ApartmentWindowMullion", center + Vector3(x, y, 2.61), Vector3(0.055, 0.72, 0.025), Color(0.76, 0.79, 0.73), false)
			_box("ApartmentBalconyFloor", center + Vector3(x, y - 0.48, 2.92), Vector3(1.08, 0.12, 0.72), Color(0.43, 0.46, 0.43), false)
			_box("ApartmentBalconyRail", center + Vector3(x, y - 0.12, 3.25), Vector3(1.08, 0.48, 0.055), Color(0.14, 0.20, 0.22), false)
			for rail_x in [-0.48, -0.16, 0.16, 0.48]:
				_box("ApartmentBalconyBar", center + Vector3(x + rail_x, y - 0.12, 3.25), Vector3(0.035, 0.48, 0.06), Color(0.62, 0.67, 0.64), false)
	# Main entrance and small canopy.
	_box("ApartmentEntranceFrame", center + Vector3(0, 0.92, 2.59), Vector3(1.12, 1.85, 0.16), Color(0.19, 0.24, 0.25), false)
	_box("ApartmentEntranceDoor", center + Vector3(0, 0.83, 2.70), Vector3(0.82, 1.62, 0.08), Color(0.38, 0.24, 0.15), false)
	_box("ApartmentDoorGlass", center + Vector3(0, 1.16, 2.755), Vector3(0.48, 0.55, 0.035), Color(0.30, 0.58, 0.65), false)
	_box("ApartmentCanopy", center + Vector3(0, 1.92, 2.92), Vector3(1.55, 0.14, 0.75), Color(0.13, 0.38, 0.36), false)
	_box("ApartmentNamePlate", center + Vector3(0, 2.18, 2.62), Vector3(1.65, 0.28, 0.08), Color(0.10, 0.22, 0.23), false)
	_add_wall_plaque("ApartmentNamePlateText", "RESIDENCE 01", center + Vector3(0, 2.18, 2.70), Vector2(1.65, 0.28), Color(0.10, 0.22, 0.23), Color(0.92, 0.84, 0.65), 22)
	# Rooftop utility room, water tank and air-conditioning units.
	_box("ApartmentRoofUtility", center + Vector3(1.35, 5.55, -1.45), Vector3(1.35, 0.75, 1.25), Color(0.42, 0.46, 0.44), false)
	_cylinder("ApartmentWaterTank", center + Vector3(-1.25, 5.62, -1.55), 0.48, 0.95, Color(0.42, 0.53, 0.55), false)
	for x in [-1.55, 1.55]:
		_box("ApartmentAC", center + Vector3(x, 2.0, -2.62), Vector3(0.72, 0.55, 0.32), Color(0.72, 0.76, 0.73), false)
		_box("ApartmentACGrill", center + Vector3(x, 2.0, -2.43), Vector3(0.42, 0.30, 0.035), Color(0.18, 0.24, 0.25), false)

func _build_first_district_details() -> void:
	# Cleaner pedestrian edge and a more lived-in entrance plaza.
	_box("ResidentialSidewalk", Vector3(-4.0, 0.025, -10.2), Vector3(7.0, 0.05, 2.0), Color(0.53, 0.55, 0.51), false)
	_box("MainWalkway", Vector3(-2.8, 0.035, -2.2), Vector3(2.1, 0.07, 10.0), Color(0.47, 0.49, 0.45), false)
	for x in [-3.72, -2.85, -1.98]:
		_box("WalkwayPaverJoint", Vector3(x, 0.075, -2.2), Vector3(0.035, 0.012, 9.8), Color(0.29, 0.33, 0.32), false)
	# Raised planters, shrubs and low decorative edging.
	for pos in [Vector3(-4.15, 0, -6.8), Vector3(2.2, 0, 10.5), Vector3(5.4, 0, 10.5)]:
		_box("PlanterBase", pos + Vector3(0, 0.22, 0), Vector3(2.1, 0.44, 1.25), Color(0.30, 0.34, 0.31), true)
		_box("PlanterSoil", pos + Vector3(0, 0.46, 0), Vector3(1.92, 0.08, 1.08), Color(0.24, 0.18, 0.12), false)
		for shrub_x in [-0.58, 0.0, 0.58]:
			var shrub := MeshInstance3D.new()
			var shrub_mesh := SphereMesh.new()
			shrub_mesh.radius = 0.38
			shrub_mesh.height = 0.68
			shrub.mesh = shrub_mesh
			shrub.position = pos + Vector3(shrub_x, 0.82, 0)
			shrub.material_override = _mat(Color(0.18, 0.38, 0.23))
			add_child(shrub)
	# Seating and waste sorting beside the entrance plaza.
	_box("BenchSeat", Vector3(-2.6, 0.62, 4.2), Vector3(2.0, 0.16, 0.55), Color(0.42, 0.27, 0.16), false)
	_box("BenchBack", Vector3(-2.6, 1.05, 4.45), Vector3(2.0, 0.72, 0.13), Color(0.42, 0.27, 0.16), false)
	for x in [-3.35, -1.85]:
		_box("BenchLeg", Vector3(x, 0.32, 4.2), Vector3(0.12, 0.58, 0.48), Color(0.16, 0.20, 0.21), false)
	_make_bin(Vector3(0.8, 0, 11.0), Color(0.16, 0.48, 0.38), "WASTE")
	# Marked pedestrian crossing and a small information board.
	for i in range(5):
		_box("PedestrianCrossingStripe", Vector3(-8.0, 0.055, -1.0 + float(i) * 0.72), Vector3(4.5, 0.035, 0.32), Color(0.82, 0.84, 0.78), false)
	# Extra warm lighting around the starting area.
	_make_lamp(Vector3(5.5, 0, 7.5))
	_make_lamp(Vector3(-5.0, 0, 13.0))


	# More realistic street treatment: curbs, lane markings, drains and manholes.
	# Keep the service-road lane open where municipal trucks turn into the depot.
	_box("RoadRaisedCurb", Vector3(-10.72, 0.10, 1.0), Vector3(0.22, 0.20, 54.0), Color(0.48, 0.50, 0.48), false)
	_box("RoadCurbHighlight", Vector3(-10.72, 0.205, 1.0), Vector3(0.24, 0.025, 54.0), Color(0.55, 0.57, 0.55), false)
	# Keep the curb only along the normal roadside. The depot approach is an open
	# truck entrance, so no curb/highlight may cross into the garbage unloading bay.
	var curb_segment := Vector3(-5.28, 0.10, 9.0)
	var curb_length := 34.0
	_box("RoadRaisedCurb", curb_segment, Vector3(0.22, 0.20, curb_length), Color(0.48, 0.50, 0.48), false)
	_box("RoadCurbHighlight", curb_segment + Vector3(0, 0.105, 0), Vector3(0.24, 0.025, curb_length), Color(0.55, 0.57, 0.55), false)
	for z in range(-23, 27, 6):
		_box("RoadCenterDash", Vector3(-8.0, 0.035, float(z)), Vector3(0.13, 0.025, 2.8), Color(0.72, 0.73, 0.69), false)
	for z in [-17.0, 8.0, 23.0]:
		_cylinder("RoadManhole", Vector3(-9.65, 0.045, z), 0.38, 0.045, Color(0.20, 0.23, 0.23), false)
		_cylinder("RoadManholeInset", Vector3(-9.65, 0.071, z), 0.27, 0.012, Color(0.31, 0.34, 0.33), false)
		_box("RoadDrain", Vector3(-5.48, 0.055, z), Vector3(0.30, 0.035, 1.0), Color(0.12, 0.15, 0.15), false)
		for slot in range(4):
			_box("RoadDrainSlot", Vector3(-5.48, 0.078, z - 0.34 + float(slot) * 0.22), Vector3(0.34, 0.012, 0.045), Color(0.48, 0.51, 0.49), false)
	# Restrained architectural and utility details; avoid toy-like bright decoration.
	var home_center := Vector3(-12.8, 0.0, -10.4)
	for floor in range(3):
		var window_y := 0.95 + float(floor) * 1.42
		for window_x in [-1.35, 0.0, 1.35]:
			_box("ApartmentConcreteSill", home_center + Vector3(window_x, window_y - 0.49, 2.70), Vector3(0.88, 0.10, 0.18), Color(0.48, 0.49, 0.46), false)
			_box("ApartmentFacadeExpansionJoint", home_center + Vector3(window_x + 0.55, window_y + 0.48, 2.56), Vector3(0.035, 0.92, 0.035), Color(0.52, 0.50, 0.45), false)
	for vent_x in [-0.72, 0.0, 0.72]:
		_cylinder("ApartmentRoofExhaust", home_center + Vector3(vent_x, 5.48, 0.75), 0.13, 0.62, Color(0.31, 0.34, 0.34), false)
		_cylinder("ApartmentRoofExhaustCap", home_center + Vector3(vent_x, 5.80, 0.75), 0.19, 0.08, Color(0.20, 0.23, 0.23), false)
	_box("HouseGardenPath", Vector3(-9.2, 0.045, -6.0), Vector3(2.0, 0.08, 5.8), Color(0.43, 0.44, 0.42), false)
	for z in [-7.8, -6.6, -5.4, -4.2]:
		_box("GardenPathJoint", Vector3(-9.2, 0.09, z), Vector3(1.9, 0.018, 0.045), Color(0.30, 0.31, 0.30), false)
	# Utility cabinet and a discreet service conduit beside the apartment.
	_box("StreetUtilityCabinet", Vector3(-15.25, 0.72, -6.2), Vector3(0.72, 1.35, 0.62), Color(0.34, 0.38, 0.37), true)
	_box("StreetUtilityCabinetDoor", Vector3(-14.87, 0.72, -6.2), Vector3(0.035, 1.12, 0.48), Color(0.24, 0.28, 0.28), false)
	_box("StreetUtilityWarningPlate", Vector3(-14.84, 0.92, -6.2), Vector3(0.025, 0.22, 0.25), Color(0.62, 0.53, 0.31), false)

func _upgrade_factory() -> void:
	if factory_stage >= 5:
		_set_message("Factory production line is fully upgraded!")
		return
	var costs := [0.0, 20.0, 55.0, 110.0, 190.0]
	var cost: float = costs[factory_stage]
	if money < cost:
		_set_message("You need %.0f ZC to add the next factory machine." % cost)
		return
	if not await _pay_gradually(cost):
		return
	factory_stage += 1
	_build_factory_expansion()
	_refresh_factory_upgrade_button()
	_update_ui()
	_save_game()
	var names := ["", "", "SHREDDER", "GRANULATOR", "TEDDY BEAR FACTORY", "PACKAGING + DELIVERY"]
	_set_message("Factory expanded! %s connected to the conveyor." % names[factory_stage])

func _refresh_factory_upgrade_button() -> void:
	if not is_instance_valid(factory_upgrade_button):
		return
	var label := factory_upgrade_button.get_node_or_null("WorldButtonLabel") as Label3D
	if not is_instance_valid(label):
		return
	if factory_stage >= 5:
		label.text = "FACTORY MAX\nDELIVERY LINE"
	else:
		var costs := [0.0, 20.0, 55.0, 110.0, 190.0]
		var names := ["", "", "ADD SHREDDER", "ADD GRANULATOR", "ADD TEDDY BEAR FACTORY", "ADD PACKAGING + TRUCK"]
		label.text = "%s\n%.0f ZC" % [names[factory_stage + 1], costs[factory_stage]]

func _build_factory_expansion() -> void:
	if not is_instance_valid(factory_visual_root):
		factory_visual_root = Node3D.new()
		factory_visual_root.name = "FactoryExpansionVisuals"
		add_child(factory_visual_root)
	for stage in range(factory_built_stage + 1, factory_stage + 1):
		var first_new_child := get_child_count()
		_build_factory_module(stage)
		# Keep each transfer belt in the open gap between machine housings.
		# The previous coordinates ran the belts into the center of the next machine,
		# hiding most of each belt inside the solid machine body.
		var z_positions := [0.0, 0.0, 0.0, 10.0, 20.0, 30.0]
		var start_z := -4.9 if stage == 2 else (z_positions[stage - 1] + 1.8)
		var end_z := -1.7 if stage == 2 else (z_positions[stage] - 1.7)
		_build_factory_link(start_z, end_z)
		var new_nodes: Array[Node] = []
		for child_index in range(first_new_child, get_child_count()):
			new_nodes.append(get_child(child_index))
		for new_node in new_nodes:
			remove_child(new_node)
			factory_visual_root.add_child(new_node)
		factory_built_stage = stage
	_refresh_factory_build_zones()

func _refresh_factory_build_zones() -> void:
	if is_instance_valid(factory_build_zones_root):
		factory_build_zones_root.queue_free()
	factory_build_zones_root = Node3D.new()
	factory_build_zones_root.name = "FactoryBuildZones"
	add_child(factory_build_zones_root)
	factory_build_label = null
	if factory_stage >= 5:
		return
	var z_positions := [0.0, 0.0, 0.0, 10.0, 20.0, 30.0]
	var stage := factory_stage + 1
	var z: float = z_positions[stage]
	var first_new_child := get_child_count()
	_box("BuildSlotFloor", Vector3(7.5, 0.025, z), Vector3(4.65, 0.035, 3.65), Color(0.43, 0.36, 0.16), false)
	var edge_color := Color(1.0, 0.76, 0.18)
	_box("BuildSlotFront", Vector3(7.5, 0.065, z + 1.82), Vector3(4.7, 0.07, 0.12), edge_color, false)
	_box("BuildSlotBack", Vector3(7.5, 0.065, z - 1.82), Vector3(4.7, 0.07, 0.12), edge_color, false)
	_box("BuildSlotLeft", Vector3(5.18, 0.065, z), Vector3(0.12, 0.07, 3.65), edge_color, false)
	_box("BuildSlotRight", Vector3(9.82, 0.065, z), Vector3(0.12, 0.07, 3.65), edge_color, false)
	factory_build_label = Label3D.new()
	factory_build_label.name = "FactoryBuildProgressLabel"
	# Lay the payment instructions directly on the build pad, like painted floor text.
	factory_build_label.position = Vector3(7.5, 0.105, z)
	factory_build_label.rotation_degrees.x = -90.0
	factory_build_label.font_size = 23
	factory_build_label.pixel_size = 0.008
	factory_build_label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	factory_build_label.modulate = Color(1.0, 0.95, 0.68)
	factory_build_zones_root.add_child(factory_build_label)
	var new_nodes: Array[Node] = []
	for child_index in range(first_new_child, get_child_count()):
		new_nodes.append(get_child(child_index))
	for new_node in new_nodes:
		remove_child(new_node)
		factory_build_zones_root.add_child(new_node)
	_update_factory_build_label()

func _process_factory_build(delta: float) -> void:
	if payment_active or factory_stage >= 5 or not is_instance_valid(player):
		return
	var z_positions := [0.0, 0.0, 0.0, 10.0, 20.0, 30.0]
	var stage := factory_stage + 1
	var target := Vector3(7.5, 0.0, z_positions[stage])
	var player_flat := Vector2(player.global_position.x, player.global_position.z)
	if player_flat.distance_to(Vector2(target.x, target.z)) > 2.15:
		return
	var costs := [0.0, 20.0, 55.0, 110.0, 190.0]
	var cost: float = costs[factory_stage]
	var payment := minf(money, minf(delta * _spending_speed_multiplier(), cost - factory_build_paid))
	if payment > 0.0:
		money -= payment
		factory_build_paid += payment
		_update_ui()
		factory_build_save_timer += delta
		if factory_build_save_timer >= 1.0:
			factory_build_save_timer = 0.0
			_save_game()
		_update_factory_build_label()
	if factory_build_paid >= cost - 0.001:
		factory_stage += 1
		factory_build_paid = 0.0
		factory_build_save_timer = 0.0
		_build_factory_expansion()
		# Move the player clear of the newly spawned machine collision immediately.
		player.global_position = Vector3(3.5, maxf(player.global_position.y, 0.0), minf(z_positions[factory_stage] + 2.8, 37.2))
		player.velocity = Vector3.ZERO
		player.reset_physics_interpolation()
		_refresh_factory_upgrade_button()
		_update_ui()
		_save_game()
		var names := ["", "", "SHREDDER", "GRANULATOR", "TEDDY BEAR FACTORY", "PACKAGING + DELIVERY"]
		_set_message("%s COMPLETED! Connected to the conveyor." % names[factory_stage])

func _update_factory_build_label() -> void:
	if not is_instance_valid(factory_build_label) or factory_stage >= 5:
		return
	var costs := [0.0, 20.0, 55.0, 110.0, 190.0]
	var names := ["", "", "SHREDDER", "GRANULATOR", "TEDDY BEAR FACTORY", "PACKAGING + TRUCK"]
	var cost: float = costs[factory_stage]
	var remaining := maxf(0.0, cost - factory_build_paid)
	factory_build_label.text = "%.1f ZC" % remaining

func _build_factory_module(stage: int) -> void:
	var z_positions := [0.0, 0.0, 0.0, 10.0, 20.0, 30.0]
	var z: float = z_positions[stage]
	var colors := [Color.WHITE, Color.WHITE, Color(0.92, 0.48, 0.12), Color(0.10, 0.63, 0.76), Color(0.22, 0.68, 0.42), Color(0.94, 0.66, 0.16)]
	var accent: Color = colors[stage]
	# Shared industrial foundation keeps every machine aligned to the existing line.
	_box("FactoryModule%dBase" % stage, Vector3(7.5, 0.34, z), Vector3(4.35, 0.68, 3.35), Color(0.045, 0.065, 0.075), true)
	_box("FactoryModule%dBaseTrim" % stage, Vector3(7.5, 0.70, z), Vector3(4.12, 0.09, 3.12), accent.darkened(0.12), false)
	_box("FactoryModule%dBody" % stage, Vector3(7.5, 1.55, z), Vector3(3.25, 1.55, 2.55), Color(0.105, 0.15, 0.17), true)
	_box("FactoryModule%dTop" % stage, Vector3(7.5, 2.38, z), Vector3(3.65, 0.16, 2.88), Color(0.16, 0.21, 0.22), false)
	_box("MachineAccentFront" , Vector3(7.5, 0.91, z - 1.31), Vector3(2.9, 0.12, 0.07), accent, false)
	_box("MachineFrontGlass", Vector3(7.5, 1.62, z - 1.31), Vector3(1.35, 0.58, 0.055), Color(0.055, 0.18, 0.22), false)
	_box("MachineFrontGlassGlow", Vector3(7.5, 1.62, z - 1.35), Vector3(1.08, 0.36, 0.025), accent.lightened(0.35), false)
	for x in [5.95, 9.05]:
		_box("MachineCornerArmor", Vector3(x, 1.55, z - 1.30), Vector3(0.18, 1.45, 0.12), accent.darkened(0.18), false)
		_box("MachineFoot", Vector3(x, 0.22, z + 0.95), Vector3(0.48, 0.30, 0.55), Color(0.07, 0.09, 0.10), false)
	_label_3d(["", "", "SHREDDER", "GRANULATOR", "TOY ASSEMBLY", "PACKAGING & DISPATCH"][stage], Vector3(7.5, 3.05, z - 0.05), 0.24)
	if stage == 2:
		# Heavy feed hopper and guarded twin cutting drums.
		_box("ShredderHopperLeft", Vector3(6.82, 2.82, z - 0.35), Vector3(0.18, 0.88, 1.75), Color(0.32, 0.38, 0.39), false)
		_box("ShredderHopperRight", Vector3(8.18, 2.82, z - 0.35), Vector3(0.18, 0.88, 1.75), Color(0.32, 0.38, 0.39), false)
		_box("ShredderHopperBack", Vector3(7.5, 2.82, z + 0.48), Vector3(1.55, 0.88, 0.18), Color(0.27, 0.33, 0.34), false)
		_box("ShredderFeedMouth", Vector3(7.5, 2.92, z - 0.38), Vector3(1.15, 0.12, 1.25), Color(0.025, 0.035, 0.04), false)
		for x in [7.12, 7.88]:
			var drum := _cylinder("ShredderCuttingDrum", Vector3(x, 1.48, z - 0.72), 0.38, 1.22, Color(0.58, 0.64, 0.64), true)
			drum.rotation_degrees.z = 90.0
			for tooth in range(5):
				_box("ShredderCuttingTooth", Vector3(x, 1.48, z - 1.18 + tooth * 0.22), Vector3(0.48, 0.10, 0.09), Color(0.92, 0.67, 0.20), false)
		_box("ShredderSafetyGrille", Vector3(7.5, 2.05, z - 1.05), Vector3(1.85, 0.10, 0.12), Color(0.94, 0.65, 0.12), false)
		_cylinder("ShredderDriveMotor", Vector3(9.05, 1.35, z + 0.35), 0.42, 0.90, Color(0.13, 0.27, 0.31), false)
		_label_3d("FEED / CUT / CRUSH", Vector3(7.5, 0.84, z + 1.42), 0.13)
	elif stage == 3:
		# Tall granulator chamber with feed funnel, inspection window and motor.
		_box("GranulatorMainChamber", Vector3(7.5, 1.72, z), Vector3(2.25, 1.78, 1.95), Color(0.10, 0.25, 0.30), true)
		_box("GranulatorHopperTop", Vector3(7.5, 2.82, z - 0.05), Vector3(2.55, 0.20, 2.2), accent, false)
		_box("GranulatorHopperNeck", Vector3(7.5, 2.55, z - 0.05), Vector3(1.25, 0.45, 1.10), Color(0.28, 0.36, 0.37), false)
		_box("GranulatorWindow", Vector3(7.5, 1.82, z - 1.02), Vector3(1.25, 0.72, 0.06), Color(0.035, 0.12, 0.15), false)
		_box("GranulatorWindowGlow", Vector3(7.5, 1.82, z - 1.06), Vector3(0.92, 0.42, 0.025), Color(0.12, 0.75, 0.78), false)
		_cylinder("GranulatorMotor", Vector3(9.05, 1.30, z + 0.25), 0.48, 1.05, Color(0.12, 0.19, 0.22), false)
		_cylinder("GranulatorMotorFan", Vector3(9.05, 1.30, z + 0.82), 0.32, 0.10, Color(0.65, 0.72, 0.72), false)
		_box("GranulatorOutlet", Vector3(7.5, 0.91, z + 1.42), Vector3(1.45, 0.48, 0.48), accent, false)
		_label_3d("RECYCLED PLASTIC", Vector3(7.5, 0.83, z - 1.43), 0.13)
	elif stage == 4:
		# Enclosed toy assembly cell, with a lit inspection bay and side supply rolls.
		_box("AssemblyGlassBay", Vector3(7.5, 1.72, z - 0.10), Vector3(2.25, 1.18, 0.12), Color(0.12, 0.43, 0.48), false)
		_box("AssemblyGlassFrameTop", Vector3(7.5, 2.34, z - 0.17), Vector3(2.45, 0.12, 0.16), accent, false)
		_box("AssemblyGlassFrameBottom", Vector3(7.5, 1.10, z - 0.17), Vector3(2.45, 0.12, 0.16), accent, false)
		for x in [6.42, 8.58]:
			_box("AssemblyGlassDivider", Vector3(x, 1.72, z - 0.19), Vector3(0.10, 1.18, 0.10), Color(0.70, 0.83, 0.82), false)
		for x in [6.15, 8.85]:
			var fabric := _cylinder("AssemblyFabricRoll", Vector3(x, 1.28, z + 0.92), 0.34, 1.05, Color(0.82, 0.48, 0.32), false)
			fabric.rotation_degrees.z = 90.0
			_cylinder("AssemblyRollHub", Vector3(x, 1.28, z + 1.48), 0.13, 0.10, Color(0.80, 0.82, 0.78), false)
		_box("AssemblyRobotArmBase", Vector3(7.5, 0.95, z + 0.72), Vector3(0.65, 0.35, 0.65), Color(0.08, 0.13, 0.15), false)
		_cylinder("AssemblyRobotArm", Vector3(7.5, 1.55, z + 0.72), 0.13, 1.05, accent, false)
		_box("AssemblyProductChute", Vector3(7.5, 0.92, z + 1.48), Vector3(1.9, 0.35, 0.60), Color(0.28, 0.35, 0.35), false)
		for x in [6.55, 8.45]:
			_box("AssemblyShippingCrate", Vector3(x, 0.90, z + 1.52), Vector3(0.58, 0.82, 0.65), Color(0.72, 0.50, 0.25), false)
		_label_3d("TOY ASSEMBLY LINE", Vector3(7.5, 0.83, z - 1.43), 0.13)
	else:
		# Packaging tunnel, carton magazine, sealing head and output roller table.
		_box("PackagingFeed", Vector3(7.5, 1.02, z - 1.72), Vector3(1.55, 0.46, 0.78), Color(0.22, 0.32, 0.34), false)
		_box("PackagingTunnelLeft", Vector3(6.48, 1.55, z), Vector3(0.18, 1.55, 2.05), accent.darkened(0.18), false)
		_box("PackagingTunnelRight", Vector3(8.52, 1.55, z), Vector3(0.18, 1.55, 2.05), accent.darkened(0.18), false)
		_box("PackagingTunnelRoof", Vector3(7.5, 2.32, z), Vector3(2.20, 0.18, 2.10), accent, false)
		_box("PackagingTunnelLight", Vector3(7.5, 2.20, z - 0.88), Vector3(1.15, 0.08, 0.08), Color(0.45, 0.95, 0.78), false)
		_box("PackagingSealingHead", Vector3(7.5, 1.18, z + 0.25), Vector3(1.18, 0.48, 0.72), Color(0.20, 0.27, 0.29), false)
		_box("PackagingOutput", Vector3(9.45, 0.95, z + 0.1), Vector3(1.2, 0.18, 1.1), Color(0.10, 0.13, 0.14), false)
		for x in [8.95, 9.35, 9.75]:
			var output_roller := _cylinder("PackagingOutputRoller", Vector3(x, 0.98, z + 0.1), 0.12, 1.05, Color(0.68, 0.73, 0.72), false)
			output_roller.rotation_degrees.z = 90.0
		_box("PackagingCartonStack", Vector3(5.95, 1.10, z + 0.80), Vector3(0.85, 1.10, 0.82), Color(0.67, 0.46, 0.23), false)
		_label_3d("PACKED TOYS", Vector3(9.25, 2.15, z + 0.82), 0.15)
		_create_delivery_truck(0)
		_build_delivery_conveyor(Vector3(9.95, 0.82, z + 0.25), Vector3(15.25, 0.82, z + 0.25))
	# A compact status beacon makes each station readable from a distance.
	_box("FactoryModule%dStatusHousing" % stage, Vector3(9.45, 2.05, z - 0.82), Vector3(0.34, 0.48, 0.30), Color(0.035, 0.06, 0.07), false)
	_cylinder("FactoryModule%dStatusLamp" % stage, Vector3(9.45, 2.30, z - 0.82), 0.12, 0.10, Color(0.10, 0.95, 0.56), false)

func _build_factory_link(start_z: float, end_z: float) -> void:
	var middle := (start_z + end_z) * 0.5
	var length := absf(end_z - start_z)
	_box("FactoryConveyorFrame", Vector3(7.5, 0.78, middle), Vector3(1.75, 0.28, length), Color(0.07, 0.11, 0.12), true)
	_box("FactoryConveyorBelt", Vector3(7.5, 0.96, middle), Vector3(1.48, 0.07, maxf(0.2, length - 0.12)), Color(0.025, 0.04, 0.045), false)
	for x in [6.68, 8.32]:
		_box("FactoryConveyorRail", Vector3(x, 1.18, middle), Vector3(0.10, 0.40, length), Color(0.48, 0.54, 0.52), false)
	for i in range(maxi(2, int(length / 0.65))):
		var z := start_z + (end_z - start_z) * float(i) / float(maxi(1, int(length / 0.65) - 1))
		var roller := _cylinder("FactoryConveyorRoller", Vector3(7.5, 0.83, z), 0.095, 1.42, Color(0.55, 0.60, 0.58), true)
		# Factory belt runs along Z, so each roller axle must span the X width.
		roller.rotation_degrees.z = 90.0
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
	label.pixel_size = 0.005
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color.WHITE
	root.add_child(label)

	area.input_event.connect(_on_world_action_input.bind(action))
	return root

func _create_gear_refill_button(world_position: Vector3, action: Callable) -> Node3D:
	# Wall-mounted industrial control station; the front faces into the yard (-X).
	var root := Node3D.new()
	root.name = "TrashRespawnWallPanel"
	root.position = world_position
	add_child(root)

	# Reinforced mounting plate and steel outer frame.
	_box_child(root, "RespawnPanelBackplate", Vector3(-0.14, 0.0, 0.0), Vector3(0.18, 1.55, 1.85), Color(0.055, 0.085, 0.09))
	_box_child(root, "RespawnPanelFace", Vector3(-0.245, 0.0, 0.0), Vector3(0.045, 1.34, 1.62), Color(0.19, 0.24, 0.24))
	_box_child(root, "RespawnPanelHeader", Vector3(-0.275, 0.48, 0.0), Vector3(0.035, 0.28, 1.42), Color(0.11, 0.16, 0.17))
	_box_child(root, "RespawnPanelWarning", Vector3(-0.30, 0.48, 0.0), Vector3(0.025, 0.045, 1.18), Color(0.88, 0.57, 0.13))

	# Status screen and industrial labels.
	_box_child(root, "RespawnPanelScreenFrame", Vector3(-0.29, 0.12, 0.0), Vector3(0.07, 0.48, 0.92), Color(0.035, 0.065, 0.07))
	_box_child(root, "RespawnPanelScreen", Vector3(-0.33, 0.12, 0.0), Vector3(0.025, 0.34, 0.72), Color(0.08, 0.30, 0.29))
	var screen_text := Label3D.new()
	screen_text.text = "WASTE SYSTEM\nREADY"
	screen_text.position = Vector3(-0.35, 0.13, 0.0)
	screen_text.rotation_degrees.y = 90.0
	screen_text.font_size = 24
	screen_text.pixel_size = 0.0045
	screen_text.modulate = Color(0.48, 1.0, 0.76)
	root.add_child(screen_text)

	# Visible manual pull lever instead of a push-button: pivot, steel rod and grip.
	_box_child(root, "RespawnLeverMount", Vector3(-0.31, -0.40, 0.0), Vector3(0.12, 0.50, 0.72), Color(0.10, 0.13, 0.13))
	var lever_pivot := Node3D.new()
	lever_pivot.name = "RespawnLeverPivot"
	lever_pivot.position = Vector3(-0.43, -0.40, 0.0)
	root.add_child(lever_pivot)
	var lever_rod := MeshInstance3D.new()
	lever_rod.name = "RespawnLeverRod"
	var lever_rod_mesh := CylinderMesh.new()
	lever_rod_mesh.top_radius = 0.075
	lever_rod_mesh.bottom_radius = 0.075
	lever_rod_mesh.height = 0.72
	lever_rod.mesh = lever_rod_mesh
	lever_rod.position = Vector3(-0.18, 0.28, 0.0)
	lever_rod.rotation_degrees.z = -32.0
	lever_rod.material_override = _mat(Color(0.72, 0.76, 0.73))
	lever_pivot.add_child(lever_rod)
	var lever_grip := MeshInstance3D.new()
	lever_grip.name = "RespawnLeverGrip"
	var grip_mesh := SphereMesh.new()
	grip_mesh.radius = 0.19
	grip_mesh.height = 0.38
	lever_grip.mesh = grip_mesh
	lever_grip.position = Vector3(-0.38, 0.58, 0.0)
	lever_grip.material_override = _mat(Color(0.86, 0.15, 0.10))
	lever_pivot.add_child(lever_grip)

	var label := Label3D.new()
	label.text = "TRASH RESPAWN"
	label.position = Vector3(-0.34, -0.72, 0.0)
	label.rotation_degrees.y = 90.0
	label.font_size = 25
	label.pixel_size = 0.005
	label.modulate = Color(1.0, 0.88, 0.62)
	root.add_child(label)

	# The hit area is placed in front of the panel face and drives the actual lever.
	var area := Area3D.new()
	area.name = "WallRespawnButtonArea"
	area.position = Vector3(-0.58, -0.12, 0.0)
	area.collision_layer = 1
	area.input_ray_pickable = true
	var collision := CollisionShape3D.new()
	var hit_shape := BoxShape3D.new()
	hit_shape.size = Vector3(1.15, 1.65, 1.72)
	collision.shape = hit_shape
	area.add_child(collision)
	root.add_child(area)
	area.input_event.connect(_on_pull_lever_input.bind(action, lever_pivot))
	return root

func _box_child(parent: Node3D, node_name: String, local_position: Vector3, dimensions: Vector3, color: Color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var box_mesh := BoxMesh.new()
	box_mesh.size = dimensions
	mesh_instance.mesh = box_mesh
	mesh_instance.position = local_position
	mesh_instance.material_override = _mat(color)
	parent.add_child(mesh_instance)
	return mesh_instance

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

	# Industrial, adult-style recycler chassis: segmented armor and a sensor visor.
	_add_robot_box(robot_visual, "Torso", Vector3(0, 1.05, 0), Vector3(0.82, 0.88, 0.52), Color(0.12, 0.18, 0.21))
	_add_robot_box(robot_visual, "ChestArmor", Vector3(0, 1.18, -0.27), Vector3(0.62, 0.52, 0.055), Color(0.27, 0.32, 0.34))
	_add_robot_box(robot_visual, "ChestPanel", Vector3(0, 1.12, -0.307), Vector3(0.38, 0.24, 0.035), Color(0.055, 0.12, 0.14))
	_add_robot_box(robot_visual, "StatusBar", Vector3(0, 1.12, -0.33), Vector3(0.24, 0.035, 0.025), Color(0.15, 0.72, 0.62))
	_add_robot_box(robot_visual, "Belt", Vector3(0, 0.62, 0), Vector3(0.84, 0.16, 0.54), Color(0.055, 0.09, 0.12))
	_add_robot_box(robot_visual, "ShoulderArmorL", Vector3(-0.49, 1.39, 0), Vector3(0.30, 0.30, 0.36), Color(0.34, 0.38, 0.39))
	_add_robot_box(robot_visual, "ShoulderArmorR", Vector3(0.49, 1.39, 0), Vector3(0.30, 0.30, 0.36), Color(0.34, 0.38, 0.39))

	robot_head = Node3D.new()
	robot_head.position = Vector3(0, 1.82, 0)
	robot_visual.add_child(robot_head)
	_add_robot_box(robot_head, "HeadShell", Vector3(0, 0, 0), Vector3(0.72, 0.58, 0.56), Color(0.38, 0.44, 0.46))
	_add_robot_box(robot_head, "Visor", Vector3(0, 0.02, -0.292), Vector3(0.58, 0.26, 0.045), Color(0.025, 0.055, 0.075))
	_add_robot_box(robot_head, "SensorL", Vector3(-0.17, 0.025, -0.323), Vector3(0.09, 0.035, 0.025), Color(0.12, 0.78, 0.72))
	_add_robot_box(robot_head, "SensorR", Vector3(0.17, 0.025, -0.323), Vector3(0.09, 0.035, 0.025), Color(0.12, 0.78, 0.72))
	_add_robot_box(robot_head, "JawPlate", Vector3(0, -0.20, -0.26), Vector3(0.40, 0.12, 0.08), Color(0.23, 0.29, 0.31))
	_add_robot_box(robot_head, "HeadSideL", Vector3(-0.39, 0, 0), Vector3(0.10, 0.30, 0.42), Color(0.19, 0.25, 0.27))
	_add_robot_box(robot_head, "HeadSideR", Vector3(0.39, 0, 0), Vector3(0.10, 0.30, 0.42), Color(0.19, 0.25, 0.27))
	_add_robot_box(robot_head, "TopSensor", Vector3(0, 0.31, 0), Vector3(0.20, 0.09, 0.22), Color(0.20, 0.28, 0.30))

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
	magnet_tool.visible = (auto_pickup_level > 0 or magnet_power_level > 1) and suction_level <= 0

	# Separate vacuum attachment on the opposite arm, unlocked by suction upgrades.
	suction_tool = Node3D.new()
	suction_tool.name = "ArmMountedVacuum"
	suction_tool.position = Vector3(0.0, -0.53, -0.08)
	robot_right_arm.add_child(suction_tool)
	_add_robot_box(suction_tool, "VacuumMotor", Vector3(0, -0.02, 0.02), Vector3(0.24, 0.25, 0.28), Color(0.12, 0.22, 0.25))
	_add_robot_box(suction_tool, "VacuumTube", Vector3(0, -0.10, -0.20), Vector3(0.13, 0.12, 0.34), Color(0.48, 0.58, 0.59))
	_add_robot_box(suction_tool, "VacuumMouth", Vector3(0, -0.12, -0.40), Vector3(0.34, 0.16, 0.12), Color(0.10, 0.75, 0.68))
	suction_tool.visible = suction_level > 0
	if suction_level > 0:
		magnet_tool.visible = false
	robot_left_leg = _robot_leg(robot_visual, "LeftLeg", Vector3(-0.20, 0.52, 0))
	robot_right_leg = _robot_leg(robot_visual, "RightLeg", Vector3(0.20, 0.52, 0))
	_build_helper_drones()
	_build_ground_collector()

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
	var magnet_is_working := suction_level <= 0 and auto_pickup_level > 0 and is_instance_valid(auto_pickup_target)
	var vacuum_is_working := suction_level > 0 and is_instance_valid(suction_target)
	var tool_is_working := magnet_is_working or vacuum_is_working
	var normal_right_arm := -stride * 0.65 - (0.18 if auto_pickup_level > 0 or suction_level > 0 else 0.0)
	# The equipped attachment reaches forward while it pulls a selected item.
	var arm_target_angle := -1.12 if tool_is_working else normal_right_arm
	robot_right_arm.rotation.x = lerp_angle(robot_right_arm.rotation.x, arm_target_angle, clampf(delta * (13.0 if tool_is_working else 8.0), 0.0, 1.0))
	var extension_target := 0.34 if tool_is_working else 0.0
	collection_tool_extension = lerpf(collection_tool_extension, extension_target, clampf(delta * 10.0, 0.0, 1.0))
	if is_instance_valid(magnet_tool):
		magnet_tool.position.z = -0.08 - collection_tool_extension
	if is_instance_valid(suction_tool):
		suction_tool.position.z = -0.08 - collection_tool_extension
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
	# Keep a fixed, city-wide pool. The distant landfill is intentionally empty.
	_spawn_trash(1000)
	_update_final_zone_label()

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var screen := get_viewport().get_visible_rect().size
	var panel := Panel.new()
	panel.position = Vector2(18, 18)
	panel.size = Vector2(270, 126)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.065, 0.075, 0.88)))
	layer.add_child(panel)
	money_label = _label("ZC  0", Vector2(32, 27), 22, layer)
	bag_label = _label("BAG  0 / 5", Vector2(32, 64), 18, layer)
	final_zone_label = _label("FINAL CLEANUP  0 / 60,000", Vector2(32, 94), 14, layer)
	final_zone_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.30))
	_update_final_zone_label()

	# Large, high-contrast mission card. Keep instructions short and readable on phones.
	var mission_card := Panel.new()
	mission_card.name = "MissionCard"
	mission_card.position = Vector2(18, 134)
	mission_card.size = Vector2(clampf(screen.x - 36.0, 284.0, 480.0), 112.0)
	mission_card.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.075, 0.068, 0.96)))
	layer.add_child(mission_card)
	var mission_title := _label("CURRENT MISSION", Vector2(14, 9), 14, mission_card)
	mission_title.name = "MissionTitle"
	mission_title.add_theme_color_override("font_color", Color(0.38, 1.0, 0.72))
	mission_label = _label("", Vector2(14, 34), 16, mission_card)
	mission_label.size = Vector2(mission_card.size.x - 28.0, 70.0)
	mission_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mission_label.add_theme_color_override("font_color", Color(0.98, 1.0, 0.99))
	mission_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	mission_label.add_theme_constant_override("shadow_offset_x", 1)
	mission_label.add_theme_constant_override("shadow_offset_y", 1)
	_update_missions()

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

	var upgrades_button := _button("⚙  UPGRADES", Vector2(-174, 24), Vector2(156, 58), layer)
	upgrades_button.anchor_left = 1.0
	upgrades_button.anchor_right = 1.0
	upgrades_button.pressed.connect(_toggle_upgrade_panel)

	var menu_button := _button("☰", Vector2(-232, 24), Vector2(48, 58), layer)
	menu_button.anchor_left = 1.0
	menu_button.anchor_right = 1.0
	menu_button.add_theme_font_size_override("font_size", 24)
	menu_button.pressed.connect(_toggle_main_menu)

	upgrade_panel = Panel.new()
	upgrade_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	upgrade_panel.z_index = 10
	upgrade_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.055, 0.065, 0.995)))
	upgrade_panel.visible = false
	layer.add_child(upgrade_panel)

	var upgrade_header := _label("UPGRADE GARAGE", Vector2(18, 16), 25, upgrade_panel)
	upgrade_header.add_theme_color_override("font_color", Color(0.45, 0.94, 0.75))
	_label("Improve your equipment and recycling empire", Vector2(18, 50), 13, upgrade_panel)
	var close_upgrades := _button("X", Vector2(-58, 12), Vector2(44, 44), upgrade_panel)
	close_upgrades.anchor_left = 1.0
	close_upgrades.anchor_right = 1.0
	close_upgrades.pressed.connect(_toggle_upgrade_panel)

	skill_scroll_container = ScrollContainer.new()
	skill_scroll_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	skill_scroll_container.offset_left = 12
	skill_scroll_container.offset_top = 84
	skill_scroll_container.offset_right = -12
	skill_scroll_container.offset_bottom = -12
	# Keep scrolling fully functional while hiding the visible scrollbar.
	skill_scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	skill_scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	skill_scroll_container.scroll_deadzone = 6
	skill_scroll_container.scroll_vertical_custom_step = 28.0
	skill_scroll_container.mouse_filter = Control.MOUSE_FILTER_STOP
	upgrade_panel.add_child(skill_scroll_container)
	skill_map = VBoxContainer.new()
	skill_map.name = "UpgradeCards"
	skill_map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skill_map.add_theme_constant_override("separation", 10)
	skill_scroll_container.add_child(skill_map)
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
	title.text = "ZEKA CITY:\nCLEANUP EMPIRE"
	title.position = Vector2(screen.x * 0.12, screen.y * 0.14)
	title.size = Vector2(screen.x * 0.84, screen.y * 0.30)
	title.add_theme_font_size_override("font_size", int(screen.y * 0.052))
	title.add_theme_color_override("font_color", Color(0.92, 0.98, 0.95))
	title.add_theme_color_override("font_shadow_color", Color(0,0,0,0.5))
	title.add_theme_constant_override("shadow_offset_x", 3)
	title.add_theme_constant_override("shadow_offset_y", 4)
	main_menu_panel.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "BUILD YOUR RECYCLING BUSINESS"
	subtitle.position = Vector2(screen.x * 0.12, screen.y * 0.44)
	subtitle.size = Vector2(screen.x * 0.8, 36)
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", Color(0.48, 0.83, 0.70))
	main_menu_panel.add_child(subtitle)
	var button_width := screen.x * 0.76
	var button_height := 66.0
	var button_x := screen.x * 0.12
	var play := _button("▶   PLAY", Vector2(button_x, screen.y * 0.50), Vector2(button_width, button_height), main_menu_panel)
	play.add_theme_font_size_override("font_size", 24)
	play.add_theme_stylebox_override("normal", _button_style(Color(0.12, 0.62, 0.43)))
	play.add_theme_stylebox_override("hover", _button_style(Color(0.16, 0.72, 0.51)))
	play.pressed.connect(_close_main_menu)
	main_menu_play_button = play
	new_game_button = _button("NEW", Vector2(button_x, screen.y * 0.50 + 84), Vector2(button_width, 58), main_menu_panel)
	new_game_button.add_theme_stylebox_override("normal", _button_style(Color(0.18, 0.32, 0.30)))
	new_game_button.pressed.connect(_confirm_new_game)
	var exit_button := _button("EXIT GAME", Vector2(button_x, screen.y * 0.50 + 158), Vector2(button_width, 52), main_menu_panel)
	exit_button.add_theme_stylebox_override("normal", _button_style(Color(0.19, 0.25, 0.26)))
	exit_button.pressed.connect(_confirm_exit_game)
	var footer := Label.new()
	footer.text = "RECYCLE • UPGRADE • EXPAND"
	footer.position = Vector2(button_x, screen.y * 0.68)
	footer.size = Vector2(button_width, 28)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 12)
	footer.add_theme_color_override("font_color", Color(0.48, 0.58, 0.57))
	main_menu_panel.add_child(footer)
	# Keep the gameplay HUD behind the menu but hide it until play is selected.
	for child in layer.get_children():
		if child != main_menu_panel:
			child.visible = false


func _toggle_main_menu() -> void:
	if main_menu_open:
		_close_main_menu()
		return
	main_menu_open = true
	if is_instance_valid(player):
		player.set_process(false)
		player.set_physics_process(false)
	if is_instance_valid(upgrade_panel):
		upgrade_panel.hide()
	if is_instance_valid(main_menu_panel):
		main_menu_panel.show()
		main_menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		var ui_layer := main_menu_panel.get_parent()
		if is_instance_valid(ui_layer):
			for child in ui_layer.get_children():
				if child != main_menu_panel:
					child.hide()

func _confirm_exit_game() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "EXIT ZEKA CITY: CLEANUP EMPIRE?"
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
	message.text = "DELETE CURRENT WORLD?\nAll progress will be lost."
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
	# NEW can be selected directly from the title screen before a player exists.
	# Initialize the scene first so reset operations never dereference a null player.
	if not world_initialized:
		await _close_main_menu()
	money = 0
	final_zone_cleaned = 0
	total_trash_collected = 0
	tutorial_mission_stage = 0
	carried = 0
	carried_bulky = 0
	capacity = 4
	upgrade_level = 1
	speed_upgrade_level = 1
	unload_upgrade_level = 1
	equipment_upgrade_level = 1
	technology_upgrade_level = 1
	trash_value_upgrade_level = 1
	spawn_upgrade_level = 1
	respawn_level = 0
	respawn_timer = 0.0
	auto_pickup_level = 0
	bulk_pickup_level = 0
	luck_upgrade_level = 1
	rare_drop_upgrade_level = 0
	magnet_power_level = 1
	suction_level = 0
	drone_level = 0
	sorting_robot_levels = [0, 0, 0, 0]
	sorting_bin_counts = [0, 0, 0, 0]
	_refresh_sorting_district()
	dispatch_upgrade_level = 0
	city_truck_upgrade_level = 0
	city_fleet_upgrade_level = 0
	city_truck_phase = 0
	city_truck_timer = 0.0
	city_trash_reserved = 0
	waste_tank_built = false
	if is_instance_valid(waste_tank_root):
		waste_tank_root.queue_free()
	waste_tank_root = null
	if is_instance_valid(waste_tank_build_label):
		waste_tank_build_label.visible = true
	_reset_city_truck_fleet()
	fleet_upgrade_level = 0
	truck_capacity_upgrade_level = 0
	packaging_upgrade_level = 0
	truck_dispatch_timer = 0.0
	shipping_active = false
	dispatch_trucks_remaining = 0
	delivery_trucks.clear()
	drone_timer = 0.0
	_refresh_helper_drone_visibility()
	auto_pickup_timer = 0.0
	recycling_bonus = 1.0
	collection_range = 2.0
	yard_stage = 4
	_reset_city_truck_fleet()
	factory_stage = 1
	factory_built_stage = 1
	teddy_stock_values.clear()
	shipping_active = false
	factory_build_paid = 0.0
	factory_build_save_timer = 0.0
	mega_factory_built_count = 1
	factory_row_input_stock = [0, 0, 0, 0, 0]
	factory_row_product_stock = [0, 0, 0, 0, 0]
	factory_production_timer = 0.0
	waste_tank_inventory = 0
	mega_factory_build_paid = 0.0
	mega_factory_build_timer = 0.0
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
	_refresh_factory_upgrade_button()
	_refresh_factory_build_zones()
	_save_game()
	_set_message("NEW WORLD STARTED!")
	_close_main_menu()

func _close_main_menu() -> void:
	# Build the heavy 3D scene only after the title menu has been rendered
	# and the player explicitly starts the game.
	if not world_initialized:
		if is_instance_valid(main_menu_play_button):
			main_menu_play_button.disabled = true
		_set_message("BUILDING YOUR RECYCLING YARD...")
		await get_tree().process_frame
		_build_player()
		_build_trash()
		_build_world()
		_refresh_delivery_fleet()
		_apply_unlocked_districts()
		world_initialized = true
		if is_instance_valid(main_menu_play_button):
			main_menu_play_button.disabled = false
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
				if child == upgrade_panel:
					child.hide()
				elif child != main_menu_panel:
					child.show()
	if is_instance_valid(player):
		player.set_process(true)
		player.set_physics_process(true)
	_update_ui()


func _build_skill_tree(parent: Control) -> void:
	var categories := [
		{"title":"ROBOT & COLLECTION","folder":"📁\nROBOT","branches":["capacity","speed","range","unload","auto","bulk_pickup","magnet_power","suction"]},
		{"title":"RECYCLING & ECONOMY","folder":"📁\nECONOMY","branches":["technology","value","supply","luck","rare_drops","respawn"]},
		{"title":"AUTOMATION & FLEET","folder":"📁\nFLEET","branches":["drones","ground_robot","sorting_robot","dispatch","fleet","truck_capacity","packaging","conveyor_speed"]}
	]
	var titles := {
		"capacity":"BACKPACK CAPACITY","speed":"MOVEMENT SPEED","range":"PICKUP RANGE","unload":"RECYCLING SPEED",
		"technology":"TECHNOLOGY","value":"TRASH VALUE","supply":"TRASH SUPPLY","auto":"AUTO PICKUP",
		"bulk_pickup":"MULTI PICKUP","respawn":"AUTO RESPAWN","luck":"LUCKY FINDS","rare_drops":"SILVER & GOLD FINDS","magnet_power":"MAGNET POWER","suction":"VACUUM SUCTION",
		"drones":"HELPER DRONES","ground_robot":"GROUND COLLECTOR ROBOT","sorting_robot":"SORTING ROBOT EFFICIENCY","dispatch":"TRUCK FREQUENCY",
		"fleet":"HIRE TRUCKS","truck_capacity":"TRUCK CAPACITY","packaging":"PACKAGING SPEED","conveyor_speed":"CONVEYOR & FACTORY SPEED","repair_robot":"MAINTENANCE ROBOT"
	}
	var descriptions := {
		"capacity":"Carry more waste before returning to unload.",
		"speed":"Move around the yard faster.",
		"range":"Collect trash from farther away.",
		"unload":"Empty your backpack into the conveyor faster.",
		"technology":"Improve recycling efficiency and production.",
		"value":"Earn more ZC when selling recycled waste.",
		"supply":"Increase how much trash appears around the yard.",
		"auto":"Automatically collect nearby trash.",
		"bulk_pickup":"Collect several nearby pieces at once.",
		"respawn":"Make collected trash respawn more often.",
		"luck":"Improve your chance of finding valuable items.",
		"rare_drops":"Increase silver and gold item drop chances.",
		"magnet_power":"Pull trash toward you from farther away.",
		"suction":"Unlock an arm-mounted vacuum. Each upgrade increases suction reach and pull speed.",
		"drones":"Add helper drones that collect trash for you.",
		"ground_robot":"Unlock a ground rover that drives to trash, loads it, then returns to the recycling point. Upgrades improve speed and cargo capacity.",
		"sorting_robot":"Increase all built sorting robots’ travel speed and search radius.",
		
		"dispatch":"Send product delivery trucks more frequently.",
		"fleet":"Hire extra delivery trucks to ship products.",
		"truck_capacity":"Let each delivery truck carry more boxes.",
		"packaging":"Package products faster for shipment.",
		"conveyor_speed":"Move recycling items through the factory line faster.","repair_robot":"Automatically repairs breakdowns and reduces downtime."
	}

	var folder_grid := GridContainer.new()
	folder_grid.columns = 3
	folder_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	folder_grid.add_theme_constant_override("h_separation", 8)
	folder_grid.add_theme_constant_override("v_separation", 8)
	parent.add_child(folder_grid)

	var detail_title := Label.new()
	detail_title.text = "CHOOSE AN UPGRADE FOLDER"
	detail_title.custom_minimum_size = Vector2(0, 34)
	detail_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_title.add_theme_font_size_override("font_size", 15)
	detail_title.add_theme_color_override("font_color", Color(0.45, 0.94, 0.75))
	parent.add_child(detail_title)

	var category_bodies: Array = []
	var folder_buttons: Array = []
	var category_titles: Array = []
	for category_index in range(categories.size()):
		var category: Dictionary = categories[category_index]
		var category_title := String(category.title)
		category_titles.append(category_title)

		var folder := Button.new()
		folder.text = String(category.folder)
		folder.custom_minimum_size = Vector2(0, 76)
		folder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		folder.add_theme_font_size_override("font_size", 14)
		folder.add_theme_color_override("font_color", Color(0.82, 0.94, 0.89))
		folder.add_theme_stylebox_override("normal", _button_style(Color(0.075, 0.14, 0.14)))
		folder.add_theme_stylebox_override("hover", _button_style(Color(0.11, 0.23, 0.19)))
		folder.add_theme_stylebox_override("pressed", _button_style(Color(0.12, 0.34, 0.25)))
		folder_grid.add_child(folder)
		folder_buttons.append(folder)

		var category_body := VBoxContainer.new()
		category_body.add_theme_constant_override("separation", 8)
		category_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		category_body.visible = false
		parent.add_child(category_body)
		category_bodies.append(category_body)

		for branch in category.branches:
			# One large touch target per upgrade: the title, description and price
			# all belong to the same button, so players can tap anywhere on the card.
			var upgrade_row := Button.new()
			upgrade_row.custom_minimum_size = Vector2(0, 132)
			upgrade_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			upgrade_row.add_theme_stylebox_override("normal", _button_style(Color(0.075, 0.15, 0.15)))
			upgrade_row.add_theme_stylebox_override("hover", _button_style(Color(0.11, 0.25, 0.21)))
			upgrade_row.add_theme_stylebox_override("pressed", _button_style(Color(0.06, 0.12, 0.12)))
			upgrade_row.add_theme_stylebox_override("disabled", _button_style(Color(0.07, 0.11, 0.105)))
			upgrade_row.pressed.connect(_purchase_upgrade_branch.bind(String(branch)))
			category_body.add_child(upgrade_row)

			var card_content := HBoxContainer.new()
			card_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			card_content.add_theme_constant_override("separation", 12)
			card_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
			upgrade_row.add_child(card_content)

			var upgrade_info := VBoxContainer.new()
			upgrade_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			upgrade_info.size_flags_stretch_ratio = 1.0
			upgrade_info.alignment = BoxContainer.ALIGNMENT_CENTER
			upgrade_info.add_theme_constant_override("separation", 7)
			upgrade_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card_content.add_child(upgrade_info)

			var row := upgrade_row
			var title_label := Label.new()
			title_label.add_theme_font_size_override("font_size", 17)
			title_label.add_theme_color_override("font_color", Color(0.96, 1.0, 0.98))
			title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			upgrade_info.add_child(title_label)

			var level_label := Label.new()
			level_label.text = "LEVEL 0 / 3"
			level_label.add_theme_font_size_override("font_size", 12)
			level_label.add_theme_color_override("font_color", Color(0.40, 0.91, 0.72))
			level_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			upgrade_info.add_child(level_label)

			var description := Label.new()
			description.text = String(descriptions.get(String(branch), "Improves this part of your operation."))
			description.custom_minimum_size = Vector2(0, 38)
			description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			description.add_theme_font_size_override("font_size", 13)
			description.add_theme_color_override("font_color", Color(0.75, 0.85, 0.81))
			description.mouse_filter = Control.MOUSE_FILTER_IGNORE
			upgrade_info.add_child(description)

			var price_panel := PanelContainer.new()
			price_panel.custom_minimum_size = Vector2(112, 82)
			price_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			price_panel.add_theme_stylebox_override("panel", _button_style(Color(0.035, 0.15, 0.105)))
			price_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card_content.add_child(price_panel)
			var price_label := Label.new()
			price_label.text = "BUY"
			price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			price_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			price_label.add_theme_font_size_override("font_size", 16)
			price_label.add_theme_color_override("font_color", Color(0.55, 1.0, 0.72))
			price_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			price_panel.add_child(price_label)
			skill_node_data.append({"button": row, "title_label": title_label, "level_label": level_label, "price_label": price_label, "description": description, "branch": String(branch), "title": String(titles[branch]), "price_panel": price_panel})

		folder.pressed.connect(_select_upgrade_category.bind(category_index, category_bodies, folder_buttons, category_titles, detail_title))

	_select_upgrade_category(0, category_bodies, folder_buttons, category_titles, detail_title)
	_refresh_upgrade_prices()


func _select_upgrade_category(index: int, bodies: Array, folders: Array, titles: Array, heading: Label) -> void:
	if index < 0 or index >= bodies.size():
		return
	for i in range(bodies.size()):
		var body := bodies[i] as VBoxContainer
		var folder := folders[i] as Button
		body.visible = i == index
		folder.add_theme_stylebox_override("normal", _button_style(Color(0.12, 0.34, 0.25) if i == index else Color(0.075, 0.14, 0.14)))
		folder.add_theme_color_override("font_color", Color(0.95, 1.0, 0.96) if i == index else Color(0.68, 0.82, 0.77))
	heading.text = String(titles[index])


func _purchase_upgrade_branch(branch: String) -> void:
	if payment_active:
		_set_message("Another upgrade is already being processed. Please wait.")
		return
	if not _skill_branch_unlocked(branch):
		_set_message("This upgrade is not available yet.")
		return
	var next_level := _skill_level(branch) + 1
	if next_level > 3:
		_set_message("This upgrade is at its maximum level.")
		return
	await _purchase_skill_node(branch, next_level)


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
		"respawn": return Color(0.24, 0.78, 0.48)
		"speed": return Color(0.20, 0.52, 0.88)
		"range": return Color(0.65, 0.48, 0.90)
		"unload": return Color(0.88, 0.57, 0.18)
		"technology": return Color(0.18, 0.68, 0.78)
		"supply": return Color(0.72, 0.48, 0.24)
		"auto": return Color(0.30, 0.72, 0.38)
		"bulk_pickup": return Color(0.18, 0.72, 0.58)
		"luck": return Color(0.92, 0.72, 0.20)
		"rare_drops": return Color(0.92, 0.78, 0.30)
		"magnet_power": return Color(0.20, 0.78, 0.88)
		"suction": return Color(0.12, 0.82, 0.70)
		"drones": return Color(0.65, 0.78, 0.30)
		"city_truck": return Color(0.95, 0.72, 0.18)
		"city_fleet": return Color(0.82, 0.58, 0.24)
		"dispatch": return Color(0.16, 0.70, 0.82)
		"fleet": return Color(0.90, 0.48, 0.22)
		"truck_capacity": return Color(0.75, 0.52, 0.22)
		"packaging": return Color(0.72, 0.32, 0.62)
	return Color(0.25, 0.45, 0.42)

func _skill_icon(branch: String) -> String:
	match branch:
		"capacity": return "🎒"
		"respawn": return "♻"
		"speed": return "⚡"
		"range": return "🧤"
		"unload": return "♻"
		"technology": return "⚙"
		"value": return "💰"
		"supply": return "🗑"
		"auto": return "🧲"
		"bulk_pickup": return "✋"
		"luck": return "🍀"
		"rare_drops": return "🥇"
		"magnet_power": return "🧲"
		"suction": return "🌪"
		"drones": return "🚁"
		"ground_robot": return "🤖"
		"city_truck": return "🚛"
		"city_fleet": return "🚚"
		"dispatch": return "⏱️"
		"fleet": return "🚚"
		"truck_capacity": return "📦"
		"packaging": return "🏭"
	return "◆"

func _skill_hex_button_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = Color(0, 0, 0, 0)
	style.shadow_size = 0
	return style

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

func _add_skill_connection(parent: Control, from_point: Vector2, to_point: Vector2, from_key: String, to_key: String) -> void:
	var line := Line2D.new()
	line.width = 5.0
	line.default_color = Color(0.28, 0.78, 0.62, 0.9)
	line.antialiased = true
	line.add_point(from_point)
	line.add_point(to_point)
	line.visible = false
	parent.add_child(line)
	skill_connection_data.append({"line":line,"from":from_key,"to":to_key})

func _skill_level(branch: String) -> int:
	match branch:
		"capacity": return upgrade_level - 1
		"speed": return speed_upgrade_level - 1
		"unload": return unload_upgrade_level - 1
		"range": return equipment_upgrade_level - 1
		"technology": return technology_upgrade_level - 1
		"value": return trash_value_upgrade_level - 1
		"supply": return spawn_upgrade_level - 1
		"respawn": return respawn_level
		"auto": return auto_pickup_level
		"bulk_pickup": return bulk_pickup_level
		"luck": return luck_upgrade_level - 1
		"rare_drops": return rare_drop_upgrade_level
		"magnet_power": return magnet_power_level - 1
		"suction": return suction_level
		"drones": return drone_level
		"ground_robot": return ground_robot_level
		"sorting_robot": return sorting_robot_upgrade_level
		"conveyor_speed": return conveyor_speed_upgrade_level
		"repair_robot": return repair_robot_level
		"city_truck": return city_truck_upgrade_level
		"city_fleet": return city_fleet_upgrade_level
		"dispatch": return dispatch_upgrade_level
		"fleet": return fleet_upgrade_level
		"truck_capacity": return truck_capacity_upgrade_level
		"packaging": return packaging_upgrade_level
	return 0

func _skill_branch_unlocked(branch: String) -> bool:
	# Vacuum is a fully independent upgrade branch; it does not require magnet upgrades.
	return true

func _purchase_skill_node(branch: String, level: int) -> void:
	if not _skill_branch_unlocked(branch):
		_set_message("This upgrade is not available yet.")
		return
	if level != _skill_level(branch) + 1 or level > 3:
		_set_message("This upgrade is already at its maximum level.")
		return
	active_upgrade_branch = branch
	_refresh_upgrade_prices()
	match branch:
		"capacity": await _upgrade_bag()
		"speed": await _upgrade_speed()
		"unload": await _upgrade_unload()
		"range": await _upgrade_equipment()
		"technology": await _upgrade_technology()
		"value": await _upgrade_trash_value()
		"supply": await _upgrade_spawn()
		"respawn": await _upgrade_respawn()
		"auto": await _upgrade_auto_pickup()
		"bulk_pickup": await _upgrade_bulk_pickup()
		"luck": await _upgrade_luck()
		"rare_drops": await _upgrade_rare_drops()
		"magnet_power": await _upgrade_magnet_power()
		"suction": await _upgrade_suction()
		"drones": await _upgrade_drones()
		"ground_robot": await _upgrade_ground_robot()
		"sorting_robot": await _upgrade_sorting_robot()
		"conveyor_speed": await _upgrade_conveyor_speed()
		"repair_robot": await _upgrade_repair_robot()
		"city_truck": await _upgrade_city_truck_frequency()
		"city_fleet": await _upgrade_city_fleet()
		"dispatch": await _upgrade_dispatch()
		"fleet": await _upgrade_fleet()
		"truck_capacity": await _upgrade_truck_capacity()
		"packaging": await _upgrade_packaging()
	active_upgrade_branch = ""
	_refresh_upgrade_prices()

func _refresh_upgrade_prices() -> void:
	var base_costs := {"capacity":8.0,"speed":10.0,"unload":9.0,"range":12.0,"technology":14.0,"value":18.0,"supply":10.0,"auto":28.0,"luck":12.0,"magnet_power":20.0,"suction":45.0,"drones":55.0,"ground_robot":65.0,"city_truck":60.0,"city_fleet":85.0,"dispatch":45.0,"fleet":85.0,"truck_capacity":70.0,"packaging":60.0,"sorting_robot":50.0,"conveyor_speed":65.0,"repair_robot":75.0,"rare_drops":25.0,"respawn":60.0,"bulk_pickup":35.0}
	for node in skill_node_data:
		var branch := String(node.branch)
		var current := _skill_level(branch)
		var unlocked := _skill_branch_unlocked(branch)
		var button := node.button as Button
		var price_label := node.price_label as Label
		var title_label := node.title_label as Label
		var price_panel := node.price_panel as PanelContainer
		var level_label := node.level_label as Label
		var icon := _skill_icon(branch)
		var maxed := current >= 3
		var price := _upgrade_cost(float(base_costs.get(branch, 4.0)), current + 1)
		if branch == "capacity":
			price = _upgrade_cost(8.0, upgrade_level)
		level_label.text = "LEVEL %d / 3" % mini(current, 3)
		if maxed:
			title_label.text = "%s  %s" % [icon, node.title]
			button.disabled = true
			price_label.text = "MAX\nLEVEL"
			price_label.add_theme_color_override("font_color", Color(0.72, 0.96, 0.78))
			price_panel.add_theme_stylebox_override("panel", _button_style(Color(0.08, 0.20, 0.13)))
			level_label.text = "FULLY UPGRADED  ✓"
			level_label.add_theme_color_override("font_color", Color(0.58, 1.0, 0.68))
		elif not unlocked:
			title_label.text = "%s  %s" % [icon, node.title]
			button.disabled = true
			price_label.text = "LOCKED"
			price_label.add_theme_color_override("font_color", Color(0.72, 0.76, 0.74))
			level_label.text = "NOT AVAILABLE"
		else:
			var next_level := current + 1
			title_label.text = "%s  %s" % [icon, node.title]
			button.disabled = payment_active
			if payment_active and branch == active_upgrade_branch:
				price_label.text = "PURCHASING"
				price_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.48))
				price_panel.add_theme_stylebox_override("panel", _button_style(Color(0.20, 0.15, 0.055)))
				level_label.text = "UPGRADING TO LEVEL %d..." % next_level
				level_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.38))
			else:
				price_label.text = "UPGRADE\n%.0f ZC" % price
				price_label.add_theme_color_override("font_color", Color(0.55, 1.0, 0.72) if money >= price else Color(1.0, 0.72, 0.48))
				price_panel.add_theme_stylebox_override("panel", _button_style(Color(0.035, 0.15, 0.105) if money >= price else Color(0.16, 0.095, 0.07)))
				level_label.text = "NEXT: LEVEL %d  •  %s" % [next_level, "READY" if money >= price else "NEED MORE ZC"]
				level_label.add_theme_color_override("font_color", Color(0.40, 0.91, 0.72) if money >= price else Color(1.0, 0.68, 0.48))

func _skill_key_owned(key: String) -> bool:
	var parts := key.rsplit("_", true, 1)
	if parts.size() != 2:
		return false
	return _skill_level(parts[0]) >= int(parts[1])

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_confirm_exit_game()

func _input(event: InputEvent) -> void:
	if main_menu_open:
		return

	# Native-feeling touch scrolling for the upgrade cards, with a short
	# momentum glide after the finger is released.
	if is_instance_valid(upgrade_panel) and upgrade_panel.visible and is_instance_valid(skill_scroll_container):
		if event is InputEventScreenTouch:
			if event.pressed and skill_scroll_container.get_global_rect().has_point(event.position):
				skill_drag_touch = event.index
				skill_touch_last_position = event.position
				skill_touch_moved = false
				skill_scroll_velocity = Vector2.ZERO
				skill_scroll_target = float(skill_scroll_container.scroll_vertical)
				skill_scroll_smoothing = true
				if is_instance_valid(skill_scroll_tween):
					skill_scroll_tween.kill()
				return
			elif not event.pressed and event.index == skill_drag_touch:
				skill_drag_touch = -1
				if skill_touch_moved:
					get_viewport().set_input_as_handled()
					_start_upgrade_scroll_glide()
				return
		elif event is InputEventScreenDrag and event.index == skill_drag_touch:
				if not skill_touch_moved and event.position.distance_to(skill_touch_last_position) < 7.0:
					return
				skill_touch_moved = true
				var drag_bar := skill_scroll_container.get_v_scroll_bar()
				var drag_max := maxi(0, int(drag_bar.max_value - drag_bar.page))
				skill_scroll_target = clampf(skill_scroll_target - event.relative.y, 0.0, float(drag_max))
				skill_scroll_velocity.y = -event.velocity.y
				skill_touch_last_position = event.position
				get_viewport().set_input_as_handled()
				return

	if is_instance_valid(upgrade_panel) and upgrade_panel.visible and is_instance_valid(skill_scroll_container) and event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var direction := -1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1
			var scroll_max := maxi(0, int(skill_scroll_container.get_v_scroll_bar().max_value - skill_scroll_container.get_v_scroll_bar().page))
			var base_scroll := skill_scroll_target if skill_scroll_smoothing else float(skill_scroll_container.scroll_vertical)
			skill_scroll_target = clampf(base_scroll + direction * 82.0, 0.0, float(scroll_max))
			skill_scroll_smoothing = true
			get_viewport().set_input_as_handled()
			return
	if not is_instance_valid(player):
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			gameplay_touch_points[event.index] = event.position
			if gameplay_touch_points.size() >= 2:
				var points: Array = gameplay_touch_points.values()
				gameplay_pinch_distance = points[0].distance_to(points[1])
				gameplay_pinch_fov = camera.fov if is_instance_valid(camera) else 58.0
			elif is_instance_valid(joystick_pad) and joystick_touch == -1 and joystick_pad.get_global_rect().has_point(event.position):
				joystick_touch = event.index
				_update_joystick(event.position)
		else:
			gameplay_touch_points.erase(event.index)
			if event.index == joystick_touch:
				_reset_joystick()
			if gameplay_touch_points.size() < 2:
				gameplay_pinch_distance = 0.0
	elif event is InputEventScreenDrag:
		if gameplay_touch_points.has(event.index):
			gameplay_touch_points[event.index] = event.position
			if gameplay_touch_points.size() >= 2 and gameplay_pinch_distance > 0.0 and is_instance_valid(camera):
				var points: Array = gameplay_touch_points.values()
				var point_a: Vector2 = points[0]
				var point_b: Vector2 = points[1]
				var distance: float = point_a.distance_to(point_b)
				camera.fov = clampf(gameplay_pinch_fov * (gameplay_pinch_distance / maxf(distance, 1.0)), 38.0, 76.0)
		if event.index == joystick_touch:
			_update_joystick(event.position)


func _start_upgrade_scroll_glide() -> void:
	if not is_instance_valid(skill_scroll_container):
		return
	var scroll_bar := skill_scroll_container.get_v_scroll_bar()
	var scroll_max := maxi(0, int(scroll_bar.max_value - scroll_bar.page))
	var glide_distance := clampf(skill_scroll_velocity.y * 0.30, -620.0, 620.0)
	if absf(glide_distance) >= 12.0:
		skill_scroll_target = clampf(skill_scroll_target + glide_distance, 0.0, float(scroll_max))
		skill_scroll_smoothing = true
	skill_scroll_velocity = Vector2.ZERO


func _process_upgrade_scroll_smoothing(delta: float) -> void:
	if not skill_scroll_smoothing or not is_instance_valid(upgrade_panel) or not upgrade_panel.visible or not is_instance_valid(skill_scroll_container):
		skill_scroll_smoothing = false
		return
	var scroll_bar := skill_scroll_container.get_v_scroll_bar()
	var scroll_max := maxi(0, int(scroll_bar.max_value - scroll_bar.page))
	skill_scroll_target = clampf(skill_scroll_target, 0.0, float(scroll_max))
	var current_scroll := float(skill_scroll_container.scroll_vertical)
	var blend := 1.0 - exp(-delta * 11.0)
	var next_scroll := lerpf(current_scroll, skill_scroll_target, blend)
	if absf(skill_scroll_target - next_scroll) < 0.45:
		next_scroll = skill_scroll_target
		skill_scroll_smoothing = false
	skill_scroll_container.scroll_vertical = int(round(next_scroll))


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

func _register_final_cleanup_pickup(item: Node3D) -> void:
	if not is_instance_valid(item):
		return
	# Count every pickup; only the endgame landfill contributes to its cleanup goal.
	total_trash_collected += 1
	if item.global_position.x >= 135.0:
		final_zone_cleaned = mini(FINAL_ZONE_TARGET, final_zone_cleaned + 1)
	_update_final_zone_label()
	_update_missions()
	_maintain_city_trash_supply()

func _maintain_city_trash_supply() -> void:
	var alive_count := _count_regular_trash()
	if alive_count > 500:
		return
	var amount := maxi(0, 1000 - alive_count)
	if amount > 0:
		_spawn_trash(amount)
		_update_final_zone_label()
		_set_message("CITY TRASH REFILLED: %d / 1,000" % _count_regular_trash())

func _spawn_city_replenishment(amount: int) -> void:
	# Compatibility wrapper for older save/progression paths; global cap applies.
	_spawn_trash(amount)


func _is_city_dump_trash(item: Node3D) -> bool:
	if not is_instance_valid(item):
		return false
	var p := item.global_position
	return p.x >= 121.4 and p.x <= 128.2 and p.z >= -3.3 and p.z <= 3.3


func _player_at_city_dump_front() -> bool:
	if not is_instance_valid(player):
		return false
	var p := player.global_position
	# The only access route is the open front (positive Z) of the bunker.
	return p.x >= 121.6 and p.x <= 128.0 and p.z >= 3.5 and p.z <= 6.5


func _can_collect_city_dump_trash(item: Node3D) -> bool:
	return not _is_city_dump_trash(item) or _player_at_city_dump_front()


func _pickup_trash_item(item: Node3D) -> bool:
	if not is_instance_valid(item):
		return false
	if not _can_collect_city_dump_trash(item):
		return false
	var weight := 2 if item.has_meta("bulky") else 1
	if carried + weight > capacity:
		return false
	if item.has_meta("rare_type"):
		var rare_type := String(item.get_meta("rare_type"))
		var bonus := 4.0 if rare_type == "gold" else 1.25
		money += bonus
		_set_message("%s rare scrap found! Bonus +%.2f ZC" % [rare_type.to_upper(), bonus])
	if weight == 2:
		carried_bulky += 1
	carried += weight
	item.queue_free()
	trash_nodes.erase(item)
	_register_final_cleanup_pickup(item)
	return true

func _collect_nearby() -> void:
	if carried >= capacity:
		_set_message("Bag full! Return to the recycling station.")
		return
	var batch_sizes := [1, 2, 3, 5]
	var collect_limit: int = batch_sizes[clampi(bulk_pickup_level, 0, 3)]
	var collected := 0
	while collected < collect_limit and carried < capacity:
		var nearest: Node3D
		var best := collection_range
		for item in trash_nodes:
			if is_instance_valid(item) and _can_collect_city_dump_trash(item) and carried + (2 if item.has_meta("bulky") else 1) <= capacity:
				var distance := player.global_position.distance_to(item.global_position)
				if distance < best:
					best = distance
					nearest = item
		if nearest == null:
			break
		if not _pickup_trash_item(nearest):
			break
		collected += 1
	if collected > 0:
		_update_ui()
		_save_game()
		if carried >= capacity:
			_set_message("BACKPACK FULL! Collected %d item(s). Return to recycling." % collected)
		else:
			_set_message("Collected %d item(s)! Keep cleaning the yard." % collected)
	else:
		_set_message("Get closer to trash that fits in your backpack.")

func _process_auto_pickup(delta: float) -> void:
	# The vacuum replaces the magnet as the active hand collector once purchased.
	if suction_level > 0 or auto_pickup_level <= 0 or not is_instance_valid(player) or carried >= capacity:
		auto_pickup_timer = 0.0
		auto_pickup_scan_timer = 0.0
		auto_pickup_target = null
		return

	# Revalidate targets frequently: manual pickup, drones, or a full backpack
	# may invalidate a target while the magnet is pulling it.
	auto_pickup_scan_timer -= delta
	var target_is_registered := is_instance_valid(auto_pickup_target) and trash_nodes.has(auto_pickup_target)
	if not target_is_registered or auto_pickup_target.get_meta("drone_reserved", -1) != -1 or auto_pickup_scan_timer <= 0.0:
		auto_pickup_target = null
		auto_pickup_scan_timer = 0.12
		var magnet_range := collection_range + 1.2 + float(maxi(auto_pickup_level - 1, 0)) * 0.85 + float(magnet_power_level - 1) * 0.7
		var best_distance := magnet_range
		var player_xz := Vector2(player.global_position.x, player.global_position.z)
		for item in trash_nodes:
			if not is_instance_valid(item) or item == suction_target or not _can_collect_city_dump_trash(item):
				continue
			var weight := 2 if item.has_meta("bulky") else 1
			if carried + weight > capacity or item.get_meta("drone_reserved", -1) != -1:
				continue
			# Pickup range is measured on the ground plane, not in 3D.
			# Trash meshes have different heights, so 3D distance made some
			# nearby pieces appear out of range forever.
			var item_xz := Vector2(item.global_position.x, item.global_position.z)
			var distance := player_xz.distance_to(item_xz)
			if distance < best_distance:
				best_distance = distance
				auto_pickup_target = item

	if not is_instance_valid(auto_pickup_target):
		auto_pickup_timer = 0.0
		return
	if not trash_nodes.has(auto_pickup_target):
		auto_pickup_target = null
		auto_pickup_timer = 0.0
		return
	# Never let a bunker item pass through a side wall.
	if _is_city_dump_trash(auto_pickup_target) and not _player_at_city_dump_front():
		auto_pickup_target = null
		auto_pickup_timer = 0.0
		return

	var pull_speed := 3.8 + float(maxi(auto_pickup_level - 1, 0)) * 0.85 + float(magnet_power_level - 1) * 1.25
	var forward := -player.global_transform.basis.z
	var pickup_point := Vector3(player.global_position.x + forward.x * 0.78, auto_pickup_target.global_position.y, player.global_position.z + forward.z * 0.78)
	var item_xz := Vector2(auto_pickup_target.global_position.x, auto_pickup_target.global_position.z)
	var pickup_xz := Vector2(pickup_point.x, pickup_point.z)
	var distance_to_target := item_xz.distance_to(pickup_xz)
	if distance_to_target > 0.72:
		auto_pickup_target.global_position = auto_pickup_target.global_position.move_toward(pickup_point, pull_speed * delta)
		auto_pickup_timer = 0.0
		return

	auto_pickup_timer += delta
	var interval := maxf(0.16, 0.58 - float(auto_pickup_level - 1) * 0.10)
	if auto_pickup_timer < interval:
		return
	auto_pickup_timer = 0.0
	var picked := auto_pickup_target
	auto_pickup_target = null
	if is_instance_valid(picked) and trash_nodes.has(picked) and _pickup_trash_item(picked):
		_update_ui()
		_save_game()
		_set_message("AUTO MAGNET  +1")
	elif carried < capacity:
		# If another system claimed the piece during the final pickup frame,
		# the next scan immediately chooses a fresh available item.
		auto_pickup_scan_timer = 0.0
	if carried >= capacity:
		_set_message("Bag full! Return to the recycling station.")


func _process_vacuum_suction(delta: float) -> void:
	# Independent vacuum system: separate target, range, speed and timing from the magnet.
	if suction_level <= 0 or not is_instance_valid(player) or carried >= capacity:
		suction_target = null
		suction_scan_timer = 0.0
		suction_pull_timer = 0.0
		return

	suction_scan_timer -= delta
	var target_valid := is_instance_valid(suction_target) and trash_nodes.has(suction_target)
	if target_valid and suction_target.get_meta("drone_reserved", -1) != -1:
		target_valid = false
	if not target_valid or suction_target == auto_pickup_target or suction_scan_timer <= 0.0:
		suction_target = null
		suction_scan_timer = 0.10
		var vacuum_range := collection_range + 1.8 + float(suction_level) * 1.25
		var nearest := vacuum_range
		var player_xz := Vector2(player.global_position.x, player.global_position.z)
		for item in trash_nodes:
			if not is_instance_valid(item) or item == auto_pickup_target or not _can_collect_city_dump_trash(item):
				continue
			if item.get_meta("drone_reserved", -1) != -1:
				continue
			var weight := 2 if item.has_meta("bulky") else 1
			if carried + weight > capacity:
				continue
			var item_xz := Vector2(item.global_position.x, item.global_position.z)
			var distance := player_xz.distance_to(item_xz)
			if distance < nearest:
				nearest = distance
				suction_target = item

	if not is_instance_valid(suction_target):
		suction_pull_timer = 0.0
		return
	if _is_city_dump_trash(suction_target) and not _player_at_city_dump_front():
		suction_target = null
		suction_pull_timer = 0.0
		return

	var forward := -player.global_transform.basis.z
	var pickup_point := Vector3(player.global_position.x + forward.x * 0.92, suction_target.global_position.y, player.global_position.z + forward.z * 0.92)
	var item_xz := Vector2(suction_target.global_position.x, suction_target.global_position.z)
	var distance_to_target := item_xz.distance_to(Vector2(pickup_point.x, pickup_point.z))
	var vacuum_speed := 4.2 + float(suction_level) * 1.9
	if distance_to_target > 0.78:
		suction_target.global_position = suction_target.global_position.move_toward(pickup_point, vacuum_speed * delta)
		suction_pull_timer = 0.0
		return

	suction_pull_timer += delta
	if suction_pull_timer < maxf(0.12, 0.42 - float(suction_level) * 0.07):
		return
	suction_pull_timer = 0.0
	var collected_item := suction_target
	suction_target = null
	if is_instance_valid(collected_item) and trash_nodes.has(collected_item) and _pickup_trash_item(collected_item):
		_update_ui()
		_save_game()
		_set_message("VACUUM SUCTION  +1")
	if carried >= capacity:
		_set_message("Bag full! Return to the recycling station.")

func _build_helper_drones() -> void:
	helper_drones.clear()
	for i in range(3):
		var drone := Node3D.new()
		drone.name = "HelperDrone%d" % (i + 1)
		add_child(drone)

		# Compact industrial quadcopter: rounded fuselage, four arms and
		# four clearly visible propeller units (front faces -Z).
		_add_robot_sphere(drone, "DroneMainShell", Vector3.ZERO, 0.22, Color(0.72, 0.79, 0.80))
		_add_robot_box(drone, "DroneTopBattery", Vector3(0, 0.13, 0.015), Vector3(0.22, 0.075, 0.19), Color(0.18, 0.25, 0.28))
		_add_robot_box(drone, "DroneFrontNose", Vector3(0, -0.015, -0.19), Vector3(0.18, 0.10, 0.12), Color(0.12, 0.34, 0.37))
		_add_robot_sphere(drone, "DroneCameraLens", Vector3(0, -0.015, -0.255), 0.055, Color(0.08, 0.92, 0.83))
		_add_robot_sphere(drone, "DroneStatusLight", Vector3(0, 0.17, 0.12), 0.025, Color(0.30, 1.0, 0.62))

		for sx in [-1.0, 1.0]:
			for sz in [-1.0, 1.0]:
				var rotor_pos := Vector3(sx * 0.39, 0.045, sz * 0.36)
				var arm := _add_robot_box(drone, "DroneArm", Vector3(sx * 0.20, 0.035, sz * 0.18), Vector3(0.43, 0.055, 0.075), Color(0.27, 0.34, 0.36))
				arm.rotation_degrees.y = -35.0 if sx == sz else 35.0
				_add_robot_sphere(drone, "MotorHousing", rotor_pos, 0.085, Color(0.13, 0.19, 0.21))
				_add_robot_box(drone, "PropellerBladeA", rotor_pos + Vector3(0, 0.075, 0), Vector3(0.31, 0.018, 0.045), Color(0.10, 0.15, 0.17))
				var blade_b := _add_robot_box(drone, "PropellerBladeB", rotor_pos + Vector3(0, 0.078, 0), Vector3(0.31, 0.014, 0.035), Color(0.16, 0.23, 0.25))
				blade_b.rotation_degrees.y = 90.0
				_add_robot_sphere(drone, "MotorCap", rotor_pos + Vector3(0, 0.105, 0), 0.035, Color(0.13, 0.82, 0.70))

		# Two landing skids make it read as a real utility drone, not a floating toy.
		for skid_x in [-0.13, 0.13]:
			_add_robot_box(drone, "LandingStrut", Vector3(skid_x, -0.19, 0.025), Vector3(0.035, 0.20, 0.045), Color(0.20, 0.27, 0.29))
			_add_robot_box(drone, "LandingSkid", Vector3(skid_x, -0.285, 0.025), Vector3(0.055, 0.035, 0.38), Color(0.12, 0.18, 0.20))

		drone.visible = i < drone_level
		drone.global_position = player.global_position + Vector3(0, 2.3, 0) if is_instance_valid(player) else Vector3.ZERO
		drone.set_meta("target", null)
		drone.set_meta("cargo_slots", 0)
		drone.set_meta("cargo_items", [])
		drone.set_meta("lifting_item", null)
		drone.set_meta("cargo_bulky", 0)
		drone.set_meta("cargo_capacity", 5)
		drone.set_meta("returning", false)
		drone.set_meta("deposit_timer", 0.0)
		helper_drones.append(drone)

func _refresh_helper_drone_visibility() -> void:
	for i in range(helper_drones.size()):
		if is_instance_valid(helper_drones[i]):
			helper_drones[i].visible = i < drone_level


func _build_ground_collector() -> void:
	if is_instance_valid(ground_collector):
		ground_collector.queue_free()
	ground_collector = Node3D.new()
	ground_collector.name = "GroundTrashCollector"
	add_child(ground_collector)
	# Low, four-wheel autonomous collection rover with a front loading scoop.
	_add_robot_box(ground_collector, "RoverChassis", Vector3(0, 0.48, 0), Vector3(1.05, 0.42, 1.35), Color(0.13, 0.24, 0.27))
	_add_robot_box(ground_collector, "RoverTop", Vector3(0, 0.76, 0.05), Vector3(0.72, 0.18, 0.78), Color(0.24, 0.42, 0.43))
	_add_robot_box(ground_collector, "RoverFrontScoop", Vector3(0, 0.22, -0.78), Vector3(0.92, 0.12, 0.34), Color(0.72, 0.78, 0.72))
	_add_robot_box(ground_collector, "RoverSensor", Vector3(0, 0.82, -0.30), Vector3(0.28, 0.12, 0.12), Color(0.12, 0.95, 0.76))
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var wheel := MeshInstance3D.new()
			wheel.name = "RoverWheel"
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.25
			wheel_mesh.bottom_radius = 0.25
			wheel_mesh.height = 0.16
			wheel_mesh.radial_segments = 16
			wheel.mesh = wheel_mesh
			wheel.position = Vector3(sx * 0.55, 0.28, sz * 0.43)
			wheel.rotation_degrees.z = 90.0
			wheel.material_override = _mat(Color(0.055, 0.07, 0.075))
			ground_collector.add_child(wheel)
	ground_collector.visible = ground_robot_level > 0
	ground_collector.global_position = Vector3(SELL_POINT.x + 3.0, 0.0, SELL_POINT.z + 2.0)
	ground_collector.set_meta("target", null)
	ground_collector.set_meta("cargo_slots", 0)
	ground_collector.set_meta("cargo_items", [])
	ground_collector.set_meta("cargo_bulky", 0)
	ground_collector.set_meta("cargo_capacity", 3)
	ground_collector.set_meta("returning", false)
	ground_collector.set_meta("deposit_timer", 0.0)
	ground_collector.set_meta("scan_cooldown", 0.0)

func _refresh_ground_collector() -> void:
	if is_instance_valid(ground_collector):
		ground_collector.visible = ground_robot_level > 0
		ground_collector.set_meta("cargo_capacity", 3 + maxi(ground_robot_level - 1, 0) * 2)

func _process_helper_drones(delta: float) -> void:
	if drone_level <= 0 or not is_instance_valid(player):
		return
	drone_timer += delta
	var interval := maxf(0.75, 3.2 - float(drone_level - 1) * 0.65)
	var drone_speed := 5.0 + float(drone_level - 1) * 1.5
	for i in range(mini(drone_level, helper_drones.size())):
		var drone := helper_drones[i]
		if not is_instance_valid(drone) or not drone.visible:
			continue
		if drone.get_meta("returning", false):
			var return_pos := SELL_POINT + Vector3(0, 1.5, 0)
			drone.global_position = drone.global_position.move_toward(return_pos, drone_speed * delta)
			if drone.global_position.distance_to(return_pos) <= 2.5:
				drone.set_meta("deposited", true)
			continue
		var lifting_item := drone.get_meta("lifting_item") as Node3D
		if is_instance_valid(lifting_item):
			var grip_pos := drone.global_position + Vector3(0, -0.30, 0)
			lifting_item.global_position = lifting_item.global_position.move_toward(grip_pos, 3.8 * delta)
			if lifting_item.global_position.distance_to(grip_pos) <= 0.12:
				var cargo_items: Array = drone.get_meta("cargo_items", [])
				var keep_transform := lifting_item.global_transform
				lifting_item.reparent(drone)
				lifting_item.global_transform = keep_transform
				lifting_item.position = Vector3(0, -0.30, 0)
				cargo_items.append(lifting_item)
				drone.set_meta("cargo_items", cargo_items)
				drone.set_meta("lifting_item", null)
				if int(drone.get_meta("cargo_slots", 0)) >= int(drone.get_meta("cargo_capacity", 5)):
					drone.set_meta("returning", true)
			continue
		if int(drone.get_meta("cargo_slots", 0)) >= int(drone.get_meta("cargo_capacity", 5)):
			drone.set_meta("returning", true)
			continue
		var target := drone.get_meta("target") as Node3D
		if not is_instance_valid(target):
			target = null
			var scan_cooldown := float(drone.get_meta("scan_cooldown", 0.0)) - delta
			if scan_cooldown <= 0.0:
				drone.set_meta("scan_cooldown", 0.45)
				var best_distance := 18.0 + float(drone_level - 1) * 6.0
				for item in trash_nodes:
					if not is_instance_valid(item) or _is_city_dump_trash(item) or item.get_meta("drone_reserved", -1) != -1:
						continue
					var weight := 2 if item.has_meta("bulky") else 1
					var drone_slots := int(drone.get_meta("cargo_slots", 0))
					var drone_capacity := int(drone.get_meta("cargo_capacity", 5))
					if drone_slots + weight > drone_capacity:
						continue
					var distance := drone.global_position.distance_to(item.global_position)
					if distance < best_distance:
						best_distance = distance
						target = item
				if target != null:
					target.set_meta("drone_reserved", i)
					drone.set_meta("target", target)
			else:
				drone.set_meta("scan_cooldown", scan_cooldown)
		if target == null:
			if int(drone.get_meta("cargo_slots", 0)) > 0:
				drone.set_meta("returning", true)
				continue
			var idle_pos := player.global_position + Vector3(cos(robot_anim_time + float(i)) * 3.0, 2.3, sin(robot_anim_time + float(i)) * 3.0)
			drone.global_position = drone.global_position.move_toward(idle_pos, drone_speed * delta)
			continue
		var destination := target.global_position + Vector3(0, 0.20, 0)
		drone.global_position = drone.global_position.move_toward(destination, drone_speed * delta)
		drone.look_at(target.global_position, Vector3.UP)
		if drone.global_position.distance_to(destination) < 0.42 and drone_timer >= interval:
			drone_timer = 0.0
			var weight := 2 if target.has_meta("bulky") else 1
			var slots := int(drone.get_meta("cargo_slots", 0))
			var drone_capacity := int(drone.get_meta("cargo_capacity", 5))
			if slots + weight <= drone_capacity:
				_register_final_cleanup_pickup(target)
				if target.has_meta("rare_type"):
					var rare_type := String(target.get_meta("rare_type"))
					money += 4.0 if rare_type == "gold" else 1.25
				if weight == 2:
					drone.set_meta("cargo_bulky", int(drone.get_meta("cargo_bulky", 0)) + 1)
				drone.set_meta("cargo_slots", slots + weight)
				trash_nodes.erase(target)
				drone.set_meta("lifting_item", target)
				drone.set_meta("target", null)
				_update_ui()
				_save_game()
				_set_message("DRONE CARGO  %d/%d" % [slots + weight, drone_capacity])
			else:
				target.set_meta("drone_reserved", -1)
				drone.set_meta("target", null)

func _process_ground_collector(delta: float) -> void:
	if ground_robot_level <= 0 or not is_instance_valid(ground_collector):
		return
	var rover := ground_collector
	var speed := 3.0 + float(ground_robot_level - 1) * 1.15
	var capacity_slots := 3 + maxi(ground_robot_level - 1, 0) * 2
	rover.set_meta("cargo_capacity", capacity_slots)
	if bool(rover.get_meta("returning", false)):
		var home := SELL_POINT + Vector3(0, 0.0, 0)
		rover.global_position = rover.global_position.move_toward(home, speed * delta)
		if Vector2(rover.global_position.x - home.x, rover.global_position.z - home.z).length() < 1.4:
			_ground_collector_deposit_cycle(rover, delta)
		return

	var cargo_slots := int(rover.get_meta("cargo_slots", 0))
	if cargo_slots >= capacity_slots:
		rover.set_meta("returning", true)
		rover.set_meta("target", null)
		return

	var target := rover.get_meta("target") as Node3D
	if not is_instance_valid(target) or not trash_nodes.has(target):
		target = null
		var cooldown := float(rover.get_meta("scan_cooldown", 0.0)) - delta
		if cooldown <= 0.0:
			rover.set_meta("scan_cooldown", 0.35)
			var nearest := 20.0 + float(ground_robot_level - 1) * 7.0
			var rover_xz := Vector2(rover.global_position.x, rover.global_position.z)
			for item in trash_nodes:
				if not is_instance_valid(item) or _is_city_dump_trash(item) or item.get_meta("drone_reserved", -1) != -1:
					continue
				var weight := 2 if item.has_meta("bulky") else 1
				if cargo_slots + weight > capacity_slots:
					continue
				var distance := rover_xz.distance_to(Vector2(item.global_position.x, item.global_position.z))
				if distance < nearest:
					nearest = distance
					target = item
			if is_instance_valid(target):
				target.set_meta("drone_reserved", -2)
				rover.set_meta("target", target)
		else:
			rover.set_meta("scan_cooldown", cooldown)
	if not is_instance_valid(target):
		if cargo_slots > 0:
			rover.set_meta("returning", true)
		return

	var destination := target.global_position + Vector3(0, 0.05, 0)
	var rover_destination := Vector3(destination.x, rover.global_position.y, destination.z)
	rover.global_position = rover.global_position.move_toward(rover_destination, speed * delta)
	if Vector2(rover.global_position.x - destination.x, rover.global_position.z - destination.z).length() > 0.72:
		rover.look_at(Vector3(destination.x, rover.global_position.y, destination.z), Vector3.UP)
		return

	var weight := 2 if target.has_meta("bulky") else 1
	if cargo_slots + weight <= capacity_slots:
		_register_final_cleanup_pickup(target)
		if target.has_meta("rare_type"):
			var rare_type := String(target.get_meta("rare_type"))
			money += 4.0 if rare_type == "gold" else 1.25
		if weight == 2:
			rover.set_meta("cargo_bulky", int(rover.get_meta("cargo_bulky", 0)) + 1)
		rover.set_meta("cargo_slots", cargo_slots + weight)
		var cargo_items: Array = rover.get_meta("cargo_items", [])
		var keep_transform := target.global_transform
		target.reparent(rover)
		target.global_transform = keep_transform
		target.position = Vector3(0, 0.88 + float(cargo_items.size()) * 0.12, 0.0)
		cargo_items.append(target)
		rover.set_meta("cargo_items", cargo_items)
		trash_nodes.erase(target)
		rover.set_meta("target", null)
		if cargo_slots + weight >= capacity_slots:
			rover.set_meta("returning", true)
		_update_ui()
		_save_game()
	else:
		target.set_meta("drone_reserved", -1)
		rover.set_meta("target", null)

func _ground_collector_deposit_cycle(rover: Node3D, delta: float) -> void:
	var slots := int(rover.get_meta("cargo_slots", 0))
	if slots <= 0:
		rover.set_meta("returning", false)
		return
	var timer := float(rover.get_meta("deposit_timer", 0.0)) + delta
	var seconds_per_item := maxf(0.35, 1.35 - float(ground_robot_level - 1) * 0.18)
	if timer < seconds_per_item:
		rover.set_meta("deposit_timer", timer)
		return
	rover.set_meta("deposit_timer", 0.0)
	var bulky := int(rover.get_meta("cargo_bulky", 0)) > 0
	var cargo_items: Array = rover.get_meta("cargo_items", [])
	if not cargo_items.is_empty():
		var cargo_item = cargo_items.pop_front()
		if is_instance_valid(cargo_item):
			if cargo_item.get_parent() == rover:
				rover.remove_child(cargo_item)
			cargo_item.queue_free()
	rover.set_meta("cargo_items", cargo_items)
	if bulky:
		rover.set_meta("cargo_bulky", int(rover.get_meta("cargo_bulky", 0)) - 1)
		rover.set_meta("cargo_slots", slots - 2)
	else:
		rover.set_meta("cargo_slots", slots - 1)
	var item_value := _recycling_item_value(bulky)
	money += item_value
	_spawn_conveyor_item(item_value)
	_update_ui()
	_save_game()
	if int(rover.get_meta("cargo_slots", 0)) <= 0:
		rover.set_meta("returning", false)
		rover.set_meta("scan_cooldown", 0.8)

func _drone_deposit_cycle(drone: Node3D) -> void:
	if not is_instance_valid(drone) or not drone.get_meta("returning", false):
		return
	var slots := int(drone.get_meta("cargo_slots", 0))
	if slots <= 0:
		drone.set_meta("returning", false)
		drone.set_meta("deposited", false)
		return
	var timer := float(drone.get_meta("deposit_timer", 0.0)) + get_process_delta_time()
	var seconds_per_item := maxf(0.35, 1.8 - float(unload_upgrade_level - 1) * 0.18)
	if timer < seconds_per_item:
		drone.set_meta("deposit_timer", timer)
		return
	drone.set_meta("deposit_timer", 0.0)
	var bulky := int(drone.get_meta("cargo_bulky", 0)) > 0
	var cargo_items: Array = drone.get_meta("cargo_items", [])
	if not cargo_items.is_empty():
		var cargo_item = cargo_items.pop_front()
		if is_instance_valid(cargo_item):
			if cargo_item.get_parent() == drone:
				drone.remove_child(cargo_item)
			cargo_item.queue_free()
		drone.set_meta("cargo_items", cargo_items)
	if bulky:
		drone.set_meta("cargo_bulky", int(drone.get_meta("cargo_bulky", 0)) - 1)
		drone.set_meta("cargo_slots", slots - 2)
	else:
		drone.set_meta("cargo_slots", slots - 1)
	var item_value := _recycling_item_value(bulky)
	money += item_value
	_spawn_conveyor_item(item_value)
	_update_ui()
	_save_game()
	if int(drone.get_meta("cargo_slots", 0)) <= 0:
		drone.set_meta("returning", false)
		drone.set_meta("deposited", false)
		drone.set_meta("scan_cooldown", 0.8)
		_set_message("Drone unloaded its cargo and is collecting again.")

func _process_auto_sell(delta: float) -> void:
	if machine_broken:
		return
	if not is_instance_valid(player):
		return
	# Drone cargo is processed separately; it never triggers a sale of the player's bag.
	for drone in helper_drones:
		if is_instance_valid(drone) and drone.visible and drone.get_meta("returning", false) and drone.global_position.distance_to(SELL_POINT + Vector3(0, 1.5, 0)) <= 3.0:
			_drone_deposit_cycle(drone)
	var inside_zone := player.global_position.distance_to(SELL_POINT) <= 2.35
	if not inside_zone or carried <= 0:
		unload_timer = 0.0
		return
	unload_timer += delta
	var seconds_per_item := maxf(0.35, 1.8 - float(unload_upgrade_level - 1) * 0.18)
	if unload_timer >= seconds_per_item:
		unload_timer = 0.0
		var sold_bulky := carried_bulky > 0
		if sold_bulky:
			carried -= 2
			carried_bulky -= 1
		else:
			carried -= 1
		var item_value := _recycling_item_value(sold_bulky)
		if randf() < float(luck_upgrade_level - 1) * 0.10:
			item_value *= 2.0
		money += item_value
		if factory_stage >= 4:
			# The teddy bear sale is a separate bonus; recycling income is still paid now.
			var teddy_sale_bonus := item_value * 2.0
			_spawn_conveyor_item(teddy_sale_bonus)
			_set_message("Recycling +%.2f ZC | Teddy bear queued for extra sale +%.2f ZC" % [item_value, teddy_sale_bonus])
		else:
			_spawn_conveyor_item(item_value)
			_set_message("Conveyor recycling... +%.2f ZC" % item_value)
		_update_ui()
		_save_game()
		if carried == 0:
			_update_missions()
			_set_message("Bag emptied! Teddy bears are being prepared for delivery." if factory_stage >= 4 else "Bag emptied! Money added.")

func _toggle_upgrade_panel() -> void:
	if is_instance_valid(upgrade_panel):
		if not skill_tree_built and is_instance_valid(skill_map):
			_build_skill_tree(skill_map)
			skill_tree_built = true
		upgrade_panel.visible = not upgrade_panel.visible

func _upgrade_bag() -> void:
	var cost := _upgrade_cost(8.0, upgrade_level)
	if money < cost:
		_set_message("You need %.1f ZC to complete this purchase." % cost)
		return
	if not await _pay_gradually(cost):
		return
	capacity += 3
	upgrade_level += 1
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Upgrade purchased! New bag capacity: %d." % capacity)

func _upgrade_speed() -> void:
	var cost := _upgrade_cost(10.0, speed_upgrade_level)
	if money < cost:
		_set_message("You need %.1f ZC to complete this purchase." % cost)
		return
	if not await _pay_gradually(cost):
		return
	speed_upgrade_level += 1
	if tutorial_mission_stage == 2:
		tutorial_mission_stage = 3
	player.set("move_speed", 4.5 + float(speed_upgrade_level - 1) * 0.75)
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Movement speed upgraded!")

func _upgrade_unload() -> void:
	var cost := _upgrade_cost(9.0, unload_upgrade_level)
	if money < cost:
		_set_message("You need %.1f ZC to complete this purchase." % cost)
		return
	if not await _pay_gradually(cost):
		return
	unload_upgrade_level += 1
	if tutorial_mission_stage == 2:
		tutorial_mission_stage = 3
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Unloading speed upgraded!")

func _upgrade_equipment() -> void:
	var cost := _upgrade_cost(12.0, equipment_upgrade_level)
	if money < cost:
		_set_message("You need %.1f ZC to complete this purchase." % cost)
		return
	if not await _pay_gradually(cost):
		return
	equipment_upgrade_level += 1
	if tutorial_mission_stage == 2:
		tutorial_mission_stage = 3
	collection_range = 2.0 + float(equipment_upgrade_level - 1) * 0.65
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Magnet range increased!")

func _upgrade_technology() -> void:
	var cost := _upgrade_cost(14.0, technology_upgrade_level)
	if money < cost:
		_set_message("You need %.1f ZC to complete this purchase." % cost)
		return
	if not await _pay_gradually(cost):
		return
	technology_upgrade_level += 1
	recycling_bonus = 1.0 + float(technology_upgrade_level - 1) * 0.15
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Recycling value increased!")

func _upgrade_rare_drops() -> void:
	if rare_drop_upgrade_level >= 3:
		_set_message("Silver & Gold Finds is already at maximum.")
		return
	var cost := _upgrade_cost(25.0, rare_drop_upgrade_level + 1)
	if not await _pay_gradually(cost):
		return
	rare_drop_upgrade_level = mini(rare_drop_upgrade_level + 1, 3)
	_refresh_upgrade_prices()
	_update_ui()
	_save_game()
	var chances := _rare_drop_chances()
	_set_message("Rare finds upgraded! Silver %.1f%% • Gold %.1f%%" % [chances.x * 100.0, chances.y * 100.0])

func _rare_drop_chances() -> Vector2:
	return Vector2(0.0, 0.0) if rare_drop_upgrade_level <= 0 else Vector2(0.025 * rare_drop_upgrade_level, 0.005 * rare_drop_upgrade_level)

func _upgrade_luck() -> void:
	var cost := _upgrade_cost(12.0, luck_upgrade_level)
	if money < cost:
		_set_message("You need %.1f ZC to complete this purchase." % cost)
		return
	if not await _pay_gradually(cost):
		return
	luck_upgrade_level += 1
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Lucky finds chance increased by 10%!")

func _upgrade_drones() -> void:
	var cost := _upgrade_cost(55.0, drone_level + 1)
	if money < cost:
		_set_message("You need %.1f ZC to complete this purchase." % cost)
		return
	if not await _pay_gradually(cost):
		return
	drone_level += 1
	_refresh_helper_drone_visibility()
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Helper drone upgraded! %d drone(s) now collect trash automatically." % drone_level)


func _sorting_robot_speed() -> float:
	return 4.2 * (1.0 + float(sorting_robot_upgrade_level) * 0.22)

func _conveyor_speed_multiplier() -> float:
	return 1.0 + float(conveyor_speed_upgrade_level) * 0.25

func _upgrade_sorting_robot() -> void:
	if sorting_robot_upgrade_level >= 3:
		return
	var next_level := sorting_robot_upgrade_level + 1
	var cost := _upgrade_cost(50.0, next_level)
	if money < cost:
		_set_message("You need %.1f ZC to upgrade the sorting robots." % cost)
		return
	if not await _pay_gradually(cost):
		return
	sorting_robot_upgrade_level = next_level
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Sorting robots upgraded: faster movement and wider search range.")

func _upgrade_repair_robot() -> void:
	if repair_robot_level >= 3:
		_set_message("Maintenance robot is fully upgraded.")
		return
	var next_level := repair_robot_level + 1
	var cost := _upgrade_cost(75.0, next_level)
	if not await _pay_gradually(cost):
		return
	repair_robot_level = next_level
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Maintenance robot upgraded!")

func _process_machine_maintenance(delta: float) -> void:
	if machine_broken:
		if repair_robot_level <= 0:
			return
		machine_repair_timer += delta
		if machine_repair_timer >= maxf(2.0, 14.0 - float(repair_robot_level) * 3.5):
			machine_broken = false
			machine_repair_timer = 0.0
			machine_work_timer = 0.0
			_set_message("Maintenance robot repaired the factory!")
			_save_game()
		return
	machine_work_timer += delta
	var failure_interval := maxf(240.0, 720.0 - float(repair_robot_level) * 120.0)
	if machine_work_timer >= failure_interval:
		machine_broken = true
		machine_repair_timer = 0.0
		_set_message("FACTORY BREAKDOWN! Hire a maintenance robot for automatic repairs.")
		_update_ui()

func _upgrade_conveyor_speed() -> void:
	if conveyor_speed_upgrade_level >= 3:
		return
	var next_level := conveyor_speed_upgrade_level + 1
	var cost := _upgrade_cost(65.0, next_level)
	if money < cost:
		_set_message("You need %.1f ZC to upgrade the factory conveyor." % cost)
		return
	if not await _pay_gradually(cost):
		return
	conveyor_speed_upgrade_level = next_level
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Factory conveyor speed increased to %.0f%%." % (_conveyor_speed_multiplier() * 100.0))

func _upgrade_ground_robot() -> void:
	if ground_robot_level >= 3:
		_set_message("Ground collector robot is fully upgraded.")
		return
	var cost := _upgrade_cost(65.0, ground_robot_level + 1)
	if money < cost:
		_set_message("You need %.1f ZC to complete this purchase." % cost)
		return
	if not await _pay_gradually(cost):
		return
	ground_robot_level = mini(ground_robot_level + 1, 3)
	if not is_instance_valid(ground_collector):
		_build_ground_collector()
	_refresh_ground_collector()
	_refresh_sorting_district()
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Ground collector robot level %d: speed and cargo capacity increased." % ground_robot_level)

func _upgrade_magnet_power() -> void:
	var cost := _upgrade_cost(20.0, magnet_power_level)
	if money < cost:
		_set_message("You need %.1f ZC to complete this purchase." % cost)
		return
	if not await _pay_gradually(cost):
		return
	magnet_power_level += 1
	if is_instance_valid(magnet_tool):
		magnet_tool.visible = suction_level <= 0
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Magnet pull power increased!")

func _upgrade_suction() -> void:
	if suction_level >= 3:
		_set_message("Vacuum suction is already at maximum.")
		return
	var cost := _upgrade_cost(45.0, suction_level + 1)
	if money < cost:
		_set_message("You need %.1f ZC to complete this purchase." % cost)
		return
	if not await _pay_gradually(cost):
		return
	suction_level = mini(suction_level + 1, 3)
	if is_instance_valid(suction_tool):
		suction_tool.visible = true
	if is_instance_valid(magnet_tool):
		magnet_tool.visible = false
	auto_pickup_target = null
	auto_pickup_timer = 0.0
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Vacuum equipped! It replaces the hand magnet and has stronger suction.")

func _upgrade_trash_value() -> void:
	var cost := _upgrade_cost(18.0, trash_value_upgrade_level)
	if money < cost:
		_set_message("You need %.1f ZC to complete this purchase." % cost)
		return
	if not await _pay_gradually(cost):
		return
	trash_value_upgrade_level += 1
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Trash sale value increased by 25%!")

func _upgrade_cost(base_cost: float, level: int) -> float:
	# Stronger effects cost more; each successive level scales by 55%.
	return ceil(base_cost * pow(1.55, float(level - 1)))

func _upgrade_spawn() -> void:
	var cost := _upgrade_cost(10.0, spawn_upgrade_level)
	if money < cost:
		_set_message("You need %.1f ZC to complete this purchase." % cost)
		return
	if not await _pay_gradually(cost):
		return
	spawn_upgrade_level += 1
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Trash supply upgraded! +6 trash on every manual refill.")

func _upgrade_respawn() -> void:
	var cost := _upgrade_cost(60.0, respawn_level + 1)
	if money < cost:
		_set_message("You need %.1f ZC to complete this purchase." % cost)
		return
	if not await _pay_gradually(cost):
		return
	respawn_level = mini(respawn_level + 1, 3)
	respawn_timer = 0.0
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Automatic trash respawn set to every %.0f minutes!" % _trash_respawn_interval_minutes())

func _trash_respawn_interval_minutes() -> float:
	return [0.0, 5.0, 4.0, 3.0][clampi(respawn_level, 0, 3)]

func _process_trash_respawn(_delta: float) -> void:
	# Supply is replenished immediately when the live city pool reaches 500.
	pass

func _upgrade_bulk_pickup() -> void:
	var cost := _upgrade_cost(35.0, bulk_pickup_level + 1)
	if money < cost:
		_set_message("You need %.1f ZC to complete this purchase." % cost)
		return
	if not await _pay_gradually(cost):
		return
	bulk_pickup_level = mini(bulk_pickup_level + 1, 3)
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	var batch_sizes := [1, 2, 3, 5]
	_set_message("Multi-pickup upgraded! One tap now collects up to %d pieces." % batch_sizes[bulk_pickup_level])

func _upgrade_auto_pickup() -> void:
	var cost := _upgrade_cost(28.0, auto_pickup_level + 1)
	if money < cost:
		_set_message("You need %.1f ZC to complete this purchase." % cost)
		return
	if not await _pay_gradually(cost):
		return
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
	label.text = "CITY DISTRICT 02\nALREADY OPEN"
	# Floor lettering sits just above the pad surface and faces upward.
	label.position = Vector3(0, 0.205, 0)
	label.rotation_degrees.x = -90.0
	label.font_size = 19
	label.pixel_size = 0.0045
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label.modulate = Color(0.82, 1.0, 0.88)
	label.outline_size = 8
	label.outline_modulate = Color(0.015, 0.045, 0.035, 0.98)
	zone.add_child(label)

func _spending_speed_multiplier() -> float:
	var seconds_per_item := maxf(0.35, 1.8 - float(unload_upgrade_level - 1) * 0.18)
	return 1.8 / seconds_per_item

func _pay_gradually(cost: float) -> bool:
	# Validate and charge atomically to prevent partial-payment failures.
	if payment_active:
		_set_message("Another upgrade is already being processed. Please wait.")
		return false
	if money + 0.0001 < cost:
		_set_message("Not enough ZC. Required: %.1f | Available: %.1f" % [cost, money])
		_refresh_upgrade_prices()
		return false

	payment_active = true
	money = maxf(0.0, money - cost)
	_update_ui()
	_save_game()
	_refresh_upgrade_prices()
	payment_active = false
	return true

func _process_expansion_zone(_delta: float) -> void:
	# Districts are permanently open; no standing pad, payment or unlock flow.
	expansion_zone_blocked = false
	district_build_active = false
	district_build_paid = 0.0


func _complete_district_unlock() -> void:
	district_build_active = false
	district_no_money_notified = false
	district_build_paid = 0.0
	district_build_save_timer = 0.0
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

func _recover_player() -> void:
	if not is_instance_valid(player):
		return
	# One continuous playable map includes the city and the endgame landfill.
	player.global_position = Vector3(
		clampf(player.global_position.x, -14.0, 207.0),
		0.05,
		clampf(player.global_position.z, -34.0, 34.0)
	)
	player.velocity = Vector3.ZERO
	player.reset_physics_interpolation()
	_set_message("Safety system: returned to the yard.")

func _refresh_expansion_world_button() -> void:
	# Compatibility hook for old save/UI paths; expansion is no longer locked.
	var zone := get_node_or_null("DistrictUnlockZone") as Node3D
	if is_instance_valid(zone):
		zone.hide()
	expansion_zone_blocked = false


func _expansion_button_label(value: String) -> void:
	var label := expansion_world_button.get_node_or_null("WorldButtonLabel") as Label3D
	if is_instance_valid(label):
		label.text = value

func _save_game() -> void:
	var save := ConfigFile.new()
	save.set_value("progress", "money", money)
	save.set_value("progress", "final_zone_cleaned", final_zone_cleaned)
	save.set_value("progress", "total_trash_collected", total_trash_collected)
	save.set_value("progress", "tutorial_mission_stage", tutorial_mission_stage)
	save.set_value("progress", "carried", carried)
	save.set_value("progress", "capacity", capacity)
	save.set_value("progress", "bag_level", upgrade_level)
	save.set_value("progress", "speed_level", speed_upgrade_level)
	save.set_value("progress", "unload_level", unload_upgrade_level)
	save.set_value("progress", "equipment_level", equipment_upgrade_level)
	save.set_value("progress", "technology_level", technology_upgrade_level)
	save.set_value("progress", "trash_value_level", trash_value_upgrade_level)
	save.set_value("progress", "spawn_level", spawn_upgrade_level)
	save.set_value("progress", "respawn_level", respawn_level)
	save.set_value("progress", "auto_pickup_level", auto_pickup_level)
	save.set_value("progress", "bulk_pickup_level", bulk_pickup_level)
	save.set_value("progress", "luck_level", luck_upgrade_level)
	save.set_value("progress", "rare_drop_level", rare_drop_upgrade_level)
	save.set_value("progress", "magnet_power_level", magnet_power_level)
	save.set_value("progress", "suction_level", suction_level)
	save.set_value("progress", "drone_level", drone_level)
	save.set_value("progress", "ground_robot_level", ground_robot_level)
	save.set_value("progress", "sorting_robot_levels", sorting_robot_levels)
	save.set_value("progress", "sorting_bin_counts", sorting_bin_counts)
	save.set_value("progress", "sorting_robot_upgrade_level", sorting_robot_upgrade_level)
	save.set_value("progress", "conveyor_speed_upgrade_level", conveyor_speed_upgrade_level)
	save.set_value("progress", "repair_robot_level", repair_robot_level)
	save.set_value("progress", "machine_work_timer", machine_work_timer)
	save.set_value("progress", "machine_broken", machine_broken)
	save.set_value("progress", "machine_repair_timer", machine_repair_timer)
	save.set_value("progress", "dispatch_upgrade_level", dispatch_upgrade_level)
	save.set_value("progress", "city_truck_upgrade_level", city_truck_upgrade_level)
	save.set_value("progress", "city_fleet_upgrade_level", city_fleet_upgrade_level)
	save.set_value("progress", "fleet_upgrade_level", fleet_upgrade_level)
	save.set_value("progress", "truck_capacity_upgrade_level", truck_capacity_upgrade_level)
	save.set_value("progress", "packaging_upgrade_level", packaging_upgrade_level)
	save.set_value("progress", "yard_stage", yard_stage)
	save.set_value("progress", "factory_stage", factory_stage)
	save.set_value("progress", "factory_build_paid", factory_build_paid)
	save.set_value("progress", "mega_factory_built_count", mega_factory_built_count)
	save.set_value("progress", "factory_row_input_stock", factory_row_input_stock)
	save.set_value("progress", "factory_row_product_stock", factory_row_product_stock)
	save.set_value("progress", "waste_tank_inventory", waste_tank_inventory)
	save.set_value("progress", "mega_factory_build_paid", mega_factory_build_paid)
	save.set_value("progress", "waste_tank_built", waste_tank_built)
	save.set_value("progress", "teddy_stock_values", teddy_stock_values)
	save.save("user://trash_empire.save")

func _load_game() -> void:
	var save := ConfigFile.new()
	if save.load("user://trash_empire.save") != OK:
		return
	money = float(save.get_value("progress", "money", 0.0))
	final_zone_cleaned = clampi(int(save.get_value("progress", "final_zone_cleaned", 0)), 0, FINAL_ZONE_TARGET)
	total_trash_collected = int(save.get_value("progress", "total_trash_collected", final_zone_cleaned))
	tutorial_mission_stage = clampi(int(save.get_value("progress", "tutorial_mission_stage", 0)), 0, 30)
	carried = int(save.get_value("progress", "carried", 0))
	capacity = int(save.get_value("progress", "capacity", 4))
	upgrade_level = int(save.get_value("progress", "bag_level", 1))
	speed_upgrade_level = int(save.get_value("progress", "speed_level", 1))
	unload_upgrade_level = int(save.get_value("progress", "unload_level", 1))
	equipment_upgrade_level = int(save.get_value("progress", "equipment_level", 1))
	technology_upgrade_level = int(save.get_value("progress", "technology_level", 1))
	trash_value_upgrade_level = int(save.get_value("progress", "trash_value_level", 1))
	spawn_upgrade_level = int(save.get_value("progress", "spawn_level", 1))
	respawn_level = clampi(int(save.get_value("progress", "respawn_level", 0)), 0, 3)
	auto_pickup_level = int(save.get_value("progress", "auto_pickup_level", 0))
	bulk_pickup_level = clampi(int(save.get_value("progress", "bulk_pickup_level", 0)), 0, 3)
	luck_upgrade_level = int(save.get_value("progress", "luck_level", 1))
	rare_drop_upgrade_level = clampi(int(save.get_value("progress", "rare_drop_level", 0)), 0, 3)
	magnet_power_level = int(save.get_value("progress", "magnet_power_level", 1))
	suction_level = clampi(int(save.get_value("progress", "suction_level", 0)), 0, 3)
	drone_level = clampi(int(save.get_value("progress", "drone_level", 0)), 0, 3)
	ground_robot_level = clampi(int(save.get_value("progress", "ground_robot_level", 0)), 0, 3)
	sorting_robot_levels = save.get_value("progress", "sorting_robot_levels", [0, 0, 0, 0])
	sorting_bin_counts = save.get_value("progress", "sorting_bin_counts", [0, 0, 0, 0])
	while sorting_robot_levels.size() < 4: sorting_robot_levels.append(0)
	while sorting_bin_counts.size() < 4: sorting_bin_counts.append(0)
	sorting_robot_upgrade_level = clampi(int(save.get_value("progress", "sorting_robot_upgrade_level", 0)), 0, 3)
	conveyor_speed_upgrade_level = clampi(int(save.get_value("progress", "conveyor_speed_upgrade_level", 0)), 0, 3)
	repair_robot_level = clampi(int(save.get_value("progress", "repair_robot_level", 0)), 0, 3)
	machine_work_timer = float(save.get_value("progress", "machine_work_timer", 0.0))
	machine_broken = bool(save.get_value("progress", "machine_broken", false))
	machine_repair_timer = float(save.get_value("progress", "machine_repair_timer", 0.0))
	dispatch_upgrade_level = clampi(int(save.get_value("progress", "dispatch_upgrade_level", 0)), 0, 3)
	city_truck_upgrade_level = clampi(int(save.get_value("progress", "city_truck_upgrade_level", 0)), 0, 3)
	city_fleet_upgrade_level = clampi(int(save.get_value("progress", "city_fleet_upgrade_level", 0)), 0, 3)
	fleet_upgrade_level = clampi(int(save.get_value("progress", "fleet_upgrade_level", 0)), 0, 3)
	truck_capacity_upgrade_level = clampi(int(save.get_value("progress", "truck_capacity_upgrade_level", 0)), 0, 3)
	packaging_upgrade_level = clampi(int(save.get_value("progress", "packaging_upgrade_level", 0)), 0, 3)
	yard_stage = 4 # All four areas are permanently open in the unified city.
	district_build_paid = 0.0
	factory_stage = clampi(int(save.get_value("progress", "factory_stage", 1)), 1, 5)
	factory_build_paid = clampf(float(save.get_value("progress", "factory_build_paid", 0.0)), 0.0, [0.0, 0.0, 12.0, 35.0, 80.0, 160.0][factory_stage])
	mega_factory_built_count = clampi(int(save.get_value("progress", "mega_factory_built_count", 1)), 1, 15)
	factory_row_input_stock = save.get_value("progress", "factory_row_input_stock", [0, 0, 0, 0, 0])
	factory_row_product_stock = save.get_value("progress", "factory_row_product_stock", [0, 0, 0, 0, 0])
	while factory_row_input_stock.size() < 5: factory_row_input_stock.append(0)
	while factory_row_product_stock.size() < 5: factory_row_product_stock.append(0)
	waste_tank_inventory = clampi(int(save.get_value("progress", "waste_tank_inventory", 0)), 0, WASTE_TANK_CAPACITY)
	mega_factory_build_paid = clampf(float(save.get_value("progress", "mega_factory_build_paid", 0.0)), 0.0, _mega_factory_machine_cost(mega_factory_built_count))
	waste_tank_built = bool(save.get_value("progress", "waste_tank_built", false))
	teddy_stock_values.clear()
	for stored_value in save.get_value("progress", "teddy_stock_values", []):
		teddy_stock_values.append(float(stored_value))
	collection_range = 2.0 + float(equipment_upgrade_level - 1) * 0.65
	recycling_bonus = 1.0 + float(technology_upgrade_level - 1) * 0.15


func _build_final_landfill_details() -> void:
	# Low heap silhouettes turn the 60,000-unit field into one obvious landfill.
	for heap in [
		{"pos": Vector3(154.0, 0.18, -3.5), "scale": Vector3(13.0, 0.22, 8.5), "color": Color(0.24, 0.27, 0.23)},
		{"pos": Vector3(168.0, 0.18, 2.5), "scale": Vector3(15.0, 0.26, 9.0), "color": Color(0.27, 0.28, 0.23)},
		{"pos": Vector3(177.0, 0.16, -5.0), "scale": Vector3(8.0, 0.20, 6.5), "color": Color(0.22, 0.25, 0.22)}
	]:
		var mound := MeshInstance3D.new()
		mound.name = "LandfillHeapBase"
		var shape := SphereMesh.new()
		shape.radius = 1.0
		shape.height = 2.0
		shape.radial_segments = 24
		shape.rings = 12
		mound.mesh = shape
		mound.position = heap.pos
		mound.scale = heap.scale
		mound.material_override = _mat(heap.color)
		add_child(mound)

	# Retaining berms and a marked industrial perimeter.
	for z in [-34.0, 34.0]:
		_box("LandfillRetainingBerm", Vector3(160.0, 0.38, z), Vector3(88.0, 0.76, 0.65), Color(0.34, 0.35, 0.30), false)
	for x in range(120, 205, 4):
		for z in [-33.2, 33.2]:
			_cylinder("LandfillFencePost", Vector3(float(x), 1.35, z), 0.075, 2.7, Color(0.20, 0.25, 0.24), false)
	for z in range(-32, 33, 4):
		for x in [117.0, 203.0]:
			_cylinder("LandfillFencePost", Vector3(x, 1.35, float(z)), 0.075, 2.7, Color(0.20, 0.25, 0.24), false)
	for rail_y in [0.72, 1.92]:
		_box("LandfillFenceRailNorth", Vector3(162.0, rail_y, -33.2), Vector3(84.0, 0.08, 0.08), Color(0.25, 0.31, 0.29), false)
		_box("LandfillFenceRailSouth", Vector3(162.0, rail_y, 33.2), Vector3(84.0, 0.08, 0.08), Color(0.25, 0.31, 0.29), false)
	for light_x in [126.0, 194.0]:
		for light_z in [-28.0, 28.0]:
			_cylinder("LandfillFloodlightPole", Vector3(light_x, 5.0, light_z), 0.13, 10.0, Color(0.25, 0.29, 0.28), false)
			_box("LandfillFloodlightHead", Vector3(light_x, 9.8, light_z), Vector3(1.25, 0.22, 0.55), Color(0.82, 0.78, 0.60), false)
	_box("LandfillTruckScale", Vector3(130.0, 0.13, 0.0), Vector3(7.0, 0.22, 9.0), Color(0.19, 0.23, 0.23), false)
	_box("LandfillScaleDeck", Vector3(130.0, 0.26, 0.0), Vector3(6.2, 0.08, 8.2), Color(0.39, 0.43, 0.41), false)
	for z in [-3.8, 3.8]:
		_box("LandfillScaleStripe", Vector3(130.0, 0.31, z), Vector3(5.8, 0.025, 0.12), Color(0.91, 0.72, 0.25), false)
	_box("LandfillProgressSign", Vector3(190.0, 2.4, -23.0), Vector3(8.5, 4.0, 0.35), Color(0.10, 0.17, 0.16), false)
	_label_3d("FINAL CLEANUP\n60,000 UNITS", Vector3(190.0, 2.35, -22.78), 0.42)
	for x in range(140, 185, 8):
		_box("LandfillLaneMarking", Vector3(float(x), 0.10, 25.0), Vector3(3.0, 0.025, 0.14), Color(0.87, 0.72, 0.32), false)



func _recycling_item_value(bulky: bool) -> float:
	var factory_multipliers := [1.0, 1.6, 2.5, 3.6, 4.8]
	var factory_multiplier: float = factory_multipliers[clampi(factory_stage - 1, 0, 4)]
	var upgrade_multiplier := 1.0 + float(trash_value_upgrade_level - 1) * 0.25
	return 0.5 * recycling_bonus * factory_multiplier * upgrade_multiplier * (2.0 if bulky else 1.0)

func _sorting_robot_item_reward() -> float:
	var factory_multipliers := [1.0, 1.6, 2.5, 3.6, 4.8]
	return 0.35 * factory_multipliers[clampi(factory_stage - 1, 0, 4)]

func _factory_row_unit_price(row: int) -> float:
	var prices := [12.0, 15.0, 10.0, 24.0, 15.0]
	return prices[clampi(row, 0, prices.size() - 1)]

func _factory_row_truck_revenue(row: int) -> float:
	# Three finished goods per truck; higher-complexity products sell for more.
	return _factory_row_unit_price(row) * 3.0

func _factory_row_z(row: int) -> float:
	return -26.0 + float(row) * 13.0

func _factory_row_product(row: int) -> String:
	var products := ["TELEVISIONS", "DINING TABLES", "CHAIRS", "REFRIGERATORS", "FLOOR LAMPS"]
	return products[clampi(row, 0, products.size() - 1)]

func _build_factory_finished_product(row: int) -> void:
	var x := 181.5
	var z := _factory_row_z(row)
	var frame := Color(0.10, 0.13, 0.15)
	var trim := Color(0.48, 0.54, 0.55)
	var wood := [Color(0.48, 0.27, 0.13), Color(0.62, 0.39, 0.20), Color(0.34, 0.22, 0.15)][row % 3]
	_box("FactoryFinishedProductStand%d" % row, Vector3(x, 0.52, z), Vector3(3.2, 0.9, 3.0), Color(0.16, 0.23, 0.22), false)
	match row:
		0:
			# Fully assembled flat-screen television.
			_box("FinishedTVFrame", Vector3(x, 1.72, z - 0.25), Vector3(2.25, 1.42, 0.16), frame, false)
			_box("FinishedTVScreen", Vector3(x, 1.75, z - 0.345), Vector3(2.03, 1.19, 0.025), Color(0.08, 0.28, 0.38), false)
			_box("FinishedTVStandNeck", Vector3(x, 0.98, z - 0.25), Vector3(0.18, 0.42, 0.16), trim, false)
			_box("FinishedTVFeet", Vector3(x, 0.76, z - 0.25), Vector3(1.15, 0.09, 0.42), frame, false)
			_box("FinishedTVPowerLight", Vector3(x + 0.92, 1.08, z - 0.35), Vector3(0.08, 0.045, 0.025), Color(0.15, 0.95, 0.48), false)
		1:
			# A finished wooden dining table with four legs.
			_box("FinishedTableTop", Vector3(x, 1.48, z), Vector3(2.55, 0.18, 1.65), wood, false)
			for lx in [-1.05, 1.05]:
				for lz in [-0.62, 0.62]:
					_box("FinishedTableLeg", Vector3(x + lx, 0.91, z + lz), Vector3(0.14, 1.05, 0.14), wood.darkened(0.12), false)
		2:
			# A complete chair with seat, backrest and four legs.
			_box("FinishedChairSeat", Vector3(x, 1.12, z + 0.28), Vector3(1.45, 0.18, 1.25), wood, false)
			_box("FinishedChairBack", Vector3(x, 1.88, z + 0.83), Vector3(1.45, 1.35, 0.16), wood, false)
			for lx in [-0.58, 0.58]:
				for lz in [-0.22, 0.78]:
					_box("FinishedChairLeg", Vector3(x + lx, 0.62, z + lz), Vector3(0.13, 0.95, 0.13), wood.darkened(0.12), false)
		3:
			# A full-size refrigerator with a separate freezer door and handle.
			_box("FinishedFridgeBody", Vector3(x, 1.72, z), Vector3(1.65, 2.55, 1.45), Color(0.68, 0.74, 0.76), false)
			_box("FinishedFridgeFreezer", Vector3(x, 2.48, z - 0.74), Vector3(1.55, 0.92, 0.045), Color(0.79, 0.83, 0.84), false)
			_box("FinishedFridgeDoor", Vector3(x, 1.48, z - 0.75), Vector3(1.55, 1.02, 0.045), Color(0.74, 0.79, 0.80), false)
			_box("FinishedFridgeHandle", Vector3(x + 0.58, 1.53, z - 0.82), Vector3(0.08, 0.72, 0.10), trim, false)
		4:
			# A complete floor lamp with base, upright and shade.
			_cylinder("FinishedLampBase", Vector3(x, 0.72, z), 0.62, 0.18, frame, false)
			_cylinder("FinishedLampPole", Vector3(x, 1.62, z), 0.075, 1.72, trim, false)
			_cylinder("FinishedLampShade", Vector3(x, 2.55, z), 0.62, 0.58, Color(0.92, 0.75, 0.38), false)
			_cylinder("FinishedLampBulb", Vector3(x, 2.28, z), 0.20, 0.22, Color(1.0, 0.94, 0.68), false)
	_label_3d("READY: " + _factory_row_product(row), Vector3(x, 1.08, z - 1.65), 0.12)

func _build_recycling_mega_factory() -> void:
	# Five independent production lines, each with three dedicated machines.
	var steel := Color(0.12, 0.18, 0.20)
	var dark_steel := Color(0.055, 0.085, 0.095)
	var teal := Color(0.08, 0.48, 0.48)
	var safety := Color(0.96, 0.66, 0.12)
	_box("MegaFactoryFoundation", Vector3(166.0, 0.08, 0.0), Vector3(72.0, 0.16, 72.0), Color(0.38, 0.41, 0.39), false)
	_box("MegaFactoryBackWall", Vector3(190.0, 5.0, 0.0), Vector3(0.7, 10.0, 66.0), steel, false)
	_box("MegaFactoryNorthWall", Vector3(166.0, 5.0, -33.0), Vector3(48.0, 10.0, 0.7), steel, false)
	_box("MegaFactorySouthWall", Vector3(166.0, 5.0, 33.0), Vector3(48.0, 10.0, 0.7), steel, false)
	_box("MegaFactoryRoof", Vector3(166.0, 10.2, 0.0), Vector3(49.0, 0.45, 66.5), dark_steel, false)
	_box("MegaFactoryRoofSkylight", Vector3(166.0, 10.46, 0.0), Vector3(34.0, 0.08, 3.2), Color(0.18, 0.52, 0.58), false)
	for x in range(145, 190, 9):
		_box("FactoryRoofRib", Vector3(float(x), 10.48, 0.0), Vector3(0.16, 0.12, 66.0), steel, false)
		_box("FactoryFrontColumn", Vector3(float(x), 4.8, 32.4), Vector3(0.65, 9.6, 0.65), dark_steel, false)
		_box("FactoryFrontSafetyStripe", Vector3(float(x), 0.18, 31.2), Vector3(1.2, 0.035, 0.16), safety, false)
	# Main waste intake conveyor and five-way distributor to the first machine in each line.
	_box("WasteFeedMainFrame", Vector3(137.0, 0.72, 0.0), Vector3(20.0, 0.32, 1.9), dark_steel, false)
	_box("WasteFeedMainBelt", Vector3(137.0, 0.94, 0.0), Vector3(19.7, 0.08, 1.55), Color(0.025, 0.045, 0.05), false)
	for side_z in [-0.95, 0.95]:
		_box("WasteFeedMainRail", Vector3(137.0, 1.16, side_z), Vector3(19.8, 0.35, 0.12), steel, false)
	_box("WasteFeedDistributorFrame", Vector3(147.0, 0.74, 0.0), Vector3(1.8, 0.32, 54.0), dark_steel, false)
	_box("WasteFeedDistributorBelt", Vector3(147.0, 0.96, 0.0), Vector3(1.45, 0.08, 53.5), Color(0.025, 0.045, 0.05), false)
	for side_x in [146.05, 147.95]:
		_box("WasteFeedDistributorRail", Vector3(side_x, 1.17, 0.0), Vector3(0.12, 0.35, 53.5), steel, false)
	for row in range(5):
		var feed_z := _factory_row_z(row)
		_box("WasteFeedBranchFrame", Vector3(149.0, 0.73, feed_z), Vector3(4.2, 0.30, 1.25), dark_steel, false)
		_box("WasteFeedBranchBelt", Vector3(149.0, 0.95, feed_z), Vector3(4.0, 0.08, 1.0), Color(0.025, 0.045, 0.05), false)
		_box("WasteFeedBranchRail", Vector3(149.0, 1.15, feed_z - 0.62), Vector3(4.0, 0.28, 0.08), steel, false)
	mega_factory_machine_labels.clear()
	for row in range(5):
		var z := _factory_row_z(row)
		# Physical divider and a clear product sign keep each production line separate.
		_box("FactoryRowDivider", Vector3(166.0, 0.22, z + 6.35), Vector3(44.0, 0.30, 0.16), safety, false)
		var product_label := Label3D.new()
		product_label.name = "FactoryProductLine%d" % row
		product_label.text = "LINE %d  •  %s" % [row + 1, _factory_row_product(row)]
		product_label.position = Vector3(166.0, 4.6, z - 4.6)
		product_label.font_size = 27
		product_label.pixel_size = 0.009
		product_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		product_label.modulate = Color(0.65, 1.0, 0.88)
		add_child(product_label)
		for machine_index in range(3):
			var x := 151.0 + float(machine_index) * 13.0
			var station_index := row * 3 + machine_index
			_box("MegaProcessBuildPad", Vector3(x, 0.16, z), Vector3(5.4, 0.22, 4.2), dark_steel, false)
			_box("MegaProcessPadAccent", Vector3(x, 0.29, z - 1.95), Vector3(4.8, 0.08, 0.12), safety, false)
			var build_label := Label3D.new()
			build_label.name = "MegaFactoryMachineLabel%d" % station_index
			build_label.text = "BUILT" if station_index < mega_factory_built_count else "BUILD\n%.0f ZC" % _mega_factory_machine_cost(station_index)
			build_label.position = Vector3(x, 0.42, z)
			build_label.font_size = 25
			build_label.pixel_size = 0.009
			build_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			build_label.modulate = Color(1.0, 0.88, 0.38)
			add_child(build_label)
			mega_factory_machine_labels.append(build_label)
			if station_index < mega_factory_built_count:
				_build_mega_factory_machine(station_index)
		for belt_x in [157.5, 170.5]:
			_box("MegaFactoryConveyorFrame", Vector3(belt_x, 0.82, z), Vector3(7.0, 0.28, 1.5), dark_steel, false)
			_box("MegaFactoryConveyorBelt", Vector3(belt_x, 1.02, z), Vector3(6.8, 0.08, 1.3), Color(0.035, 0.05, 0.055), false)
			for side_z in [z - 0.72, z + 0.72]:
				_box("MegaFactoryConveyorRail", Vector3(belt_x, 1.22, side_z), Vector3(6.8, 0.28, 0.09), steel, false)
		# Large loading doors sit just outside the entrance of each production row.
		_box("FactoryLoadingDoorFrame", Vector3(143.5, 3.2, z), Vector3(0.55, 6.4, 6.2), dark_steel, false)
		_box("FactoryLoadingDoorHeader", Vector3(143.4, 6.5, z), Vector3(0.8, 0.45, 6.5), safety, false)
		_label_3d("LOADING BAY %d" % (row + 1), Vector3(143.0, 7.0, z - 2.0), 0.13)
		# A finished usable product appears only after all three machines in this line are built.
		if mega_factory_built_count >= (row + 1) * 3:
			_build_factory_finished_product(row)
		else:
			_box("FactoryProductOutput", Vector3(181.5, 0.48, z), Vector3(3.0, 0.8, 2.8), Color(0.18, 0.27, 0.25), false)
			_label_3d("3 MACHINES REQUIRED", Vector3(181.5, 1.15, z - 1.55), 0.12)
	# Utility equipment is kept along the rear service strip, away from the five lines.
	for tank_index in range(3):
		var tx := 181.0 + float(tank_index) * 2.8
		_cylinder("RecyclingStorageSilo", Vector3(tx, 3.0, -31.0), 1.15, 5.8, Color(0.55, 0.62, 0.61), false)
		_cylinder("RecyclingSiloCap", Vector3(tx, 6.0, -31.0), 1.22, 0.35, teal, false)
		_cylinder("WaterTreatmentTank", Vector3(tx, 1.65, 30.0), 1.35, 3.2, Color(0.18, 0.38, 0.42), false)
	for stack_x in [184.0, 188.0]:
		_cylinder("FactoryExhaustStack", Vector3(stack_x, 8.2, 7.0), 0.52, 6.8, steel, false)
		_cylinder("FactoryStackRim", Vector3(stack_x, 11.65, 7.0), 0.68, 0.24, safety, false)
	_box("FactoryLoadingDock", Vector3(137.0, 0.22, 0.0), Vector3(13.0, 0.44, 30.0), Color(0.25, 0.29, 0.29), false)
	for z in [-24.0, -12.0, 0.0, 12.0, 24.0]:
		_box("FactoryTruckLane", Vector3(137.0, 0.47, z), Vector3(11.0, 0.035, 0.16), safety, false)
	_box("FactoryNameBoard", Vector3(166.0, 7.2, 33.45), Vector3(20.0, 2.4, 0.35), dark_steel, false)
	_label_3d("ZEKA RECYCLING\n5 INDEPENDENT PRODUCTION LINES", Vector3(166.0, 7.15, 33.25), 0.34)
	_box("FactoryEntranceCanopy", Vector3(137.0, 5.0, 0.0), Vector3(12.0, 0.35, 31.0), teal, false)
	for z in [-13.0, 13.0]:
		_box("FactoryCanopySupport", Vector3(132.0, 2.5, z), Vector3(0.35, 5.0, 0.35), dark_steel, false)
	_build_first_machine_feed_trigger()

func _build_first_machine_feed_trigger() -> void:
	var trigger := Area3D.new()
	trigger.name = "FirstMachineManualFeed"
	trigger.position = Vector3(151.0, 1.0, _factory_row_z(0))
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(5.8, 2.2, 4.6)
	shape.shape = box
	trigger.add_child(shape)
	trigger.body_entered.connect(_on_first_machine_feed_entered)
	add_child(trigger)
	_label_3d("ADD WASTE HERE", Vector3(151.0, 2.25, _factory_row_z(0) - 2.7), 0.20)

func _on_first_machine_feed_entered(body: Node3D) -> void:
	if body != player or mega_factory_built_count < 1 or carried <= 0:
		return
	var item_count := maxi(0, carried - carried_bulky)
	if item_count <= 0:
		return
	factory_row_input_stock[0] += item_count
	carried = 0
	carried_bulky = 0
	_update_ui()
	_save_game()
	_set_message("Loaded %d pieces directly into the first machine. Input: %d" % [item_count, factory_row_input_stock[0]])

func _create_factory_row_truck(row: int) -> Node3D:
	var truck := Node3D.new()
	truck.name = "FactoryProductTruck%d" % (row + 1)
	truck.position = Vector3(132.0, 0.0, _factory_row_z(row))
	_box_child(truck, "TruckCargoBed", Vector3(1.15, 1.35, 0.0), Vector3(4.0, 1.35, 3.0), Color(0.76, 0.79, 0.76))
	_box_child(truck, "TruckCab", Vector3(-2.15, 1.3, 0.0), Vector3(1.65, 1.65, 2.65), Color(0.82, 0.22, 0.12))
	_box_child(truck, "TruckWindshield", Vector3(-3.0, 1.62, 0.0), Vector3(0.06, 0.78, 1.55), Color(0.12, 0.23, 0.29))
	for wheel_x in [-2.45, 0.0, 2.45]:
		for wheel_z in [-1.45, 1.45]:
			var wheel := MeshInstance3D.new()
			var mesh := CylinderMesh.new()
			mesh.top_radius = 0.46
			mesh.bottom_radius = 0.46
			mesh.height = 0.22
			wheel.mesh = mesh
			wheel.position = Vector3(wheel_x, 0.48, wheel_z)
			wheel.rotation_degrees.x = 90.0
			wheel.material_override = _mat(Color(0.035, 0.04, 0.045))
			truck.add_child(wheel)
	var sign := Label3D.new()
	sign.text = _factory_row_product(row)
	sign.position = Vector3(0.0, 2.25, 1.52)
	sign.font_size = 18
	sign.pixel_size = 0.012
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sign.modulate = Color(0.12, 0.20, 0.18)
	truck.add_child(sign)
	add_child(truck)
	return truck

func _process_factory_row_shipping(delta: float) -> void:
	if mega_factory_built_count < 1 or factory_shipping_busy:
		return
	factory_shipping_timer += delta
	if factory_shipping_timer < 30.0:
		return
	factory_shipping_timer = 0.0
	var available_rows: Array[int] = []
	for row in range(5):
		if mega_factory_built_count >= row * 3 + 1 and factory_row_product_stock[row] >= 3:
			available_rows.append(row)
	if available_rows.is_empty():
		return
	var selected_row := -1
	for offset in range(5):
		var candidate := (factory_shipping_row + offset) % 5
		if available_rows.has(candidate):
			selected_row = candidate
			break
	if selected_row < 0:
		return
	factory_shipping_row = (selected_row + 1) % 5
	_dispatch_factory_row_truck(selected_row)

func _dispatch_factory_row_truck(row: int) -> void:
	factory_shipping_busy = true
	var truck := _create_factory_row_truck(row)
	var z := _factory_row_z(row)
	# Open the two large sliding door leaves before the truck enters.
	var door_left := _box("FactoryDoorMovingLeft", Vector3(143.15, 3.0, z - 1.35), Vector3(0.24, 5.7, 2.7), Color(0.08, 0.48, 0.48), false)
	var door_right := _box("FactoryDoorMovingRight", Vector3(143.15, 3.0, z + 1.35), Vector3(0.24, 5.7, 2.7), Color(0.08, 0.48, 0.48), false)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(door_left, "position:z", z - 3.0, 0.55)
	tween.parallel().tween_property(door_right, "position:z", z + 3.0, 0.55)
	tween.tween_property(truck, "position:x", 139.0, 2.0)
	for package_index in range(3):
		var product := Node3D.new()
		product.name = "LoadedFactoryProduct"
		product.position = truck.position + Vector3(1.0, 2.2 + float(package_index) * 0.02, float(package_index - 1) * 0.82)
		var body := MeshInstance3D.new()
		var body_mesh := BoxMesh.new()
		body_mesh.size = Vector3(0.82, 0.72, 0.72)
		body.mesh = body_mesh
		body.material_override = _mat([Color(0.18, 0.36, 0.56), Color(0.52, 0.34, 0.18), Color(0.72, 0.74, 0.76), Color(0.30, 0.48, 0.38), Color(0.88, 0.72, 0.32)][row])
		product.add_child(body)
		add_child(product)
		tween.tween_property(product, "position", truck.position + Vector3(1.0, 2.35, float(package_index - 1) * 0.82), 0.35)
		tween.tween_callback(func(): product.reparent(truck))
	tween.tween_interval(0.5)
	tween.tween_property(truck, "position:x", 124.0, 2.4)
	tween.tween_callback(func():
		truck.queue_free()
		door_left.queue_free()
		door_right.queue_free()
		factory_shipping_busy = false
		factory_row_product_stock[row] = maxi(0, factory_row_product_stock[row] - 3)
		var revenue := _factory_row_truck_revenue(row)
		money += revenue
		_update_ui()
		_save_game()
		_set_message("%s truck delivered 3 products. Sale +%.0f ZC!" % [_factory_row_product(row), revenue])
	)

func _mega_factory_machine_cost(index: int) -> float:
	var costs := [25.0, 35.0, 50.0, 60.0, 80.0, 100.0, 120.0, 140.0, 165.0, 190.0, 225.0, 260.0, 300.0, 350.0, 400.0]
	return costs[clampi(index, 0, costs.size() - 1)]

func _build_mega_factory_machine(index: int) -> void:
	var row := int(index / 3)
	var column := index % 3
	var x := 151.0 + float(column) * 13.0
	var z := _factory_row_z(row)
	var accents := [Color(0.08, 0.48, 0.48), Color(0.18, 0.58, 0.36), Color(0.96, 0.66, 0.12)]
	var accent: Color = accents[column]
	var steel := Color(0.12, 0.18, 0.20)
	var dark_steel := Color(0.055, 0.085, 0.095)
	_box("MegaProcessMachineBase%d" % index, Vector3(x, 0.62, z), Vector3(5.0, 0.72, 3.8), dark_steel, false)
	_box("MegaProcessMachineBody%d" % index, Vector3(x, 2.15, z), Vector3(4.3, 2.7, 3.4), steel, false)
	_box("MegaProcessMachineTop%d" % index, Vector3(x, 3.58, z), Vector3(4.7, 0.18, 3.8), accent.darkened(0.2), false)
	_box("MegaProcessMachineWindow%d" % index, Vector3(x, 2.25, z - 1.73), Vector3(1.9, 0.8, 0.06), accent, false)
	_box("MegaProcessMachineControl%d" % index, Vector3(x + 1.65, 1.8, z - 1.78), Vector3(0.58, 0.9, 0.12), dark_steel, false)
	for wheel_x in [x - 1.5, x + 1.5]:
		_cylinder("MegaProcessMachineDrum%d" % index, Vector3(wheel_x, 0.98, z + 2.0), 0.38, 0.22, accent, true)
	_label_3d(["PREPARATION", "PROCESSING", "FINISHING"][column], Vector3(x, 4.0, z - 2.0), 0.15)

func _process_mega_factory_build(delta: float) -> void:
	if payment_active or mega_factory_built_count >= 15 or not is_instance_valid(player):
		return
	var index := mega_factory_built_count
	var row := int(index / 3)
	var column := index % 3
	var target := Vector3(151.0 + float(column) * 13.0, 0.0, _factory_row_z(row))
	var player_flat := Vector2(player.global_position.x, player.global_position.z)
	if player_flat.distance_to(Vector2(target.x, target.z)) > 2.8:
		return
	var cost := _mega_factory_machine_cost(index)
	var payment := minf(money, minf(delta * _spending_speed_multiplier(), cost - mega_factory_build_paid))
	if payment > 0.0:
		money -= payment
		mega_factory_build_paid += payment
		_update_ui()
		mega_factory_build_timer += delta
		if mega_factory_build_timer >= 1.0:
			mega_factory_build_timer = 0.0
			_save_game()
		if index < mega_factory_machine_labels.size() and is_instance_valid(mega_factory_machine_labels[index]):
			mega_factory_machine_labels[index].text = "BUILDING\n%.0f / %.0f ZC" % [mega_factory_build_paid, cost]
	if mega_factory_build_paid >= cost - 0.001:
		_build_mega_factory_machine(index)
		mega_factory_built_count += 1
		mega_factory_build_paid = 0.0
		mega_factory_build_timer = 0.0
		if index < mega_factory_machine_labels.size() and is_instance_valid(mega_factory_machine_labels[index]):
			mega_factory_machine_labels[index].text = "BUILT"
		if mega_factory_built_count % 3 == 0:
			_build_factory_finished_product(int(index / 3))
			_set_message("Production line complete! %s is now being manufactured." % _factory_row_product(int(index / 3)))
		_update_ui()
		_save_game()
		if mega_factory_built_count < 15:
			_set_message("Machine %d / 15 installed! Move to the next marked pad." % mega_factory_built_count)
		else:
			_set_message("ALL 15 FACTORY MACHINES INSTALLED!")


func _build_city_dump_area() -> void:
	# Waste storage is purchased and built beside the factory intake.
	_box("FactoryWasteTankBuildPad", Vector3(124.8, 0.035, 10.5), Vector3(6.0, 0.07, 3.6), Color(0.12, 0.18, 0.18), false)
	_box("FactoryWasteTankBuildBorder", Vector3(124.8, 0.08, 10.5), Vector3(5.6, 0.025, 3.2), Color(0.92, 0.64, 0.13), false)
	waste_tank_build_label = Label3D.new()
	waste_tank_build_label.name = "WasteTankBuildLabel"
	waste_tank_build_label.text = "BUILD WASTE STORAGE\n120 ZC"
	waste_tank_build_label.position = Vector3(124.8, 1.45, 10.5)
	waste_tank_build_label.font_size = 25
	waste_tank_build_label.pixel_size = 0.009
	waste_tank_build_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	waste_tank_build_label.modulate = Color(1.0, 0.83, 0.34)
	add_child(waste_tank_build_label)
	var trigger := Area3D.new()
	trigger.name = "BuildFactoryWasteTank"
	trigger.position = Vector3(124.8, 0.9, 10.5)
	var trigger_shape := CollisionShape3D.new()
	var trigger_box := BoxShape3D.new()
	trigger_box.size = Vector3(5.8, 2.0, 3.4)
	trigger_shape.shape = trigger_box
	trigger.add_child(trigger_shape)
	trigger.body_entered.connect(_on_waste_tank_build_entered)
	add_child(trigger)
	if waste_tank_built:
		_build_waste_tank_structure()
		waste_tank_build_label.visible = false
	# No city garbage trucks are spawned; the player supplies the tank.

func _on_waste_tank_build_entered(body: Node3D) -> void:
	if body != player:
		return
	if waste_tank_built:
		if carried <= 0:
			_set_message("Collect waste first, then return here to load the factory tank.")
			return
		var item_count := maxi(0, carried - carried_bulky)
		var accepted := mini(item_count, WASTE_TANK_CAPACITY - waste_tank_inventory)
		if accepted <= 0:
			_set_message("Factory tank is full (%d / %d)." % [waste_tank_inventory, WASTE_TANK_CAPACITY])
			return
		waste_tank_inventory += accepted
		carried = 0
		carried_bulky = 0
		_update_ui()
		_save_game()
		_set_message("Loaded %d pieces into factory storage. Tank: %d / %d" % [accepted, waste_tank_inventory, WASTE_TANK_CAPACITY])
		return
	const BUILD_COST := 120.0
	if money < BUILD_COST:
		_set_message("Build the factory waste tank: 120 ZC required.")
		return
	money -= BUILD_COST
	waste_tank_built = true
	_build_waste_tank_structure()
	if is_instance_valid(waste_tank_build_label):
		waste_tank_build_label.visible = false
	_update_ui()
	_save_game()
	_set_message("Waste storage built! Return here with collected waste to feed the conveyor.")

func _build_waste_tank_structure() -> void:
	if is_instance_valid(waste_tank_root):
		return
	waste_tank_root = Node3D.new()
	waste_tank_root.name = "FactoryWasteStorageTank"
	waste_tank_root.position = Vector3(0.0, 0.0, 22.5)
	add_child(waste_tank_root)
	# Reinforced steel bunker relocated intact to the factory entrance.
	_box("CityDumpApproachApron", Vector3(-7.0, 0.025, -18.0), Vector3(5.0, 0.05, 8.0), Color(0.22, 0.25, 0.25), false)
	_box("CityDumpConcrete", Vector3(-4.8, 0.035, -22.5), Vector3(7.2, 0.07, 7.0), Color(0.25, 0.28, 0.27), false)
	_box("CityDumpMarking", Vector3(-4.8, 0.078, -22.5), Vector3(6.7, 0.025, 6.5), Color(0.31, 0.34, 0.32), false)
	for z in [-24.8, -23.4, -22.0, -20.6]:
		_box("DumpBunkerSideRibL", Vector3(-8.16, 1.0, z), Vector3(0.10, 1.9, 0.16), Color(0.32, 0.37, 0.37), false)
		_box("DumpBunkerSideRibR", Vector3(-1.44, 1.0, z), Vector3(0.10, 1.9, 0.16), Color(0.32, 0.37, 0.37), false)
	_box("DumpBunkerTopRailBack", Vector3(-4.8, 2.18, -25.72), Vector3(7.45, 0.18, 0.28), Color(0.34, 0.39, 0.39), false)
	_box("DumpBunkerTopRailLeft", Vector3(-8.18, 2.18, -22.5), Vector3(0.28, 0.18, 6.5), Color(0.34, 0.39, 0.39), false)
	_box("DumpBunkerTopRailRight", Vector3(-1.42, 2.18, -22.5), Vector3(0.28, 0.18, 6.5), Color(0.34, 0.39, 0.39), false)
	_box("DumpCompactorHousing", Vector3(-4.8, 2.55, -26.05), Vector3(3.0, 0.62, 0.55), Color(0.20, 0.25, 0.25), false)
	_box("DumpCompactorServicePanel", Vector3(-4.8, 2.58, -25.76), Vector3(1.15, 0.34, 0.035), Color(0.48, 0.39, 0.22), false)
	_box("CityDumpBackWall", Vector3(-4.8, 1.15, -25.85), Vector3(7.2, 2.3, 0.22), Color(0.27, 0.31, 0.31), true)
	_box("CityDumpLeftWall", Vector3(-8.25, 1.0, -22.5), Vector3(0.22, 2.0, 6.5), Color(0.27, 0.31, 0.31), true)
	_box("CityDumpRightWall", Vector3(-1.35, 1.0, -22.5), Vector3(0.22, 2.0, 6.5), Color(0.27, 0.31, 0.31), true)
	for z in [-25.0, -22.5, -20.0]:
		_box("DepotConcreteJoint", Vector3(-4.8, 0.082, z), Vector3(6.8, 0.012, 0.035), Color(0.16, 0.19, 0.19), false)
	_box("DepotDrainChannel", Vector3(-4.8, 0.10, -19.18), Vector3(6.3, 0.08, 0.22), Color(0.10, 0.13, 0.13), false)
	for i in range(12):
		_box("DepotDrainSlot", Vector3(-7.65 + float(i) * 0.52, 0.145, -19.18), Vector3(0.30, 0.018, 0.055), Color(0.48, 0.51, 0.49), false)
	_box("CityDumpHazardStripe", Vector3(-4.8, 0.10, -19.0), Vector3(6.9, 0.08, 0.14), Color(0.78, 0.59, 0.16), false)
	_box("CityDumpSignPostL", Vector3(-6.65, 2.0, -25.66), Vector3(0.09, 2.0, 0.09), Color(0.13, 0.17, 0.18), false)
	_box("CityDumpSignPostR", Vector3(-2.95, 2.0, -25.66), Vector3(0.09, 2.0, 0.09), Color(0.13, 0.17, 0.18), false)
	_box("CityDumpSign", Vector3(-4.8, 2.55, -25.66), Vector3(3.8, 0.72, 0.12), Color(0.10, 0.17, 0.17), false)
	var tank_sign := Label3D.new()
	tank_sign.text = "FACTORY WASTE STORAGE"
	tank_sign.position = Vector3(-4.8, 2.55, -25.56)
	tank_sign.font_size = 20
	tank_sign.pixel_size = 0.009
	tank_sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	waste_tank_root.add_child(tank_sign)
	for x in [-8.8, -0.8]:
		for z in [-19.0, -24.5]:
			_cylinder("DepotSafetyBollard", Vector3(x, 0.48, z), 0.13, 0.96, Color(0.62, 0.48, 0.20), true)
	for x in [-7.85, -1.75]:
		_box("DepotFloodlightHousing", Vector3(x, 2.05, -25.48), Vector3(0.72, 0.28, 0.22), Color(0.16, 0.21, 0.22), false)
		_box("DepotFloodlightLens", Vector3(x, 1.98, -25.34), Vector3(0.48, 0.08, 0.035), Color(0.92, 0.82, 0.55), false)
		var lamp := OmniLight3D.new()
		lamp.name = "DepotFloodlight"
		lamp.position = Vector3(x, 1.85, -25.15)
		lamp.light_color = Color(0.82, 0.86, 0.82)
		lamp.light_energy = 0.22
		lamp.omni_range = 5.0
		waste_tank_root.add_child(lamp)
	_box("DepotElectricalCabinet", Vector3(-1.75, 0.95, -24.6), Vector3(0.48, 1.6, 0.34), Color(0.34, 0.39, 0.38), true)
	_box("DepotCabinetDoor", Vector3(-1.75, 0.95, -24.41), Vector3(0.38, 1.42, 0.035), Color(0.24, 0.29, 0.29), false)
	# Move all geometry helpers, which create at scene root, under the tank transform.
	var tank_names := ["CityDumpApproachApron", "CityDumpConcrete", "CityDumpMarking", "DumpBunkerSideRibL", "DumpBunkerSideRibR", "DumpBunkerTopRailBack", "DumpBunkerTopRailLeft", "DumpBunkerTopRailRight", "DumpCompactorHousing", "DumpCompactorServicePanel", "CityDumpBackWall", "CityDumpLeftWall", "CityDumpRightWall", "DepotConcreteJoint", "DepotDrainChannel", "DepotDrainSlot", "CityDumpHazardStripe", "CityDumpSignPostL", "CityDumpSignPostR", "CityDumpSign", "DepotSafetyBollard", "DepotFloodlightHousing", "DepotFloodlightLens", "DepotElectricalCabinet", "DepotCabinetDoor"]
	for child in get_children():
		if child is Node3D and tank_names.has(child.name):
			remove_child(child)
			waste_tank_root.add_child(child)
	for child in waste_tank_root.get_children():
		if child is Node3D:
			child.position.x += 129.6

func _create_city_truck(index: int) -> Node3D:
	var truck := Node3D.new()
	truck.name = "MunicipalGarbageTruck%d" % (index + 1)
	truck.position = city_truck_start
	truck.visible = false
	truck.set_meta("phase", 0)
	truck.set_meta("timer", maxf(0.0, _city_truck_interval() - float(index) * 12.0))
	truck.set_meta("queue_position", Vector3(-7.2, 0.0, -15.0 + float(index) * 3.8))
	truck.set_meta("load", _city_truck_load())
	truck.set_meta("reserved", false)
	add_child(truck)
	# Rounded chassis and sculpted cab replace the old block-like toy silhouette.
	_city_truck_sphere(truck, "TruckChassis", Vector3(0, 0.72, 0.0), Vector3(1.02, 0.19, 1.78), Color(0.10, 0.13, 0.14))
	_city_truck_sphere(truck, "TruckCabLower", Vector3(0, 1.18, -1.12), Vector3(0.91, 0.48, 0.70), Color(0.76, 0.56, 0.29))
	_city_truck_sphere(truck, "TruckCabRoof", Vector3(0, 1.72, -1.17), Vector3(0.88, 0.43, 0.66), Color(0.82, 0.64, 0.36))
	_city_truck_sphere(truck, "TruckHood", Vector3(0, 1.08, -1.73), Vector3(0.88, 0.30, 0.42), Color(0.72, 0.51, 0.27))
	_city_truck_sphere(truck, "TruckWindshield", Vector3(0, 1.53, -1.72), Vector3(0.70, 0.29, 0.035), Color(0.10, 0.22, 0.27))
	_city_truck_add_driver(truck)
	_city_truck_box(truck, "TruckGrille", Vector3(0, 0.96, -2.08), Vector3(0.78, 0.30, 0.045), Color(0.16, 0.20, 0.21))
	# Open-top cargo bed: a floor and four raised sides keep collected litter visibly inside.
	_city_truck_box(truck, "TruckCargoFloor", Vector3(0, 0.88, 0.72), Vector3(1.82, 0.12, 1.78), Color(0.16, 0.25, 0.22))
	_city_truck_box(truck, "TruckCargoSideLeft", Vector3(-0.91, 1.34, 0.72), Vector3(0.10, 0.92, 1.82), Color(0.20, 0.34, 0.29))
	_city_truck_box(truck, "TruckCargoSideRight", Vector3(0.91, 1.34, 0.72), Vector3(0.10, 0.92, 1.82), Color(0.20, 0.34, 0.29))
	_city_truck_box(truck, "TruckCargoFrontWall", Vector3(0, 1.34, -0.18), Vector3(1.82, 0.92, 0.10), Color(0.20, 0.34, 0.29))
	_city_truck_box(truck, "TruckCargoRearWall", Vector3(0, 1.34, 1.62), Vector3(1.82, 0.92, 0.10), Color(0.20, 0.34, 0.29))
	var wheels: Array[Node3D] = []
	for side in [-1.0, 1.0]:
		for wheel_z in [-1.18, 1.12]:
			# Each wheel spins around the axle (local X), while the tire itself
			# is a solid cylinder whose axis also runs across the truck.
			var wheel_pivot := Node3D.new()
			wheel_pivot.name = "TruckWheelPivot"
			wheel_pivot.position = Vector3(side * 1.04, 0.42, wheel_z)
			truck.add_child(wheel_pivot)

			var tire := MeshInstance3D.new()
			tire.name = "TruckRubberTire"
			var tire_mesh := CylinderMesh.new()
			tire_mesh.top_radius = 0.40
			tire_mesh.bottom_radius = 0.40
			tire_mesh.height = 0.34
			tire_mesh.radial_segments = 32
			tire.mesh = tire_mesh
			tire.rotation_degrees.z = 90.0
			tire.material_override = _mat(Color(0.025, 0.031, 0.034))
			wheel_pivot.add_child(tire)

			# Deep sidewall rim, recessed into the tire so it cannot float outside it.
			var rim := MeshInstance3D.new()
			rim.name = "TruckWheelRim"
			var rim_mesh := CylinderMesh.new()
			rim_mesh.top_radius = 0.255
			rim_mesh.bottom_radius = 0.255
			rim_mesh.height = 0.035
			rim_mesh.radial_segments = 32
			rim.mesh = rim_mesh
			rim.position.x = side * 0.174
			rim.rotation_degrees.z = 90.0
			rim.material_override = _mat(Color(0.29, 0.34, 0.35))
			wheel_pivot.add_child(rim)

			var hub := MeshInstance3D.new()
			hub.name = "TruckWheelHub"
			var hub_mesh := CylinderMesh.new()
			hub_mesh.top_radius = 0.12
			hub_mesh.bottom_radius = 0.12
			hub_mesh.height = 0.045
			hub_mesh.radial_segments = 24
			hub.mesh = hub_mesh
			hub.position.x = side * 0.185
			hub.rotation_degrees.z = 90.0
			hub.material_override = _mat(Color(0.68, 0.71, 0.68))
			wheel_pivot.add_child(hub)

			wheels.append(wheel_pivot)
	truck.set_meta("wheels", wheels)
	_city_truck_box(truck, "TruckLogo", Vector3(0, 1.45, 1.68), Vector3(0.9, 0.32, 0.035), Color(0.72, 0.66, 0.48))
	# Rounded industrial details break up the toy-like rectangular silhouette.
	_city_truck_sphere(truck, "FrontSteelBumper", Vector3(0, 0.69, -2.10), Vector3(1.00, 0.10, 0.10), Color(0.28, 0.32, 0.33))
	_city_truck_sphere(truck, "CabRoofHighlight", Vector3(0, 2.02, -1.15), Vector3(0.72, 0.045, 0.52), Color(0.91, 0.73, 0.43))
	_city_truck_box(truck, "LeftMirrorArm", Vector3(-1.02, 1.48, -1.35), Vector3(0.28, 0.07, 0.08), Color(0.18, 0.21, 0.21))
	_city_truck_box(truck, "RightMirrorArm", Vector3(1.02, 1.48, -1.35), Vector3(0.28, 0.07, 0.08), Color(0.18, 0.21, 0.21))
	for side in [-1.0, 1.0]:
		_city_truck_box(truck, "CargoSideRib", Vector3(side * 0.985, 1.38, 0.72), Vector3(0.07, 0.92, 1.55), Color(0.12, 0.23, 0.20))
		_city_truck_box(truck, "CabStep", Vector3(side * 0.91, 0.73, -0.72), Vector3(0.22, 0.12, 0.72), Color(0.34, 0.38, 0.37))
		for wheel_z in [-1.18, 1.12]:
			var fender := MeshInstance3D.new()
			fender.name = "TruckWheelFender"
			var fender_mesh := TorusMesh.new()
			fender_mesh.inner_radius = 0.32
			fender_mesh.outer_radius = 0.46
			fender_mesh.rings = 12
			fender_mesh.ring_segments = 20
			fender.mesh = fender_mesh
			fender.position = Vector3(side * 1.045, 0.43, wheel_z)
			# TorusMesh is oriented around local Y by default. Rotate it onto
			# the wheel plane (normal along X), not around Y where it lies flat.
			fender.rotation_degrees.z = 90.0
			fender.material_override = _mat(Color(0.22, 0.27, 0.27))
			truck.add_child(fender)
	for x in [-0.68, 0.68]:
		var lamp := MeshInstance3D.new()
		lamp.name = "TruckHeadlight"
		var lamp_mesh := SphereMesh.new()
		lamp_mesh.radius = 0.13
		lamp_mesh.height = 0.20
		lamp.mesh = lamp_mesh
		lamp.position = Vector3(x, 1.02, -2.12)
		lamp.material_override = _mat(Color(0.96, 0.84, 0.48))
		truck.add_child(lamp)
	return truck

func _city_truck_sphere(parent: Node3D, node_name: String, pos: Vector3, dimensions: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	mesh.name = node_name
	var shape := SphereMesh.new()
	shape.radial_segments = 32
	shape.rings = 16
	mesh.mesh = shape
	mesh.position = pos
	mesh.scale = dimensions
	var material := _mat(color)
	if node_name == "TruckWindshield":
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(color.r, color.g, color.b, 0.42)
	mesh.material_override = material
	parent.add_child(mesh)

func _city_truck_add_driver(truck: Node3D) -> void:
	# A seated municipal driver, visible through the slightly tinted windshield.
	_city_truck_sphere(truck, "TruckDriverTorso", Vector3(0.0, 1.34, -1.28), Vector3(0.34, 0.43, 0.25), Color(0.16, 0.29, 0.48))
	_city_truck_sphere(truck, "TruckDriverHead", Vector3(0.0, 1.76, -1.34), Vector3(0.25, 0.29, 0.24), Color(0.72, 0.51, 0.36))
	_city_truck_sphere(truck, "TruckDriverHair", Vector3(0.0, 1.91, -1.33), Vector3(0.26, 0.13, 0.25), Color(0.12, 0.10, 0.085))
	_city_truck_sphere(truck, "TruckDriverLeftArm", Vector3(-0.27, 1.39, -1.48), Vector3(0.13, 0.30, 0.13), Color(0.16, 0.29, 0.48))
	_city_truck_sphere(truck, "TruckDriverRightArm", Vector3(0.27, 1.39, -1.48), Vector3(0.13, 0.30, 0.13), Color(0.16, 0.29, 0.48))
	_city_truck_sphere(truck, "TruckDriverLeftHand", Vector3(-0.22, 1.30, -1.62), Vector3(0.10, 0.10, 0.09), Color(0.72, 0.51, 0.36))
	_city_truck_sphere(truck, "TruckDriverRightHand", Vector3(0.22, 1.30, -1.62), Vector3(0.10, 0.10, 0.09), Color(0.72, 0.51, 0.36))
	var steering_wheel := MeshInstance3D.new()
	steering_wheel.name = "TruckSteeringWheel"
	var steering_mesh := TorusMesh.new()
	steering_mesh.inner_radius = 0.16
	steering_mesh.outer_radius = 0.205
	steering_mesh.rings = 10
	steering_mesh.ring_segments = 20
	steering_wheel.mesh = steering_mesh
	steering_wheel.position = Vector3(0.0, 1.31, -1.64)
	steering_wheel.rotation_degrees.x = 90.0
	steering_wheel.material_override = _mat(Color(0.055, 0.065, 0.07))
	truck.add_child(steering_wheel)

func _city_truck_box(parent: Node3D, node_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	mesh.name = node_name
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.position = pos
	mesh.material_override = _mat(color)
	parent.add_child(mesh)

func _refresh_city_truck_fleet() -> void:
	_reset_city_truck_fleet()

func _reset_city_truck_fleet() -> void:
	# Municipal garbage collection is retired; only product-delivery trucks remain.
	city_trash_reserved = 0
	for truck in city_trucks:
		if is_instance_valid(truck):
			truck.queue_free()
	city_trucks.clear()
	city_truck = null
	city_truck_phase = 0
	city_truck_timer = 0.0

func _process_city_truck(_delta: float) -> void:
	# Municipal garbage collection is retired.
	return
	for truck_index in range(city_trucks.size()):
		var truck := city_trucks[truck_index]
		if not is_instance_valid(truck):
			continue
		var phase := int(truck.get_meta("phase", 0))
		var timer := float(truck.get_meta("timer", 0.0)) + delta
		truck.set_meta("timer", timer)
		var queue_point: Vector3 = truck.get_meta("queue_position", Vector3(-7.2, 0.0, -15.0))
		var target := truck.position
		match phase:
			0:
				# Do not dispatch or reveal a truck until the depot can fit its
				# entire load. Reserve that space before it starts driving so
				# multiple fleet trucks can never overbook the bunker.
				var next_load := _city_truck_load()
				var free_capacity := _city_dump_capacity() - _city_dump_trash_count() - city_trash_reserved
				if timer >= _city_truck_interval() and free_capacity >= next_load:
					city_trash_reserved += next_load
					truck.set_meta("reserved", true)
					truck.visible = true
					truck.set_meta("load", next_load)
					truck.set_meta("phase", 1)
					truck.set_meta("timer", 0.0)
					phase = 1
			1:
				target = queue_point
				if _move_city_truck(truck, target, delta):
					truck.set_meta("phase", 2)
					truck.set_meta("timer", 0.0)
			2:
				# Single-truck unloading bay: keep every other truck at its own
				# queue slot until the truck in the bunker has fully driven out.
				var dump_bay_occupied := false
				for other_index in range(city_trucks.size()):
					if other_index == truck_index:
						continue
					var other_truck := city_trucks[other_index]
					if not is_instance_valid(other_truck):
						continue
					var other_phase := int(other_truck.get_meta("phase", 0))
					if bool(other_truck.visible) and other_phase in [3, 4, 5]:
						dump_bay_occupied = true
						break
				if bool(truck.get_meta("reserved", false)) and not dump_bay_occupied:
					truck.set_meta("phase", 3)
					truck.set_meta("timer", 0.0)
			3:
				target = city_truck_dump
				if _move_city_truck(truck, target, delta):
					truck.set_meta("phase", 4)
					truck.set_meta("timer", 0.0)
			4:
				if timer >= 2.5:
					var delivered := _spawn_city_trash(int(truck.get_meta("load", _city_truck_load())))
					city_trash_reserved = maxi(0, city_trash_reserved - int(truck.get_meta("load", _city_truck_load())))
					truck.set_meta("reserved", false)
					_set_message("City truck unloaded %d bags. Depot: %d / %d" % [delivered, _city_dump_trash_count(), _city_dump_capacity()])
					truck.set_meta("phase", 5)
					truck.set_meta("timer", 0.0)
			5:
				target = queue_point
				if _move_city_truck(truck, target, delta):
					truck.set_meta("phase", 6)
			6:
				target = city_truck_start
				if _move_city_truck(truck, target, delta):
					truck.visible = false
					truck.set_meta("phase", 0)
					truck.set_meta("timer", 0.0)
		# Roll the complete wheel assembly around its axle while the truck is moving.
		# The axle is the truck's local X axis; update the pivot's local rotation
		# directly so the tire, rim, hub and lug nuts all rotate as one assembly.
		var wheels: Array = truck.get_meta("wheels", [])
		if phase in [1, 3, 5, 6] and truck.visible:
			var wheel_roll := delta * 7.5
			if phase in [5, 6]:
				wheel_roll = -wheel_roll
			for wheel in wheels:
				if is_instance_valid(wheel):
					wheel.rotation.x = wrapf(wheel.rotation.x + wheel_roll, -PI, PI)

func _move_city_truck(truck: Node3D, target: Vector3, delta: float, move_speed: float = 3.8) -> bool:
	var direction := target - truck.position
	direction.y = 0.0
	if direction.length() > 0.06:
		var desired_yaw := atan2(-direction.x, -direction.z)
		truck.rotation.y = lerp_angle(truck.rotation.y, desired_yaw, minf(1.0, delta * 4.5))
	truck.position = truck.position.move_toward(target, delta * move_speed)
	return truck.position.distance_to(target) < 0.07

func _city_truck_interval() -> float:
	var intervals := [300.0, 240.0, 180.0, 120.0]
	return intervals[clampi(city_truck_upgrade_level, 0, 3)]

func _city_truck_load() -> int:
	# Every municipal truck delivers a full 500-piece load.
	return 500

func _city_dump_capacity() -> int:
	# The bunker holds exactly three full municipal truckloads.
	return _city_truck_load() * 3

func _city_dump_trash_count() -> int:
	var count := 0
	for item in trash_nodes:
		if is_instance_valid(item):
			var p := item.global_position
			if p.x >= 121.9 and p.x <= 127.5 and p.z >= -3.2 and p.z <= 3.2:
				count += 1
	return count

func _apply_rare_drop(item: Node3D, rng: RandomNumberGenerator) -> void:
	var chances := _rare_drop_chances()
	var roll := rng.randf()
	if chances.y > 0.0 and roll < chances.y:
		item.set_meta("rare_type", "gold")
	elif chances.x > 0.0 and roll < chances.x + chances.y:
		item.set_meta("rare_type", "silver")

func _spawn_city_trash(amount: int) -> int:
	var spawned := 0
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var allowed := mini(amount, maxi(0, 1000 - _count_regular_trash()))
	for i in range(allowed):
		var item := Node3D.new()
		item.set_script(TRASH_SCRIPT)
		item.position = Vector3(rng.randf_range(122.05, 127.55), 0.05, rng.randf_range(-2.75, 2.65))
		add_child(item)
		trash_nodes.append(item)
		spawned += 1
	return spawned

func _spawn_final_cleanup_trash() -> void:
	# The landfill is spread over the full cleanup yard, with dense irregular
	# piles and loose debris between them. Each pickup is a visible, detailed item.
	var remaining_units := maxi(0, FINAL_ZONE_TARGET - final_zone_cleaned)
	var remaining_objects := ceili(float(remaining_units) / 100.0)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_build_final_landfill_debris(remaining_units, rng)
	for i in range(remaining_objects):
		var item := Node3D.new()
		item.set_script(TRASH_SCRIPT)
		item.set_meta("final_cleanup_units", 1)
		item.position = _random_final_landfill_position(rng)
		add_child(item)
		trash_nodes.append(item)


func _random_final_landfill_position(rng: RandomNumberGenerator) -> Vector3:
	# Spread endgame litter across every unlocked district, not only the far landfill.
	var point := Vector2.ZERO
	if rng.randf() < 0.78:
		var center: Vector2 = FINAL_LANDFILL_CLUSTERS[rng.randi_range(0, FINAL_LANDFILL_CLUSTERS.size() - 1)]
		point = center + Vector2(rng.randfn(0.0, 4.2), rng.randfn(0.0, 3.6))
	else:
		point = Vector2(rng.randf_range(-11.0, 203.0), rng.randf_range(-29.0, 29.0))
	point.x = clampf(point.x, -11.5, 203.0)
	point.y = clampf(point.y, -29.0, 29.0)
	var nearest_cluster_distance := 1000.0
	for center in FINAL_LANDFILL_CLUSTERS:
		nearest_cluster_distance = minf(nearest_cluster_distance, point.distance_to(center))
	var small_pile_height := maxf(0.0, 1.0 - nearest_cluster_distance / 6.5) * 1.25
	return Vector3(point.x, 0.30 + small_pile_height + rng.randf_range(0.0, 0.16), point.y)


func _build_final_landfill_debris(remaining_units: int, rng: RandomNumberGenerator) -> void:
	if remaining_units <= 0:
		return
	var debris_meshes: Array[Mesh] = []
	var box := BoxMesh.new()
	box.size = Vector3(0.62, 0.20, 0.46)
	debris_meshes.append(box)
	var bottle := CylinderMesh.new()
	bottle.top_radius = 0.13
	bottle.bottom_radius = 0.18
	bottle.height = 0.52
	bottle.radial_segments = 8
	debris_meshes.append(bottle)
	var scrap := SphereMesh.new()
	scrap.radius = 0.25
	scrap.height = 0.34
	scrap.radial_segments = 8
	scrap.rings = 5
	debris_meshes.append(scrap)
	var tire := TorusMesh.new()
	tire.inner_radius = 0.13
	tire.outer_radius = 0.29
	tire.rings = 8
	tire.ring_segments = 12
	debris_meshes.append(tire)
	var debris_colors := [
		Color(0.48, 0.34, 0.22),
		Color(0.18, 0.43, 0.39),
		Color(0.57, 0.59, 0.53),
		Color(0.075, 0.085, 0.08)
	]
	var debris_names := ["LandfillCardboard", "LandfillBottles", "LandfillScrap", "LandfillTires"]
	var base_count := int(remaining_units / 4)
	var extra_count := remaining_units % 4
	for kind in range(4):
		var count := base_count + (1 if kind < extra_count else 0)
		if count <= 0:
			continue
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = debris_meshes[kind]
		multimesh.instance_count = count
		var visual := MultiMeshInstance3D.new()
		visual.name = debris_names[kind]
		visual.multimesh = multimesh
		var material := StandardMaterial3D.new()
		material.albedo_color = debris_colors[kind]
		material.roughness = 0.94
		visual.material_override = material
		visual.custom_aabb = AABB(Vector3(135.0, -0.5, -31.0), Vector3(70.0, 6.0, 62.0))
		add_child(visual)
		for instance_index in range(count):
			var position := _random_final_landfill_position(rng)
			var random_scale := Vector3(
				rng.randf_range(0.72, 1.35),
				rng.randf_range(0.72, 1.30),
				rng.randf_range(0.72, 1.35)
			)
			var basis := Basis.from_euler(Vector3(
				rng.randf_range(-0.65, 0.65),
				rng.randf_range(0.0, TAU),
				rng.randf_range(-0.65, 0.65)
			)).scaled(random_scale)
			multimesh.set_instance_transform(instance_index, Transform3D(basis, position))

func _update_final_zone_label() -> void:
	if is_instance_valid(final_zone_label):
		final_zone_label.text = "CITY TRASH  %d / 1,000" % _count_regular_trash()


func _count_regular_trash() -> int:
	var count := 0
	for item in trash_nodes:
		if is_instance_valid(item) and not item.is_queued_for_deletion() and not item.has_meta("final_cleanup_units"):
			count += 1
	return count

func _spawn_trash(amount: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var allowed := mini(amount, maxi(0, 1000 - _count_regular_trash()))
	for i in range(allowed):
		var item := Node3D.new()
		item.set_script(TRASH_SCRIPT)
		_apply_rare_drop(item, rng)
		item.position = _random_trash_position(rng)
		add_child(item)
		trash_nodes.append(item)
	_update_final_zone_label()

func _spawn_district_two_trash(amount: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var allowed := mini(amount, maxi(0, 1000 - _count_regular_trash()))
	for i in range(allowed):
		var item := Node3D.new()
		item.set_script(TRASH_SCRIPT)
		var spawn_point := Vector3.ZERO
		var attempts := 0
		while attempts < 40:
			var angle := rng.randf_range(0.0, TAU)
			var radius := sqrt(rng.randf()) * 9.5
			spawn_point = Vector3(32.0 + cos(angle) * radius, 0.05 + rng.randf_range(0.0, 0.02), sin(angle) * radius)
			if _is_clear_trash_spawn(spawn_point):
				break
			attempts += 1
		item.position = spawn_point
		add_child(item)
		trash_nodes.append(item)

func _refill_first_district() -> void:
	# Each lever pull adds up to 500 items, while the regular city supply is capped at 1,000.
	var alive_count := _count_regular_trash()
	var amount := mini(500, maxi(0, 1000 - alive_count))
	if amount <= 0:
		_set_message("CITY TRASH LIMIT REACHED: 1,000 / 1,000")
		return
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var max_city_x := minf(111.5, 15.5 + float(maxi(0, yard_stage - 1)) * 32.0)
	var spawned := 0
	var attempts := 0
	while spawned < amount and attempts < amount * 100:
		attempts += 1
		var point := Vector3(rng.randf_range(-11.5, max_city_x), 0.05, rng.randf_range(-31.0, 31.0))
		if not _is_clear_trash_spawn(point):
			continue
		var item := Node3D.new()
		item.set_script(TRASH_SCRIPT)
		item.position = point
		add_child(item)
		trash_nodes.append(item)
		spawned += 1
	_update_ui()
	_set_message("RESPAWN COMPLETE: %d new trash | City supply: %d / 1,000" % [spawned, alive_count + spawned])

func _is_city_truck_lane_position(point: Vector3) -> bool:
	var on_service_road := point.x >= -9.2 and point.x <= -5.2 and point.z >= -8.5 and point.z <= 34.0
	var depot_entrance := point.x >= -7.8 and point.x <= -3.8 and point.z >= -13.5 and point.z <= -5.0
	return on_service_road or depot_entrance

func _is_clear_trash_spawn(point: Vector3) -> bool:
	# Protect road lanes, gates, curb/crosswalk details, pocket parks and parked cars.
	if point.distance_to(SELL_POINT) < 4.0 or _is_city_truck_lane_position(point):
		return false
	if point.x >= -10.8 and point.x <= -5.2:
		return false
	if (point.x > 14.0 and point.x < 20.0) or (point.x > 46.0 and point.x < 52.0):
		return false
	for district_x in [32.0, 64.0]:
		var park_z := 14.0 if district_x < 48.0 else -14.0
		if absf(point.x - district_x) < 5.0 and absf(point.z - park_z) < 4.5:
			return false
		if absf(point.z - 4.1) < 0.8 or absf(point.z + 4.1) < 0.8:
			if absf(point.x - district_x) < 14.5:
				return false
	for car_pos in [Vector3(20.0, 0.0, -15.5), Vector3(44.0, 0.0, 15.5), Vector3(52.0, 0.0, 15.5), Vector3(76.0, 0.0, -15.5)]:
		if absf(point.x - car_pos.x) < 2.4 and absf(point.z - car_pos.z) < 1.6:
			return false
	return true

func _random_trash_position(rng: RandomNumberGenerator) -> Vector3:
	# Spread the capped supply across the playable city only, never into the empty landfill.
	var point := Vector3(rng.randf_range(-11.5, 107.5), 0.05, rng.randf_range(-29.0, 29.0))
	var attempts := 0
	while not _is_clear_trash_spawn(point) and attempts < 100:
		point = Vector3(rng.randf_range(-11.5, 107.5), 0.05, rng.randf_range(-29.0, 29.0))
		attempts += 1
	return point

func _update_ui() -> void:
	money_label.text = "ZC  %.1f" % money
	bag_label.text = "BACKPACK  %d / %d" % [carried, capacity]
	var is_full := carried >= capacity
	var bag_color := Color(1.0, 0.20, 0.16) if is_full else Color(0.88, 0.96, 0.92)
	bag_label.add_theme_color_override("font_color", bag_color)
	bag_label.add_theme_color_override("font_outline_color", Color(0.20, 0.015, 0.01) if is_full else Color(0.015, 0.035, 0.03))
	bag_label.add_theme_constant_override("outline_size", 5 if is_full else 2)
	if is_full:
		bag_label.text += "  FULL!"
	_update_missions()

func _set_message(_value: String) -> void:
	# Gameplay status chatter is intentionally no longer shown under the HUD;
	# the space is reserved for persistent missions.
	pass

func _mission_is_complete(stage: int) -> bool:
	match stage:
		0:
			return total_trash_collected >= 5
		1:
			return total_trash_collected >= 5 and carried == 0
		2:
			return upgrade_level > 1 or speed_upgrade_level > 1 or unload_upgrade_level > 1 or equipment_upgrade_level > 1
		3:
			return drone_level >= 1
		4:
			return total_trash_collected >= 25
		5:
			return upgrade_level >= 2
		6:
			return speed_upgrade_level >= 2
		7:
			return equipment_upgrade_level >= 2
		8:
			return auto_pickup_level >= 1
		9:
			return respawn_level >= 1
		10:
			return technology_upgrade_level >= 2
		11:
			return yard_stage >= 2
		12:
			return factory_stage >= 2
		13:
			return dispatch_upgrade_level >= 1
		14:
			return truck_capacity_upgrade_level >= 1
		15:
			return packaging_upgrade_level >= 1
		16:
			return waste_tank_built
		17:
			return total_trash_collected >= 100
		18:
			return final_zone_cleaned >= FINAL_ZONE_TARGET
		19:
			return ground_robot_level >= 1
		20:
			return sorting_robot_upgrade_level >= 1
		21:
			return conveyor_speed_upgrade_level >= 1
		23:
			return mega_factory_built_count >= 2
		24:
			return fleet_upgrade_level >= 1
		25:
			return bulk_pickup_level >= 1
		26:
			return magnet_power_level >= 2 or suction_level >= 1
		27:
			return rare_drop_upgrade_level >= 1
		28:
			return luck_upgrade_level >= 2
		29:
			return respawn_level >= 2
		30:
			return total_trash_collected >= 1000
	return false


func _update_missions() -> void:
	if not is_instance_valid(mission_label):
		return
	# Missions teach the complete gameplay loop and unlock in a strict sequence.
	# Completed missions disappear; progress is saved and never shown again.
	var previous_stage := tutorial_mission_stage
	while tutorial_mission_stage < 30 and _mission_is_complete(tutorial_mission_stage):
		tutorial_mission_stage += 1
	if tutorial_mission_stage != previous_stage:
		_save_game()

	var missions: Array[String] = [
		"Collect 5 pieces of trash.\nProgress: %d / 5" % mini(total_trash_collected, 5),
		"Recycle your trash.\nStand on the YELLOW recycling pad until your bag is empty.",
		"Buy your first upgrade.\nTap UPGRADES, choose an item, then tap its card.",
		"Get a helper drone.\nOpen UPGRADES → FLEET → HELPER DRONES.",
		"Collect 25 pieces of trash.\nProgress: %d / 25" % mini(total_trash_collected, 25),
		"Expand your backpack.\nOpen UPGRADES → ROBOT → BACKPACK CAPACITY.",
		"Move faster.\nOpen UPGRADES → ROBOT → MOVEMENT SPEED.",
		"Increase pickup range.\nOpen UPGRADES → ROBOT → PICKUP RANGE.",
		"Unlock Auto Pickup.\nOpen UPGRADES → ROBOT → AUTO PICKUP.",
		"Unlock automatic trash respawn.\nOpen UPGRADES → ECONOMY → AUTO RESPAWN.",
		"Earn more from each item.\nOpen UPGRADES → ECONOMY → TRASH VALUE.",
		"Expand to the next district.\nUse the district expansion point in the city.",
		"Upgrade the recycling factory.\nUse the factory upgrade point beside the factory.",
		"Send delivery trucks more often.\nOpen UPGRADES → FLEET → TRUCK FREQUENCY.",
		"Carry more boxes per truck.\nOpen UPGRADES → FLEET → TRUCK CAPACITY.",
		"Make packages faster.\nOpen UPGRADES → FLEET → PACKAGING SPEED.",
		"Build factory waste storage.\nBring 120 ZC to the marked tank pad, then deposit collected waste.",
		"Collect 100 pieces of trash.\nProgress: %d / 100" % mini(total_trash_collected, 100),
		"Clean 60,000 pieces in the final landfill.\nProgress: %d / 60,000" % mini(final_zone_cleaned, FINAL_ZONE_TARGET),
		"Build a ground collector.\nUnlock the GROUND COLLECTOR ROBOT in UPGRADES.",
		"Improve all sorting robots.\nBuy SORTING ROBOT EFFICIENCY level 1.",
		"Speed up the factory line.\nBuy CONVEYOR & FACTORY SPEED level 1.",
		"Build your second factory machine.\nStand on the next machine pad and complete its construction.",
		"Expand delivery operations.\nBuy HIRE TRUCKS level 1.",
		"Collect several pieces at once.\nUnlock MULTI-PICKUP level 1.",
		"Upgrade your collection tool.\nReach MAGNET POWER level 2 or unlock VACUUM.",
		"Find valuable rare items.\nUnlock SILVER & GOLD FINDS level 1.",
		"Become luckier at recycling.\nUpgrade LUCK at least once.",
		"Keep the city supplied with litter.\nUpgrade AUTO RESPAWN to level 2.",
		"MASTER CLEANER: Collect 1,000 pieces.\nProgress: %d / 1,000" % mini(total_trash_collected, 1000)
	]
	var mission_title := mission_label.get_parent().get_node_or_null("MissionTitle")
	if tutorial_mission_stage < missions.size():
		mission_label.text = missions[tutorial_mission_stage]
	else:
		mission_label.text = "ALL MISSIONS COMPLETE!\nYou cleaned the city. Great work!"
	if is_instance_valid(mission_title):
		mission_title.visible = true
	mission_label.visible = true

func _anchor_bottom_right(control: Control) -> void:
	control.anchor_left = 1.0
	control.anchor_right = 1.0
	control.anchor_top = 1.0
	control.anchor_bottom = 1.0

func _add_invisible_barrier(node_name: String, pos: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)

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

func _process_waste_feed_conveyor(delta: float) -> void:
	if not waste_tank_built or waste_feed_busy or waste_tank_inventory <= 0:
		return
	waste_feed_timer += delta
	if waste_feed_timer < 0.55:
		return
	waste_feed_timer = 0.0
	var active_rows: Array[int] = []
	for row in range(5):
		if mega_factory_built_count >= row * 3 + 1:
			active_rows.append(row)
	if active_rows.is_empty():
		return
	var selected_row := active_rows[waste_feed_line_index % active_rows.size()]
	waste_feed_line_index += 1
	waste_tank_inventory -= 1
	var selected_item := Node3D.new()
	selected_item.name = "FactoryWasteConveyorItem"
	selected_item.set_script(TRASH_SCRIPT)
	selected_item.position = Vector3(124.8, 1.25, 0.0)
	add_child(selected_item)
	waste_feed_busy = true
	var target_z := _factory_row_z(selected_row)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(selected_item, "global_position", Vector3(137.0, 1.25, 0.0), 0.8)
	tween.tween_property(selected_item, "global_position", Vector3(146.0, 1.25, 0.0), 0.8)
	tween.tween_property(selected_item, "global_position", Vector3(147.0, 1.25, target_z), 0.65)
	tween.tween_property(selected_item, "global_position", Vector3(150.4, 1.25, target_z), 0.45)
	tween.tween_callback(_finish_waste_feed_item.bind(selected_item, selected_row))

func _finish_waste_feed_item(item: Node3D, row: int) -> void:
	if is_instance_valid(item):
		item.queue_free()
	if row >= 0 and row < factory_row_input_stock.size():
		factory_row_input_stock[row] += 1
	waste_feed_busy = false
	_save_game()

func _process_factory_production(delta: float) -> void:
	if machine_broken:
		return
	factory_production_timer += delta
	if factory_production_timer < 1.2:
		return
	factory_production_timer = 0.0
	for row in range(5):
		if mega_factory_built_count < row * 3 + 1:
			continue
		if factory_row_input_stock[row] >= 3:
			factory_row_input_stock[row] -= 3
			factory_row_product_stock[row] += 1
			_set_message("%s produced! Stock: %d" % [_factory_row_product(row), factory_row_product_stock[row]])
			_save_game()

func _animate_conveyor(delta: float) -> void:
	var conveyor_speed := _conveyor_speed_multiplier()
	conveyor_time += delta * conveyor_speed
	for roller in conveyor_rollers:
		if is_instance_valid(roller):
			# The cylinder's local Y axis is its axle after its placement rotation.
			roller.rotate_object_local(Vector3.UP, delta * 5.0 * conveyor_speed)
	for i in range(conveyor_slats.size()):
		var slat := conveyor_slats[i]
		if is_instance_valid(slat):
			var x := 2.65 + fposmod(float(i) * 0.38 + conveyor_time * 1.15, 3.04)
			slat.position.x = x

func _spawn_conveyor_item(item_value: float) -> void:
	# One piece of collected litter travels through each unlocked recycling stage.
	var duration_scale := 1.0 / _conveyor_speed_multiplier()
	var item := Node3D.new()
	item.name = "ConveyorRecyclingItem"
	item.set_script(TRASH_SCRIPT)
	item.position = Vector3(2.55, 1.22, -6.5 + randf_range(-0.32, 0.32))
	item.scale = Vector3.ONE * 0.72
	add_child(item)

	# Stage 1 output: compressed, strapped bale.
	var bale := Node3D.new()
	bale.name = "CompressedRecyclingBale"
	bale.position = Vector3(7.5, 1.25, -6.5)
	bale.scale = Vector3.ONE * 0.12
	bale.visible = false
	add_child(bale)
	var core := MeshInstance3D.new()
	var core_mesh := BoxMesh.new()
	core_mesh.size = Vector3(0.82, 0.48, 0.72)
	core.mesh = core_mesh
	core.material_override = _mat(Color(0.20, 0.43, 0.37))
	bale.add_child(core)
	for x in [-0.29, 0.29]:
		var strap := MeshInstance3D.new()
		var strap_mesh := BoxMesh.new()
		strap_mesh.size = Vector3(0.075, 0.53, 0.76)
		strap.mesh = strap_mesh
		strap.position.x = x
		strap.material_override = _mat(Color(0.78, 0.69, 0.43))
		bale.add_child(strap)

	# Stage 2 output: visible shredded flakes.
	var flakes := Node3D.new()
	flakes.name = "ShreddedPlasticFlakes"
	flakes.position = Vector3(7.5, 1.18, 3.5)
	flakes.scale = Vector3.ONE * 0.08
	flakes.visible = false
	add_child(flakes)
	for i in range(9):
		var flake := MeshInstance3D.new()
		var flake_mesh := BoxMesh.new()
		flake_mesh.size = Vector3(0.16, 0.055, 0.12)
		flake.mesh = flake_mesh
		flake.position = Vector3(randf_range(-0.42, 0.42), randf_range(-0.12, 0.14), randf_range(-0.36, 0.36))
		flake.rotation = Vector3(randf_range(-0.5, 0.5), randf_range(0.0, TAU), randf_range(-0.5, 0.5))
		flake.material_override = _mat([Color(0.12, 0.62, 0.72), Color(0.20, 0.72, 0.48), Color(0.88, 0.68, 0.22)][i % 3])
		flakes.add_child(flake)

	# Stage 3 output: recycled plastic pellets.
	var pellets := Node3D.new()
	pellets.name = "RecycledPlasticPellets"
	pellets.position = Vector3(7.5, 1.15, 13.5)
	pellets.scale = Vector3.ONE * 0.08
	pellets.visible = false
	add_child(pellets)
	for i in range(18):
		var pellet := MeshInstance3D.new()
		var pellet_mesh := SphereMesh.new()
		pellet_mesh.radius = 0.075
		pellet_mesh.height = 0.12
		pellet.mesh = pellet_mesh
		pellet.position = Vector3(randf_range(-0.42, 0.42), randf_range(-0.12, 0.16), randf_range(-0.35, 0.35))
		pellet.material_override = _mat([Color(0.12, 0.62, 0.72), Color(0.20, 0.72, 0.48), Color(0.88, 0.68, 0.22)][i % 3])
		pellets.add_child(pellet)

	# Stage 4 output: a teddy bear made from the recycled material.
	var teddy := Node3D.new()
	teddy.name = "RecycledTeddyBear"
	teddy.position = Vector3(7.5, 0.62, 23.5)
	teddy.scale = Vector3.ONE * 0.05
	teddy.visible = false
	add_child(teddy)
	_add_teddy_part(teddy, "TeddyBody", Vector3(0, 0.48, 0), Vector3(0.48, 0.58, 0.34), Color(0.68, 0.39, 0.20))
	_add_teddy_part(teddy, "TeddyHead", Vector3(0, 1.05, -0.02), Vector3(0.58, 0.56, 0.48), Color(0.76, 0.48, 0.27))
	_add_teddy_part(teddy, "TeddyEarL", Vector3(-0.36, 1.34, 0), Vector3(0.23, 0.25, 0.20), Color(0.76, 0.48, 0.27))
	_add_teddy_part(teddy, "TeddyEarR", Vector3(0.36, 1.34, 0), Vector3(0.23, 0.25, 0.20), Color(0.76, 0.48, 0.27))
	_add_teddy_part(teddy, "TeddyMuzzle", Vector3(0, 0.94, -0.25), Vector3(0.28, 0.20, 0.18), Color(0.94, 0.79, 0.60))
	_add_teddy_part(teddy, "TeddyNose", Vector3(0, 1.00, -0.405), Vector3(0.10, 0.075, 0.055), Color(0.12, 0.08, 0.06))
	for x in [-0.18, 0.18]:
		_add_teddy_part(teddy, "TeddyEye", Vector3(x, 1.12, -0.405), Vector3(0.055, 0.065, 0.04), Color(0.035, 0.025, 0.02))
	for x in [-0.38, 0.38]:
		_add_teddy_part(teddy, "TeddyArm", Vector3(x, 0.52, -0.01), Vector3(0.22, 0.42, 0.23), Color(0.76, 0.48, 0.27))
		_add_teddy_part(teddy, "TeddyFoot", Vector3(x * 0.62, 0.12, -0.04), Vector3(0.28, 0.20, 0.30), Color(0.68, 0.39, 0.20))
	_add_teddy_part(teddy, "TeddyRibbon", Vector3(0, 0.80, -0.20), Vector3(0.32, 0.09, 0.07), Color(0.82, 0.16, 0.20))

	var travel := create_tween()
	travel.set_trans(Tween.TRANS_SINE)
	travel.set_ease(Tween.EASE_IN_OUT)
	travel.tween_property(item, "position", Vector3(5.35, 1.25, item.position.z), 1.0 * duration_scale)
	travel.parallel().tween_property(item, "rotation:y", item.rotation.y + TAU, 1.0 * duration_scale)
	travel.tween_property(item, "position", Vector3(7.5, 1.25, -6.5), 0.55 * duration_scale)
	travel.tween_property(item, "scale", Vector3.ONE * 0.22, 0.55 * duration_scale)
	travel.tween_callback(func():
		item.visible = false
		bale.visible = true
	)
	travel.tween_property(bale, "scale", Vector3.ONE, 0.22 * duration_scale)
	if factory_stage >= 2:
		travel.tween_property(bale, "position", Vector3(7.5, 1.25, 3.5), 1.35 * duration_scale)
		travel.tween_callback(func():
			bale.visible = false
			flakes.visible = true
		)
		travel.tween_property(flakes, "scale", Vector3.ONE, 0.22 * duration_scale)
	if factory_stage >= 3:
		travel.tween_property(flakes, "position", Vector3(7.5, 1.15, 13.5), 1.35 * duration_scale)
		travel.tween_callback(func():
			flakes.visible = false
			pellets.visible = true
		)
		travel.tween_property(pellets, "scale", Vector3.ONE, 0.22 * duration_scale)
	if factory_stage >= 4:
		travel.tween_property(pellets, "position", Vector3(7.5, 0.62, 23.5), 1.35 * duration_scale)
		travel.tween_callback(func():
			pellets.visible = false
			teddy.visible = true
		)
		travel.tween_property(teddy, "scale", Vector3.ONE, 0.35 * duration_scale)
		travel.tween_property(teddy, "rotation:y", TAU, 0.55 * duration_scale)
		travel.tween_callback(func():
			teddy_stock_values.append(item_value)
			_save_game()
			_set_message("Teddy bear ready for packaging! %d waiting." % teddy_stock_values.size())
		)
	travel.tween_callback(func():
		item.queue_free()
		bale.queue_free()
		flakes.queue_free()
		pellets.queue_free()
		teddy.queue_free()
	)

func _process_teddy_shipping(delta: float) -> void:
	if factory_stage < 5 or delivery_trucks.is_empty():
		return
	if shipping_active:
		return
	var interval := _truck_dispatch_interval()
	truck_dispatch_timer += delta
	if truck_dispatch_timer < interval:
		return
	truck_dispatch_timer = 0.0
	if teddy_stock_values.is_empty():
		return
	_dispatch_truck_fleet()

func _truck_dispatch_interval() -> float:
	var intervals := [60.0, 45.0, 30.0, 20.0]
	return intervals[clampi(dispatch_upgrade_level, 0, 3)]

func _truck_fleet_size() -> int:
	return clampi(1 + fleet_upgrade_level, 1, 4)

func _truck_box_capacity() -> int:
	var capacities := [5, 8, 12, 16]
	return capacities[clampi(truck_capacity_upgrade_level, 0, 3)]

func _packaging_seconds() -> float:
	var cycle_times := [1.15, 0.85, 0.62, 0.42]
	return cycle_times[clampi(packaging_upgrade_level, 0, 3)]

func _refresh_delivery_fleet() -> void:
	if factory_stage < 5 or not is_instance_valid(factory_visual_root):
		return
	while delivery_trucks.size() < _truck_fleet_size():
		_create_delivery_truck(delivery_trucks.size())

func _build_delivery_conveyor(start_point: Vector3, end_point: Vector3) -> void:
	var midpoint := (start_point + end_point) * 0.5
	var direction := end_point - start_point
	var length := direction.length()
	if length <= 0.1:
		return
	var yaw := atan2(direction.x, direction.z)
	var base := Node3D.new()
	base.name = "DeliveryConveyor"
	base.position = midpoint
	base.rotation.y = yaw
	add_child(base)
	_box_child(base, "ConveyorFrame", Vector3(0, -0.18, 0), Vector3(1.45, 0.28, length), Color(0.24, 0.27, 0.30))
	_box_child(base, "MovingBelt", Vector3(0, 0.02, 0), Vector3(1.12, 0.12, length - 0.18), Color(0.10, 0.12, 0.13))
	_box_child(base, "LeftGuardRail", Vector3(-0.68, 0.28, 0), Vector3(0.12, 0.42, length), Color(0.75, 0.58, 0.20))
	_box_child(base, "RightGuardRail", Vector3(0.68, 0.28, 0), Vector3(0.12, 0.42, length), Color(0.75, 0.58, 0.20))
	for i in range(9):
		var z_offset := -length * 0.5 + length * float(i + 1) / 10.0
		_box_child(base, "Support_%d" % i, Vector3(0, -0.62, z_offset), Vector3(1.25, 0.78, 0.16), Color(0.24, 0.27, 0.30))

func _create_delivery_truck(index: int) -> void:
	var truck := Node3D.new()
	truck.name = "TeddyDeliveryTruck%d" % (index + 1)
	var dock_z := 30.25 + (float(index) - float(_truck_fleet_size() - 1) * 0.5) * 3.1
	truck.position = Vector3(17.4, 0.0, dock_z)
	var cargo := MeshInstance3D.new()
	var cargo_mesh := BoxMesh.new()
	cargo_mesh.size = Vector3(3.5, 1.8, 3.0)
	cargo.mesh = cargo_mesh
	cargo.position = Vector3(0.0, 1.45, 0.0)
	cargo.material_override = _mat(Color(0.88, 0.88, 0.78))
	truck.add_child(cargo)
	var cab := MeshInstance3D.new()
	var cab_mesh := BoxMesh.new()
	cab_mesh.size = Vector3(1.65, 1.65, 2.8)
	cab.mesh = cab_mesh
	cab.position = Vector3(-2.1, 1.35, 0.0)
	cab.material_override = _mat(Color(0.82, 0.22, 0.12))
	truck.add_child(cab)
	var windshield := MeshInstance3D.new()
	var windshield_mesh := BoxMesh.new()
	windshield_mesh.size = Vector3(0.06, 0.72, 1.55)
	windshield.mesh = windshield_mesh
	windshield.position = Vector3(-3.0, 1.65, 0.0)
	windshield.material_override = _mat(Color(0.12, 0.23, 0.29))
	truck.add_child(windshield)
	for wheel_x in [-2.5, 0.0, 2.4]:
		for wheel_z in [-1.45, 1.45]:
			var wheel := MeshInstance3D.new()
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.48
			wheel_mesh.bottom_radius = 0.48
			wheel_mesh.height = 0.22
			wheel.mesh = wheel_mesh
			wheel.position = Vector3(wheel_x, 0.48, wheel_z)
			wheel.rotation_degrees.x = 90.0
			wheel.material_override = _mat(Color(0.035, 0.04, 0.045))
			truck.add_child(wheel)
	var sign := Label3D.new()
	sign.text = "ZEKA TOYS  #%d" % (index + 1)
	sign.position = Vector3(0.0, 2.45, 1.52)
	sign.font_size = 22
	sign.pixel_size = 0.012
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sign.modulate = Color(0.12, 0.20, 0.18)
	truck.add_child(sign)
	if is_instance_valid(factory_visual_root):
		factory_visual_root.add_child(truck)
	else:
		add_child(truck)
	delivery_trucks.append(truck)

func _dispatch_truck_fleet() -> void:
	shipping_active = true
	dispatch_trucks_remaining = 0
	for index in range(delivery_trucks.size()):
		if teddy_stock_values.is_empty():
			break
		var truck := delivery_trucks[index]
		if not is_instance_valid(truck):
			continue
		dispatch_trucks_remaining += 1
		var dock_z := 30.25 + (float(index) - float(_truck_fleet_size() - 1) * 0.5) * 3.1
		var arrive := create_tween()
		arrive.set_trans(Tween.TRANS_SINE)
		arrive.set_ease(Tween.EASE_OUT)
		arrive.tween_property(truck, "position", Vector3(12.2, 0.0, dock_z), 1.8)
		arrive.tween_callback(_load_next_teddy_package.bind(index, 0))

func _load_next_teddy_package(truck_index: int, loaded_count: int) -> void:
	if truck_index >= delivery_trucks.size() or teddy_stock_values.is_empty() or loaded_count >= _truck_box_capacity():
		_depart_delivery_truck(truck_index)
		return
	var truck := delivery_trucks[truck_index]
	if not is_instance_valid(truck):
		_depart_delivery_truck(truck_index)
		return
	var package := Node3D.new()
	package.name = "TeddyShippingPackage"
	package.position = Vector3(9.45, 1.05, 30.25)
	var carton := MeshInstance3D.new()
	var carton_mesh := BoxMesh.new()
	carton_mesh.size = Vector3(0.72, 0.62, 0.62)
	carton.mesh = carton_mesh
	carton.material_override = _mat(Color(0.72, 0.49, 0.25))
	package.add_child(carton)
	var tape := MeshInstance3D.new()
	var tape_mesh := BoxMesh.new()
	tape_mesh.size = Vector3(0.12, 0.64, 0.64)
	tape.mesh = tape_mesh
	tape.material_override = _mat(Color(0.93, 0.80, 0.48))
	package.add_child(tape)
	add_child(package)
	var target := truck.global_position + Vector3(0.0, 2.05, 0.0)
	var load_tween := create_tween()
	load_tween.set_trans(Tween.TRANS_SINE)
	load_tween.set_ease(Tween.EASE_IN_OUT)
	load_tween.tween_property(package, "global_position", target, _packaging_seconds())
	load_tween.tween_callback(func():
		package.queue_free()
		if teddy_stock_values.is_empty():
			_depart_delivery_truck(truck_index)
			return
		var sold_value: float = teddy_stock_values.pop_front()
		money += sold_value
		_update_ui()
		_save_game()
		_set_message("Teddy bear delivered! Extra sale +%.2f ZC" % sold_value)
		_load_next_teddy_package(truck_index, loaded_count + 1)
	)

func _depart_delivery_truck(truck_index: int) -> void:
	if truck_index < 0 or truck_index >= delivery_trucks.size():
		return
	var truck := delivery_trucks[truck_index]
	if is_instance_valid(truck):
		var depart := create_tween()
		depart.set_trans(Tween.TRANS_SINE)
		depart.set_ease(Tween.EASE_IN)
		depart.tween_property(truck, "position:x", 17.4, 2.0)
		depart.tween_callback(func():
			dispatch_trucks_remaining = maxi(0, dispatch_trucks_remaining - 1)
			if dispatch_trucks_remaining == 0:
				shipping_active = false
		)
	else:
		dispatch_trucks_remaining = maxi(0, dispatch_trucks_remaining - 1)
		if dispatch_trucks_remaining == 0:
			shipping_active = false

func _upgrade_city_truck_frequency() -> void:
	if city_truck_upgrade_level >= 3:
		_set_message("City truck frequency is already at maximum.")
		return
	var cost := _upgrade_cost(60.0, city_truck_upgrade_level + 1)
	if not await _pay_gradually(cost):
		return
	city_truck_upgrade_level = mini(city_truck_upgrade_level + 1, 3)
	_refresh_upgrade_prices()
	_save_game()
	_set_message("City trucks now arrive every %.0f minutes!" % (_city_truck_interval() / 60.0))

func _upgrade_city_fleet() -> void:
	if city_fleet_upgrade_level >= 3:
		_set_message("City truck fleet is already at maximum.")
		return
	var cost := _upgrade_cost(85.0, city_fleet_upgrade_level + 1)
	if not await _pay_gradually(cost):
		return
	city_fleet_upgrade_level = mini(city_fleet_upgrade_level + 1, 3)
	_refresh_city_truck_fleet()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("City fleet expanded: %d trucks. Extra trucks will queue at the depot." % city_trucks.size())

func _upgrade_dispatch() -> void:
	var cost := _upgrade_cost(45.0, dispatch_upgrade_level + 1)
	if not await _pay_gradually(cost):
		return
	dispatch_upgrade_level += 1
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Truck dispatch interval reduced to %.0f seconds!" % _truck_dispatch_interval())

func _upgrade_fleet() -> void:
	var cost := _upgrade_cost(85.0, fleet_upgrade_level + 1)
	if not await _pay_gradually(cost):
		return
	fleet_upgrade_level += 1
	_refresh_delivery_fleet()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("A new delivery truck hired! Fleet size: %d." % _truck_fleet_size())

func _upgrade_truck_capacity() -> void:
	var cost := _upgrade_cost(70.0, truck_capacity_upgrade_level + 1)
	if not await _pay_gradually(cost):
		return
	truck_capacity_upgrade_level += 1
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Truck capacity increased to %d boxes!" % _truck_box_capacity())

func _upgrade_packaging() -> void:
	var cost := _upgrade_cost(60.0, packaging_upgrade_level + 1)
	if not await _pay_gradually(cost):
		return
	packaging_upgrade_level += 1
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Packaging cycle reduced to %.2f seconds!" % _packaging_seconds())
func _add_teddy_part(parent: Node3D, part_name: String, part_position: Vector3, part_size: Vector3, part_color: Color) -> void:
	var part := MeshInstance3D.new()
	part.name = part_name
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	part.mesh = mesh
	part.scale = part_size
	part.position = part_position
	part.material_override = _mat(part_color)
	parent.add_child(part)
func _make_street_bin(pos: Vector3, color: Color) -> void:
	# Compact domestic wheelie bin with a rounded lid and no industrial sorting label.
	_box("StreetBinBody", pos + Vector3(0, 0.58, 0), Vector3(0.92, 1.12, 0.88), color, true)
	_box("StreetBinFront", pos + Vector3(0, 0.62, -0.455), Vector3(0.72, 0.72, 0.035), color.lightened(0.08), false)
	var lid := _box("StreetBinLid", pos + Vector3(0, 1.18, 0.0), Vector3(1.02, 0.16, 0.96), Color(0.075, 0.10, 0.095), false)
	lid.rotation_degrees.x = -3.0
	_box("StreetBinHandle", pos + Vector3(0, 1.28, -0.34), Vector3(0.34, 0.07, 0.12), Color(0.12, 0.15, 0.14), false)
	for x in [-0.34, 0.34]:
		_cylinder("StreetBinWheel", pos + Vector3(x, 0.16, 0.36), 0.14, 0.11, Color(0.035, 0.04, 0.04), true)

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

func _add_wall_plaque(node_name: String, value: String, pos: Vector3, dimensions: Vector2, plate_color: Color, text_color: Color, font_px: int) -> void:
	# Physical plaque sits flush on the facade; lettering is fixed to the wall,
	# not billboarded toward the camera like floating world-space UI.
	var plate := MeshInstance3D.new()
	plate.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = Vector3(dimensions.x, dimensions.y, 0.055)
	plate.mesh = mesh
	plate.position = pos
	plate.material_override = _mat(plate_color)
	add_child(plate)
	var label := Label3D.new()
	label.name = node_name + "Text"
	label.text = value
	label.position = pos + Vector3(0, 0, 0.031)
	label.font_size = font_px
	label.pixel_size = 0.0045
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label.modulate = text_color
	label.outline_size = 4
	label.outline_modulate = Color(0.025, 0.045, 0.045, 0.95)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(label)


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
	# More convincing PBR response: dark neutral surfaces read as rubber/steel,
	# while painted, organic and concrete surfaces keep a softer matte finish.
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	var highest := maxf(color.r, maxf(color.g, color.b))
	var lowest := minf(color.r, minf(color.g, color.b))
	var chroma := highest - lowest
	var luminance := color.get_luminance()
	if chroma < 0.13 and luminance < 0.42:
		material.metallic = 0.48
		material.roughness = 0.48
	elif chroma < 0.16 and luminance < 0.72:
		material.metallic = 0.22
		material.roughness = 0.58
	else:
		material.metallic = 0.04
		material.roughness = 0.68
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


func _build_city_polish() -> void:
	# Small public squares in the spare blocks: all props stay off streets,
	# alleys and building lots so the player and trucks keep clear routes.
	for district_x in [32.0, 64.0]:
		var park_z := 14.0 if district_x < 48.0 else -14.0
		_box("CityPocketParkBase", Vector3(district_x, 0.035, park_z), Vector3(8.4, 0.07, 6.8), Color(0.30, 0.43, 0.29), false)
		_box("ParkPath", Vector3(district_x, 0.078, park_z), Vector3(1.35, 0.025, 6.2), Color(0.67, 0.63, 0.52), false)
		_box("ParkCrossPath", Vector3(district_x, 0.082, park_z), Vector3(7.8, 0.025, 1.05), Color(0.67, 0.63, 0.52), false)
		for side in [-1.0, 1.0]:
			var planter_pos := Vector3(district_x + side * 3.0, 0.10, park_z - 2.2)
			_box("ParkPlanter", planter_pos, Vector3(1.25, 0.22, 1.05), Color(0.43, 0.29, 0.18), false)
			_cylinder("ParkShrub", planter_pos + Vector3(0, 0.42, 0), 0.43, 0.62, Color(0.19, 0.39, 0.20), false)
			_make_bench(Vector3(district_x + side * 2.55, 0.0, park_z + 1.75))
		_build_neighborhood_tree(Vector3(district_x - 3.0, 0.0, park_z + 2.3))
		_build_neighborhood_tree(Vector3(district_x + 3.0, 0.0, park_z + 2.3))
		_make_lamp(Vector3(district_x - 4.5, 0.0, park_z))
		_make_lamp(Vector3(district_x + 4.5, 0.0, park_z))

		# Street furniture and waste bins at the edge of the pedestrian zone.
		_make_bin(Vector3(district_x - 4.0, 0.0, park_z - 3.5), Color(0.16, 0.48, 0.34), "CITY")
		_box("BusStopSignPole", Vector3(district_x + 4.0, 1.25, -5.0 if district_x < 48.0 else 5.0), Vector3(0.09, 2.5, 0.09), Color(0.18, 0.22, 0.23), false)
		_box("BusStopSign", Vector3(district_x + 4.0, 2.25, -5.0 if district_x < 48.0 else 5.0), Vector3(0.72, 0.82, 0.12), Color(0.10, 0.39, 0.68), false)
		_label_3d("BUS", Vector3(district_x + 4.0, 2.22, -4.91 if district_x < 48.0 else 5.09), 0.16)

	# Marked parking pockets along the outer edge, not on the central road.
	for car_pos in [Vector3(20.0, 0.0, -15.5), Vector3(44.0, 0.0, 15.5), Vector3(52.0, 0.0, 15.5), Vector3(76.0, 0.0, -15.5)]:
		_box("StreetParkingBay", car_pos + Vector3(0, 0.018, 0), Vector3(4.4, 0.025, 2.35), Color(0.36, 0.39, 0.36), false)
		_box("ParkingBayStripeA", car_pos + Vector3(-2.05, 0.04, 0), Vector3(0.07, 0.018, 2.2), Color(0.88, 0.85, 0.72), false)
		_box("ParkingBayStripeB", car_pos + Vector3(2.05, 0.04, 0), Vector3(0.07, 0.018, 2.2), Color(0.88, 0.85, 0.72), false)
		_make_parked_car(car_pos)

	# Extra curb stones and pedestrian crossing marks are visual only.
	for district_x in [32.0, 64.0]:
		for z_side in [-4.1, 4.1]:
			for x_offset in range(-13, 14, 2):
				_box("StreetCurbStone", Vector3(district_x + float(x_offset), 0.075, z_side), Vector3(1.75, 0.13, 0.22), Color(0.59, 0.60, 0.55), false)
		for stripe in range(5):
			_box("PedestrianCrossingStripe", Vector3(district_x - 2.2 + stripe * 1.1, 0.052, 3.0), Vector3(0.62, 0.018, 0.48), Color(0.88, 0.87, 0.78), false)



func _build_city_life_details() -> void:
	# Add crosswalks and traffic signals at the main connected-road junctions.
	for crossing_x in [16.0, 48.0, 80.0, 104.0]:
		for stripe in range(7):
			_box("BoulevardCrosswalkStripe", Vector3(crossing_x - 2.4 + float(stripe) * 0.8, 0.058, 0.0), Vector3(0.46, 0.018, 4.8), Color(0.88, 0.87, 0.78), false)
		for side in [-1.0, 1.0]:
			var signal_pos := Vector3(crossing_x + side * 4.2, 0.0, -4.8)
			_box("TrafficSignalPole", signal_pos + Vector3(0, 1.65, 0), Vector3(0.10, 3.3, 0.10), Color(0.17, 0.21, 0.22), false)
			_box("TrafficSignalHousing", signal_pos + Vector3(0, 3.0, 0), Vector3(0.34, 0.86, 0.28), Color(0.08, 0.11, 0.12), false)
			for lamp_index in range(3):
				_cylinder("TrafficSignalLamp", signal_pos + Vector3(0, 3.28 - float(lamp_index) * 0.27, 0.16), 0.075, 0.055, [Color(0.82, 0.18, 0.13), Color(0.91, 0.68, 0.16), Color(0.20, 0.72, 0.36)][lamp_index], false)

	# Trees and benches fill spare sidewalk pockets without blocking lanes.
	for tree_pos in [
		Vector3(18.0, 0.0, -18.0), Vector3(44.0, 0.0, 18.0),
		Vector3(50.0, 0.0, -18.0), Vector3(76.0, 0.0, 18.0),
		Vector3(84.0, 0.0, -18.0), Vector3(108.0, 0.0, 18.0)
	]:
		_build_neighborhood_tree(tree_pos)
	for bench_pos in [Vector3(27.0, 0.0, 17.0), Vector3(59.0, 0.0, -17.0), Vector3(91.0, 0.0, 17.0)]:
		_make_bench(bench_pos)

	# District signs make the long boulevard easier to read.
	for marker in [
		{"x": 16.0, "name": "RESIDENTIAL"},
		{"x": 48.0, "name": "CIVIC"},
		{"x": 80.0, "name": "MARKET"}
	]:
		_box("DistrictWelcomeSignPost", Vector3(float(marker.x), 1.55, -31.5), Vector3(0.12, 3.1, 0.12), Color(0.20, 0.25, 0.24), false)
		_box("DistrictWelcomeSignBoard", Vector3(float(marker.x), 2.65, -31.5), Vector3(5.0, 1.0, 0.18), Color(0.12, 0.27, 0.25), false)
		_label_3d(String(marker.name), Vector3(float(marker.x), 2.68, -31.36), 0.20)


func _build_commercial_district() -> void:
	# Detailed commercial quarter with a boulevard, six stores and a public plaza.
	_box("MarketBoulevard", Vector3(96, 0.022, 0), Vector3(31.0, 0.045, 6.2), Color(0.105, 0.13, 0.15), false)
	for side_z in [-4.0, 4.0]:
		_box("MarketStoneSidewalk", Vector3(96, 0.06, side_z), Vector3(31.0, 0.12, 1.65), Color(0.58, 0.57, 0.51), false)
		for x in range(82, 111, 2):
			_box("MarketPavingJoint", Vector3(float(x), 0.126, side_z), Vector3(0.025, 0.008, 1.55), Color(0.42, 0.43, 0.40), false)
	for x in range(82, 111, 4):
		_box("MarketRoadDash", Vector3(float(x), 0.055, 0), Vector3(1.75, 0.012, 0.11), Color(0.91, 0.80, 0.55), false)

	var shop_names: Array[String] = ["GROCERY", "BAKERY", "COFFEE", "MARKET", "FLOWERS", "TOOLS"]
	var shop_colors: Array[Color] = [
		Color(0.76, 0.56, 0.30), Color(0.70, 0.36, 0.25),
		Color(0.32, 0.48, 0.53), Color(0.48, 0.57, 0.40),
		Color(0.68, 0.43, 0.53), Color(0.42, 0.49, 0.58)
	]
	var shop_xs: Array[float] = [85.5, 96.0, 106.5]
	for i in range(3):
		_build_market_shop(Vector3(shop_xs[i], 0, -23.5), shop_names[i], shop_colors[i], i)
		_build_market_shop(Vector3(shop_xs[i], 0, 23.5), shop_names[i + 3], shop_colors[i + 3], i + 3)

	# A proper civic square, with a tiered fountain, pavers, planters and seating.
	var plaza := Vector3(96, 0, 13.0)
	_box("MarketSquareBase", plaza + Vector3(0, 0.055, 0), Vector3(17.5, 0.11, 12.0), Color(0.61, 0.59, 0.51), false)
	for x in range(88, 105, 2):
		_box("MarketSquarePaverLine", Vector3(float(x), 0.116, 13), Vector3(0.025, 0.008, 11.6), Color(0.45, 0.46, 0.42), false)
	for z in [8.0, 18.0]:
		_box("MarketSquareBorder", Vector3(96, 0.14, z), Vector3(17.0, 0.08, 0.12), Color(0.34, 0.37, 0.34), false)
	_cylinder("FountainLowerBasin", Vector3(96, 0.32, 13), 2.0, 0.48, Color(0.43, 0.48, 0.47), false)
	_cylinder("FountainWater", Vector3(96, 0.57, 13), 1.72, 0.06, Color(0.18, 0.55, 0.68), false)
	_cylinder("FountainColumn", Vector3(96, 0.92, 13), 0.34, 0.72, Color(0.68, 0.67, 0.60), false)
	_cylinder("FountainTopBowl", Vector3(96, 1.34, 13), 0.82, 0.18, Color(0.55, 0.61, 0.59), false)
	_cylinder("FountainJet", Vector3(96, 1.70, 13), 0.10, 0.62, Color(0.26, 0.66, 0.78), false)
	for corner in [Vector3(89, 0, 9), Vector3(103, 0, 9), Vector3(89, 0, 17), Vector3(103, 0, 17)]:
		_box("MarketPlanterStone", corner + Vector3(0, 0.35, 0), Vector3(1.8, 0.7, 1.5), Color(0.36, 0.38, 0.34), false)
		_cylinder("MarketPlanterShrub", corner + Vector3(0, 0.95, 0), 0.62, 0.9, Color(0.17, 0.37, 0.20), false)
	for bench in [Vector3(92, 0, 13), Vector3(100, 0, 13)]:
		_make_bench(bench)

	# Four parking bays are kept clear of the boulevard and plaza.
	for car in [Vector3(84.0, 0, 11.0), Vector3(108.0, 0, 11.0), Vector3(84.0, 0, -11.0), Vector3(108.0, 0, -11.0)]:
		_box("MarketParkingBay", car + Vector3(0, 0.02, 0), Vector3(4.4, 0.025, 2.35), Color(0.34, 0.37, 0.35), false)
		_box("MarketParkingStripeL", car + Vector3(-2.05, 0.04, 0), Vector3(0.07, 0.02, 2.2), Color(0.90, 0.86, 0.72), false)
		_box("MarketParkingStripeR", car + Vector3(2.05, 0.04, 0), Vector3(0.07, 0.02, 2.2), Color(0.90, 0.86, 0.72), false)
		_make_parked_car(car)

	for lamp_x in [82.5, 91.0, 101.0, 109.5]:
		_make_lamp(Vector3(lamp_x, 0, -5.2))
		_make_lamp(Vector3(lamp_x, 0, 5.2))
	for bin_pos in [Vector3(89, 0, 5.1), Vector3(103, 0, -5.1)]:
		_make_bin(bin_pos, Color(0.12, 0.42, 0.34), "MARKET")
	for x in range(92, 101, 2):
		_box("MarketCrosswalkStripe", Vector3(float(x), 0.075, 7.0), Vector3(0.9, 0.02, 0.42), Color(0.91, 0.89, 0.80), false)


func _build_ad_billboards() -> void:
	# Full-size roadside advertising structures: grounded supports, steel frames,
	# double-sided panels and illuminated lettering. They are decorative only.
	_create_ad_billboard(
		Vector3(16.0, 0.0, -8.5),
		"ZEKA MEDIA",
		"CREATE. SHARE. DISCOVER.",
		Color(0.08, 0.20, 0.34),
		Color(0.10, 0.78, 0.82)
	)
	_create_ad_billboard(
		Vector3(48.0, 0.0, 8.5),
		"SAVE THE CITY",
		"EVERY PIECE OF TRASH COUNTS",
		Color(0.08, 0.27, 0.19),
		Color(0.83, 0.76, 0.31)
	)
	_create_ad_billboard(
		Vector3(80.0, 0.0, -8.5),
		"PLAY ZEKA CITY",
		"CLEANUP EMPIRE  •  BUILD A CLEANER WORLD",
		Color(0.24, 0.13, 0.29),
		Color(0.93, 0.57, 0.20)
	)


func _create_ad_billboard(center: Vector3, headline: String, subtitle: String, panel_color: Color, accent_color: Color) -> void:
	var width := 9.2
	var board_bottom := 4.35
	var board_height := 3.35
	# Heavy concrete footings keep both steel columns visibly planted in the ground.
	for side_x in [-3.35, 3.35]:
		_box("AdBillboardConcreteFooting", center + Vector3(side_x, 0.20, 0), Vector3(1.0, 0.40, 1.0), Color(0.31, 0.33, 0.32), false)
		_box("AdBillboardSteelColumn", center + Vector3(side_x, 2.55, 0), Vector3(0.30, 5.1, 0.34), Color(0.20, 0.24, 0.26), false)
		_box("AdBillboardColumnTrim", center + Vector3(side_x, 4.85, 0.20), Vector3(0.42, 0.16, 0.48), accent_color, false)
	# Main sign body and raised perimeter frame.
	_box("AdBillboardBackPanel", center + Vector3(0, board_bottom + board_height * 0.5, 0), Vector3(width, board_height, 0.48), Color(0.055, 0.075, 0.09), false)
	_box("AdBillboardFace", center + Vector3(0, board_bottom + board_height * 0.5, 0.255), Vector3(width - 0.34, board_height - 0.34, 0.055), panel_color, false)
	for edge_y in [board_bottom + 0.08, board_bottom + board_height - 0.08]:
		_box("AdBillboardHorizontalFrame", center + Vector3(0, edge_y, 0.31), Vector3(width, 0.16, 0.16), accent_color, false)
	for edge_x in [-width * 0.5 + 0.08, width * 0.5 - 0.08]:
		_box("AdBillboardVerticalFrame", center + Vector3(edge_x, board_bottom + board_height * 0.5, 0.31), Vector3(0.16, board_height, 0.16), accent_color, false)
	# Cross-bracing and maintenance platform make the structure read as real street furniture.
	_box("AdBillboardRearCrossbar", center + Vector3(0, 4.15, -0.30), Vector3(7.0, 0.18, 0.20), Color(0.24, 0.28, 0.29), false)
	_box("AdBillboardServiceRail", center + Vector3(0, 4.05, -0.48), Vector3(7.5, 0.12, 0.85), Color(0.18, 0.22, 0.23), false)
	# Billboard lettering is world-space 3D text, not a HUD overlay.
	_label_3d(headline, center + Vector3(0, board_bottom + 2.18, 0.43), 0.62)
	_label_3d(subtitle, center + Vector3(0, board_bottom + 0.88, 0.43), 0.19)
	# Slim floodlights sit above the sign and point toward its face.
	for light_x in [-2.8, 0.0, 2.8]:
		_box("AdBillboardFloodlightArm", center + Vector3(light_x, board_bottom + board_height + 0.28, 0.08), Vector3(0.12, 0.42, 0.12), Color(0.22, 0.25, 0.26), false)
		_box("AdBillboardFloodlight", center + Vector3(light_x, board_bottom + board_height + 0.08, 0.38), Vector3(0.85, 0.10, 0.28), Color(0.94, 0.84, 0.55), false)

func _build_market_shop(center: Vector3, shop_name: String, facade: Color, index: int) -> void:
	var front_dir := 1.0 if center.z < 0.0 else -1.0
	var front_z := center.z + front_dir * 4.05
	var wall_depth := 7.2
	_box("MarketShopFoundation", center + Vector3(0, 0.14, 0), Vector3(7.6, 0.28, wall_depth + 0.5), Color(0.28, 0.30, 0.29), true)
	_box("MarketShopWalls", center + Vector3(0, 2.15, 0), Vector3(7.2, 4.0, wall_depth), facade, true)
	_box("MarketShopRoof", center + Vector3(0, 4.22, 0), Vector3(7.55, 0.22, wall_depth + 0.3), Color(0.17, 0.22, 0.24), false)
	_box("ShopWindowFrame", Vector3(center.x - 1.55, 1.72, front_z), Vector3(3.15, 2.45, 0.16), Color(0.10, 0.17, 0.19), false)
	_box("ShopWindowGlass", Vector3(center.x - 1.55, 1.75, front_z + front_dir * 0.09), Vector3(2.86, 2.16, 0.045), Color(0.30, 0.58, 0.65), false)
	_box("ShopDoorFrame", Vector3(center.x + 2.25, 1.18, front_z), Vector3(1.15, 2.25, 0.18), Color(0.10, 0.15, 0.17), false)
	_box("ShopDoorGlass", Vector3(center.x + 2.25, 1.18, front_z + front_dir * 0.10), Vector3(0.91, 1.98, 0.045), Color(0.24, 0.49, 0.56), false)
	_cylinder("ShopDoorHandle", Vector3(center.x + 2.55, 1.18, front_z + front_dir * 0.15), 0.045, 0.32, Color(0.78, 0.70, 0.48), false)
	var awning_color: Color = [Color(0.78, 0.25, 0.18), Color(0.16, 0.43, 0.58), Color(0.79, 0.66, 0.35)][index % 3]
	_box("ShopAwning", Vector3(center.x, 3.18, front_z + front_dir * 0.38), Vector3(7.55, 0.62, 0.95), awning_color, false)
	for stripe_x in range(-3, 4):
		_box("ShopAwningStripe", Vector3(center.x + float(stripe_x), 3.18, front_z + front_dir * 0.88), Vector3(0.07, 0.56, 0.025), Color(0.92, 0.88, 0.76), false)
	_box("ShopSignBoard", Vector3(center.x, 3.85, front_z + front_dir * 0.16), Vector3(5.5, 0.62, 0.16), Color(0.08, 0.18, 0.20), false)
	_label_3d(shop_name, Vector3(center.x, 3.84, front_z + front_dir * 0.27), 0.25)
	for pillar_x in [-3.35, 3.35]:
		_box("ShopFacadePillar", Vector3(center.x + pillar_x, 1.9, front_z + front_dir * 0.18), Vector3(0.22, 3.7, 0.24), facade.darkened(0.25), false)
	for vent_x in [-2.4, 0.0, 2.4]:
		_box("ShopRoofVent", center + Vector3(vent_x, 4.55, -1.8), Vector3(0.85, 0.42, 0.72), Color(0.28, 0.32, 0.33), false)
	_box("ShopRearServiceDoor", center + Vector3(0, 1.0, -front_dir * 3.66), Vector3(0.9, 1.9, 0.08), Color(0.24, 0.20, 0.16), false)

func _build_city_pedestrians() -> void:
	# Pedestrians stay on the wide sidewalks; they have no collision and never
	# enter the vehicle lanes or interfere with the player's movement.
	var outfits: Array[Color] = [
		Color(0.20, 0.38, 0.72), Color(0.72, 0.30, 0.16),
		Color(0.20, 0.48, 0.34), Color(0.62, 0.48, 0.22),
		Color(0.43, 0.30, 0.58), Color(0.18, 0.20, 0.23)
	]
	var skin_tones: Array[Color] = [
		Color(0.78, 0.57, 0.40), Color(0.55, 0.36, 0.25),
		Color(0.91, 0.72, 0.55)
	]
	var index := 0
	for district_x in [32.0, 64.0]:
		for side_z in [-3.35, 3.35]:
			for offset in [-8.0, 0.0, 8.0]:
				var start := Vector3(district_x + offset, 0.0, side_z)
				var walker := Node3D.new()
				walker.name = "CityPedestrian"
				walker.position = start
				add_child(walker)

				var outfit: Color = outfits[index % outfits.size()]
				var skin: Color = skin_tones[index % skin_tones.size()]
				_box_child(walker, "PedestrianTorso", Vector3(0, 1.02, 0), Vector3(0.43, 0.62, 0.27), outfit)
				_sphere_child(walker, "PedestrianHead", Vector3(0, 1.55, 0), Vector3(0.34, 0.36, 0.32), skin)
				_sphere_child(walker, "PedestrianHair", Vector3(0, 1.72, -0.025), Vector3(0.36, 0.17, 0.34), Color(0.16, 0.13, 0.11))
				var left_arm := _cylinder_child(walker, "PedestrianLeftArm", Vector3(-0.29, 1.03, 0), 0.085, 0.58, outfit)
				left_arm.rotation_degrees.z = -12
				var right_arm := _cylinder_child(walker, "PedestrianRightArm", Vector3(0.29, 1.03, 0), 0.085, 0.58, outfit)
				right_arm.rotation_degrees.z = 12
				var left_leg := _cylinder_child(walker, "PedestrianLeftLeg", Vector3(-0.12, 0.43, 0), 0.095, 0.55, Color(0.12, 0.16, 0.20))
				var right_leg := _cylinder_child(walker, "PedestrianRightLeg", Vector3(0.12, 0.43, 0), 0.095, 0.55, Color(0.12, 0.16, 0.20))
				_box_child(walker, "PedestrianLeftShoe", Vector3(-0.12, 0.12, 0.08), Vector3(0.18, 0.10, 0.30), Color(0.055, 0.065, 0.07))
				_box_child(walker, "PedestrianRightShoe", Vector3(0.12, 0.12, 0.08), Vector3(0.18, 0.10, 0.30), Color(0.055, 0.065, 0.07))
				city_pedestrians.append({
					"root": walker,
					"start": start,
					"phase": float(index) * 1.37,
					"direction": 1.0 if index % 2 == 0 else -1.0,
					"left_leg": left_leg,
					"right_leg": right_leg,
					"left_arm": left_arm,
					"right_arm": right_arm
				})
				index += 1


func _animate_city_pedestrians(delta: float) -> void:
	pedestrian_clock += delta
	for pedestrian in city_pedestrians:
		var root := pedestrian.root as Node3D
		if not is_instance_valid(root):
			continue
		var phase: float = pedestrian.phase
		var direction: float = pedestrian.direction
		var walk_phase := pedestrian_clock * 2.6 * direction + phase
		var start: Vector3 = pedestrian.start
		root.position = start + Vector3(sin(walk_phase * 0.35) * 2.0, absf(sin(walk_phase)) * 0.045, 0)
		root.rotation_degrees.y = 90.0 if direction > 0.0 else -90.0
		(pedestrian.left_leg as Node3D).rotation_degrees.z = sin(walk_phase) * 24.0
		(pedestrian.right_leg as Node3D).rotation_degrees.z = -sin(walk_phase) * 24.0
		(pedestrian.left_arm as Node3D).rotation_degrees.z = -sin(walk_phase) * 18.0
		(pedestrian.right_arm as Node3D).rotation_degrees.z = sin(walk_phase) * 18.0


func _sphere_child(parent: Node3D, node_name: String, pos: Vector3, dimensions: Vector3, color: Color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	mesh_instance.scale = dimensions
	mesh_instance.material_override = _mat(color)
	parent.add_child(mesh_instance)
	return mesh_instance


func _cylinder_child(parent: Node3D, node_name: String, pos: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	mesh_instance.material_override = _mat(color)
	parent.add_child(mesh_instance)
	return mesh_instance

func _make_bench(pos: Vector3) -> void:
	_box("ParkBenchSeat", pos + Vector3(0, 0.52, 0), Vector3(1.55, 0.14, 0.48), Color(0.48, 0.29, 0.15), false)
	_box("ParkBenchBack", pos + Vector3(0, 0.92, -0.19), Vector3(1.55, 0.62, 0.12), Color(0.42, 0.25, 0.13), false)
	for x in [-0.58, 0.58]:
		_box("ParkBenchLeg", pos + Vector3(x, 0.26, 0), Vector3(0.12, 0.52, 0.42), Color(0.16, 0.20, 0.20), false)

func _make_parked_car(pos: Vector3) -> void:
	# Decorative vehicle meshes have no collision; parking never blocks movement.
	var paint: Color = [Color(0.68, 0.20, 0.14), Color(0.16, 0.34, 0.56), Color(0.72, 0.68, 0.52), Color(0.18, 0.40, 0.31)][randi() % 4]
	_box("ParkedCarBody", pos + Vector3(0, 0.62, 0), Vector3(3.35, 0.78, 1.55), paint, false)
	_box("ParkedCarCabin", pos + Vector3(0.05, 1.18, 0), Vector3(1.85, 0.62, 1.32), paint.lightened(0.08), false)
	_box("ParkedCarWindshield", pos + Vector3(-0.90, 1.20, 0), Vector3(0.045, 0.43, 1.12), Color(0.12, 0.21, 0.26), false)
	_box("ParkedCarRearGlass", pos + Vector3(1.0, 1.20, 0), Vector3(0.045, 0.40, 1.10), Color(0.12, 0.21, 0.26), false)
	for wheel_x in [-1.05, 1.05]:
		for wheel_z in [-0.82, 0.82]:
			# Wheels stand upright: their axle runs across the car's body (Z axis).
			var wheel := MeshInstance3D.new()
			wheel.name = "ParkedCarWheel"
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.34
			wheel_mesh.bottom_radius = 0.34
			wheel_mesh.height = 0.18
			wheel.mesh = wheel_mesh
			wheel.position = pos + Vector3(wheel_x, 0.34, wheel_z)
			wheel.rotation_degrees.x = 90.0
			wheel.material_override = _mat(Color(0.035, 0.04, 0.045))
			add_child(wheel)
			# Small metallic hub visible on the outside face of each tire.
			var hub := MeshInstance3D.new()
			hub.name = "ParkedCarWheelHub"
			var hub_mesh := CylinderMesh.new()
			hub_mesh.top_radius = 0.15
			hub_mesh.bottom_radius = 0.15
			hub_mesh.height = 0.025
			hub.mesh = hub_mesh
			hub.position = pos + Vector3(wheel_x, 0.34, wheel_z + (0.095 if wheel_z > 0.0 else -0.095))
			hub.rotation_degrees.x = 90.0
			hub.material_override = _mat(Color(0.48, 0.52, 0.52))
			add_child(hub)
	_box("ParkedCarHeadlightL", pos + Vector3(-1.69, 0.70, -0.48), Vector3(0.05, 0.20, 0.28), Color(0.96, 0.84, 0.55), false)
	_box("ParkedCarHeadlightR", pos + Vector3(-1.69, 0.70, 0.48), Vector3(0.05, 0.20, 0.28), Color(0.96, 0.84, 0.55), false)

# Rebuild official Android release for the latest trash-content update.
