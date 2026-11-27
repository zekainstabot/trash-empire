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
var drone_speed_upgrade_level := 0
var drone_capacity_upgrade_level := 0
var ground_robot_level := 0
var ground_collector: Node3D
var ground_collector_timer := 0.0
var sorting_bins: Array[Node3D] = []
var sorting_robots: Array[Node3D] = []
var sorting_robot_levels: Array = [0, 0, 0, 0]
var sorting_bin_counts: Array = [0, 0, 0, 0]
var sorting_area_root: Node3D
var sorting_build_labels: Array[Label3D] = []
# Four stations share one service strip beside the factory, facing the future waste-tank intake.
var sorting_bin_positions: Array[Vector3] = [Vector3(124.8, 0, -26), Vector3(124.8, 0, -12), Vector3(124.8, 0, 20), Vector3(124.8, 0, 30)]
var sorting_pad_positions: Array[Vector3] = [Vector3(119.5, 0, -26), Vector3(119.5, 0, -12), Vector3(119.5, 0, 20), Vector3(119.5, 0, 30)]
var sorting_station_colors: Array[Color] = [Color(0.12, 0.42, 0.88), Color(0.88, 0.76, 0.22), Color(0.48, 0.52, 0.55), Color(0.15, 0.68, 0.42)]
var sorting_station_names: Array[String] = ["PLASTIC", "PAPER", "METAL", "GLASS"]
var sorting_station_categories: Array[String] = ["plastic", "paper", "metal", "glass"]
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
var magnet_field_ring: MeshInstance3D
var vacuum_rotor: Node3D
var vacuum_status_light: MeshInstance3D
var unload_timer := 0.0
var upgrade_panel: Panel
var bag_upgrade_button: Button
var movement_upgrade_button: Button
var unload_upgrade_button: Button
var trash_nodes: Array[Node3D] = []
var final_zone_cleaned := 0
var final_cleanup_spawned := false
var total_trash_collected := 0
var replenishment_threshold := 500
var final_zone_label: Label
const FINAL_ZONE_TARGET := 60000
const COLLECTION_TARGET := 600000
const FINAL_ZONE_MISSION_TARGET := 1000
const MISSION_ORDER := [0, 1, 2, 4, 5, 6, 7, 3, 8, 9, 10, 12, 16, 31, 22, 23, 13, 14, 15, 19, 20, 21, 24, 25, 26, 27, 28, 29, 17, 18, 30]
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
var factory_conveyor_slats: Array[Node3D] = []
var conveyor_item_count := 0
var factory_stage := 1
var factory_built_stage := 1
var factory_visual_root: Node3D
var factory_build_zones_root: Node3D
var factory_build_label: Label3D
var factory_build_paid := 0.0
var factory_build_save_timer := 0.0
var mega_factory_built_count := 1
var factory_row_input_stock: Array = [0, 0, 0, 0, 0]
var factory_row_stage1_stock: Array = [0, 0, 0, 0, 0]
var factory_row_stage2_stock: Array = [0, 0, 0, 0, 0]
var factory_row_product_stock: Array = [0, 0, 0, 0, 0]
var factory_row_belt_items: Array = [[], [], [], [], []]
var factory_total_products_made := 0
const FACTORY_INPUT_CAPACITY_PER_ROW := 90
const FACTORY_PRODUCT_CAPACITY_PER_ROW := 60
var factory_production_timer := 0.0
var waste_tank_inventory := 0
var factory_waste_deposited_total := 0
const WASTE_TANK_BASE_CAPACITY := 300
var waste_tank_capacity_upgrade_level := 0

func _waste_tank_capacity() -> int:
	return WASTE_TANK_BASE_CAPACITY + waste_tank_capacity_upgrade_level * 200
var mega_factory_build_paid := 0.0
var mega_factory_build_timer := 0.0
var mega_factory_machine_labels: Array[Label3D] = []
var factory_machine_status_label: Label3D
var factory_shipping_timer := 0.0
var factory_shipping_cooldown := 0.0
var factory_truck_interval_upgrade_level := 0
var factory_shipping_busy := false
var factory_shipping_row := 0
var factory_shipping_trucks: Array[Node3D] = []
var waste_tank_built := false
var waste_tank_root: Node3D
var waste_tank_build_label: Label3D
var waste_tank_inventory_label: Label3D
var waste_feed_timer := 0.0
var waste_feed_busy := false
var waste_feed_conveyor_network_built := false
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
var sorting_robot_upgrade_level := 0
var conveyor_speed_upgrade_level := 0
var waste_tank_unload_upgrade_level := 0
var repair_robot_level := 0
var machine_broken := false
var machine_work_timer := 0.0
var machine_repair_timer := 0.0
var refill_world_button: Node3D
var main_menu_panel: Control
var main_menu_open := true
var new_game_button: Button
var main_menu_play_button: Button
var skill_tree_built := false
var world_initialized := false
var city_pedestrians: Array[Dictionary] = []
var pedestrian_clock := 0.0
var street_sweepers: Array[Node3D] = []
var street_sweeper_route: Array[Vector3] = []

const YARD_LIMIT := 14.5
const SELL_POINT := Vector3(1.35, 0.0, -6.5)
const STARTER_SELL_POINT := Vector3(143.0, 0.0, 5.5)

func _ready() -> void:
	# Establish a known, non-black first frame before loading saves or building UI.
	RenderingServer.set_default_clear_color(Color(0.035, 0.055, 0.065, 1.0))
	camera = Camera3D.new()
	camera.name = "BootCamera"
	camera.position = Vector3(0.0, 12.0, 24.0)
	camera.rotation_degrees = Vector3(-22.0, 0.0, 0.0)
	camera.near = 0.05
	camera.far = 250.0
	add_child(camera)
	camera.make_current()

	# Draw a tiny startup screen immediately. The previous boot path performed
	# save loading and the complete HUD construction before Android rendered a
	# frame, which could leave slower devices displaying only a black screen.
	var boot_layer := CanvasLayer.new()
	boot_layer.name = "BootLoadingLayer"
	boot_layer.layer = 100
	add_child(boot_layer)
	var boot_backdrop := ColorRect.new()
	boot_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	boot_backdrop.color = Color(0.035, 0.055, 0.065, 1.0)
	boot_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boot_layer.add_child(boot_backdrop)
	var boot_title := Label.new()
	boot_title.text = "ZEKA CITY"
	boot_title.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	boot_title.position = Vector2(-150, -34)
	boot_title.size = Vector2(300, 48)
	boot_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boot_title.add_theme_font_size_override("font_size", 30)
	boot_title.add_theme_color_override("font_color", Color(0.48, 0.94, 0.75))
	boot_layer.add_child(boot_title)
	var boot_status := Label.new()
	boot_status.text = "LOADING GAME..."
	boot_status.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	boot_status.position = Vector2(-150, 18)
	boot_status.size = Vector2(300, 28)
	boot_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boot_status.add_theme_font_size_override("font_size", 14)
	boot_status.add_theme_color_override("font_color", Color(0.88, 0.93, 0.91))
	boot_layer.add_child(boot_status)
	main_menu_open = true
	set_process(true)
	set_physics_process(true)
	call_deferred("_finish_boot_sequence")


func _finish_boot_sequence() -> void:
	# Run after the loading screen has had a chance to render on mobile.
	await get_tree().process_frame
	_load_game()
	_build_ui()
	_update_ui()
	if is_instance_valid(main_menu_panel):
		main_menu_panel.show()
	var boot_layer := get_node_or_null("BootLoadingLayer")
	if is_instance_valid(boot_layer):
		boot_layer.queue_free()
	if OS.get_cmdline_user_args().has("--test-gameplay"):
		await _close_main_menu()
		await _start_new_world()
		if not world_initialized or not is_instance_valid(player) or not is_instance_valid(camera) or not is_instance_valid(factory_visual_root) or trash_nodes.is_empty():
			push_error("GAMEPLAY_SMOKE_TEST_FAILED: the world, player, factory, or trash pool did not initialize.")
			get_tree().quit(1)
			return

		var movement_start := player.global_position
		player.set_touch_move(Vector2(0.0, -1.0))
		await get_tree().create_timer(0.55).timeout
		player.set_touch_move(Vector2.ZERO)
		if player.global_position.distance_to(movement_start) < 0.20:
			push_error("GAMEPLAY_SMOKE_TEST_FAILED: touch movement did not move the player.")
			get_tree().quit(1)
			return

		var test_item := Node3D.new()
		test_item.set_script(TRASH_SCRIPT)
		test_item.position = player.global_position + Vector3(0.0, 0.0, -0.85)
		add_child(test_item)
		trash_nodes.append(test_item)
		await get_tree().process_frame
		var carried_before_test := carried
		_collect_nearby()
		if carried <= carried_before_test:
			push_error("GAMEPLAY_SMOKE_TEST_FAILED: the player could not collect nearby litter.")
			get_tree().quit(1)
			return

		player.global_position = STARTER_SELL_POINT
		player.velocity = Vector3.ZERO
		unload_timer = 0.0
		var money_before_test := money
		_process_auto_sell(5.0)
		if carried != 0 or money <= money_before_test:
			push_error("GAMEPLAY_SMOKE_TEST_FAILED: automatic recycling drop-off did not unload and pay.")
			get_tree().quit(1)
			return

		money = 1000.0
		factory_stage = 1
		factory_built_stage = 1
		factory_build_paid = 0.0
		player.global_position = Vector3(7.5, 0.0, 0.0)
		for build_step in range(40):
			_process_factory_build(1.0)
			if factory_stage >= 2:
				break
		if factory_stage < 2 or factory_built_stage < 2:
			push_error("GAMEPLAY_SMOKE_TEST_FAILED: the first factory expansion could not be constructed.")
			get_tree().quit(1)
			return

		money = 10000.0
		await _purchase_skill_node("ground_robot", 1)
		if ground_robot_level != 1 or not is_instance_valid(ground_collector) or not ground_collector.visible:
			push_error("GAMEPLAY_SMOKE_TEST_FAILED: the ground collector upgrade did not deploy its rover.")
			get_tree().quit(1)
			return

		money = 10000.0
		await _purchase_skill_node("drones", 1)
		var first_drone_visible := not helper_drones.is_empty() and is_instance_valid(helper_drones[0]) and helper_drones[0].visible
		if drone_level != 1 or not first_drone_visible:
			push_error("GAMEPLAY_SMOKE_TEST_FAILED: helper drone deployment failed (level=%d, count=%d, money=%.1f)." % [drone_level, helper_drones.size(), money])
			get_tree().quit(1)
			return

		money = 10000.0
		_build_sorting_station(0)
		if sorting_robot_levels[0] != 1 or sorting_robots.is_empty() or not sorting_robots[0].visible or not is_instance_valid(sorting_bins[0]):
			push_error("GAMEPLAY_SMOKE_TEST_FAILED: the first recycling station did not build its loader and bin.")
			get_tree().quit(1)
			return
		money = 10000.0
		await _purchase_skill_node("sorting_robot", 1)
		if sorting_robot_upgrade_level != 1:
			push_error("GAMEPLAY_SMOKE_TEST_FAILED: sorting loader efficiency upgrade did not apply.")
			get_tree().quit(1)
			return

		print("GAMEPLAY_SMOKE_TEST_OK: movement, collection, recycling, factory construction, rover, drones, and sorting loaders.")
		await get_tree().create_timer(0.5).timeout
		get_tree().quit(0)

func _process(delta: float) -> void:
	if main_menu_open:
		return
	_process_upgrade_scroll_smoothing(delta)
	_process_expansion_zone(delta)
	_process_factory_build(delta)
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
	_process_street_sweeper(delta)
	_process_trash_respawn(delta)
	_animate_city_pedestrians(delta)

func _build_world() -> void:
	# Clean daylight lighting for the redesigned, open city.
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky_resource := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.12, 0.22, 0.28)
	sky_material.sky_horizon_color = Color(0.48, 0.56, 0.58)
	sky_material.ground_bottom_color = Color(0.12, 0.16, 0.15)
	sky_material.ground_horizon_color = Color(0.34, 0.40, 0.39)
	sky_material.use_debanding = true
	sky_resource.sky_material = sky_material
	env.sky = sky_resource
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.62, 0.69, 0.68)
	env.ambient_light_energy = 0.88
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.0
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -32, 0)
	sun.light_energy = 1.12
	sun.shadow_enabled = true
	sun.shadow_bias = 0.035
	sun.directional_shadow_max_distance = 90.0
	add_child(sun)

	_build_city_rework_layout()
	_build_industrial_road_fixtures()
	_build_street_sweeper()
	_build_city_dump_area()
	_build_recycling_mega_factory()
	_build_ground_robot_service_station()
	_build_industrial_campus_details()
	_build_starter_dropoff_pad()
	_build_sorting_district()
	_build_city_pedestrians()
	_build_world_bounds()
	refill_world_button = _create_gear_refill_button(Vector3(0.0, 2.0, -35.20), Callable(self, "_refill_first_district"))
	refill_world_button.rotation_degrees.y = 90.0


func _build_industrial_road_fixtures() -> void:
	# Flat, non-colliding utility details reinforce the municipal/industrial road
	# language while preserving the requested longitudinal-only lane markings.
	var reflector := Color(0.96, 0.68, 0.16)
	var drain_steel := Color(0.24, 0.30, 0.31)
	var drain_dark := Color(0.045, 0.06, 0.065)

	for road_x in range(-10, 113, 8):
		for side in [-1.0, 1.0]:
			_box("IndustrialBoulevardReflector", Vector3(float(road_x), 0.078, side * 3.42), Vector3(0.30, 0.025, 0.10), reflector, false)

	for street_x in [16.0, 48.0, 80.0, 104.0]:
		for road_z in range(-34, 35, 8):
			for side in [-1.0, 1.0]:
				_box("IndustrialCrossStreetReflector", Vector3(street_x + side * 2.86, 0.078, float(road_z)), Vector3(0.10, 0.025, 0.30), reflector, false)
		for side in [-1.0, 1.0]:
			var drain_x: float = float(street_x) + float(side) * 3.08
			for drain_z in [-27.0, -9.0, 9.0, 27.0]:
				_box("IndustrialStreetDrainFrame", Vector3(drain_x, 0.074, drain_z), Vector3(0.34, 0.035, 0.92), drain_steel, false)
				for slot in range(5):
					_box("IndustrialStreetDrainSlot", Vector3(drain_x, 0.095, drain_z - 0.34 + float(slot) * 0.17), Vector3(0.25, 0.012, 0.035), drain_dark, false)

	for cover_x in [4.0, 36.0, 68.0, 100.0]:
		for side in [-1.0, 1.0]:
			_cylinder("IndustrialBoulevardManhole", Vector3(cover_x, 0.072, side * 3.05), 0.34, 0.035, drain_steel, false)
			_cylinder("IndustrialBoulevardManholeInset", Vector3(cover_x, 0.094, side * 3.05), 0.27, 0.012, drain_dark, false)
			for slot in range(4):
				_box("IndustrialManholeSlot", Vector3(cover_x - 0.16 + float(slot) * 0.105, 0.103, side * 3.05), Vector3(0.025, 0.008, 0.32), drain_steel, false)

	# The factory approach gets durable yellow edge paint and drainage channels.
	for side in [-1.0, 1.0]:
		_box("IndustrialAccessRoadEdgeLine", Vector3(119.25, 0.068, side * 3.48), Vector3(22.5, 0.022, 0.085), reflector, false)
		_box("IndustrialAccessRoadDrain", Vector3(119.25, 0.075, side * 3.88), Vector3(21.5, 0.035, 0.22), drain_steel, false)
		for slot in range(22):
			_box("IndustrialAccessDrainSlot", Vector3(108.8 + float(slot) * 0.98, 0.098, side * 3.88), Vector3(0.035, 0.012, 0.16), drain_dark, false)


func _build_ground_robot_service_station() -> void:
	# Dedicated autonomous rover service bay. All meshes are decorative and
	# non-colliding; the rover's home/dispatch coordinates remain unchanged.
	var center := Vector3(144.0, 0.0, 10.0)
	var steel := Color(0.13, 0.19, 0.21)
	var frame := Color(0.34, 0.43, 0.44)
	var safety := Color(0.96, 0.64, 0.13)
	var dark := Color(0.045, 0.075, 0.082)
	var cyan := Color(0.10, 0.86, 0.78)
	var floor := Color(0.20, 0.27, 0.28)

	_box("RoverServiceFoundation", center + Vector3(0, 0.045, 0), Vector3(7.2, 0.09, 7.0), steel, false)
	_box("RoverServiceBayFloor", center + Vector3(0, 0.105, 0), Vector3(6.5, 0.035, 6.3), floor, false)
	for side in [-1.0, 1.0]:
		_box("RoverServiceBayEdge", center + Vector3(side * 3.22, 0.14, 0), Vector3(0.10, 0.035, 6.25), safety, false)
		_box("RoverServiceBayEdge", center + Vector3(0, 0.14, side * 3.10), Vector3(6.45, 0.035, 0.10), safety, false)
		_box("RoverServiceWheelGuide", center + Vector3(side * 0.78, 0.17, 0), Vector3(0.09, 0.06, 4.65), Color(0.48, 0.58, 0.56), false)
	for stripe_index in range(8):
		_box("RoverServiceHazardStripe", center + Vector3(-2.65 + float(stripe_index) * 0.76, 0.17, -2.72), Vector3(0.42, 0.025, 0.28), safety, false)

	# Four clear-span columns keep the rover's approach and turning envelope open.
	for side_x in [-1.0, 1.0]:
		for side_z in [-1.0, 1.0]:
			var post := center + Vector3(side_x * 3.05, 2.15, side_z * 2.85)
			_box("RoverServiceCanopyColumn", post, Vector3(0.22, 4.3, 0.22), frame, false)
			_box("RoverServiceColumnFoot", post + Vector3(0, -1.98, 0), Vector3(0.58, 0.18, 0.58), steel, false)
			_box("RoverServiceColumnSafetyBand", post + Vector3(0, -1.25, 0), Vector3(0.25, 0.32, 0.25), safety, false)
	_box("RoverServiceCanopyBeamFront", center + Vector3(0, 4.28, -2.85), Vector3(6.35, 0.24, 0.24), frame, false)
	_box("RoverServiceCanopyBeamRear", center + Vector3(0, 4.28, 2.85), Vector3(6.35, 0.24, 0.24), frame, false)
	_box("RoverServiceCanopyBeamLeft", center + Vector3(-3.05, 4.28, 0), Vector3(0.24, 0.24, 5.7), frame, false)
	_box("RoverServiceCanopyBeamRight", center + Vector3(3.05, 4.28, 0), Vector3(0.24, 0.24, 5.7), frame, false)
	_box("RoverServiceRoof", center + Vector3(0, 4.48, 0), Vector3(6.35, 0.16, 5.95), dark, false)
	_box("RoverServiceRoofPanel", center + Vector3(0, 4.575, 0), Vector3(5.85, 0.035, 5.45), Color(0.20, 0.30, 0.32), false)
	for roof_rib in range(7):
		_box("RoverServiceRoofRib", center + Vector3(-2.55 + float(roof_rib) * 0.85, 4.61, 0), Vector3(0.055, 0.045, 5.35), frame, false)

	# Retractable service arms and charging couplers sit outside the rover footprint.
	for side in [-1.0, 1.0]:
		var arm_x: float = side * 2.45
		_box("RoverServiceArmPedestal", center + Vector3(arm_x, 0.82, 0.15), Vector3(0.42, 1.55, 0.48), steel, false)
		_box("RoverServiceArmShoulder", center + Vector3(side * 1.95, 1.62, 0.15), Vector3(1.05, 0.16, 0.18), frame, false)
		_box("RoverServiceArmTool", center + Vector3(side * 1.48, 1.48, 0.15), Vector3(0.18, 0.42, 0.34), safety, false)
		_box("RoverServiceChargePost", center + Vector3(arm_x, 1.45, 2.05), Vector3(0.28, 2.45, 0.28), frame, false)
		_box("RoverServiceChargeHead", center + Vector3(arm_x, 2.55, 1.78), Vector3(0.42, 0.28, 0.62), dark, false)
		_box("RoverServiceChargeIndicator", center + Vector3(arm_x, 2.58, 1.45), Vector3(0.22, 0.08, 0.035), cyan, false)

	# Diagnostic kiosk and status signage are mounted on the rear service edge.
	_box("RoverServiceControlCabinet", center + Vector3(0, 1.05, 3.65), Vector3(1.75, 2.05, 0.62), dark, false)
	_box("RoverServiceControlScreen", center + Vector3(0, 1.38, 3.315), Vector3(1.18, 0.72, 0.045), Color(0.025, 0.20, 0.22), false)
	_box("RoverServiceScreenGlow", center + Vector3(0, 1.39, 3.285), Vector3(0.92, 0.045, 0.018), cyan, false)
	_label_3d("ZEKA ROVER SERVICE", center + Vector3(0, 2.35, 3.28), 0.18)
	_box("RoverServiceStatusBeacon", center + Vector3(-1.25, 2.55, 3.55), Vector3(0.22, 0.42, 0.22), safety, false)
	_box("RoverServiceStatusLight", center + Vector3(-1.25, 2.80, 3.55), Vector3(0.15, 0.08, 0.15), cyan, false)
	for lamp_x in [-2.0, 2.0]:
		_box("RoverServiceCanopyLamp", center + Vector3(lamp_x, 4.30, 0), Vector3(0.72, 0.08, 0.42), Color(0.78, 0.91, 0.84), false)
	_box("RoverServiceIdentitySign", center + Vector3(0, 5.15, -2.96), Vector3(4.6, 0.78, 0.16), dark, false)
	_label_3d("AUTONOMOUS FLEET / CHARGE + REPAIR", center + Vector3(0, 5.16, -2.84), 0.14)


func _build_starter_dropoff_pad() -> void:
	var center := STARTER_SELL_POINT
	var steel := Color(0.15, 0.22, 0.24)
	var yellow := Color(0.96, 0.66, 0.14)
	_box("IndustrialStartupDropoffPad", center + Vector3(0, 0.035, 0), Vector3(6.2, 0.07, 6.2), steel, false)
	_box("IndustrialStartupDropoffInner", center + Vector3(0, 0.078, 0), Vector3(5.35, 0.018, 5.35), Color(0.22, 0.29, 0.30), false)
	for side in [-1.0, 1.0]:
		_box("IndustrialStartupDropoffEdge", center + Vector3(side * 2.78, 0.092, 0), Vector3(0.14, 0.022, 5.5), yellow, false)
		_box("IndustrialStartupDropoffEdge", center + Vector3(0, 0.092, side * 2.78), Vector3(5.5, 0.022, 0.14), yellow, false)
	for stripe_index in range(7):
		_box("IndustrialStartupDropoffStripe", center + Vector3(-2.0 + float(stripe_index) * 0.66, 0.095, -2.55), Vector3(0.34, 0.02, 0.30), yellow, false)
	for bollard_x in [-2.55, 2.55]:
		for bollard_z in [-2.55, 2.55]:
			_cylinder("IndustrialStartupDropoffBollard", center + Vector3(bollard_x, 0.48, bollard_z), 0.13, 0.92, yellow, false)
	_box("IndustrialStartupDropoffKiosk", center + Vector3(0, 1.10, -3.65), Vector3(1.25, 1.55, 0.52), Color(0.055, 0.095, 0.105), false)
	_box("IndustrialStartupDropoffDisplay", center + Vector3(0, 1.26, -3.94), Vector3(0.82, 0.55, 0.045), Color(0.08, 0.63, 0.58), false)
	_label_3d("STARTUP RECYCLING DROP-OFF", center + Vector3(0, 2.20, -3.65), 0.16)


func _build_industrial_campus_details() -> void:
	# Decorative infrastructure frames the production hall without blocking
	# conveyors, machine pads, truck lanes, or player paths.
	var structural_steel := Color(0.19, 0.25, 0.27)
	var pipe_steel := Color(0.48, 0.55, 0.55)
	var safety_yellow := Color(0.94, 0.64, 0.14)
	var floor_joint := Color(0.22, 0.27, 0.27)

	for side in [-1.0, 1.0]:
		var rack_z: float = float(side) * 32.55
		for support_x in [149.0, 162.0, 175.0, 188.0, 201.0]:
			_box("IndustrialCampusPipeRackFoot", Vector3(support_x, 0.20, rack_z), Vector3(0.76, 0.38, 0.76), structural_steel, false)
			_box("IndustrialCampusPipeRackColumn", Vector3(support_x, 2.45, rack_z), Vector3(0.24, 4.55, 0.24), pipe_steel, false)
			_box("IndustrialCampusPipeRackCrossbeam", Vector3(support_x, 4.78, rack_z), Vector3(0.34, 0.24, 2.05), structural_steel, false)
			_box("IndustrialCampusPipeRackSafetyBand", Vector3(support_x, 1.05, rack_z), Vector3(0.25, 0.46, 0.27), safety_yellow, false)
		for pipe_index in range(3):
			var pipe_z: float = rack_z + (float(pipe_index) - 1.0) * 0.58
			var pipe_y := 3.95 + float(pipe_index) * 0.43
			var utility_pipe := _cylinder("IndustrialCampusUtilityPipe", Vector3(175.0, pipe_y, pipe_z), 0.105, 52.0, pipe_steel.darkened(float(pipe_index) * 0.08), false)
			utility_pipe.rotation_degrees.z = 90.0
		for valve_x in [158.0, 184.0]:
			_cylinder("IndustrialCampusPipeValve", Vector3(valve_x, 4.42, rack_z), 0.22, 0.42, Color(0.15, 0.35, 0.34), false)
			_box("IndustrialCampusValveHandle", Vector3(valve_x, 4.72, rack_z), Vector3(0.56, 0.07, 0.08), safety_yellow, false)

	for stack_z in [-28.8, 28.8]:
		_cylinder("IndustrialCampusExhaustStackBase", Vector3(201.0, 0.52, stack_z), 0.86, 1.04, structural_steel, false)
		_cylinder("IndustrialCampusExhaustStack", Vector3(201.0, 4.15, stack_z), 0.58, 6.35, Color(0.34, 0.41, 0.42), false)
		for band_y in [2.0, 4.5, 6.8]:
			_cylinder("IndustrialCampusExhaustCollar", Vector3(201.0, band_y, stack_z), 0.64, 0.16, structural_steel, false)
		_cylinder("IndustrialCampusExhaustRainCap", Vector3(201.0, 7.42, stack_z), 0.82, 0.18, Color(0.16, 0.22, 0.24), false)
		_box("IndustrialCampusExhaustWarningBand", Vector3(200.40, 5.7, stack_z), Vector3(0.05, 0.22, 0.68), safety_yellow, false)

	for row in range(5):
		var row_z := _factory_row_z(row)
		for side in [-1.0, 1.0]:
			_box("IndustrialCampusSafetyWalkway", Vector3(174.0, 0.312, row_z + side * 4.92), Vector3(48.0, 0.018, 0.11), safety_yellow, false)
		for bay_x in [151.0, 164.0, 177.0, 190.0]:
			for side in [-1.0, 1.0]:
				_box("IndustrialCampusMachineBayMark", Vector3(bay_x, 0.314, row_z + side * 2.68), Vector3(3.0, 0.018, 0.07), safety_yellow, false)
	for joint_x in [146.0, 160.0, 174.0, 188.0, 202.0]:
		_box("IndustrialCampusConcreteJoint", Vector3(joint_x, 0.307, 0.0), Vector3(0.035, 0.012, 60.0), floor_joint, false)

	for light_x in [153.0, 175.0, 197.0]:
		for light_z in [-30.5, 30.5]:
			_box("IndustrialCampusFloodlightMast", Vector3(light_x, 3.0, light_z), Vector3(0.14, 6.0, 0.14), structural_steel, false)
			_box("IndustrialCampusFloodlightHousing", Vector3(light_x, 6.05, light_z), Vector3(0.88, 0.22, 0.48), structural_steel, false)
			_box("IndustrialCampusFloodlightLens", Vector3(light_x, 5.92, light_z - signf(light_z) * 0.18), Vector3(0.62, 0.055, 0.08), Color(0.95, 0.84, 0.58), false)
	_box("IndustrialCampusIdentitySign", Vector3(174.0, 6.55, -34.15), Vector3(15.0, 1.75, 0.24), Color(0.045, 0.085, 0.095), false)
	_label_3d("ZEKA INDUSTRIAL RECYCLING COMPLEX", Vector3(174.0, 6.55, -33.98), 0.28)


func _build_world_bounds() -> void:
	# Invisible collision walls keep the player inside the continuous playable map.
	# The ground spans approximately X=-14..208 and Z=-37..37.
	var wall_y := 4.0
	var wall_height := 8.0
	_add_invisible_barrier("WorldBoundaryWest", Vector3(-12.8, wall_y, 0.0), Vector3(1.2, wall_height, 76.0))
	_add_invisible_barrier("WorldBoundaryEast", Vector3(206.8, wall_y, 0.0), Vector3(1.2, wall_height, 76.0))
	# Leave a dedicated access opening for the drone annex on the north edge.
	_add_invisible_barrier("WorldBoundaryNorthWest", Vector3(54.5, wall_y, -36.2), Vector3(135.0, wall_height, 1.2))
	_add_invisible_barrier("WorldBoundaryNorthEast", Vector3(173.5, wall_y, -36.2), Vector3(67.0, wall_height, 1.2))
	_add_invisible_barrier("WorldBoundarySouth", Vector3(97.0, wall_y, 36.2), Vector3(220.0, wall_height, 1.2))


func _build_city_rework_layout() -> void:
	# One continuous, walkable city surface replaces the old fenced concrete yard.
	var grass := Color(0.27, 0.43, 0.29)
	var asphalt := Color(0.105, 0.125, 0.14)
	var sidewalk := Color(0.43, 0.29, 0.19)
	var curb := Color(0.63, 0.47, 0.32)
	var white := Color(0.90, 0.88, 0.79)
	_box("CityTerrain", Vector3(49.0, -0.34, 0.0), Vector3(126.0, 0.68, 74.0), grass, true)
	# Keep the cleanup ground out of the factory footprint. These slabs previously
	# occupied the exact same Y=0 plane as the factory apron/foundation and each
	# other, causing severe z-fighting across the entire industrial area.
	_box("FinalCleanupGroundWest", Vector3(121.25, -0.34, 0.0), Vector3(18.5, 0.68, 74.0), grass, true)
	_box("FinalCleanupGroundEast", Vector3(205.0, -0.34, 0.0), Vector3(6.0, 0.68, 74.0), grass, true)
	# Separate northern annex gives the autonomous drones a clear home away from roads,
	# factory conveyors, loading trucks and sorting equipment.
	_box("DroneHubAnnexGround", Vector3(130.0, -0.34, -43.5), Vector3(18.0, 0.68, 15.0), grass, true)
	_box("DroneHubAccessPath", Vector3(130.0, 0.035, -38.5), Vector3(5.5, 0.07, 5.5), Color(0.43, 0.46, 0.42), false)

	# Dark charcoal asphalt, raised curbs and layered markings make this read as a
	# paved multi-lane boulevard rather than a flat grey platform.
	var road_asphalt := Color(0.105, 0.112, 0.118)
	var road_worn := Color(0.135, 0.143, 0.148)
	var road_white := Color(0.91, 0.91, 0.84)
	var road_yellow := Color(0.96, 0.72, 0.12)
	_box("CityGrandBoulevard", Vector3(49.0, 0.025, 0.0), Vector3(126.0, 0.05, 8.2), road_asphalt, false)
	# Subtle resurfaced asphalt strips add material variation without visual clutter.
	for patch_x in range(-10, 111, 18):
		_box("BoulevardAsphaltPatch", Vector3(float(patch_x), 0.052, 0.0), Vector3(8.0, 0.006, 7.65), road_worn, false)
	for side in [-1.0, 1.0]:
		_box("BoulevardCurb", Vector3(49.0, 0.09, side * 4.25), Vector3(126.0, 0.18, 0.28), curb, true)
		_box("BoulevardEdgeLine", Vector3(49.0, 0.061, side * 3.72), Vector3(126.0, 0.025, 0.12), road_white, false)
		_add_sidewalk_x_segments("BoulevardSidewalk", -14.0, 112.0, 0.075, 0.15, side * 6.0, 3.2, sidewalk, [16.0, 48.0, 80.0, 104.0], 13.0)
		_add_sidewalk_x_segments("BoulevardGrassVerge", -14.0, 112.0, 0.025, 0.05, side * 8.45, 0.9, grass.lightened(0.08), [16.0, 48.0, 80.0, 104.0], 13.0)
	# Double yellow no-passing divider and broken white lane separators.
	for offset in [-0.13, 0.13]:
		for segment in [[-14.0, 12.3], [19.7, 44.3], [51.7, 76.3], [83.7, 100.3], [107.7, 112.0]]:
			var segment_start: float = segment[0]
			var segment_end: float = segment[1]
			_box("BoulevardDoubleYellow", Vector3((segment_start + segment_end) * 0.5, 0.064, offset), Vector3(segment_end - segment_start, 0.025, 0.075), road_yellow, false)
	for lane_z in [-1.55, 1.55]:
		for dash_x in range(-12, 115, 8):
			var clear_of_junctions := true
			for junction_x in [16.0, 48.0, 80.0, 104.0]:
				if absf(float(dash_x) - junction_x) < 5.0:
					clear_of_junctions = false
			if clear_of_junctions:
				_box("BoulevardLaneDash", Vector3(float(dash_x), 0.064, lane_z), Vector3(4.0, 0.022, 0.095), road_white, false)

	# Four perpendicular streets with their own asphalt, center lines, edge lines,
	# stop bars and zebra crossings at the boulevard junctions.
	for street_x in [16.0, 48.0, 80.0, 104.0]:
		_box("CityCrossStreet", Vector3(street_x, 0.028, 0.0), Vector3(6.8, 0.056, 74.0), road_asphalt, false)
		for side in [-1.0, 1.0]:
			# Break the raised curb at the boulevard crossings for wheelchair access.
			for curb_segment in [[-37.0, -8.0], [-4.0, 4.0], [8.0, 37.0]]:
				var curb_start: float = curb_segment[0]
				var curb_end: float = curb_segment[1]
				_box("CrossStreetCurb", Vector3(street_x + side * 3.55, 0.09, (curb_start + curb_end) * 0.5), Vector3(0.22, 0.18, curb_end - curb_start), curb, true)
			_add_sidewalk_z_segments("CrossStreetWalkway", -37.0, 37.0, 0.075, 0.15, street_x + side * 5.0, 2.7, sidewalk, [Vector2(-29.0, 9.0), Vector2(-22.0, 9.0), Vector2(0.0, 16.0), Vector2(22.0, 9.0), Vector2(29.0, 9.0)], 8.0)
			# Flush ramp landing and tactile warning strip at both boulevard crossings.
			for ramp_z in [-6.0, 6.0]:
				_box("AccessibleCurbRamp", Vector3(street_x + side * 3.78, 0.045, ramp_z), Vector3(0.62, 0.09, 2.4), Color(0.55, 0.39, 0.26), false)
				_box("RampTactileWarning", Vector3(street_x + side * 4.35, 0.084, ramp_z), Vector3(0.32, 0.018, 2.15), Color(0.86, 0.70, 0.43), false)
			# Continue the tiled sidewalk through every boulevard-junction corner.
			# The four corner pads meet both sidewalk runs and cover the exposed grass,
			# while staying outside the asphalt road footprint.
			for boulevard_side in [-1.0, 1.0]:
				var corner_x: float = street_x + side * 5.0
				var corner_z: float = boulevard_side * 6.0
				# Span the full curb-to-curb corner: 3.1 m joins the boulevard
				# sidewalk edge at X=+/-6.5 to the cross-street walk at X=+/-3.65.
				_sidewalk_detailed_segment_x("IntersectionSidewalkCorner", corner_x - 1.55, corner_x + 1.55, 0.075, 0.15, corner_z, 3.2, sidewalk)

		# High-visibility zebra crossings connect both sidewalk approaches across each side street.
		for crossing_side in [-1.0, 1.0]:
			var crossing_center_z: float = crossing_side * 6.0
			for stripe_index in range(6):
				var stripe_z: float = crossing_center_z + (float(stripe_index) - 2.5) * 0.62
				_box("CrossStreetZebraStripe", Vector3(street_x, 0.067, stripe_z), Vector3(5.85, 0.026, 0.34), road_white, false)
			# Stop line is set back from the crossing, outside the pedestrian path.
			var stop_z: float = crossing_side * 9.2
			_box("CrossStreetStopBar", Vector3(street_x, 0.067, stop_z), Vector3(5.85, 0.026, 0.14), road_white, false)

		for offset in [-0.13, 0.13]:
			for segment in [[-37.0, -32.5], [-25.0, -19.0], [-4.0, 4.0], [19.0, 25.0], [32.5, 37.0]]:
				var line_start: float = segment[0]
				var line_end: float = segment[1]
				_box("CrossStreetDoubleYellow", Vector3(street_x + offset, 0.064, (line_start + line_end) * 0.5), Vector3(0.075, 0.025, line_end - line_start), road_yellow, false)
		for lane_z in [-1.35, 1.35]:
			for dash_z in range(-35, 36, 9):
				var clear_of_junctions := true
				for junction_z in [-29.0, -22.0, 0.0, 22.0, 29.0]:
					if absf(float(dash_z) - junction_z) < 5.0:
						clear_of_junctions = false
				if clear_of_junctions:
					_box("CrossStreetLaneDash", Vector3(street_x + lane_z, 0.064, float(dash_z)), Vector3(0.09, 0.022, 4.2), road_white, false)

	# Narrow neighborhood streets get realistic edge paint, broken center markings,
	# parking-bay separators and curbside pavements.
	for street_z in [-22.0, 22.0]:
		_box("NeighborhoodStreet", Vector3(49.0, 0.024, street_z), Vector3(126.0, 0.048, 5.4), road_asphalt, false)
		for side in [-1.0, 1.0]:
			_add_sidewalk_x_segments("NeighborhoodSidewalk", -14.0, 112.0, 0.07, 0.14, street_z + side * 3.45, 1.5, sidewalk, [16.0, 48.0, 80.0, 104.0], 13.0)
			for segment in [[-14.0, 12.0], [20.0, 44.0], [52.0, 76.0], [84.0, 100.0], [108.0, 112.0]]:
				var edge_start: float = segment[0]
				var edge_end: float = segment[1]
				_box("NeighborhoodEdgeLine", Vector3((edge_start + edge_end) * 0.5, 0.057, street_z + side * 2.45), Vector3(edge_end - edge_start, 0.02, 0.075), road_white, false)
		for segment in [[-14.0, 12.0], [20.0, 44.0], [52.0, 76.0], [84.0, 100.0], [108.0, 112.0]]:
			var line_start: float = segment[0]
			var line_end: float = segment[1]
			_box("NeighborhoodCenterLine", Vector3((line_start + line_end) * 0.5, 0.058, street_z), Vector3(line_end - line_start, 0.02, 0.09), road_yellow, false)


	# Residential and civic buildings are arranged as real blocks, leaving clear
	# pedestrian routes and keeping the four sorting-station plots unobstructed.
	_build_city_block_building(Vector3(6.0, 0.0, -31.0), "APARTMENTS", Color(0.72, 0.67, 0.56), 3, 8.0)
	_build_city_block_building(Vector3(38.0, 0.0, -31.0), "CITY HALL", Color(0.70, 0.73, 0.68), 2, 10.0)
	_build_city_block_building(Vector3(70.0, 0.0, -31.0), "LIBRARY", Color(0.70, 0.57, 0.43), 2, 8.0)
	_build_city_block_building(Vector3(96.0, 0.0, -31.0), "CLINIC", Color(0.73, 0.76, 0.72), 2, 7.0)
	_build_city_block_building(Vector3(6.0, 0.0, 31.0), "RESIDENCES", Color(0.67, 0.70, 0.73), 3, 8.5)
	_build_city_block_building(Vector3(38.0, 0.0, 31.0), "SCHOOL", Color(0.76, 0.66, 0.48), 2, 7.0)
	_build_city_block_building(Vector3(70.0, 0.0, 31.0), "FIRE STATION", Color(0.68, 0.43, 0.37), 2, 7.0)
	_build_city_block_building(Vector3(96.0, 0.0, 31.0), "SUPERMARKET", Color(0.52, 0.66, 0.58), 1, 6.0)

	# A proper public park occupies the open civic block, with paths and seating.
	_box("CityParkLawn", Vector3(69.0, 0.055, 13.0), Vector3(9.0, 0.11, 9.5), Color(0.25, 0.48, 0.27), false)
	_box("ParkPathLong", Vector3(69.0, 0.12, 13.0), Vector3(8.0, 0.04, 1.5), sidewalk, false)
	_box("ParkPathCross", Vector3(69.0, 0.125, 13.0), Vector3(1.5, 0.04, 8.0), sidewalk, false)
	_cylinder("CityParkFountainBasin", Vector3(69.0, 0.30, 13.0), 1.55, 0.42, Color(0.48, 0.53, 0.50), false)
	_cylinder("CityParkFountainWater", Vector3(69.0, 0.53, 13.0), 1.30, 0.05, Color(0.19, 0.55, 0.69), false)
	_cylinder("CityParkFountainCore", Vector3(69.0, 0.83, 13.0), 0.24, 0.58, Color(0.70, 0.72, 0.67), false)
	for bench_pos in [Vector3(65.5, 0.0, 13.0), Vector3(72.0, 0.0, 13.0)]:
		_make_bench(bench_pos)
	for tree_pos in [Vector3(65.5, 0.0, 10.0), Vector3(72.0, 0.0, 10.0), Vector3(65.5, 0.0, 16.0), Vector3(72.0, 0.0, 16.0)]:
		_build_neighborhood_tree(tree_pos)

	# Player's starting plaza and waste drop-off remain easy to find.
	_box("PlayerWelcomePlaza", Vector3(0.0, 0.035, 7.0), Vector3(12.0, 0.07, 12.0), Color(0.53, 0.54, 0.49), false)
	_box("PlayerWelcomeInset", Vector3(0.0, 0.078, 7.0), Vector3(10.8, 0.018, 10.8), Color(0.62, 0.62, 0.55), false)
	_box("SpawnPad", Vector3(0.0, 0.105, 7.0), Vector3(4.5, 0.035, 3.5), Color(0.78, 0.68, 0.43), false)
	_label_3d("ZEKA CITY", Vector3(0.0, 3.2, 34.0), 0.65)
	_box("UnloadPad", Vector3(1.35, 0.12, -6.5), Vector3(3.5, 0.035, 3.2), Color(0.94, 0.66, 0.13), false)
	_label_3d("WASTE DROP-OFF", Vector3(1.35, 0.45, -7.45), 0.24)

	# Additional homes fill unused grass blocks between the existing civic buildings.
	_build_city_block_building(Vector3(28.0, 0.0, -12.0), "HOMES", Color(0.72, 0.58, 0.43), 2, 6.5)
	_build_city_block_building(Vector3(60.0, 0.0, -12.0), "TOWNHOUSES", Color(0.62, 0.68, 0.62), 2, 6.5)
	_build_city_block_building(Vector3(28.0, 0.0, 12.0), "HOMES", Color(0.66, 0.61, 0.72), 2, 6.5)
	_build_city_block_building(Vector3(60.0, 0.0, 12.0), "RESIDENCES", Color(0.70, 0.65, 0.52), 2, 6.5)

	# Evenly spaced street furniture follows the pedestrian strips, not the road surface.
	for furniture_x in [-8.0, 4.0, 28.0, 40.0, 60.0, 72.0, 92.0, 112.0]:
		for side_z in [-6.0, 6.0]:
			_make_lamp(Vector3(furniture_x, 0.0, side_z))
	for bench_pos in [Vector3(10.0, 0.0, -6.0), Vector3(34.0, 0.0, 6.0), Vector3(58.0, 0.0, -6.0), Vector3(74.0, 0.0, 6.0), Vector3(98.0, 0.0, -6.0)]:
		_make_bench(bench_pos)

	# Signal heads at every neighborhood-street junction face approaching traffic; red is lit.
	for signal_x in [16.0, 48.0, 80.0, 104.0]:
		for signal_z in [-22.0, 22.0]:
			for corner_x in [-1.0, 1.0]:
				var signal_base := Vector3(signal_x + corner_x * 4.4, 0.0, signal_z - signf(signal_z) * 3.8)
				_build_red_traffic_signal(signal_base)

	# Public waste bins are placed beside sidewalks, never in the traffic lanes.
	for bin_pos in [Vector3(-11.0, 0.0, -7.0), Vector3(12.0, 0.0, 9.0), Vector3(29.0, 0.0, -12.0), Vector3(61.0, 0.0, -8.0), Vector3(91.0, 0.0, 9.0), Vector3(108.0, 0.0, -10.0)]:
		_make_street_bin(bin_pos, Color(0.18, 0.34, 0.31))
	for barrel_pos in [Vector3(-11.5, 0.0, 3.0), Vector3(13.0, 0.0, 12.0)]:
		_make_barrel(barrel_pos, Color(0.72, 0.34, 0.18))

	# Street furniture: lamps, traffic lights, signs and parking.
	for lamp_pos in [Vector3(13.0, 0.0, -8.0), Vector3(19.0, 0.0, 8.0), Vector3(45.0, 0.0, -8.0), Vector3(51.0, 0.0, 8.0), Vector3(77.0, 0.0, -8.0), Vector3(83.0, 0.0, 8.0), Vector3(101.0, 0.0, -8.0), Vector3(107.0, 0.0, 8.0)]:
		_make_lamp(lamp_pos)
	for signal_x in [16.0, 48.0, 80.0, 104.0]:
		for signal_side in [-1.0, 1.0]:
			var signal_pos := Vector3(signal_x + signal_side * 4.4, 0.0, signal_side * 5.8)
			_box("TrafficSignalPole", signal_pos + Vector3(0, 1.55, 0), Vector3(0.11, 3.1, 0.11), Color(0.16, 0.20, 0.21), false)
			_box("TrafficSignalHead", signal_pos + Vector3(0, 2.85, 0), Vector3(0.34, 0.78, 0.28), Color(0.055, 0.075, 0.08), false)
			for light_i in range(3):
				_cylinder("TrafficLightLens", signal_pos + Vector3(0, 3.08 - float(light_i) * 0.23, 0.16), 0.07, 0.045, [Color(0.82, 0.18, 0.14), Color(0.92, 0.69, 0.16), Color(0.20, 0.72, 0.34)][light_i], false)
	for car_pos in [Vector3(22.0, 0.0, -10.0), Vector3(44.0, 0.0, 10.0), Vector3(68.0, 0.0, -10.0), Vector3(92.0, 0.0, 10.0)]:
		_make_parked_car(car_pos)

	# Trees line the sidewalks and create green pockets between buildings.
	for tree_pos in [Vector3(20.0, 0.0, -8.0), Vector3(28.0, 0.0, 8.0), Vector3(44.0, 0.0, -8.0), Vector3(52.0, 0.0, 8.0), Vector3(76.0, 0.0, -8.0), Vector3(84.0, 0.0, 8.0), Vector3(100.0, 0.0, -8.0), Vector3(108.0, 0.0, 8.0)]:
		_build_neighborhood_tree(tree_pos)

	# Road connection from the city into the industrial recycling campus.
	_box("FactoryAccessRoad", Vector3(119.25, 0.03, 0.0), Vector3(22.5, 0.06, 8.2), asphalt, false)
	_box("FactoryAccessCenterLine", Vector3(119.25, 0.065, 0.0), Vector3(21.8, 0.012, 0.13), white, false)
	# Removed the decorative factory entrance posts and overhead gate to keep the approach clear.

	# The shared access road above now serves both the factory and final cleanup district.
	for marker_x in range(118, 207, 8):
		_box("FinalZoneBoundaryMarker", Vector3(float(marker_x), 0.05, -34.0), Vector3(0.7, 0.1, 0.7), Color(0.88, 0.62, 0.12), false)
		_box("FinalZoneBoundaryMarker", Vector3(float(marker_x), 0.05, 34.0), Vector3(0.7, 0.1, 0.7), Color(0.88, 0.62, 0.12), false)



func _build_red_traffic_signal(base: Vector3) -> void:
	_box("NeighborhoodTrafficSignalPole", base + Vector3(0, 1.55, 0), Vector3(0.10, 3.1, 0.10), Color(0.15, 0.19, 0.20), false)
	_box("NeighborhoodTrafficSignalHousing", base + Vector3(0, 2.85, 0), Vector3(0.34, 0.82, 0.28), Color(0.045, 0.06, 0.065), false)
	_cylinder("TrafficSignalRedLight", base + Vector3(0, 3.12, 0.16), 0.075, 0.05, Color(1.0, 0.035, 0.025), false)
	_cylinder("TrafficSignalAmberLight", base + Vector3(0, 2.87, 0.16), 0.065, 0.045, Color(0.32, 0.20, 0.035), false)
	_cylinder("TrafficSignalGreenLight", base + Vector3(0, 2.62, 0.16), 0.065, 0.045, Color(0.035, 0.22, 0.09), false)

func _build_city_block_building(center: Vector3, sign_text: String, facade: Color, floors: int, width: float) -> void:
	# Modular low-poly architecture with a real base, layered facade, roofline,
	# recessed windows, balconies and a visible entrance.
	var depth := 9.0
	var height := float(floors) * 2.7
	var front_z := center.z + (5.0 if center.z < 0.0 else -5.0)
	_box("CityBuildingFoundation", center + Vector3(0, 0.18, 0), Vector3(width + 0.8, 0.36, depth + 0.8), Color(0.36, 0.37, 0.34), true)
	_box("CityBuildingFacade", center + Vector3(0, height * 0.5 + 0.25, 0), Vector3(width, height, depth), facade, true)
	_box("CityBuildingRoofCap", center + Vector3(0, height + 0.40, 0), Vector3(width + 0.55, 0.32, depth + 0.55), Color(0.20, 0.25, 0.27), false)
	_box("CityBuildingCornice", center + Vector3(0, height - 0.10, front_z - center.z), Vector3(width + 0.18, 0.22, 0.22), facade.darkened(0.22), false)
	for floor_i in range(floors):
		var window_y := 1.55 + float(floor_i) * 2.7
		for window_x in [-width * 0.30, 0.0, width * 0.30]:
			_box("CityWindowFrame", center + Vector3(window_x, window_y, front_z - center.z), Vector3(1.25, 1.35, 0.16), Color(0.12, 0.18, 0.20), false)
			_box("CityWindowGlass", center + Vector3(window_x, window_y, front_z - center.z + (0.10 if center.z < 0.0 else -0.10)), Vector3(1.03, 1.12, 0.045), Color(0.32, 0.56, 0.66), false)
			_box("CityWindowSill", center + Vector3(window_x, window_y - 0.73, front_z - center.z), Vector3(1.4, 0.10, 0.24), Color(0.76, 0.76, 0.68), false)
	_box("CityEntranceFrame", center + Vector3(0, 1.25, front_z - center.z), Vector3(1.55, 2.45, 0.22), Color(0.12, 0.16, 0.18), false)
	_box("CityEntranceGlass", center + Vector3(0, 1.25, front_z - center.z + (0.13 if center.z < 0.0 else -0.13)), Vector3(1.22, 2.1, 0.05), Color(0.26, 0.48, 0.56), false)
	_box("CityBuildingSign", center + Vector3(0, height + 1.05, front_z - center.z), Vector3(minf(width - 1.0, 7.0), 0.72, 0.22), Color(0.10, 0.20, 0.22), false)
	_label_3d(sign_text, center + Vector3(0, height + 1.06, front_z - center.z + (0.15 if center.z < 0.0 else -0.15)), 0.22)
	for roof_x in [-width * 0.32, width * 0.32]:
		_box("CityRoofVent", center + Vector3(roof_x, height + 0.72, 0), Vector3(0.9, 0.5, 0.8), Color(0.32, 0.36, 0.36), false)


func _build_sorting_district() -> void:
	# All four recycling stations are grouped beside the factory on one service strip.
	# Their robots use the same direct return route to the future factory waste tank.
	sorting_area_root = Node3D.new()
	sorting_area_root.name = "FactorySortingStations"
	add_child(sorting_area_root)
	sorting_bins.clear()
	sorting_robots.clear()
	sorting_build_labels.clear()
	for i in range(4):
		var pad_pos: Vector3 = sorting_pad_positions[i]
		var color: Color = sorting_station_colors[i]
		_box("SortingStationPad", pad_pos + Vector3(0, 0.035, 0), Vector3(4.2, 0.07, 3.8), Color(0.10, 0.14, 0.15), false)
		_box("SortingStationPadBorder", pad_pos + Vector3(0, 0.08, 0), Vector3(3.85, 0.025, 3.45), color, false)
		_box("SortingStationFootprint", pad_pos + Vector3(0, 0.095, 0), Vector3(3.55, 0.025, 3.15), color.darkened(0.68), false)
		var cost_label := Label3D.new()
		cost_label.name = "SortingStationBuildCost_%s" % sorting_station_categories[i]
		cost_label.text = "45 ZC"
		cost_label.position = pad_pos + Vector3(0, 0.48, -0.3)
		cost_label.font_size = 28
		cost_label.pixel_size = 0.009
		cost_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		cost_label.modulate = Color(1.0, 0.84, 0.35)
		sorting_area_root.add_child(cost_label)
		sorting_build_labels.append(cost_label)
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
	_build_sorting_cell_visuals()
	_refresh_sorting_district()



func _build_sorting_cell_visuals() -> void:
	# Four independent, open-sided sorting cells. All additions are visual-only:
	# no new collision shapes, triggers, path blockers, or changes to robot routes.
	var steel := Color(0.20, 0.27, 0.29)
	var dark_steel := Color(0.075, 0.10, 0.11)
	var bright_steel := Color(0.53, 0.61, 0.61)
	var safety := Color(0.98, 0.66, 0.13)
	for i in range(4):
		var center: Vector3 = sorting_pad_positions[i]
		var accent: Color = sorting_station_colors[i]
		var cell := Node3D.new()
		cell.name = "SortingCellVisual_%s" % sorting_station_categories[i]
		sorting_area_root.add_child(cell)
		# Raised machine frame stays above the loader's operating envelope.
		for side_x in [-1.0, 1.0]:
			for side_z in [-1.0, 1.0]:
				_sorting_visual_box(cell, "CellColumn", center + Vector3(side_x * 1.86, 2.20, side_z * 1.55), Vector3(0.16, 4.40, 0.16), steel)
				_sorting_visual_box(cell, "ColumnFoot", center + Vector3(side_x * 1.86, 0.16, side_z * 1.55), Vector3(0.42, 0.32, 0.42), dark_steel)
			_sorting_visual_box(cell, "CanopySideBeam", center + Vector3(side_x * 1.86, 4.32, 0.0), Vector3(0.18, 0.18, 3.25), bright_steel)
			_sorting_visual_box(cell, "SafetyRail", center + Vector3(side_x * 1.78, 0.72, 0.0), Vector3(0.07, 0.10, 2.65), safety)
			_sorting_visual_box(cell, "SafetyRailMid", center + Vector3(side_x * 1.78, 0.43, 0.0), Vector3(0.06, 0.06, 2.65), steel)
			# High-mounted robotic sorting arm and illuminated tool head.
			_sorting_visual_box(cell, "SorterShoulder", center + Vector3(side_x * 1.52, 3.22, -0.18), Vector3(0.42, 0.48, 0.42), dark_steel)
			_sorting_visual_box(cell, "SorterArm", center + Vector3(side_x * 0.98, 3.02, -0.18), Vector3(0.98, 0.14, 0.16), bright_steel)
			_sorting_visual_box(cell, "SorterWrist", center + Vector3(side_x * 0.50, 2.82, -0.18), Vector3(0.16, 0.38, 0.16), steel)
			_sorting_visual_box(cell, "SorterGripper", center + Vector3(side_x * 0.50, 2.60, -0.18), Vector3(0.34, 0.08, 0.28), accent)
			_sorting_visual_box(cell, "ArmStatusLight", center + Vector3(side_x * 1.52, 3.58, -0.18), Vector3(0.20, 0.09, 0.20), accent)
		_sorting_visual_box(cell, "CanopyFrontBeam", center + Vector3(0.0, 4.32, -1.55), Vector3(3.75, 0.18, 0.18), bright_steel)
		_sorting_visual_box(cell, "CanopyRearBeam", center + Vector3(0.0, 4.32, 1.55), Vector3(3.75, 0.18, 0.18), bright_steel)
		_sorting_visual_box(cell, "CanopyRoof", center + Vector3(0.0, 4.46, 0.0), Vector3(3.62, 0.10, 3.05), dark_steel)
		_sorting_visual_box(cell, "CanopyAccent", center + Vector3(0.0, 4.53, -1.48), Vector3(2.10, 0.035, 0.08), accent)
		# Clearly marked operating bay and a compact operator/control cabinet.
		_sorting_visual_box(cell, "BayThreshold", center + Vector3(0.0, 0.13, -1.78), Vector3(2.80, 0.035, 0.12), safety)
		_sorting_visual_box(cell, "ControlCabinet", center + Vector3(-1.52, 1.02, 1.08), Vector3(0.42, 1.35, 0.48), dark_steel)
		_sorting_visual_box(cell, "ControlScreen", center + Vector3(-1.52, 1.30, 0.82), Vector3(0.28, 0.22, 0.035), Color(0.10, 0.72, 0.70))
		_sorting_visual_box(cell, "ControlBeacon", center + Vector3(-1.52, 1.76, 1.08), Vector3(0.12, 0.10, 0.12), safety)
		var bay_label := Label3D.new()
		bay_label.name = "SortingCellLabel"
		bay_label.text = "%s  /  AUTO SORT" % sorting_station_names[i]
		bay_label.position = center + Vector3(0.0, 4.08, -1.68)
		bay_label.font_size = 22
		bay_label.pixel_size = 0.008
		bay_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		bay_label.modulate = accent.lightened(0.35)
		cell.add_child(bay_label)


func _sorting_visual_box(parent: Node3D, node_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var visual := MeshInstance3D.new()
	visual.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	visual.position = pos
	visual.material_override = _mat(color)
	parent.add_child(visual)

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
	var robot := CharacterBody3D.new()
	robot.name = "SortingRobot_%d" % category_index
	# Compact autonomous loader-truck: enclosed cab, rear cargo body and a front bucket.
	var dark := Color(0.055, 0.075, 0.08)
	var metal := Color(0.58, 0.66, 0.65)
	var glass := Color(0.035, 0.13, 0.16)
	_add_robot_box(robot, "LoaderTruckChassis", Vector3(0, 0.57, 0.08), Vector3(1.02, 0.42, 1.62), dark)
	_add_robot_box(robot, "LoaderTruckRearBody", Vector3(0, 0.93, 0.55), Vector3(0.94, 0.68, 0.82), robot_color)
	_add_robot_box(robot, "LoaderTruckRearTop", Vector3(0, 1.30, 0.55), Vector3(0.82, 0.08, 0.72), robot_color.lightened(0.16))
	_add_robot_box(robot, "LoaderTruckCab", Vector3(0, 1.08, -0.48), Vector3(0.88, 0.92, 0.78), robot_color.lightened(0.10))
	_add_robot_box(robot, "LoaderTruckWindshield", Vector3(0, 1.20, -0.885), Vector3(0.68, 0.40, 0.035), glass)
	_add_robot_box(robot, "LoaderTruckRoof", Vector3(0, 1.57, -0.47), Vector3(0.94, 0.12, 0.82), dark)
	_add_robot_box(robot, "LoaderTruckRoofBeacon", Vector3(0, 1.68, -0.47), Vector3(0.22, 0.08, 0.18), Color(0.98, 0.62, 0.16))
	_add_robot_box(robot, "LoaderTruckFrontGrille", Vector3(0, 0.72, -0.91), Vector3(0.62, 0.25, 0.045), dark)
	_add_robot_box(robot, "LoaderTruckBumper", Vector3(0, 0.42, -0.94), Vector3(1.08, 0.14, 0.18), metal)
	for side in [-1.0, 1.0]:
		_add_robot_box(robot, "LoaderTruckHeadlight", Vector3(side * 0.37, 0.77, -0.945), Vector3(0.16, 0.12, 0.045), Color(1.0, 0.86, 0.48))
		_add_robot_box(robot, "LoaderTruckCargoRail", Vector3(side * 0.49, 1.05, 0.55), Vector3(0.07, 0.50, 0.78), robot_color.darkened(0.16))
		_add_robot_box(robot, "LoaderTruckCabSideWindow", Vector3(side * 0.447, 1.25, -0.48), Vector3(0.035, 0.34, 0.48), glass)
		_add_robot_box(robot, "LoaderTruckSideStep", Vector3(side * 0.52, 0.49, -0.38), Vector3(0.16, 0.10, 0.50), metal)
		_add_robot_box(robot, "LoaderTruckHazardStripe", Vector3(side * 0.49, 0.80, 0.55), Vector3(0.035, 0.10, 0.55), Color(0.96, 0.64, 0.14))
		_add_robot_box(robot, "LoaderHydraulicPiston", Vector3(side * 0.34, 0.58, -0.99), Vector3(0.075, 0.28, 0.075), Color(0.46, 0.53, 0.54))
	# Loader arms and a broad, slightly raised scoop at the front.
	_add_robot_box(robot, "LoaderArmLeft", Vector3(-0.43, 0.48, -0.82), Vector3(0.12, 0.16, 0.74), metal)
	_add_robot_box(robot, "LoaderArmRight", Vector3(0.43, 0.48, -0.82), Vector3(0.12, 0.16, 0.74), metal)
	_add_robot_box(robot, "LoaderBucketBack", Vector3(0, 0.30, -1.22), Vector3(0.92, 0.30, 0.16), metal)
	_add_robot_box(robot, "LoaderBucketFloor", Vector3(0, 0.17, -1.40), Vector3(1.02, 0.10, 0.50), metal)
	_add_robot_box(robot, "LoaderBucketLeftSide", Vector3(-0.48, 0.32, -1.38), Vector3(0.10, 0.32, 0.48), metal)
	_add_robot_box(robot, "LoaderBucketRightSide", Vector3(0.48, 0.32, -1.38), Vector3(0.10, 0.32, 0.48), metal)
	_add_robot_box(robot, "LoaderBucketCuttingEdge", Vector3(0, 0.12, -1.66), Vector3(1.08, 0.07, 0.10), Color(0.78, 0.82, 0.78))
	for tooth_x in [-0.42, -0.21, 0.0, 0.21, 0.42]:
		_add_robot_box(robot, "LoaderBucketTooth", Vector3(tooth_x, 0.08, -1.72), Vector3(0.085, 0.07, 0.13), Color(0.94, 0.66, 0.16))
	# Four large rubber tires with hubs that rotate with the wheel.
	var robot_wheels: Array[Node3D] = []
	for side in [-1.0, 1.0]:
		for z in [-0.62, 0.72]:
			var wheel := MeshInstance3D.new()
			wheel.name = "SortingRobotWheel"
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.30
			wheel_mesh.bottom_radius = 0.30
			wheel_mesh.height = 0.20
			wheel_mesh.radial_segments = 20
			wheel.mesh = wheel_mesh
			wheel.position = Vector3(side * 0.55, 0.34, z)
			wheel.rotation_degrees.z = 90.0
			wheel.material_override = _mat(Color(0.035, 0.045, 0.05))
			robot.add_child(wheel)
			robot_wheels.append(wheel)
			var hub := MeshInstance3D.new()
			hub.name = "SortingRobotWheelHub"
			var hub_mesh := CylinderMesh.new()
			hub_mesh.top_radius = 0.15
			hub_mesh.bottom_radius = 0.15
			hub_mesh.height = 0.06
			hub_mesh.radial_segments = 20
			hub.mesh = hub_mesh
			hub.position = Vector3.ZERO
			hub.material_override = _mat(Color(0.40, 0.48, 0.47))
			wheel.add_child(hub)
	# Industrial finish pass: raised side service panels, vents and warning markings.
	for side in [-1.0, 1.0]:
		_add_robot_box(robot, "LoaderSideServicePanel", Vector3(side * 0.505, 0.92, -0.05), Vector3(0.035, 0.30, 0.46), metal)
		for vent_index in range(4):
			_add_robot_box(robot, "LoaderSideVent", Vector3(side * 0.53, 1.02, -0.18 + float(vent_index) * 0.09), Vector3(0.018, 0.025, 0.055), dark)
		_add_robot_box(robot, "LoaderRearReflector", Vector3(side * 0.36, 0.60, 0.90), Vector3(0.18, 0.08, 0.035), Color(0.95, 0.28, 0.12))
	_add_robot_box(robot, "LoaderCabRoofPanel", Vector3(0, 1.64, -0.47), Vector3(0.58, 0.025, 0.46), metal)
	_add_robot_box(robot, "LoaderFrontBrandPanel", Vector3(0, 0.92, -0.94), Vector3(0.34, 0.08, 0.025), robot_color.lightened(0.30))
	var robot_collision := CollisionShape3D.new()
	var robot_collision_shape := CapsuleShape3D.new()
	robot_collision_shape.radius = 0.58
	robot_collision_shape.height = 1.45
	robot_collision.shape = robot_collision_shape
	robot_collision.position.y = 0.72
	robot.add_child(robot_collision)
	robot.set_meta("wheels", robot_wheels)
	robot.set_meta("category_index", category_index)
	robot.set_meta("target", null)
	robot.set_meta("cargo", null)
	robot.set_meta("mode", "idle")
	robot.set_meta("scan_timer", 0.0)
	return robot

func _factory_waste_drop_point() -> Vector3:
	# Center of the open loading apron in front of the factory waste tank.
	return Vector3(124.8, 0.0, 8.5)


func _drone_station_point() -> Vector3:
	# A dedicated northern annex, clear of all city streets and factory equipment.
	return Vector3(130.0, 0.0, -43.5)


func _drone_dock_point(drone: Node3D) -> Vector3:
	var slot := helper_drones.find(drone)
	if slot < 0:
		slot = 0
	return _drone_station_point() + Vector3(0.0, 1.8, (float(slot) - 1.0) * 2.65)


func _build_drone_station() -> void:
	var dock := _drone_station_point()
	var dark := Color(0.045, 0.075, 0.09)
	var graphite := Color(0.12, 0.18, 0.21)
	var metal := Color(0.31, 0.40, 0.43)
	var light_metal := Color(0.56, 0.65, 0.65)
	var teal := Color(0.035, 0.32, 0.34)
	var glow := Color(0.18, 0.95, 0.78)
	var amber := Color(1.0, 0.62, 0.16)
	var concrete := Color(0.25, 0.31, 0.33)

	# Expanded industrial apron with a raised, armored perimeter.
	_box("DroneDepotFoundation", dock + Vector3(0, 0.08, 0), Vector3(12.8, 0.16, 12.2), dark, false)
	_box("DroneDepotDeck", dock + Vector3(0, 0.19, 0), Vector3(12.45, 0.08, 11.85), concrete, false)
	_box("DroneDepotFrontApron", dock + Vector3(0, 0.12, 6.45), Vector3(9.2, 0.12, 1.0), graphite, false)
	for side in [-1.0, 1.0]:
		_box("DroneDepotPerimeterRail", dock + Vector3(side * 6.12, 0.42, 0), Vector3(0.16, 0.48, 11.5), metal, false)
		_box("DroneDepotPerimeterStripe", dock + Vector3(side * 6.02, 0.68, 0), Vector3(0.035, 0.035, 11.1), amber, false)
		_box("DroneDepotApronStripe", dock + Vector3(side * 4.95, 0.245, 6.0), Vector3(0.10, 0.025, 0.72), amber, false)

	# Three individually marked landing and charging lanes.
	for slot in range(3):
		var bay_z := (float(slot) - 1.0) * 2.65
		var bay := dock + Vector3(0.0, 0.25, bay_z)
		_box("DroneBayBase", bay, Vector3(3.15, 0.07, 2.42), dark, false)
		_box("DroneBayInset", bay + Vector3(0, 0.045, 0), Vector3(2.86, 0.025, 2.16), teal, false)
		_box("DroneBayCenterPad", bay + Vector3(0, 0.065, 0), Vector3(1.72, 0.025, 1.55), graphite, false)
		for edge in [-1.0, 1.0]:
			_box("DroneBayGuide", bay + Vector3(edge * 1.34, 0.075, 0), Vector3(0.055, 0.035, 1.96), glow, false)
			_box("DroneBaySideMarker", bay + Vector3(edge * 1.48, 0.075, 0), Vector3(0.045, 0.035, 2.15), amber, false)
		_box("DroneBayNoseMark", bay + Vector3(0, 0.085, -0.91), Vector3(1.02, 0.035, 0.075), amber, false)
		_box("DroneBayTailMark", bay + Vector3(0, 0.085, 0.91), Vector3(0.72, 0.035, 0.055), glow, false)
		# Raised charging pylons and articulated overhead charging rails.
		_box("DroneChargePost", bay + Vector3(1.78, 0.55, 0.78), Vector3(0.20, 0.92, 0.20), metal, false)
		_box("DroneChargeLight", bay + Vector3(1.78, 1.04, 0.78), Vector3(0.14, 0.12, 0.14), glow, false)
		_box("DroneChargeArm", bay + Vector3(1.20, 1.02, 0.78), Vector3(0.98, 0.10, 0.12), light_metal, false)
		_box("DroneBayNumberPanel", bay + Vector3(-1.20, 0.12, 0.78), Vector3(0.32, 0.035, 0.34), amber, false)
		_label_3d("BAY 0%d" % (slot + 1), bay + Vector3(-1.20, 0.18, 0.78), 0.10)

	# Heavy portal-frame hangar canopy with visible cross-bracing.
	for px in [-5.65, 5.65]:
		for pz in [-5.15, 5.15]:
			_box("DroneHangarColumnFoot", dock + Vector3(px, 0.42, pz), Vector3(0.72, 0.20, 0.72), dark, false)
			_box("DroneHangarColumn", dock + Vector3(px, 1.82, pz), Vector3(0.34, 3.0, 0.34), metal, false)
			_box("DroneHangarColumnFace", dock + Vector3(px - signf(px) * 0.19, 1.85, pz), Vector3(0.045, 2.55, 0.19), light_metal, false)
	for pz in [-5.15, 5.15]:
		_box("DroneHangarRoofBeam", dock + Vector3(0, 3.22, pz), Vector3(11.7, 0.42, 0.42), graphite, false)
	for px in [-5.65, 5.65]:
		_box("DroneHangarSideBeam", dock + Vector3(px, 3.22, 0), Vector3(0.42, 0.42, 10.5), graphite, false)
	_box("DroneHangarRoof", dock + Vector3(0, 3.48, 0), Vector3(12.2, 0.20, 11.0), dark, false)
	for roof_x in [-4.2, -2.1, 0.0, 2.1, 4.2]:
		_box("DroneHangarRoofRib", dock + Vector3(roof_x, 3.60, 0), Vector3(0.075, 0.055, 10.2), metal, false)
	for pz in [-3.9, 0.0, 3.9]:
		_box("DroneHangarRoofTruss", dock + Vector3(0, 3.08, pz), Vector3(10.9, 0.14, 0.18), light_metal, false)
	_box("DroneHangarFrontFascia", dock + Vector3(0, 2.98, 5.18), Vector3(11.3, 0.48, 0.24), graphite, false)
	_box("DroneHangarSignPanel", dock + Vector3(0, 3.00, -5.18), Vector3(6.2, 0.52, 0.20), teal, false)
	_label_3d("ZEKA // AUTONOMOUS FLIGHT OPERATIONS", dock + Vector3(0, 3.34, -5.12), 0.15)
	for px in [-4.3, -2.15, 0.0, 2.15, 4.3]:
		_box("DroneHangarLampHousing", dock + Vector3(px, 3.02, 0), Vector3(0.92, 0.12, 0.34), graphite, false)
		_box("DroneHangarLamp", dock + Vector3(px, 2.94, 0), Vector3(0.72, 0.045, 0.18), glow, false)

	# Dedicated maintenance bay, diagnostics console and safety equipment.
	_box("DroneServiceCabinet", dock + Vector3(4.75, 0.82, -3.75), Vector3(1.25, 1.55, 1.05), graphite, false)
	_box("DroneServiceCabinetDoor", dock + Vector3(4.75, 0.82, -3.20), Vector3(0.92, 1.28, 0.045), metal, false)
	_box("DroneServiceScreen", dock + Vector3(4.10, 1.20, -3.20), Vector3(0.055, 0.48, 0.68), glow, false)
	_box("DroneServiceStatusStrip", dock + Vector3(4.10, 0.78, -3.20), Vector3(0.06, 0.12, 0.68), amber, false)
	_box("DroneServiceWorktop", dock + Vector3(4.35, 1.48, -2.35), Vector3(1.75, 0.12, 0.72), light_metal, false)
	_box("DroneServiceToolRack", dock + Vector3(5.20, 1.92, -2.35), Vector3(0.12, 0.72, 0.68), dark, false)
	_cylinder("DroneDepotBeacon", dock + Vector3(5.35, 2.22, -4.30), 0.16, 0.42, amber, false)
	_box("DroneDepotSafetyMark", dock + Vector3(0, 0.27, 5.55), Vector3(3.8, 0.035, 0.12), amber, false)
	_label_3d("AUTHORIZED UAV SERVICE ZONE", dock + Vector3(0, 0.42, 5.62), 0.12)

	# Battery exchange wall: three ready packs and a dedicated depleted-pack return slot.
	_box("DroneBatteryExchangeRack", dock + Vector3(-4.85, 1.05, -3.65), Vector3(1.35, 2.05, 1.05), dark, false)
	_box("DroneBatteryRackHeader", dock + Vector3(-4.85, 2.16, -3.65), Vector3(1.42, 0.22, 1.12), teal, false)
	_label_3d("BATTERY EXCHANGE", dock + Vector3(-4.85, 2.34, -3.65), 0.10)
	for pack_slot in range(4):
		var pack_y: float = 0.55 + float(pack_slot) * 0.39
		var pack_z: float = -4.02
		_box("DroneSpareBatteryTray", dock + Vector3(-4.85, pack_y, pack_z), Vector3(0.94, 0.28, 0.58), metal, false)
		_box("DroneSpareBatteryPack", dock + Vector3(-4.85, pack_y + 0.10, pack_z - 0.04), Vector3(0.70, 0.15, 0.42), graphite, false)
		_box("DroneBatteryChargeIndicator", dock + Vector3(-4.85, pack_y + 0.12, pack_z - 0.265), Vector3(0.34, 0.035, 0.025), glow if pack_slot < 3 else amber, false)

	# Two articulated-looking maintenance manipulators work from the clear side lanes.
	for arm_side in [-1.0, 1.0]:
		var arm_base := dock + Vector3(arm_side * 4.72, 0.30, 0.15)
		_box("DroneMaintenanceArmPedestal", arm_base + Vector3(0, 0.58, 0), Vector3(0.66, 1.16, 0.66), dark, false)
		_box("DroneMaintenanceArmTurntable", arm_base + Vector3(0, 1.20, 0), Vector3(0.82, 0.16, 0.82), amber, false)
		_box("DroneMaintenanceArmUpper", arm_base + Vector3(-arm_side * 0.42, 1.78, 0), Vector3(0.18, 1.12, 0.18), metal, false)
		_box("DroneMaintenanceArmForearm", arm_base + Vector3(-arm_side * 0.78, 2.22, 0.12), Vector3(0.78, 0.16, 0.18), light_metal, false)
		_box("DroneMaintenanceToolHead", arm_base + Vector3(-arm_side * 1.12, 2.22, 0.12), Vector3(0.22, 0.30, 0.32), teal, false)
		_box("DroneMaintenanceToolLight", arm_base + Vector3(-arm_side * 1.12, 2.24, 0.29), Vector3(0.10, 0.08, 0.035), glow, false)

	# Marked one-way approach and departure lane; kept south of the active landing pads.
	_box("DroneTaxiLaneBase", dock + Vector3(0, 0.115, 7.30), Vector3(8.8, 0.055, 1.55), graphite, false)
	for lane_edge in [-1.0, 1.0]:
		_box("DroneTaxiLaneEdge", dock + Vector3(lane_edge * 4.20, 0.155, 7.30), Vector3(0.09, 0.025, 1.45), amber, false)
	for lane_dash in range(5):
		_box("DroneTaxiLaneDash", dock + Vector3(-3.0 + float(lane_dash) * 1.5, 0.16, 7.30), Vector3(0.72, 0.025, 0.07), glow, false)
	_box("DroneTaxiDirectionArrowStem", dock + Vector3(0, 0.17, 7.30), Vector3(0.10, 0.035, 0.82), glow, false)
	_box("DroneTaxiDirectionArrowHead", dock + Vector3(0, 0.17, 7.70), Vector3(0.62, 0.035, 0.12), glow, false)
	_label_3d("UAV IN / OUT", dock + Vector3(0, 0.38, 8.15), 0.12)


func _refresh_sorting_district() -> void:
	for i in range(mini(4, sorting_robots.size())):
		if is_instance_valid(sorting_robots[i]):
			sorting_robots[i].visible = sorting_robot_levels[i] > 0
	for i in range(mini(4, sorting_build_labels.size())):
		if is_instance_valid(sorting_build_labels[i]):
			sorting_build_labels[i].visible = sorting_robot_levels[i] <= 0
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
		var previous_position: Vector3 = robot.get_meta("previous_position", robot.global_position)
		var travel_distance := robot.global_position.distance_to(previous_position)
		if travel_distance > 0.0001:
			for wheel in robot.get_meta("wheels", []):
				if is_instance_valid(wheel):
					wheel.rotate_object_local(Vector3.UP, travel_distance * 3.0)
		robot.set_meta("previous_position", robot.global_position)
		var mode := String(robot.get_meta("mode", "idle"))
		var target := _get_meta_node(robot, "target")
		if mode == "return":
			var drop_point := _factory_waste_drop_point()
			drop_point.y = robot.global_position.y
			_move_autonomous_ground_robot(robot, drop_point, _sorting_robot_speed() * delta)
			if robot.global_position.distance_to(drop_point) < 0.8:
				var cargo := _get_meta_node(robot, "cargo")
				if is_instance_valid(cargo):
					if not waste_tank_built or waste_tank_inventory >= _waste_tank_capacity():
						_set_message("Sorting robot is waiting at the factory tank for storage to become available.")
						continue
					cargo.queue_free()
					robot.set_meta("cargo", null)
					sorting_bin_counts[i] += 1
					waste_tank_inventory += 1
					factory_waste_deposited_total += 1
					_update_missions()
					_refresh_waste_tank_inventory_label()
					_refresh_sorting_district()
					_update_ui()
					_save_game()
				robot.set_meta("mode", "idle")
			continue
		if not is_instance_valid(target) or not trash_nodes.has(target) or int(target.get_meta("drone_reserved", -1)) != -30 - i:
			# The robot must still own the reservation when approaching pickup.
			# If another system claimed or removed the item, abandon it safely.
			if is_instance_valid(target) and int(target.get_meta("drone_reserved", -1)) == -30 - i:
				target.set_meta("drone_reserved", -1)
			robot.set_meta("target", null)
			target = null
			var cooldown := float(robot.get_meta("scan_timer", 0.0)) - delta
			if cooldown <= 0.0:
				robot.set_meta("scan_timer", 0.90)
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
			idle_point.y = robot.global_position.y
			_move_autonomous_ground_robot(robot, idle_point, _sorting_robot_speed() * 0.43 * delta)
			continue
		var destination := target.global_position + Vector3(0, 0.55, 0)
		destination.y = robot.global_position.y
		_move_autonomous_ground_robot(robot, destination, _sorting_robot_speed() * delta)
		if robot.global_position.distance_to(destination) <= 0.65:
			_register_final_cleanup_pickup(target)
			var keep_transform := target.global_transform
			target.reparent(robot)
			target.global_transform = keep_transform
			# Keep collected waste inside the rear hopper, behind the cab roof.
			target.position = Vector3(0, 1.34, 0.58)
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


func _add_sidewalk_x_segments(node_name: String, start_x: float, end_x: float, center_y: float, thickness: float, fixed_z: float, width_z: float, color: Color, gap_centers: Array, gap_width: float) -> void:
	var cursor := start_x
	for gap_center in gap_centers:
		var gap_start: float = maxf(start_x, float(gap_center) - gap_width * 0.5)
		var gap_end: float = minf(end_x, float(gap_center) + gap_width * 0.5)
		if gap_start > cursor:
			_sidewalk_detailed_segment_x(node_name, cursor, gap_start, center_y, thickness, fixed_z, width_z, color)
		cursor = maxf(cursor, gap_end)
	if end_x > cursor:
		_sidewalk_detailed_segment_x(node_name, cursor, end_x, center_y, thickness, fixed_z, width_z, color)


func _sidewalk_detailed_segment_x(node_name: String, start_x: float, end_x: float, center_y: float, thickness: float, fixed_z: float, width_z: float, color: Color) -> void:
	_box(node_name, Vector3((start_x + end_x) * 0.5, center_y, fixed_z), Vector3(end_x - start_x, thickness, width_z), color, false)
	var seam := color.darkened(0.20)
	var x := start_x + 2.0
	while x < end_x - 0.25:
		_box(node_name + "TileSeam", Vector3(x, center_y + thickness * 0.51, fixed_z), Vector3(0.045, 0.008, width_z - 0.12), seam, false)
		x += 2.0
	_box(node_name + "TileBorder", Vector3((start_x + end_x) * 0.5, center_y + thickness * 0.51, fixed_z - width_z * 0.5 + 0.08), Vector3(end_x - start_x, 0.008, 0.06), color.lightened(0.15), false)
	_box(node_name + "TileBorder", Vector3((start_x + end_x) * 0.5, center_y + thickness * 0.51, fixed_z + width_z * 0.5 - 0.08), Vector3(end_x - start_x, 0.008, 0.06), color.lightened(0.15), false)


func _add_sidewalk_z_segments(node_name: String, start_z: float, end_z: float, center_y: float, thickness: float, fixed_x: float, width_x: float, color: Color, gap_centers: Array, gap_width: float) -> void:
	var cursor := start_z
	for gap_entry in gap_centers:
		var gap_center := 0.0
		var this_gap_width := gap_width
		if gap_entry is Vector2:
			gap_center = gap_entry.x
			this_gap_width = gap_entry.y
		else:
			gap_center = float(gap_entry)
		var gap_start: float = maxf(start_z, gap_center - this_gap_width * 0.5)
		var gap_end: float = minf(end_z, gap_center + this_gap_width * 0.5)
		if gap_start > cursor:
			_sidewalk_detailed_segment_z(node_name, cursor, gap_start, center_y, thickness, fixed_x, width_x, color)
		cursor = maxf(cursor, gap_end)
	if end_z > cursor:
		_sidewalk_detailed_segment_z(node_name, cursor, end_z, center_y, thickness, fixed_x, width_x, color)


func _sidewalk_detailed_segment_z(node_name: String, start_z: float, end_z: float, center_y: float, thickness: float, fixed_x: float, width_x: float, color: Color) -> void:
	_box(node_name, Vector3(fixed_x, center_y, (start_z + end_z) * 0.5), Vector3(width_x, thickness, end_z - start_z), color, false)
	var seam := color.darkened(0.20)
	var z := start_z + 2.0
	while z < end_z - 0.25:
		_box(node_name + "TileSeam", Vector3(fixed_x, center_y + thickness * 0.51, z), Vector3(width_x - 0.12, 0.008, 0.045), seam, false)
		z += 2.0
	_box(node_name + "TileBorder", Vector3(fixed_x - width_x * 0.5 + 0.08, center_y + thickness * 0.51, (start_z + end_z) * 0.5), Vector3(0.06, 0.008, end_z - start_z), color.lightened(0.15), false)
	_box(node_name + "TileBorder", Vector3(fixed_x + width_x * 0.5 - 0.08, center_y + thickness * 0.51, (start_z + end_z) * 0.5), Vector3(0.06, 0.008, end_z - start_z), color.lightened(0.15), false)


func _build_connected_city_streets() -> void:
	# Replace the removed district boundary walls with a continuous street grid.
	# All road surfaces are decorative and non-colliding; the city stays walkable.
	var asphalt := Color(0.14, 0.17, 0.18)
	var curb := Color(0.88, 0.81, 0.66)
	var sidewalk := Color(0.43, 0.29, 0.19)
	# Two continuous cross-town streets run through the former front/back wall lines.
	for street_z in [-29.0, 29.0]:
		_box("CrossTownStreet", Vector3(49.0, 0.022, street_z), Vector3(126.0, 0.045, 5.8), asphalt, false)
		_box("CrossTownSidewalk", Vector3(49.0, 0.055, street_z - 3.55), Vector3(126.0, 0.11, 1.25), sidewalk, false)
		_box("CrossTownSidewalk", Vector3(49.0, 0.055, street_z + 3.55), Vector3(126.0, 0.11, 1.25), sidewalk, false)

	# Side streets join the central avenue to both cross-town roads, creating real alleys.
	for street_x in [16.0, 48.0, 80.0, 104.0]:
		_box("NeighborhoodConnectorRoad", Vector3(street_x, 0.025, 0.0), Vector3(5.2, 0.05, 74.0), asphalt, false)
		for edge_x in [street_x - 3.0, street_x + 3.0]:
			_box("ConnectorCurb", Vector3(edge_x, 0.075, 0.0), Vector3(0.18, 0.15, 74.0), curb, false)
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
		_box("NeighborhoodSidewalkNorth", Vector3(district_x, 0.045, -3.45), Vector3(31.0, 0.07, 1.45), Color(0.66, 0.53, 0.37), false)
		_box("NeighborhoodSidewalkSouth", Vector3(district_x, 0.045, 3.45), Vector3(31.0, 0.07, 1.45), Color(0.66, 0.53, 0.37), false)
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
		{"x": 24.0, "z": -14.0}, {"x": 37.0, "z": 14.0},
		{"x": 57.0, "z": -14.0}, {"x": 71.0, "z": 14.0}
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
	# Keep the complete tree canopy outside roads and sidewalks, not only its trunk.
	# Boulevard asphalt and its wide sidewalks occupy the central north/south strip.
	if absf(pos.z) < 9.2:
		return
	# Neighborhood streets at Z=+/-22 and cross-town streets at Z=+/-29.
	if absf(absf(pos.z) - 22.0) < 5.7 or absf(absf(pos.z) - 29.0) < 4.5:
		return
	# Each perpendicular street also has sidewalks on both sides; reserve the
	# full road-plus-sidewalk corridor so foliage cannot spill over either.
	for road_x in [16.0, 48.0, 80.0, 104.0]:
		if absf(pos.x - road_x) < 7.9:
			return
	if absf(pos.x - 49.0) < 7.0:
		return
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
	_box("ResidentialSidewalk", Vector3(-4.0, 0.025, -10.2), Vector3(7.0, 0.05, 2.0), Color(0.72, 0.59, 0.42), false)
	_box("MainWalkway", Vector3(-2.8, 0.035, -2.2), Vector3(2.1, 0.07, 10.0), Color(0.68, 0.54, 0.37), false)
	for x in [-3.72, -2.85, -1.98]:
		_box("WalkwayPaverJoint", Vector3(x, 0.075, -2.2), Vector3(0.035, 0.012, 9.8), Color(0.48, 0.37, 0.25), false)
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
	# Pedestrian crossing stripes removed for a clean roadway.
	# Extra warm lighting around the starting area.
	_make_lamp(Vector3(5.5, 0, 7.5))
	_make_lamp(Vector3(-5.0, 0, 13.0))


	# More realistic street treatment: curbs, lane markings, drains and manholes.
	# Keep the service-road edge clear for player and robot access.
	_box("RoadRaisedCurb", Vector3(-10.72, 0.10, 1.0), Vector3(0.22, 0.20, 54.0), Color(0.48, 0.50, 0.48), false)
	_box("RoadCurbHighlight", Vector3(-10.72, 0.205, 1.0), Vector3(0.24, 0.025, 54.0), Color(0.55, 0.57, 0.55), false)
	# Keep the curb only along the normal roadside. The depot approach is an open
	# service entrance, so no curb/highlight crosses the unloading access.
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
		var z_positions: Array[float] = [0.0, 0.0, 0.0, 10.0, 20.0, 30.0]
		var start_z: float = -4.9 if stage == 2 else (z_positions[stage - 1] + 1.8)
		var end_z: float = -1.7 if stage == 2 else (z_positions[stage] - 1.7)
		_build_factory_link(Vector3(7.5, 0.0, start_z), Vector3(7.5, 0.0, end_z))
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
		player.global_position = Vector3(143.0, maxf(player.global_position.y, 0.0), minf(z_positions[factory_stage] + 2.8, 37.2))
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

func _build_factory_link(start_pos: Vector3, end_pos: Vector3) -> void:
	# Build the conveyor in a local coordinate system whose Z axis follows the path.
	# This keeps the frame, belt, rails and roller axles aligned at every yaw angle.
	var direction := end_pos - start_pos
	direction.y = 0.0
	var length := direction.length()
	if length < 0.1:
		return

	var middle := (start_pos + end_pos) * 0.5
	middle.y = 0.0
	var angle := atan2(direction.x, direction.z)

	var conveyor_root := Node3D.new()
	conveyor_root.name = "FactoryConveyorLink"
	conveyor_root.position = middle
	conveyor_root.rotation.y = angle
	add_child(conveyor_root)

	# Reinforced frame with a matching collision body, belt surface and side guards.
	var frame_body := StaticBody3D.new()
	frame_body.name = "FactoryConveyorFrame"
	frame_body.position.y = 0.78
	conveyor_root.add_child(frame_body)

	var frame_mesh := MeshInstance3D.new()
	var frame_box := BoxMesh.new()
	frame_box.size = Vector3(1.75, 0.28, length)
	frame_mesh.mesh = frame_box
	frame_mesh.material_override = _mat(Color(0.07, 0.11, 0.12))
	frame_body.add_child(frame_mesh)

	var frame_collision := CollisionShape3D.new()
	var frame_shape := BoxShape3D.new()
	frame_shape.size = frame_box.size
	frame_collision.shape = frame_shape
	frame_body.add_child(frame_collision)

	_box_child(conveyor_root, "FactoryConveyorBelt", Vector3(0.0, 0.96, 0.0), Vector3(1.48, 0.07, maxf(0.2, length - 0.12)), Color(0.025, 0.04, 0.045))
	for side in [-1.0, 1.0]:
		_box_child(conveyor_root, "FactoryConveyorRail", Vector3(side * 0.82, 1.18, 0.0), Vector3(0.10, 0.40, length), Color(0.48, 0.54, 0.52))

	# Compact drive assembly: guarded motor, gearbox and service-side coupling.
	_box_child(conveyor_root, "FactoryConveyorDriveGuard", Vector3(1.12, 0.70, -length * 0.5 + minf(0.95, length * 0.25)), Vector3(0.42, 0.62, 0.72), Color(0.13, 0.19, 0.20))
	_box_child(conveyor_root, "FactoryConveyorGearbox", Vector3(1.40, 0.76, -length * 0.5 + minf(0.95, length * 0.25)), Vector3(0.28, 0.40, 0.42), Color(0.38, 0.44, 0.43))
	var drive_motor := MeshInstance3D.new()
	drive_motor.name = "FactoryConveyorDriveMotor"
	var drive_motor_mesh := CylinderMesh.new()
	drive_motor_mesh.top_radius = 0.22
	drive_motor_mesh.bottom_radius = 0.22
	drive_motor_mesh.height = 0.48
	drive_motor.mesh = drive_motor_mesh
	drive_motor.position = Vector3(1.34, 0.72, -length * 0.5 + minf(0.95, length * 0.25))
	drive_motor.rotation_degrees.z = 90.0
	drive_motor.material_override = _mat(Color(0.20, 0.29, 0.30))
	conveyor_root.add_child(drive_motor)
	_box_child(conveyor_root, "FactoryConveyorMotorLabel", Vector3(1.36, 1.02, -length * 0.5 + minf(0.95, length * 0.25)), Vector3(0.30, 0.035, 0.24), Color(0.94, 0.62, 0.13))
	# Repeated support feet and diagonal bracing keep long transfer links grounded.
	var support_count := maxi(2, int(floor(length / 3.5)))
	for support_i in range(support_count):
		var support_z := (float(support_i) + 0.5) / float(support_count) * length - length * 0.5
		for support_side in [-1.0, 1.0]:
			_box_child(conveyor_root, "FactoryConveyorSupportLeg", Vector3(support_side * 0.62, 0.34, support_z), Vector3(0.13, 0.68, 0.14), Color(0.15, 0.20, 0.21))
		_box_child(conveyor_root, "FactoryConveyorSupportCrossbar", Vector3(0.0, 0.12, support_z), Vector3(1.20, 0.12, 0.14), Color(0.38, 0.44, 0.43))

	# Rollers are children of the rotated root, so their axles stay perpendicular to travel.
	var roller_count := maxi(2, int(ceil(length / 0.65)) + 1)
	for i in range(roller_count):
		var t := (float(i) + 0.5) / float(roller_count)
		var roller := MeshInstance3D.new()
		roller.name = "FactoryConveyorRoller"
		var roller_mesh := CylinderMesh.new()
		roller_mesh.top_radius = 0.095
		roller_mesh.bottom_radius = 0.095
		roller_mesh.height = 1.42
		roller.mesh = roller_mesh
		roller.position = Vector3(0.0, 0.83, (t - 0.5) * length)
		roller.rotation_degrees.z = 90.0
		roller.material_override = _mat(Color(0.55, 0.60, 0.58))
		conveyor_root.add_child(roller)
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

	# Dark inactive display panel; no misleading static status text.
	_box_child(root, "RespawnPanelScreenFrame", Vector3(-0.29, 0.12, 0.0), Vector3(0.07, 0.48, 0.92), Color(0.035, 0.065, 0.07))
	_box_child(root, "RespawnPanelScreen", Vector3(-0.33, 0.12, 0.0), Vector3(0.025, 0.34, 0.72), Color(0.08, 0.30, 0.29))

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
	label.text = "CITY REFILL"
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
	# Start beside the factory entrance, not in the middle of the city.
	player.position = Vector3(143.0, 0.05, 5.5)
	player.set("move_speed", 4.5 + float(speed_upgrade_level - 1) * 0.75)
	add_child(player)

	# Compact friendly recycling robot with animated joints.
	robot_visual = Node3D.new()
	robot_visual.name = "RecyclerBot"
	player.add_child(robot_visual)

	# Industrial, adult-style recycler chassis: segmented armor and a sensor visor.
	# Rounded, layered teal-and-graphite recycler armor with visible mechanical joints.
	_add_robot_box(robot_visual, "Torso", Vector3(0, 1.05, 0), Vector3(0.82, 0.88, 0.52), Color(0.10, 0.22, 0.24))
	_add_robot_box(robot_visual, "ChestArmor", Vector3(0, 1.18, -0.27), Vector3(0.66, 0.55, 0.075), Color(0.34, 0.43, 0.42))
	_add_robot_box(robot_visual, "ChestPanel", Vector3(0, 1.13, -0.318), Vector3(0.40, 0.25, 0.035), Color(0.035, 0.12, 0.14))
	_add_robot_box(robot_visual, "StatusBar", Vector3(0, 1.19, -0.342), Vector3(0.27, 0.045, 0.025), Color(0.12, 0.95, 0.72))
	_add_robot_box(robot_visual, "ChestLowerTrim", Vector3(0, 0.91, -0.318), Vector3(0.48, 0.045, 0.025), Color(0.82, 0.68, 0.30))
	_add_robot_box(robot_visual, "Belt", Vector3(0, 0.62, 0), Vector3(0.84, 0.16, 0.54), Color(0.045, 0.075, 0.085))
	_add_robot_box(robot_visual, "BeltBuckle", Vector3(0, 0.63, -0.285), Vector3(0.22, 0.12, 0.045), Color(0.82, 0.68, 0.30))
	_add_robot_box(robot_visual, "ShoulderArmorL", Vector3(-0.49, 1.39, 0), Vector3(0.34, 0.34, 0.38), Color(0.38, 0.48, 0.46))
	_add_robot_box(robot_visual, "ShoulderArmorR", Vector3(0.49, 1.39, 0), Vector3(0.34, 0.34, 0.38), Color(0.38, 0.48, 0.46))
	for shoulder_x in [-0.49, 0.49]:
		_add_robot_sphere(robot_visual, "ShoulderJoint", Vector3(shoulder_x, 1.30, 0), 0.17, Color(0.08, 0.13, 0.15))
		_add_robot_sphere(robot_visual, "ShoulderBolt", Vector3(shoulder_x, 1.30, -0.19), 0.055, Color(0.86, 0.70, 0.32))

	robot_head = Node3D.new()
	robot_head.position = Vector3(0, 1.82, 0)
	robot_visual.add_child(robot_head)
	_add_robot_box(robot_head, "HeadShell", Vector3(0, 0, 0), Vector3(0.76, 0.62, 0.60), Color(0.52, 0.61, 0.59))
	_add_robot_box(robot_head, "Visor", Vector3(0, 0.015, -0.315), Vector3(0.62, 0.27, 0.045), Color(0.018, 0.045, 0.055))
	_add_robot_box(robot_head, "VisorGlow", Vector3(0, -0.105, -0.342), Vector3(0.48, 0.018, 0.018), Color(0.05, 0.55, 0.52))
	_add_robot_sphere(robot_head, "EyeL", Vector3(-0.16, 0.035, -0.345), 0.065, Color(0.18, 1.0, 0.83))
	_add_robot_sphere(robot_head, "EyeR", Vector3(0.16, 0.035, -0.345), 0.065, Color(0.18, 1.0, 0.83))
	_add_robot_box(robot_head, "JawPlate", Vector3(0, -0.22, -0.275), Vector3(0.42, 0.13, 0.085), Color(0.20, 0.30, 0.31))
	_add_robot_box(robot_head, "MouthGrille", Vector3(0, -0.22, -0.324), Vector3(0.20, 0.035, 0.018), Color(0.08, 0.15, 0.16))
	_add_robot_box(robot_head, "HeadSideL", Vector3(-0.39, 0, 0), Vector3(0.10, 0.30, 0.42), Color(0.19, 0.25, 0.27))
	_add_robot_box(robot_head, "HeadSideR", Vector3(0.39, 0, 0), Vector3(0.10, 0.30, 0.42), Color(0.19, 0.25, 0.27))
	_add_robot_box(robot_head, "TopSensor", Vector3(0, 0.34, 0), Vector3(0.17, 0.13, 0.19), Color(0.12, 0.22, 0.23))
	_add_robot_sphere(robot_head, "TopStatusLight", Vector3(0, 0.43, 0), 0.055, Color(0.18, 0.95, 0.72))

	robot_left_arm = _robot_limb(robot_visual, "LeftArm", Vector3(-0.48, 1.30, 0), Color(0.22, 0.43, 0.48))
	robot_right_arm = _robot_limb(robot_visual, "RightArm", Vector3(0.48, 1.30, 0), Color(0.22, 0.43, 0.48))
	magnet_tool = Node3D.new()
	magnet_tool.name = "UnlockedHandMagnet"
	magnet_tool.position = Vector3(0.0, -0.43, -0.015)
	robot_right_arm.add_child(magnet_tool)
	_add_robot_box(magnet_tool, "MagnetCore", Vector3(0, -0.02, 0), Vector3(0.30, 0.12, 0.16), Color(0.16, 0.22, 0.27))
	_add_robot_box(magnet_tool, "MagnetLeftPole", Vector3(-0.12, -0.14, 0), Vector3(0.10, 0.22, 0.16), Color(0.88, 0.20, 0.18))
	_add_robot_box(magnet_tool, "MagnetRightPole", Vector3(0.12, -0.14, 0), Vector3(0.10, 0.22, 0.16), Color(0.18, 0.42, 0.92))
	_add_robot_box(magnet_tool, "MagnetGrip", Vector3(0, 0.10, 0), Vector3(0.12, 0.10, 0.18), Color(0.65, 0.72, 0.73))
	# Exposed induction coil and a subtle animated field loop make the magnet
	# read as a powered industrial tool, not a plain colored block.
	var magnet_coil := _add_robot_sphere(magnet_tool, "InductionCoil", Vector3(0, -0.12, -0.105), 0.075, Color(0.18, 0.92, 0.82))
	magnet_coil.scale = Vector3(1.0, 1.0, 0.48)
	magnet_field_ring = MeshInstance3D.new()
	magnet_field_ring.name = "MagneticFieldLoop"
	var field_mesh := TorusMesh.new()
	field_mesh.inner_radius = 0.105
	field_mesh.outer_radius = 0.125
	magnet_field_ring.mesh = field_mesh
	magnet_field_ring.position = Vector3(0, -0.17, -0.10)
	magnet_field_ring.rotation.x = PI * 0.5
	magnet_field_ring.material_override = _mat(Color(0.12, 0.82, 0.76, 0.72))
	magnet_tool.add_child(magnet_field_ring)
	magnet_tool.visible = (auto_pickup_level > 0 or magnet_power_level > 1) and suction_level <= 0

	# Separate vacuum attachment on the opposite arm, unlocked by suction upgrades.
	suction_tool = Node3D.new()
	suction_tool.name = "ArmMountedVacuum"
	suction_tool.position = Vector3(0.0, -0.43, -0.015)
	robot_right_arm.add_child(suction_tool)
	_add_robot_box(suction_tool, "VacuumMotor", Vector3(0, -0.02, 0.02), Vector3(0.24, 0.25, 0.28), Color(0.12, 0.22, 0.25))
	_add_robot_box(suction_tool, "VacuumTube", Vector3(0, -0.10, -0.20), Vector3(0.13, 0.12, 0.34), Color(0.48, 0.58, 0.59))
	_add_robot_box(suction_tool, "VacuumMouth", Vector3(0, -0.12, -0.40), Vector3(0.34, 0.16, 0.12), Color(0.10, 0.75, 0.68))
	# Guarded intake, spinning impeller and live status lamp.
	_add_robot_box(suction_tool, "IntakeGuardTop", Vector3(0, -0.035, -0.475), Vector3(0.31, 0.035, 0.045), Color(0.68, 0.76, 0.74))
	_add_robot_box(suction_tool, "IntakeGuardBottom", Vector3(0, -0.205, -0.475), Vector3(0.31, 0.035, 0.045), Color(0.68, 0.76, 0.74))
	vacuum_status_light = _add_robot_sphere(suction_tool, "VacuumStatus", Vector3(0.13, 0.015, -0.13), 0.035, Color(0.16, 0.95, 0.70))
	vacuum_rotor = Node3D.new()
	vacuum_rotor.name = "Impeller"
	vacuum_rotor.position = Vector3(0, -0.02, -0.23)
	suction_tool.add_child(vacuum_rotor)
	_add_robot_sphere(vacuum_rotor, "ImpellerHub", Vector3.ZERO, 0.045, Color(0.78, 0.86, 0.82))
	for blade_angle in [0.0, TAU / 3.0, TAU * 2.0 / 3.0]:
		var blade := _add_robot_box(vacuum_rotor, "ImpellerBlade", Vector3(0, 0.0, -0.055), Vector3(0.035, 0.025, 0.13), Color(0.20, 0.72, 0.66))
		blade.rotation.z = blade_angle
	suction_tool.visible = suction_level > 0
	if suction_level > 0:
		magnet_tool.visible = false
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
	camera_pivot.position = player.global_position + Vector3(0, 8.0, 10.5)
	add_child(camera_pivot)
	camera = Camera3D.new()
	camera.position = Vector3.ZERO
	camera.rotation_degrees = Vector3(-30, 0, 0)
	camera.current = true
	camera.fov = 58
	camera_pivot.add_child(camera)
	player.set("camera_pivot", camera_pivot)

	# Industrial service markings, cooling fins and high-visibility safety armor.
	for shoulder_x in [-0.49, 0.49]:
		_add_robot_box(robot_visual, "ShoulderHazardStripe", Vector3(shoulder_x, 1.48, -0.205), Vector3(0.23, 0.075, 0.035), Color(0.96, 0.62, 0.13))
	for fin_y in [0.84, 1.02, 1.20]:
		_add_robot_box(robot_visual, "BatteryCoolingFin", Vector3(0.0, fin_y, 0.505), Vector3(0.40, 0.055, 0.045), Color(0.34, 0.43, 0.44))
	_add_robot_box(robot_visual, "BatteryServiceLatch", Vector3(0.0, 1.36, 0.505), Vector3(0.20, 0.09, 0.04), Color(0.91, 0.63, 0.16))
	_add_robot_box(robot_visual, "BackpackWarningPlate", Vector3(0.0, 0.76, 0.505), Vector3(0.30, 0.12, 0.035), Color(0.06, 0.12, 0.14))
	_add_robot_sphere(robot_visual, "BackpackStatusBeacon", Vector3(0.27, 1.34, 0.28), 0.065, Color(1.0, 0.56, 0.12))

	# Hero robot redesign: recognizable industrial rescue/recycling silhouette.
	# Layered chest armor, framed power core and clear high-visibility identity.
	_add_robot_box(robot_visual, "ChestOuterBezel", Vector3(0.0, 1.18, -0.365), Vector3(0.54, 0.39, 0.045), Color(0.075, 0.13, 0.15))
	_add_robot_box(robot_visual, "ChestCoreGlass", Vector3(0.0, 1.19, -0.395), Vector3(0.34, 0.20, 0.025), Color(0.035, 0.24, 0.24))
	_add_robot_sphere(robot_visual, "ChestCorePulse", Vector3(0.0, 1.20, -0.418), 0.065, Color(0.16, 1.0, 0.76))
	_add_robot_box(robot_visual, "ChestLeftArmor", Vector3(-0.30, 1.34, -0.29), Vector3(0.18, 0.30, 0.12), Color(0.18, 0.38, 0.40))
	_add_robot_box(robot_visual, "ChestRightArmor", Vector3(0.30, 1.34, -0.29), Vector3(0.18, 0.30, 0.12), Color(0.18, 0.38, 0.40))
	# Helmet brow and cheek guards give the face a more purposeful industrial profile.
	_add_robot_box(robot_head, "HelmetBrow", Vector3(0.0, 0.19, -0.33), Vector3(0.70, 0.09, 0.12), Color(0.30, 0.40, 0.41))
	_add_robot_box(robot_head, "HelmetCheekL", Vector3(-0.34, -0.12, -0.30), Vector3(0.13, 0.22, 0.13), Color(0.22, 0.34, 0.36))
	_add_robot_box(robot_head, "HelmetCheekR", Vector3(0.34, -0.12, -0.30), Vector3(0.13, 0.22, 0.13), Color(0.22, 0.34, 0.36))
	_add_robot_box(robot_head, "LeftAudioModule", Vector3(-0.45, 0.02, 0.02), Vector3(0.14, 0.24, 0.30), Color(0.12, 0.21, 0.23))
	_add_robot_box(robot_head, "RightAudioModule", Vector3(0.45, 0.02, 0.02), Vector3(0.14, 0.24, 0.30), Color(0.12, 0.21, 0.23))
	_add_robot_sphere(robot_head, "LeftAudioIndicator", Vector3(-0.49, 0.03, -0.13), 0.045, Color(0.96, 0.62, 0.13))
	_add_robot_sphere(robot_head, "RightAudioIndicator", Vector3(0.49, 0.03, -0.13), 0.045, Color(0.96, 0.62, 0.13))
	# Armored forearms and knuckle plates remain attached to animated arm pivots.
	for arm in [robot_left_arm, robot_right_arm]:
		_add_robot_box(arm, "ForearmOuterShell", Vector3(0.0, -0.31, -0.205), Vector3(0.32, 0.23, 0.10), Color(0.34, 0.48, 0.48))
		_add_robot_box(arm, "ForearmSafetyInset", Vector3(0.0, -0.31, -0.263), Vector3(0.19, 0.055, 0.025), Color(0.96, 0.62, 0.13))
		_add_robot_sphere(arm, "WristBearing", Vector3(0.0, -0.48, -0.015), 0.105, Color(0.12, 0.20, 0.22))
	# Reinforced boots, ankle rings and visible shin warning panels.
	for leg in [robot_left_leg, robot_right_leg]:
		_add_robot_box(leg, "ShinSafetyPlate", Vector3(0.0, -0.20, -0.165), Vector3(0.17, 0.16, 0.025), Color(0.96, 0.62, 0.13))
		_add_robot_box(leg, "AnkleBearing", Vector3(0.0, -0.39, 0.0), Vector3(0.29, 0.09, 0.29), Color(0.12, 0.20, 0.22))
	# Waist utility pods and rear battery frame finish the functional silhouette.
	for pod_x in [-0.43, 0.43]:
		_add_robot_box(robot_visual, "WaistUtilityPod", Vector3(pod_x, 0.68, -0.12), Vector3(0.17, 0.24, 0.27), Color(0.16, 0.28, 0.30))
		_add_robot_box(robot_visual, "WaistPodLatch", Vector3(pod_x, 0.68, -0.265), Vector3(0.09, 0.06, 0.025), Color(0.92, 0.61, 0.14))

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
	var planar_speed := Vector2(player.velocity.x, player.velocity.z).length()
	var moving := planar_speed > 0.25
	var gait_amount := clampf(inverse_lerp(0.25, 4.0, planar_speed), 0.0, 1.0) if moving else 0.0
	var gait_phase := robot_anim_time * lerpf(7.5, 11.5, gait_amount)
	var stride := sin(gait_phase) * gait_amount
	var opposite_stride := sin(gait_phase + PI) * gait_amount

	# A weighted industrial gait: restrained body counter-sway and alternating steps.
	var bob := absf(sin(gait_phase * 2.0)) * 0.035 * gait_amount
	robot_visual.position.y = bob
	robot_visual.rotation.z = sin(gait_phase) * 0.018 * gait_amount
	robot_visual.rotation.x = -absf(stride) * 0.012
	robot_visual.rotation.y = sin(gait_phase * 0.5) * 0.018 * gait_amount

	var magnet_is_working := suction_level <= 0 and auto_pickup_level > 0 and is_instance_valid(auto_pickup_target)
	var vacuum_is_working := suction_level > 0 and is_instance_valid(suction_target)
	var tool_is_working := magnet_is_working or vacuum_is_working
	var tool_equipped := auto_pickup_level > 0 or suction_level > 0

	# Left arm counter-swings naturally; right arm transitions into a deliberate
	# reach pose when the collector locks onto waste.
	var left_swing := stride * 0.52
	var right_swing := -stride * 0.52 - (0.14 if tool_equipped else 0.0)
	var right_target := 1.08 if tool_is_working else right_swing
	robot_left_arm.rotation.x = lerp_angle(robot_left_arm.rotation.x, left_swing, clampf(delta * 9.0, 0.0, 1.0))
	robot_left_arm.rotation.z = lerp_angle(robot_left_arm.rotation.z, -0.035 - absf(stride) * 0.035, clampf(delta * 7.0, 0.0, 1.0))
	robot_right_arm.rotation.x = lerp_angle(robot_right_arm.rotation.x, right_target, clampf(delta * (12.0 if tool_is_working else 8.0), 0.0, 1.0))
	var right_roll_target := -0.10 if tool_is_working else 0.025 + stride * 0.035
	robot_right_arm.rotation.z = lerp_angle(robot_right_arm.rotation.z, right_roll_target, clampf(delta * 8.0, 0.0, 1.0))

	# Collector extension eases in/out instead of snapping, keeping both tools
	# rigidly aligned to the wrist through the full working animation.
	# Tool-specific motion: the induction loop pulses while locked on, and the
	# vacuum impeller spins only when suction is actively pulling an item.
	if is_instance_valid(magnet_field_ring):
		var field_active := magnet_is_working
		var field_pulse := 1.0 + (sin(robot_anim_time * 12.0) * 0.10 if field_active else 0.025)
		magnet_field_ring.scale = Vector3.ONE * field_pulse
		magnet_field_ring.visible = auto_pickup_level > 0 and suction_level <= 0
		magnet_field_ring.rotation.y += delta * (2.8 if field_active else 0.35)
	if is_instance_valid(vacuum_rotor):
		vacuum_rotor.rotation.z += delta * (22.0 if vacuum_is_working else 1.2)
	if is_instance_valid(vacuum_status_light):
		vacuum_status_light.visible = suction_level > 0
		vacuum_status_light.scale = Vector3.ONE * (1.0 + (sin(robot_anim_time * 10.0) * 0.18 if vacuum_is_working else 0.0))

	var extension_target := 0.34 if tool_is_working else 0.0
	collection_tool_extension = lerpf(collection_tool_extension, extension_target, clampf(delta * 8.5, 0.0, 1.0))
	if is_instance_valid(magnet_tool):
		magnet_tool.position.y = -0.43 - collection_tool_extension
		magnet_tool.position.z = -0.015
	if is_instance_valid(suction_tool):
		suction_tool.position.y = -0.43 - collection_tool_extension
		suction_tool.position.z = -0.015

	robot_left_leg.rotation.x = -stride * 0.42
	robot_right_leg.rotation.x = opposite_stride * 0.42
	# The head scans subtly while idle and steadies its gaze during collection.
	var head_scan := sin(robot_anim_time * 1.15) * 0.055 if not moving else sin(gait_phase * 0.5) * 0.025
	if tool_is_working:
		head_scan = lerpf(head_scan, -0.035, 0.65)
	robot_head.rotation.y = lerpf(robot_head.rotation.y, head_scan, clampf(delta * 4.5, 0.0, 1.0))

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
	_add_robot_box(pivot, "UpperArm", Vector3(0, -0.19, 0), Vector3(0.25, 0.43, 0.27), color)
	_add_robot_box(pivot, "ForearmArmor", Vector3(0, -0.29, -0.15), Vector3(0.29, 0.25, 0.12), color.lightened(0.16))
	_add_robot_sphere(pivot, "ElbowJoint", Vector3(0, -0.39, 0), 0.13, Color(0.08, 0.14, 0.16))
	_add_robot_sphere(pivot, "Hand", Vector3(0, -0.47, -0.015), 0.15, Color(0.58, 0.68, 0.65))
	return pivot

func _robot_leg(parent: Node3D, part_name: String, pos: Vector3) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = part_name
	pivot.position = pos
	parent.add_child(pivot)
	_add_robot_box(pivot, "Shin", Vector3(0, -0.20, 0), Vector3(0.24, 0.40, 0.25), Color(0.25, 0.36, 0.39))
	_add_robot_box(pivot, "ShinFrontArmor", Vector3(0, -0.20, -0.135), Vector3(0.27, 0.27, 0.035), Color(0.43, 0.55, 0.54))
	_add_robot_sphere(pivot, "KneeJoint", Vector3(0, -0.025, -0.015), 0.13, Color(0.08, 0.14, 0.16))
	_add_robot_box(pivot, "Boot", Vector3(0, -0.42, -0.09), Vector3(0.34, 0.16, 0.43), Color(0.07, 0.12, 0.15))
	_add_robot_box(pivot, "BootSole", Vector3(0, -0.505, -0.09), Vector3(0.36, 0.035, 0.45), Color(0.025, 0.04, 0.05))
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
	money_label = _label("CASH  0 ZC", Vector2(32, 27), 22, layer)
	bag_label = _label("BAG  0 / 5", Vector2(32, 64), 18, layer)
	final_zone_label = _label("COLLECTED  0 / 600,000", Vector2(32, 94), 14, layer)
	final_zone_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.30))
	_update_final_zone_label()

	# Large, high-contrast mission card. Keep instructions short and readable on phones.
	var mission_card := Panel.new()
	mission_card.name = "MissionCard"
	var wide_layout := screen.x > screen.y
	mission_card.position = Vector2(220 if wide_layout else 18, 152 if wide_layout else 134)
	mission_card.size = Vector2(clampf(screen.x - (350.0 if wide_layout else 36.0), 284.0, 360.0), 132.0)
	mission_card.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.075, 0.068, 0.96)))
	layer.add_child(mission_card)
	var mission_title := _label("NEXT STEP", Vector2(14, 9), 14, mission_card)
	mission_title.name = "MissionTitle"
	mission_title.add_theme_color_override("font_color", Color(0.38, 1.0, 0.72))
	mission_label = _label("", Vector2(14, 34), 16, mission_card)
	mission_label.size = Vector2(mission_card.size.x - 28.0, 54.0)
	mission_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mission_label.add_theme_color_override("font_color", Color(0.98, 1.0, 0.99))
	mission_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	mission_label.add_theme_constant_override("shadow_offset_x", 1)
	mission_label.add_theme_constant_override("shadow_offset_y", 1)
	message_label = _label("", Vector2(14, 91), 12, mission_card)
	message_label.size = Vector2(mission_card.size.x - 28.0, 30.0)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.30))
	message_label.visible = false
	_update_missions()

	var collect := _button("", Vector2(-124, -150), Vector2(104, 104), layer)
	_anchor_bottom_right(collect)
	collect.tooltip_text = "COLLECT"
	collect.icon = load("res://robot_claw.svg") as Texture2D
	collect.expand_icon = true
	collect.add_theme_stylebox_override("normal", _circle_button_style(Color(0.08, 0.34, 0.29, 0.58)))
	collect.add_theme_stylebox_override("hover", _circle_button_style(Color(0.12, 0.46, 0.37, 0.68)))
	collect.add_theme_stylebox_override("pressed", _circle_button_style(Color(0.05, 0.24, 0.22, 0.76)))
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
	# Keep the whole upgrade window comfortably inside the phone screen edges.
	upgrade_panel.offset_left = 18
	upgrade_panel.offset_top = 18
	upgrade_panel.offset_right = -18
	upgrade_panel.offset_bottom = -18
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
	skill_scroll_container.scroll_deadzone = 1
	skill_scroll_container.scroll_vertical_custom_step = 48.0
	skill_scroll_container.mouse_filter = Control.MOUSE_FILTER_STOP
	upgrade_panel.add_child(skill_scroll_container)
	skill_map = VBoxContainer.new()
	skill_map.name = "UpgradeCards"
	skill_map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skill_map.add_theme_constant_override("separation", 10)
	skill_scroll_container.add_child(skill_map)
	var hint := _label("SWIPE UP / DOWN TO BROWSE", Vector2(0, -30), 12, upgrade_panel)
	hint.anchor_left = 0.0
	hint.anchor_right = 1.0
	hint.anchor_top = 1.0
	hint.anchor_bottom = 1.0
	hint.offset_left = 12
	hint.offset_right = -12
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_color_override("font_color", Color(0.48, 0.78, 0.69))
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
	# Subtle blueprint grid and a low industrial skyline give the title screen
	# a branded factory atmosphere without loading a heavy background texture.
	for grid_x in range(0, int(screen.x), 64):
		var grid_line := ColorRect.new()
		grid_line.position = Vector2(grid_x, 0)
		grid_line.size = Vector2(1, screen.y)
		grid_line.color = Color(0.30, 0.55, 0.55, 0.045)
		grid_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		main_menu_panel.add_child(grid_line)
	for grid_y in range(0, int(screen.y), 64):
		var grid_row_line := ColorRect.new()
		grid_row_line.position = Vector2(0, grid_y)
		grid_row_line.size = Vector2(screen.x, 1)
		grid_row_line.color = Color(0.30, 0.55, 0.55, 0.035)
		grid_row_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		main_menu_panel.add_child(grid_row_line)
	var skyline_heights := [54.0, 86.0, 62.0, 118.0, 76.0, 96.0, 66.0, 108.0, 58.0, 90.0]
	for building_index in range(skyline_heights.size()):
		var building := ColorRect.new()
		var building_width := screen.x / float(skyline_heights.size()) + 1.0
		building.position = Vector2(float(building_index) * building_width, screen.y - skyline_heights[building_index])
		building.size = Vector2(building_width, skyline_heights[building_index])
		building.color = Color(0.08, 0.16, 0.18, 0.62)
		building.mouse_filter = Control.MOUSE_FILTER_IGNORE
		main_menu_panel.add_child(building)
	var logo := TextureRect.new()
	logo.texture = load("res://icon.svg")
	logo.position = Vector2(screen.x * 0.78, screen.y * 0.055)
	logo.size = Vector2(68, 68)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_menu_panel.add_child(logo)
	var system_status := Label.new()
	system_status.text = "ZEKA INDUSTRIAL SYSTEMS  /  OPERATIONS ONLINE"
	system_status.position = Vector2(screen.x * 0.12, screen.y * 0.065)
	system_status.size = Vector2(screen.x * 0.62, 24)
	system_status.add_theme_font_size_override("font_size", 11)
	system_status.add_theme_color_override("font_color", Color(0.91, 0.66, 0.20))
	system_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_menu_panel.add_child(system_status)
	var accent := ColorRect.new()
	accent.position = Vector2(screen.x * 0.08, screen.y * 0.19)
	accent.size = Vector2(8, screen.y * 0.34)
	accent.color = Color(0.94, 0.65, 0.16)
	main_menu_panel.add_child(accent)
	var accent_inner := ColorRect.new()
	accent_inner.position = Vector2(screen.x * 0.08 + 11, screen.y * 0.19)
	accent_inner.size = Vector2(3, screen.y * 0.34)
	accent_inner.color = Color(0.18, 0.73, 0.61)
	main_menu_panel.add_child(accent_inner)
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
	subtitle.text = "INDUSTRIAL RECYCLING SIMULATOR"
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
	footer.text = "COLLECT  •  AUTOMATE  •  RECYCLE  •  EXPAND"
	footer.position = Vector2(button_x, screen.y * 0.82)
	footer.size = Vector2(button_width, 28)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 12)
	footer.add_theme_color_override("font_color", Color(0.48, 0.58, 0.57))
	main_menu_panel.add_child(footer)
	for stripe_index in range(24):
		var hazard_stripe := ColorRect.new()
		hazard_stripe.position = Vector2(float(stripe_index) * screen.x / 24.0, screen.y * 0.965)
		hazard_stripe.size = Vector2(screen.x / 24.0, 7)
		hazard_stripe.color = Color(0.95, 0.65, 0.15) if stripe_index % 2 == 0 else Color(0.055, 0.075, 0.08)
		hazard_stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
		main_menu_panel.add_child(hazard_stripe)
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
	dialog.confirmed.connect(func() -> void:
		_save_game()
		get_tree().quit()
	)
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
	final_cleanup_spawned = false
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
	drone_speed_upgrade_level = 0
	drone_capacity_upgrade_level = 0
	ground_robot_level = 0
	ground_collector_timer = 0.0
	sorting_robot_levels = [0, 0, 0, 0]
	sorting_bin_counts = [0, 0, 0, 0]
	sorting_robot_upgrade_level = 0
	conveyor_speed_upgrade_level = 0
	waste_tank_unload_upgrade_level = 0
	waste_tank_capacity_upgrade_level = 0
	repair_robot_level = 0
	machine_broken = false
	machine_work_timer = 0.0
	machine_repair_timer = 0.0
	factory_truck_interval_upgrade_level = 0
	_reset_automation_units_for_new_world()
	_refresh_helper_drone_visibility()
	_refresh_ground_collector()
	if is_instance_valid(magnet_tool):
		magnet_tool.visible = false
	if is_instance_valid(suction_tool):
		suction_tool.visible = false
	_refresh_sorting_district()
	dispatch_upgrade_level = 0
	waste_tank_built = false
	if is_instance_valid(waste_tank_root):
		waste_tank_root.queue_free()
	waste_tank_root = null
	if is_instance_valid(waste_tank_build_label):
		waste_tank_build_label.visible = true
	fleet_upgrade_level = 0
	truck_capacity_upgrade_level = 0
	packaging_upgrade_level = 0
	truck_dispatch_timer = 0.0
	shipping_active = false
	dispatch_trucks_remaining = 0
	factory_shipping_timer = 0.0
	factory_shipping_cooldown = 0.0
	factory_shipping_busy = false
	factory_shipping_row = 0
	factory_shipping_trucks.clear()
	waste_feed_timer = 0.0
	waste_feed_busy = false
	waste_feed_line_index = 0
	delivery_trucks.clear()
	_refresh_helper_drone_visibility()
	auto_pickup_timer = 0.0
	recycling_bonus = 1.0
	collection_range = 2.0
	yard_stage = 4
	factory_stage = 1
	factory_built_stage = 1
	teddy_stock_values.clear()
	shipping_active = false
	factory_build_paid = 0.0
	factory_build_save_timer = 0.0
	mega_factory_built_count = 1
	factory_row_input_stock = [0, 0, 0, 0, 0]
	factory_row_stage1_stock = [0, 0, 0, 0, 0]
	factory_row_stage2_stock = [0, 0, 0, 0, 0]
	factory_row_product_stock = [0, 0, 0, 0, 0]
	factory_row_belt_items = [[], [], [], [], []]
	factory_total_products_made = 0
	factory_production_timer = 0.0
	factory_shipping_timer = 0.0
	factory_shipping_cooldown = 0.0
	factory_shipping_busy = false
	factory_shipping_row = 0
	waste_feed_timer = 0.0
	waste_feed_busy = false
	waste_feed_line_index = 0
	waste_tank_inventory = 0
	factory_waste_deposited_total = 0
	mega_factory_build_paid = 0.0
	mega_factory_build_timer = 0.0
	if is_instance_valid(factory_visual_root):
		for factory_child in factory_visual_root.get_children():
			factory_visual_root.remove_child(factory_child)
			factory_child.queue_free()
	# Factory machinery and conveyors are created as direct scene children, not
	# under factory_visual_root. Remove those generated visuals on every NEW run.
	var factory_reset_prefixes := [
		"MegaProcessMachine", "FactoryMainConveyor",
		"FactoryWasteConveyorItem", "FactorySpecificProduct", "FactoryProductTruck",
		"FactoryDoorMoving", "DeliveryConveyor", "TeddyShippingPackage",
		"FinishedPlasticBottle", "PlasticBottleCap", "FinishedCardboardBox",
		"CardboardBoxTape", "FinishedMetalComponent", "MetalComponentCore",
		"FinishedGlassJar", "GlassJarRim", "RefurbishedElectronicUnit",
		"ElectronicDisplay", "FactoryRowTruck"
	]
	for row_items in factory_row_belt_items:
		for product in row_items:
			if is_instance_valid(product):
				product.queue_free()
	for child in get_children():
		for prefix in factory_reset_prefixes:
			if child.name.begins_with(prefix):
				child.queue_free()
				break
	conveyor_rollers.clear()
	conveyor_slats.clear()
	factory_conveyor_slats.clear()
	waste_feed_conveyor_network_built = false
	mega_factory_machine_labels.clear()
	# A fresh world starts with only the first machine and its connected belt.
	_build_mega_factory_machine(0)
	_build_factory_row_main_conveyor(0)
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

func _reset_automation_units_for_new_world() -> void:
	for drone in helper_drones:
		if not is_instance_valid(drone):
			continue
		var target := _get_meta_node(drone, "target")
		if is_instance_valid(target):
			target.set_meta("drone_reserved", -1)
		var lifting_item := _get_meta_node(drone, "lifting_item")
		if is_instance_valid(lifting_item):
			lifting_item.queue_free()
		for cargo_item in drone.get_meta("cargo_items", []):
			if is_instance_valid(cargo_item):
				cargo_item.queue_free()
		drone.set_meta("target", null)
		drone.set_meta("lifting_item", null)
		drone.set_meta("cargo_items", [])
		drone.set_meta("cargo_slots", 0)
		drone.set_meta("cargo_bulky", 0)
		drone.set_meta("returning", false)
		drone.set_meta("deposit_timer", 0.0)
		drone.set_meta("pickup_timer", 0.0)
		drone.set_meta("scan_cooldown", 0.0)
		drone.global_position = _drone_dock_point(drone)

	if is_instance_valid(ground_collector):
		var rover_target := _get_meta_node(ground_collector, "target")
		if is_instance_valid(rover_target):
			rover_target.set_meta("drone_reserved", -1)
		for cargo_item in ground_collector.get_meta("cargo_items", []):
			if is_instance_valid(cargo_item):
				cargo_item.queue_free()
		ground_collector.set_meta("target", null)
		ground_collector.set_meta("cargo_items", [])
		ground_collector.set_meta("cargo_slots", 0)
		ground_collector.set_meta("cargo_bulky", 0)
		ground_collector.set_meta("returning", false)
		ground_collector.set_meta("deposit_timer", 0.0)
		ground_collector.set_meta("scan_cooldown", 0.0)
		ground_collector.global_position = Vector3(144.0, 0.0, 10.0)
		ground_collector.set_meta("previous_position", ground_collector.global_position)

	for index in range(sorting_robots.size()):
		var robot := sorting_robots[index]
		if not is_instance_valid(robot):
			continue
		var target := _get_meta_node(robot, "target")
		if is_instance_valid(target):
			target.set_meta("drone_reserved", -1)
		var cargo := _get_meta_node(robot, "cargo")
		if is_instance_valid(cargo):
			cargo.queue_free()
		robot.set_meta("target", null)
		robot.set_meta("cargo", null)
		robot.set_meta("mode", "idle")
		robot.global_position = sorting_pad_positions[index] + Vector3(0.0, 0.0, 1.7)
		robot.set_meta("previous_position", robot.global_position)

	for sweeper in street_sweepers:
		if not is_instance_valid(sweeper):
			continue
		sweeper.set_meta("cargo", 0)
		sweeper.set_meta("returning", false)
		sweeper.set_meta("route_index", 0)
		if not street_sweeper_route.is_empty():
			sweeper.global_position = street_sweeper_route[0]
			sweeper.set_meta("previous_position", sweeper.global_position)

	if is_instance_valid(auto_pickup_target):
		auto_pickup_target.set_meta("drone_reserved", -1)
	if is_instance_valid(suction_target):
		suction_target.set_meta("drone_reserved", -1)
	auto_pickup_target = null
	suction_target = null
	auto_pickup_timer = 0.0
	auto_pickup_scan_timer = 0.0
	suction_scan_timer = 0.0
	suction_pull_timer = 0.0


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
		# Reconstruct saved starter-factory stages before gameplay resumes.
		_build_factory_expansion()
		_refresh_factory_upgrade_button()
		_refresh_delivery_fleet()
		_apply_unlocked_districts()
		world_initialized = true
		if final_cleanup_spawned or tutorial_mission_stage >= 29:
			final_cleanup_spawned = true
			_spawn_final_cleanup_trash()
			_save_game()
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
		{"title":"ROBOT & COLLECTION","folder":"📁\nROBOT","branches":["capacity","speed","range","unload","auto","bulk_pickup","magnet_power","suction","ground_robot"]},
		{"title":"RECYCLING & ECONOMY","folder":"📁\nECONOMY","branches":["technology","value","supply","luck","rare_drops","respawn"]},
		{"title":"AUTOMATION & FLEET","folder":"📁\nFLEET","branches":["drones","drone_speed","drone_capacity","sorting_robot","waste_tank_unload","waste_tank_capacity","dispatch","fleet","truck_capacity","packaging","conveyor_speed","factory_truck_interval"]}
	]
	var titles := {
		"capacity":"BACKPACK CAPACITY","speed":"MOVEMENT SPEED","range":"PICKUP RANGE","unload":"RECYCLING SPEED",
		"technology":"TECHNOLOGY","value":"TRASH VALUE","supply":"TRASH SUPPLY","auto":"AUTO PICKUP",
		"bulk_pickup":"MULTI PICKUP","respawn":"AUTO RESPAWN","luck":"LUCKY FINDS","rare_drops":"SILVER & GOLD FINDS","magnet_power":"MAGNET POWER","suction":"VACUUM SUCTION",
		"drones":"HELPER DRONES","drone_speed":"DRONE FLIGHT SPEED","drone_capacity":"DRONE CARGO CAPACITY","ground_robot":"GROUND COLLECTOR","sorting_robot":"SORTING ROBOT EFFICIENCY","dispatch":"TRUCK FREQUENCY",
		"fleet":"HIRE TRUCKS","truck_capacity":"TRUCK CAPACITY","packaging":"PACKAGING SPEED","conveyor_speed":"CONVEYOR & FACTORY SPEED","waste_tank_unload":"WASTE TANK DISCHARGE","waste_tank_capacity":"WASTE TANK CAPACITY","factory_truck_interval":"FACTORY TRUCK ARRIVAL"
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
		"drone_speed":"Make every helper drone fly faster on collection and return trips.",
		"drone_capacity":"Increase how much waste each helper drone carries before returning to its own station.",
		"ground_robot":"Deploy a four-wheel autonomous collection rover. Each level improves its speed and cargo capacity.",
		"sorting_robot":"Increase all built sorting robots’ travel speed and search radius.",
		"dispatch":"Send product delivery trucks more frequently.",
		"fleet":"Hire extra delivery trucks to ship products.",
		"truck_capacity":"Let each delivery truck carry more boxes.",
		"packaging":"Package products faster for shipment.",
		"conveyor_speed":"Move recycling items through the factory line faster.","waste_tank_unload":"Feed stored waste from the main tank onto the factory conveyor faster.","waste_tank_capacity":"Increase the main waste tank storage by 200 units per level.","factory_truck_interval":"Reduce the wait after each full truck: 45s, then 30s, 15s and 5s."
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
		category_body.add_theme_constant_override("separation", 12)
		category_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		category_body.visible = false
		parent.add_child(category_body)
		category_bodies.append(category_body)

		for branch in category.branches:
			# One large touch target per upgrade: the title, description and price
			# all belong to the same button, so players can tap anywhere on the card.
			var upgrade_row := Button.new()
			upgrade_row.custom_minimum_size = Vector2(0, 126)
			upgrade_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			upgrade_row.add_theme_stylebox_override("normal", _button_style(Color(0.075, 0.15, 0.15)))
			upgrade_row.add_theme_stylebox_override("hover", _button_style(Color(0.11, 0.25, 0.21)))
			upgrade_row.add_theme_stylebox_override("pressed", _button_style(Color(0.06, 0.12, 0.12)))
			upgrade_row.add_theme_stylebox_override("disabled", _button_style(Color(0.07, 0.11, 0.105)))
			var card_outline := StyleBoxFlat.new()
			card_outline.bg_color = Color(0.075, 0.15, 0.15)
			card_outline.set_corner_radius_all(14)
			card_outline.set_border_width_all(1)
			card_outline.border_color = Color(0.20, 0.39, 0.36, 0.9)
			card_outline.content_margin_left = 10
			card_outline.content_margin_right = 10
			card_outline.content_margin_top = 8
			card_outline.content_margin_bottom = 8
			upgrade_row.add_theme_stylebox_override("normal", card_outline)
			upgrade_row.pressed.connect(_purchase_upgrade_branch.bind(String(branch)))
			category_body.add_child(upgrade_row)

			var card_content := HBoxContainer.new()
			card_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			card_content.offset_left = 12
			card_content.offset_top = 9
			card_content.offset_right = -12
			card_content.offset_bottom = -9
			card_content.add_theme_constant_override("separation", 14)
			card_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
			upgrade_row.add_child(card_content)

			var upgrade_info := VBoxContainer.new()
			upgrade_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			upgrade_info.size_flags_stretch_ratio = 1.0
			upgrade_info.alignment = BoxContainer.ALIGNMENT_CENTER
			upgrade_info.add_theme_constant_override("separation", 5)
			upgrade_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card_content.add_child(upgrade_info)

			var row := upgrade_row
			var title_label := Label.new()
			title_label.custom_minimum_size = Vector2(0, 24)
			title_label.add_theme_font_size_override("font_size", 17)
			title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			title_label.add_theme_color_override("font_color", Color(0.96, 1.0, 0.98))
			title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			upgrade_info.add_child(title_label)

			var level_label := Label.new()
			level_label.text = "LEVEL 0 / 3"
			level_label.custom_minimum_size = Vector2(0, 18)
			level_label.add_theme_font_size_override("font_size", 12)
			level_label.add_theme_color_override("font_color", Color(0.40, 0.91, 0.72))
			level_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			upgrade_info.add_child(level_label)

			var description := Label.new()
			description.text = String(descriptions.get(String(branch), "Improves this part of your operation."))
			description.custom_minimum_size = Vector2(0, 48)
			description.size_flags_vertical = Control.SIZE_EXPAND_FILL
			description.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			description.add_theme_font_size_override("font_size", 13)
			description.add_theme_constant_override("line_spacing", 2)
			description.add_theme_color_override("font_color", Color(0.75, 0.85, 0.81))
			description.mouse_filter = Control.MOUSE_FILTER_IGNORE
			upgrade_info.add_child(description)

			var price_panel := PanelContainer.new()
			price_panel.custom_minimum_size = Vector2(92, 76)
			price_panel.size_flags_horizontal = Control.SIZE_SHRINK_END
			price_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			var price_style := StyleBoxFlat.new()
			price_style.bg_color = Color(0.035, 0.15, 0.105)
			price_style.set_corner_radius_all(11)
			price_style.set_border_width_all(1)
			price_style.border_color = Color(0.18, 0.55, 0.39)
			price_style.content_margin_left = 5
			price_style.content_margin_right = 5
			price_style.content_margin_top = 5
			price_style.content_margin_bottom = 5
			price_panel.add_theme_stylebox_override("panel", price_style)
			price_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card_content.add_child(price_panel)
			var price_label := Label.new()
			price_label.text = "BUY"
			price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			price_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			price_label.add_theme_font_size_override("font_size", 15)
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
		"ground_robot": return Color(0.96, 0.66, 0.16)
		"dispatch": return Color(0.16, 0.70, 0.82)
		"fleet": return Color(0.90, 0.48, 0.22)
		"truck_capacity": return Color(0.75, 0.52, 0.22)
		"packaging": return Color(0.72, 0.32, 0.62)
		"factory_truck_interval": return Color(0.18, 0.72, 0.62)
		"waste_tank_unload": return Color(0.18, 0.78, 0.68)
		"waste_tank_capacity": return Color(0.22, 0.68, 0.52)
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
		"drone_speed": return "💨"
		"drone_capacity": return "📦"
		"ground_robot": return "🚜"
		"repair_robot": return "🛠"
		"dispatch": return "⏱️"
		"fleet": return "🚚"
		"truck_capacity": return "📦"
		"packaging": return "🏭"
		"factory_truck_interval": return "🚛"
		"waste_tank_unload": return "🗑️"
		"waste_tank_capacity": return "🛢️"
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
		"drone_speed": return drone_speed_upgrade_level
		"drone_capacity": return drone_capacity_upgrade_level
		"ground_robot": return ground_robot_level
		"sorting_robot": return sorting_robot_upgrade_level
		"conveyor_speed": return conveyor_speed_upgrade_level
		"waste_tank_unload": return waste_tank_unload_upgrade_level
		"waste_tank_capacity": return waste_tank_capacity_upgrade_level
		"repair_robot": return repair_robot_level
		"dispatch": return dispatch_upgrade_level
		"fleet": return fleet_upgrade_level
		"truck_capacity": return truck_capacity_upgrade_level
		"packaging": return packaging_upgrade_level
		"factory_truck_interval": return factory_truck_interval_upgrade_level
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
		"drone_speed": await _upgrade_drone_speed()
		"drone_capacity": await _upgrade_drone_capacity()
		"ground_robot": await _upgrade_ground_robot()
		"sorting_robot": await _upgrade_sorting_robot()
		"conveyor_speed": await _upgrade_conveyor_speed()
		"waste_tank_unload": await _upgrade_waste_tank_unload()
		"waste_tank_capacity": await _upgrade_waste_tank_capacity()
		"repair_robot": await _upgrade_repair_robot()
		"dispatch": await _upgrade_dispatch()
		"fleet": await _upgrade_fleet()
		"truck_capacity": await _upgrade_truck_capacity()
		"packaging": await _upgrade_packaging()
		"factory_truck_interval": await _upgrade_factory_truck_interval()
	_update_missions()
	active_upgrade_branch = ""
	_refresh_upgrade_prices()

func _refresh_upgrade_prices() -> void:
	var base_costs := {"capacity":8.0,"speed":10.0,"unload":9.0,"range":12.0,"technology":14.0,"value":18.0,"supply":10.0,"auto":28.0,"luck":12.0,"magnet_power":20.0,"suction":45.0,"drones":55.0,"drone_speed":42.0,"drone_capacity":48.0,"ground_robot":65.0,"dispatch":45.0,"fleet":85.0,"truck_capacity":70.0,"packaging":60.0,"factory_truck_interval":70.0,"sorting_robot":50.0,"conveyor_speed":65.0,"waste_tank_unload":58.0,"waste_tank_capacity":72.0,"repair_robot":75.0,"rare_drops":25.0,"respawn":60.0,"bulk_pickup":35.0}
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
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Android may suspend or close the app without another gameplay input.
		# Flush the latest state at the lifecycle boundary as a final safeguard.
		_save_game()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
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
	var glide_distance := clampf(skill_scroll_velocity.y * 0.55, -850.0, 850.0)
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
	var blend := 1.0 - exp(-delta * 7.0)
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

func _is_on_city_asphalt(point: Vector3) -> bool:
	# The sweeper is restricted to the boulevard and the four paved cross streets.
	var on_boulevard := point.x >= -14.0 and point.x <= 112.0 and absf(point.z) <= 3.82
	if on_boulevard:
		return true
	for street_x in [16.0, 48.0, 80.0, 104.0]:
		if absf(point.x - street_x) <= 3.12 and point.z >= -37.0 and point.z <= 37.0:
			return true
	return false


func _build_street_sweeper() -> void:
	street_sweeper_route = [
		Vector3(-11.0, 0.0, 0.0),
		Vector3(16.0, 0.0, 0.0),
		Vector3(16.0, 0.0, -34.0),
		Vector3(16.0, 0.0, 0.0),
		Vector3(48.0, 0.0, 0.0),
		Vector3(48.0, 0.0, 34.0),
		Vector3(48.0, 0.0, 0.0),
		Vector3(80.0, 0.0, 0.0),
		Vector3(80.0, 0.0, -34.0),
		Vector3(80.0, 0.0, 0.0),
		Vector3(104.0, 0.0, 0.0),
		Vector3(104.0, 0.0, 34.0),
		Vector3(104.0, 0.0, 0.0),
		Vector3(-11.0, 0.0, 0.0)
	]
	street_sweepers.clear()
	var sweeper := _make_street_sweeper()
	add_child(sweeper)
	sweeper.global_position = street_sweeper_route[0]
	sweeper.set_meta("previous_position", sweeper.global_position)
	sweeper.set_meta("route_index", 1)
	sweeper.set_meta("cargo", 0)
	sweeper.set_meta("returning", false)
	street_sweepers.append(sweeper)


func _make_street_sweeper() -> Node3D:
	# Use a physics body so the sweeper respects the same world obstacles as vehicles.
	var root := CharacterBody3D.new()
	root.name = "AutonomousStreetSweeper"
	var body_collision := CollisionShape3D.new()
	body_collision.name = "SweeperBodyCollision"
	var body_shape := BoxShape3D.new()
	body_shape.size = Vector3(1.78, 1.18, 3.62)
	body_collision.shape = body_shape
	body_collision.position = Vector3(0.0, 1.12, 0.0)
	root.add_child(body_collision)
	root.floor_snap_length = 0.0
	root.safe_margin = 0.08
	var yellow := Color(0.94, 0.62, 0.08)
	var dark_yellow := Color(0.66, 0.39, 0.045)
	var glass := Color(0.10, 0.22, 0.27)
	var rubber := Color(0.025, 0.031, 0.034)
	_add_utility_vehicle_box(root, "SweeperLowerChassis", Vector3(0, 0.70, 0.0), Vector3(1.55, 0.32, 3.55), Color(0.12, 0.16, 0.16))
	_add_utility_vehicle_box(root, "SweeperCab", Vector3(0, 1.40, -1.05), Vector3(1.48, 1.25, 1.42), yellow)
	_add_utility_vehicle_box(root, "SweeperCabGlassFront", Vector3(0, 1.57, -1.78), Vector3(1.18, 0.76, 0.045), glass)
	_add_utility_vehicle_box(root, "SweeperCabGlassSideL", Vector3(-0.755, 1.57, -1.05), Vector3(0.035, 0.72, 0.92), glass)
	_add_utility_vehicle_box(root, "SweeperCabGlassSideR", Vector3(0.755, 1.57, -1.05), Vector3(0.035, 0.72, 0.92), glass)
	_add_utility_vehicle_box(root, "SweeperCabRoof", Vector3(0, 2.06, -1.05), Vector3(1.58, 0.16, 1.50), dark_yellow)
	# Rear-mounted cylindrical debris hopper and its visible metal cover.
	_add_utility_vehicle_box(root, "SweeperHopper", Vector3(0, 1.32, 0.82), Vector3(1.68, 1.12, 1.72), Color(0.23, 0.29, 0.28))
	_add_utility_vehicle_box(root, "SweeperHopperTop", Vector3(0, 1.91, 0.82), Vector3(1.72, 0.12, 1.76), Color(0.34, 0.40, 0.38))
	_add_utility_vehicle_box(root, "SweeperHopperRear", Vector3(0, 1.34, 1.70), Vector3(1.48, 0.82, 0.06), Color(0.13, 0.19, 0.19))
	_add_utility_vehicle_box(root, "SweeperFrontBumper", Vector3(0, 0.60, -1.98), Vector3(1.82, 0.20, 0.22), Color(0.16, 0.19, 0.19))
	var sweeper_wheels: Array[Node3D] = []
	for side in [-1.0, 1.0]:
		_add_utility_vehicle_box(root, "SweeperHeadlight", Vector3(side * 0.57, 1.05, -1.80), Vector3(0.25, 0.19, 0.08), Color(1.0, 0.88, 0.52))
		_add_utility_vehicle_box(root, "SweeperAmberBeacon", Vector3(side * 0.48, 2.20, -1.05), Vector3(0.16, 0.12, 0.16), Color(1.0, 0.42, 0.04))
		for axle_z in [-1.15, 1.22]:
			var wheel := MeshInstance3D.new()
			wheel.name = "SweeperWheel"
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.39
			wheel_mesh.bottom_radius = 0.39
			wheel_mesh.height = 0.24
			wheel_mesh.radial_segments = 24
			wheel.mesh = wheel_mesh
			wheel.position = Vector3(side * 0.82, 0.40, axle_z)
			wheel.rotation_degrees.z = 90.0
			wheel.material_override = _mat(rubber)
			root.add_child(wheel)
			sweeper_wheels.append(wheel)
			var hub := MeshInstance3D.new()
			hub.name = "SweeperWheelHub"
			var hub_mesh := CylinderMesh.new()
			hub_mesh.top_radius = 0.19
			hub_mesh.bottom_radius = 0.19
			hub_mesh.height = 0.07
			hub.mesh = hub_mesh
			hub.position = Vector3.ZERO
			hub.material_override = _mat(Color(0.58, 0.60, 0.56))
			wheel.add_child(hub)
		# Side brush assemblies: yellow guards and black radial bristles.
		_add_utility_vehicle_box(root, "BrushArm", Vector3(side * 1.02, 0.34, -1.18), Vector3(0.52, 0.10, 0.24), Color(0.28, 0.31, 0.29))
		var brush := Node3D.new()
		brush.name = "RotatingStreetBrush"
		brush.position = Vector3(side * 1.30, 0.19, -1.43)
		root.add_child(brush)
		var disc := MeshInstance3D.new()
		var disc_mesh := CylinderMesh.new()
		disc_mesh.top_radius = 0.43
		disc_mesh.bottom_radius = 0.43
		disc_mesh.height = 0.10
		disc.mesh = disc_mesh
		disc.material_override = _mat(dark_yellow)
		brush.add_child(disc)
		for bristle_index in range(12):
			var angle := TAU * float(bristle_index) / 12.0
			var bristle := MeshInstance3D.new()
			var bristle_mesh := BoxMesh.new()
			bristle_mesh.size = Vector3(0.07, 0.10, 0.36)
			bristle.mesh = bristle_mesh
			bristle.position = Vector3(cos(angle) * 0.29, -0.08, sin(angle) * 0.29)
			bristle.rotation.y = -angle
			bristle.material_override = _mat(Color(0.045, 0.052, 0.048))
			brush.add_child(bristle)
		brush.set_meta("side", side)
	_add_utility_vehicle_box(root, "SweeperSuctionMouth", Vector3(0, 0.30, -1.80), Vector3(0.78, 0.12, 0.30), Color(0.08, 0.10, 0.10))
	root.set_meta("wheels", sweeper_wheels)
	return root


func _drive_street_sweeper(sweeper: Node3D, target: Vector3, speed: float) -> void:
	if not is_instance_valid(sweeper):
		return
	var direction := target - sweeper.global_position
	direction.y = 0.0
	if direction.length_squared() <= 0.0001:
		return
	if sweeper is CharacterBody3D:
		var body := sweeper as CharacterBody3D
		body.velocity = direction.normalized() * speed
		body.move_and_slide()
	else:
		sweeper.global_position = sweeper.global_position.move_toward(target, speed * get_process_delta_time())


func _process_street_sweeper(delta: float) -> void:
	for sweeper in street_sweepers:
		if not is_instance_valid(sweeper):
			continue
		var previous_position: Vector3 = sweeper.get_meta("previous_position", sweeper.global_position)
		var travel_distance := sweeper.global_position.distance_to(previous_position)
		if travel_distance > 0.0001:
			for wheel in sweeper.get_meta("wheels", []):
				if is_instance_valid(wheel):
					wheel.rotate_object_local(Vector3.UP, travel_distance / 0.39)
		sweeper.set_meta("previous_position", sweeper.global_position)
		for child in sweeper.get_children():
			if child.name == "RotatingStreetBrush":
				child.rotation.y += delta * 10.0
		var cargo := int(sweeper.get_meta("cargo", 0))
		var returning := bool(sweeper.get_meta("returning", false))
		if returning:
			var dump_point := _factory_waste_drop_point()
			dump_point.y = sweeper.global_position.y
			_face_travel_direction(sweeper, dump_point, delta, 5.0)
			_drive_street_sweeper(sweeper, dump_point, 5.0)
			if sweeper.global_position.distance_to(dump_point) <= 1.1:
				if waste_tank_built and waste_tank_inventory < _waste_tank_capacity():
					var delivered := mini(cargo, _waste_tank_capacity() - waste_tank_inventory)
					waste_tank_inventory += delivered
					factory_waste_deposited_total += delivered
					_update_missions()
					_refresh_waste_tank_inventory_label()
					_refresh_sorting_district()
					_update_ui()
					_save_game()
					sweeper.set_meta("cargo", cargo - delivered)
				if int(sweeper.get_meta("cargo", 0)) <= 0:
					sweeper.set_meta("cargo", 0)
					sweeper.set_meta("returning", false)
					sweeper.set_meta("route_index", 0)
					sweeper.global_position = street_sweeper_route[0]
					sweeper.set_meta("previous_position", sweeper.global_position)
			continue
		if cargo >= 30:
			sweeper.set_meta("returning", true)
			continue
		var route_index := int(sweeper.get_meta("route_index", 0)) % street_sweeper_route.size()
		var waypoint: Vector3 = street_sweeper_route[route_index]
		var travel := waypoint - sweeper.global_position
		if travel.length() > 0.10:
			_face_travel_direction(sweeper, waypoint, delta, 3.0)
			_drive_street_sweeper(sweeper, waypoint, 3.6)
		else:
			sweeper.set_meta("route_index", (route_index + 1) % street_sweeper_route.size())
		# Brushes only pick up litter physically placed on the asphalt surface.
		for item in trash_nodes.duplicate():
			if not is_instance_valid(item) or item.get_meta("drone_reserved", -1) != -1:
				continue
			if not _is_on_city_asphalt(item.global_position):
				continue
			if sweeper.global_position.distance_to(item.global_position) > 2.25:
				continue
			item.queue_free()
			trash_nodes.erase(item)
			_register_final_cleanup_pickup(item)
			cargo += 1
			sweeper.set_meta("cargo", cargo)
			if cargo >= 30:
				break


func _register_final_cleanup_pickup(item: Node3D) -> void:
	if not is_instance_valid(item):
		return
	# Endgame salvage bundles represent 100 units; ordinary litter represents one.
	var cleanup_units := maxi(0, int(item.get_meta("final_cleanup_units", 0)))
	var collected_units := maxi(1, cleanup_units)
	total_trash_collected += collected_units
	if cleanup_units > 0:
		final_zone_cleaned = mini(FINAL_ZONE_TARGET, final_zone_cleaned + cleanup_units)
	_update_final_zone_label()
	_update_missions()
	_maintain_city_trash_supply()
	_save_game()

func _maintain_city_trash_supply() -> void:
	var alive_count := _count_regular_trash()
	if alive_count > 500:
		return
	var amount := maxi(0, 500 - alive_count)
	if amount > 0:
		_spawn_trash(amount)
		_update_final_zone_label()
		_set_message("CITY SUPPLY RESTORED: %d / 1,000" % _count_regular_trash())

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
			# Do not steal pieces already claimed by a drone, rover, sorting robot,
			# magnet or vacuum. Those systems own the target until they release it.
			if is_instance_valid(item) and item.get_meta("drone_reserved", -1) == -1 and _can_collect_city_dump_trash(item) and carried + (2 if item.has_meta("bulky") else 1) <= capacity:
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
		if is_instance_valid(auto_pickup_target) and auto_pickup_target.get_meta("drone_reserved", -1) == -4:
			auto_pickup_target.set_meta("drone_reserved", -1)
		auto_pickup_timer = 0.0
		auto_pickup_scan_timer = 0.0
		auto_pickup_target = null
		return

	# Revalidate targets frequently: manual pickup, drones, or a full backpack
	# may invalidate a target while the magnet is pulling it.
	auto_pickup_scan_timer -= delta
	var target_is_registered := is_instance_valid(auto_pickup_target) and trash_nodes.has(auto_pickup_target)
	if not target_is_registered or auto_pickup_target.get_meta("drone_reserved", -1) != -4 or auto_pickup_scan_timer <= 0.0:
		if is_instance_valid(auto_pickup_target) and auto_pickup_target.get_meta("drone_reserved", -1) == -4:
			auto_pickup_target.set_meta("drone_reserved", -1)
		auto_pickup_target = null
		auto_pickup_scan_timer = 0.24
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
				auto_pickup_target.set_meta("drone_reserved", -4)

	if not is_instance_valid(auto_pickup_target):
		auto_pickup_timer = 0.0
		return
	if not trash_nodes.has(auto_pickup_target) or auto_pickup_target.get_meta("drone_reserved", -1) != -4:
		if is_instance_valid(auto_pickup_target) and auto_pickup_target.get_meta("drone_reserved", -1) == -4:
			auto_pickup_target.set_meta("drone_reserved", -1)
		auto_pickup_target = null
		auto_pickup_timer = 0.0
		return
	# Never let a bunker item pass through a side wall.
	if _is_city_dump_trash(auto_pickup_target) and not _player_at_city_dump_front():
		auto_pickup_target.set_meta("drone_reserved", -1)
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
	if is_instance_valid(picked) and picked.get_meta("drone_reserved", -1) == -4:
		picked.set_meta("drone_reserved", -1)
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
	# Reservation -3 prevents drones and the ground rover from claiming a piece
	# while the vacuum is physically pulling it toward the player.
	if suction_level <= 0 or not is_instance_valid(player) or carried >= capacity:
		if is_instance_valid(suction_target) and suction_target.get_meta("drone_reserved", -1) == -3:
			suction_target.set_meta("drone_reserved", -1)
		suction_target = null
		suction_scan_timer = 0.0
		suction_pull_timer = 0.0
		return

	suction_scan_timer -= delta
	var target_valid := is_instance_valid(suction_target) and trash_nodes.has(suction_target)
	if target_valid and suction_target.get_meta("drone_reserved", -1) != -3:
		target_valid = false
	if not target_valid or suction_target == auto_pickup_target or suction_scan_timer <= 0.0:
		if is_instance_valid(suction_target) and suction_target.get_meta("drone_reserved", -1) == -3:
			suction_target.set_meta("drone_reserved", -1)
		suction_target = null
		suction_scan_timer = 0.20
		var vacuum_range := collection_range + 1.8 + float(suction_level) * 1.25 + float(magnet_power_level - 1) * 0.7
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
				suction_target.set_meta("drone_reserved", -3)

	if not is_instance_valid(suction_target):
		suction_pull_timer = 0.0
		return
	if _is_city_dump_trash(suction_target) and not _player_at_city_dump_front():
		suction_target.set_meta("drone_reserved", -1)
		suction_target = null
		suction_pull_timer = 0.0
		return

	var forward := -player.global_transform.basis.z
	var pickup_point := Vector3(player.global_position.x + forward.x * 0.92, suction_target.global_position.y, player.global_position.z + forward.z * 0.92)
	var item_xz := Vector2(suction_target.global_position.x, suction_target.global_position.z)
	var distance_to_target := item_xz.distance_to(Vector2(pickup_point.x, pickup_point.z))
	var vacuum_speed := 4.2 + float(suction_level) * 1.9 + float(magnet_power_level - 1) * 1.25
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
	if is_instance_valid(collected_item) and trash_nodes.has(collected_item):
		if collected_item.get_meta("drone_reserved", -1) == -3:
			collected_item.set_meta("drone_reserved", -1)
		if _pickup_trash_item(collected_item):
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
		_add_robot_box(drone, "DroneRearTailPanel", Vector3(0, 0.015, 0.19), Vector3(0.15, 0.075, 0.12), Color(0.18, 0.28, 0.31))
		_add_robot_box(drone, "DroneFrontSafetyMark", Vector3(0, -0.085, -0.12), Vector3(0.13, 0.025, 0.025), Color(0.95, 0.62, 0.18))
		_add_robot_sphere(drone, "DroneStatusLight", Vector3(0, 0.17, 0.12), 0.025, Color(0.30, 1.0, 0.62))

		var rotor_assemblies: Array[Node3D] = []
		for sx in [-1.0, 1.0]:
			for sz in [-1.0, 1.0]:
				var rotor_pos := Vector3(sx * 0.39, 0.045, sz * 0.36)
				var arm := _add_robot_box(drone, "DroneArm", Vector3(sx * 0.20, 0.035, sz * 0.18), Vector3(0.43, 0.055, 0.075), Color(0.27, 0.34, 0.36))
				arm.rotation_degrees.y = -35.0 if sx == sz else 35.0
				_add_robot_sphere(drone, "MotorHousing", rotor_pos, 0.085, Color(0.13, 0.19, 0.21))
				_add_robot_sphere(drone, "MotorTopCap", rotor_pos + Vector3(0, 0.12, 0), 0.045, Color(0.28, 0.91, 0.74))
				var rotor := Node3D.new()
				rotor.name = "DroneRotorAssembly"
				rotor.position = rotor_pos + Vector3(0, 0.075, 0)
				drone.add_child(rotor)
				_add_robot_box(rotor, "PropellerBladeA", Vector3.ZERO, Vector3(0.31, 0.018, 0.045), Color(0.10, 0.15, 0.17))
				var blade_b := _add_robot_box(rotor, "PropellerBladeB", Vector3.ZERO, Vector3(0.31, 0.014, 0.035), Color(0.16, 0.23, 0.25))
				blade_b.rotation_degrees.y = 90.0
				_add_robot_sphere(drone, "MotorCap", rotor_pos + Vector3(0, 0.105, 0), 0.035, Color(0.13, 0.82, 0.70))
				rotor_assemblies.append(rotor)
		# Protective rotor rings and high-visibility side stripes for a finished industrial drone silhouette.
		for sx in [-1.0, 1.0]:
			for sz in [-1.0, 1.0]:
				var guard_pos := Vector3(sx * 0.39, 0.045, sz * 0.36)
				_add_robot_sphere(drone, "RotorGuardRing", guard_pos + Vector3(0, 0.055, 0), 0.105, Color(0.25, 0.33, 0.35))
				_add_robot_box(drone, "RotorGuardSafetyStripe", guard_pos + Vector3(0, 0.13, 0), Vector3(0.09, 0.025, 0.09), Color(0.96, 0.65, 0.16))
		_add_robot_box(drone, "DroneSideBrandStripe", Vector3(0.0, -0.12, 0.20), Vector3(0.24, 0.035, 0.09), Color(0.96, 0.65, 0.16))
		drone.set_meta("rotors", rotor_assemblies)

		# Reinforced landing skids and a visible lifting winch.
		for skid_x in [-0.13, 0.13]:
			_add_robot_box(drone, "LandingStrut", Vector3(skid_x, -0.19, 0.025), Vector3(0.035, 0.20, 0.045), Color(0.20, 0.27, 0.29))
			_add_robot_box(drone, "LandingSkid", Vector3(skid_x, -0.285, 0.025), Vector3(0.055, 0.035, 0.38), Color(0.12, 0.18, 0.20))
		_add_robot_box(drone, "WinchHousing", Vector3(0, -0.245, 0.025), Vector3(0.16, 0.09, 0.16), Color(0.12, 0.19, 0.21))
		_add_robot_box(drone, "WinchCable", Vector3(0, -0.335, 0.025), Vector3(0.025, 0.13, 0.025), Color(0.64, 0.69, 0.66))
		_add_robot_box(drone, "CargoHook", Vector3(0, -0.415, 0.025), Vector3(0.12, 0.045, 0.10), Color(0.94, 0.62, 0.15))
		# Mission-grade sensor package: raised lidar mast, protected side scanners,
		# and a high-visibility status beacon. These remain decorative and lightweight.
		var lidar_mast := _add_robot_box(drone, "DroneLidarMast", Vector3(0, 0.235, 0.17), Vector3(0.035, 0.13, 0.035), Color(0.22, 0.31, 0.33))
		var lidar_head := _add_robot_sphere(drone, "DroneLidarHead", Vector3(0, 0.315, 0.17), 0.055, Color(0.16, 0.92, 0.82))
		var nav_beacon := _add_robot_sphere(drone, "DroneNavigationBeacon", Vector3(0, 0.205, -0.12), 0.045, Color(1.0, 0.58, 0.13))
		var scan_lights: Array[Node3D] = []
		for scan_x in [-1.0, 1.0]:
			var scan_light := _add_robot_box(drone, "DroneSideScanner", Vector3(scan_x * 0.205, -0.015, -0.12), Vector3(0.035, 0.045, 0.11), Color(0.12, 0.88, 0.95))
			scan_lights.append(scan_light)
		drone.set_meta("lidar_mast", lidar_mast)
		drone.set_meta("lidar_head", lidar_head)
		drone.set_meta("navigation_beacon", nav_beacon)
		drone.set_meta("scan_lights", scan_lights)
		drone.set_meta("visual_phase", float(i) * 1.7)

		drone.visible = i < drone_level
		drone.global_position = _drone_dock_point(drone)
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
	ground_collector = CharacterBody3D.new()
	ground_collector.name = "GroundTrashCollector"
	add_child(ground_collector)
	# Low, four-wheel autonomous collection rover with a front loading scoop.
	_add_robot_box(ground_collector, "RoverChassis", Vector3(0, 0.48, 0), Vector3(1.05, 0.42, 1.35), Color(0.13, 0.24, 0.27))
	_add_robot_box(ground_collector, "RoverTop", Vector3(0, 0.76, 0.05), Vector3(0.72, 0.18, 0.78), Color(0.24, 0.42, 0.43))
	_add_robot_box(ground_collector, "RoverBatteryHousing", Vector3(0, 0.91, 0.36), Vector3(0.58, 0.22, 0.36), Color(0.08, 0.15, 0.18))
	_add_robot_box(ground_collector, "RoverBatteryIndicator", Vector3(0, 1.035, 0.36), Vector3(0.28, 0.025, 0.035), Color(0.18, 0.96, 0.68))
	_add_robot_box(ground_collector, "RoverFrontScoop", Vector3(0, 0.22, -0.78), Vector3(0.92, 0.12, 0.34), Color(0.72, 0.78, 0.72))
	_add_robot_box(ground_collector, "RoverScoopLeftBrace", Vector3(-0.40, 0.32, -0.65), Vector3(0.10, 0.30, 0.16), Color(0.34, 0.43, 0.43))
	_add_robot_box(ground_collector, "RoverScoopRightBrace", Vector3(0.40, 0.32, -0.65), Vector3(0.10, 0.30, 0.16), Color(0.34, 0.43, 0.43))
	_add_robot_box(ground_collector, "RoverSensor", Vector3(0, 0.82, -0.30), Vector3(0.28, 0.12, 0.12), Color(0.12, 0.95, 0.76))
	_add_robot_box(ground_collector, "RoverSideArmorL", Vector3(-0.53, 0.48, 0.05), Vector3(0.08, 0.30, 0.88), Color(0.20, 0.34, 0.37))
	_add_robot_box(ground_collector, "RoverSideArmorR", Vector3(0.53, 0.48, 0.05), Vector3(0.08, 0.30, 0.88), Color(0.20, 0.34, 0.37))
	_add_robot_box(ground_collector, "RoverFrontBumper", Vector3(0, 0.40, -0.99), Vector3(1.02, 0.14, 0.12), Color(0.12, 0.18, 0.20))
	for tooth_x in [-0.36, -0.18, 0.0, 0.18, 0.36]:
		_add_robot_box(ground_collector, "RoverScoopTooth", Vector3(tooth_x, 0.16, -0.98), Vector3(0.085, 0.07, 0.12), Color(0.70, 0.76, 0.70))
	for headlight_x in [-0.36, 0.36]:
		_add_robot_box(ground_collector, "RoverHeadlight", Vector3(headlight_x, 0.60, -0.72), Vector3(0.17, 0.12, 0.045), Color(0.98, 0.86, 0.56))
		_add_robot_box(ground_collector, "RoverHazardStripe", Vector3(headlight_x * 1.48, 0.50, 0.06), Vector3(0.035, 0.09, 0.52), Color(0.96, 0.64, 0.14))

	_add_robot_box(ground_collector, "RoverRearCargoBin", Vector3(0, 0.98, 0.68), Vector3(0.58, 0.28, 0.30), Color(0.10, 0.17, 0.19))
	_add_robot_box(ground_collector, "RoverRearCargoRim", Vector3(0, 1.14, 0.68), Vector3(0.64, 0.06, 0.34), Color(0.46, 0.54, 0.53))
	_add_robot_sphere(ground_collector, "RoverWarningBeacon", Vector3(0.0, 1.10, -0.05), 0.075, Color(0.98, 0.57, 0.12))
	# Industrial finish: segmented armor, service fasteners and reinforced scoop edges.
	for sx in [-1.0, 1.0]:
		for panel_z in [-0.28, 0.30]:
			_add_robot_box(ground_collector, "RoverArmorPanel", Vector3(sx * 0.575, 0.50, panel_z), Vector3(0.025, 0.18, 0.22), Color(0.28, 0.39, 0.40))
		for bolt_z in [-0.36, 0.36]:
			_add_robot_sphere(ground_collector, "RoverArmorFastener", Vector3(sx * 0.59, 0.60, bolt_z), 0.025, Color(0.70, 0.76, 0.72))
	for rib_z in [0.56, 0.66, 0.76, 0.86]:
		_add_robot_box(ground_collector, "RoverCargoBinRib", Vector3(0, 1.14, rib_z), Vector3(0.50, 0.045, 0.025), Color(0.30, 0.39, 0.40))
	_add_robot_box(ground_collector, "RoverScoopWearEdge", Vector3(0, 0.145, -0.94), Vector3(0.90, 0.035, 0.07), Color(0.90, 0.65, 0.18))
	_add_robot_box(ground_collector, "RoverRearServicePlate", Vector3(0, 0.72, 0.72), Vector3(0.44, 0.16, 0.035), Color(0.31, 0.40, 0.41))
	var rover_wheels: Array[Node3D] = []
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
			_add_robot_sphere(wheel, "RoverWheelHub", Vector3.ZERO, 0.105, Color(0.54, 0.61, 0.60))
			rover_wheels.append(wheel)
	var rover_collision := CollisionShape3D.new()
	var rover_collision_shape := CapsuleShape3D.new()
	rover_collision_shape.radius = 0.62
	rover_collision_shape.height = 1.15
	rover_collision.shape = rover_collision_shape
	rover_collision.position.y = 0.57
	ground_collector.add_child(rover_collision)
	ground_collector.set_meta("wheels", rover_wheels)
	ground_collector.visible = ground_robot_level > 0
	ground_collector.global_position = Vector3(144.0, 0.0, 10.0)
	ground_collector.set_meta("previous_position", ground_collector.global_position)
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
	var interval := maxf(0.75, 3.2 - float(drone_level - 1) * 0.65)
	var drone_speed := (5.0 + float(drone_level - 1) * 1.5) * (1.0 + float(drone_speed_upgrade_level) * 0.20)
	for i in range(mini(drone_level, helper_drones.size())):
		var drone := helper_drones[i]
		if not is_instance_valid(drone) or not drone.visible:
			continue
		for rotor in drone.get_meta("rotors", []):
			if is_instance_valid(rotor):
				rotor.rotation.y = fposmod(rotor.rotation.y + delta * 48.0, TAU)
		# Subtle telemetry animation communicates active scanning without changing flight logic.
		var visual_phase := float(drone.get_meta("visual_phase", 0.0)) + delta * 3.4
		drone.set_meta("visual_phase", visual_phase)
		var scan_pulse := 0.72 + 0.28 * (0.5 + 0.5 * sin(visual_phase))
		var lidar_head := _get_meta_node(drone, "lidar_head")
		if is_instance_valid(lidar_head):
			lidar_head.scale = Vector3.ONE * scan_pulse
		var nav_beacon := _get_meta_node(drone, "navigation_beacon")
		if is_instance_valid(nav_beacon):
			nav_beacon.scale = Vector3.ONE * (0.78 + 0.32 * (0.5 + 0.5 * sin(visual_phase * 1.8)))
		for scan_index in range(drone.get_meta("scan_lights", []).size()):
			var scan_light = drone.get_meta("scan_lights", [])[scan_index]
			if is_instance_valid(scan_light):
				scan_light.scale.y = 0.7 + 0.3 * (0.5 + 0.5 * sin(visual_phase + float(scan_index) * PI))
		if drone.get_meta("returning", false):
			var return_pos := _drone_dock_point(drone)
			_face_travel_direction(drone, return_pos, delta, 5.0)
			drone.global_position = drone.global_position.move_toward(return_pos, drone_speed * delta)
			if drone.global_position.distance_to(return_pos) <= 2.5:
				drone.set_meta("deposited", true)
				# Unload from the drone's own update loop so delivery never depends
				# on the player's auto-sell area or proximity to the tank.
				_drone_deposit_cycle(drone)
			continue
		var lifting_item := _get_meta_node(drone, "lifting_item")
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
				if int(drone.get_meta("cargo_slots", 0)) >= _drone_cargo_capacity():
					drone.set_meta("returning", true)
			continue
		if int(drone.get_meta("cargo_slots", 0)) >= _drone_cargo_capacity():
			drone.set_meta("returning", true)
			continue
		var target := _get_meta_node(drone, "target")
		if not is_instance_valid(target):
			target = null
			var scan_cooldown := float(drone.get_meta("scan_cooldown", 0.0)) - delta
			if scan_cooldown <= 0.0:
				drone.set_meta("scan_cooldown", 0.65)
				# Drones dispatch from their depot and search the whole reachable city, not just around the player.
				var best_distance := 190.0
				for item in trash_nodes:
					if not is_instance_valid(item) or _is_city_dump_trash(item) or item.get_meta("drone_reserved", -1) != -1:
						continue
					var weight := 2 if item.has_meta("bulky") else 1
					var drone_slots := int(drone.get_meta("cargo_slots", 0))
					var drone_capacity := _drone_cargo_capacity()
					if drone_slots + weight > drone_capacity:
						continue
					var distance := drone.global_position.distance_to(item.global_position)
					if distance < best_distance:
						best_distance = distance
						target = item
				if target != null:
					target.set_meta("drone_reserved", i)
					drone.set_meta("target", target)
					drone.set_meta("pickup_timer", 0.0)
			else:
				drone.set_meta("scan_cooldown", scan_cooldown)
		if target == null:
			if int(drone.get_meta("cargo_slots", 0)) > 0:
				drone.set_meta("returning", true)
				continue
			# Stay docked at the depot while idle; never orbit or follow the player.
			var idle_pos := _drone_dock_point(drone)
			drone.global_position = drone.global_position.move_toward(idle_pos, drone_speed * delta)
			continue
		var destination := target.global_position + Vector3(0, 0.20, 0)
		_face_travel_direction(drone, destination, delta, 7.0)
		drone.global_position = drone.global_position.move_toward(destination, drone_speed * delta)
		var pickup_timer := float(drone.get_meta("pickup_timer", 0.0)) + delta
		drone.set_meta("pickup_timer", pickup_timer)
		if drone.global_position.distance_to(destination) < 0.42 and pickup_timer >= interval:
			drone.set_meta("pickup_timer", 0.0)
			var weight := 2 if target.has_meta("bulky") else 1
			var slots := int(drone.get_meta("cargo_slots", 0))
			var drone_capacity := _drone_cargo_capacity()
			if slots + weight <= drone_capacity:
				_register_final_cleanup_pickup(target)
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

func _move_autonomous_ground_robot(actor: Node3D, destination: Vector3, max_distance: float) -> void:
	if not is_instance_valid(actor) or max_distance <= 0.0:
		return
	var offset := destination - actor.global_position
	offset.y = 0.0
	var distance := offset.length()
	if distance <= 0.001:
		return
	var motion := offset.normalized() * minf(max_distance, distance)
	if actor is CharacterBody3D:
		var body := actor as CharacterBody3D
		var collision := body.move_and_collide(motion)
		if collision != null:
			# Slide along an obstacle instead of driving into it or freezing at the first contact.
			var slide_motion := motion.slide(collision.get_normal())
			if slide_motion.length_squared() > 0.0001:
				body.move_and_collide(slide_motion)
	else:
		actor.global_position += motion


func _get_meta_node(node: Object, key: String) -> Node3D:
	if node == null or not is_instance_valid(node) or not node.has_meta(key):
		return null
	return node.get_meta(key) as Node3D


func _face_travel_direction(actor: Node3D, destination: Vector3, delta: float, turn_speed: float = 7.0) -> void:
	if not is_instance_valid(actor):
		return
	var direction := destination - actor.global_position
	direction.y = 0.0
	if direction.length_squared() <= 0.0001:
		return
	# Ground robot models have their scoop/nose along local -Z. Rotate the
	# complete chassis toward its actual travel vector before advancing.
	var desired_yaw := atan2(-direction.x, -direction.z)
	var turn_weight := clampf(delta * turn_speed, 0.0, 1.0)
	actor.rotation.y = lerp_angle(actor.rotation.y, desired_yaw, turn_weight)


func _ground_robot_forward_step(actor: Node3D, destination: Vector3, max_distance: float, delta: float, turn_speed: float = 9.0) -> void:
	if not is_instance_valid(actor) or max_distance <= 0.0:
		return
	var direction := destination - actor.global_position
	direction.y = 0.0
	var distance := direction.length()
	if distance <= 0.001:
		return
	_face_travel_direction(actor, destination, delta, turn_speed)
	var forward := -actor.global_transform.basis.z
	forward.y = 0.0
	if forward.length_squared() <= 0.0001:
		return
	forward = forward.normalized()
	var desired := direction.normalized()
	# Do not translate sideways/backwards while the chassis is still turning.
	var alignment := forward.dot(desired)
	if alignment < 0.0:
		return
	var step := minf(max_distance, distance) * clampf(alignment, 0.0, 1.0)
	if step <= 0.0001:
		return
	_move_autonomous_ground_robot(actor, actor.global_position + forward * step, step)


func _process_ground_collector(delta: float) -> void:
	if ground_robot_level <= 0 or not is_instance_valid(ground_collector):
		return
	var rover := ground_collector
	var speed := 3.0 + float(ground_robot_level - 1) * 1.15
	var capacity_slots := 3 + maxi(ground_robot_level - 1, 0) * 2
	rover.set_meta("cargo_capacity", capacity_slots)
	var previous_position: Vector3 = rover.get_meta("previous_position", rover.global_position)
	var travel_distance := rover.global_position.distance_to(previous_position)
	if travel_distance > 0.0001:
		for wheel in rover.get_meta("wheels", []):
			if is_instance_valid(wheel):
				wheel.rotate_object_local(Vector3.UP, travel_distance * 3.6)
	rover.set_meta("previous_position", rover.global_position)
	if bool(rover.get_meta("returning", false)):
		var home := _factory_waste_drop_point()
		_ground_robot_forward_step(rover, home, speed * delta, delta, 9.0)
		if Vector2(rover.global_position.x - home.x, rover.global_position.z - home.z).length() < 1.4:
			_ground_collector_deposit_cycle(rover, delta)
		return

	var cargo_slots := int(rover.get_meta("cargo_slots", 0))
	if cargo_slots >= capacity_slots:
		rover.set_meta("returning", true)
		rover.set_meta("target", null)
		return

	var target := _get_meta_node(rover, "target")
	if not is_instance_valid(target) or not trash_nodes.has(target):
		target = null
		var cooldown := float(rover.get_meta("scan_cooldown", 0.0)) - delta
		if cooldown <= 0.0:
			rover.set_meta("scan_cooldown", 0.55)
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
	_ground_robot_forward_step(rover, rover_destination, speed * delta, delta, 10.0)
	if Vector2(rover.global_position.x - destination.x, rover.global_position.z - destination.z).length() > 0.72:
		return

	var weight := 2 if target.has_meta("bulky") else 1
	if cargo_slots + weight <= capacity_slots:
		_register_final_cleanup_pickup(target)
		if weight == 2:
			rover.set_meta("cargo_bulky", int(rover.get_meta("cargo_bulky", 0)) + 1)
		rover.set_meta("cargo_slots", cargo_slots + weight)
		var cargo_items: Array = rover.get_meta("cargo_items", [])
		var keep_transform := target.global_transform
		target.reparent(rover)
		target.global_transform = keep_transform
		# Load the rover's rear cargo bin, not the chassis roof.
		target.position = Vector3(0, 1.18 + float(cargo_items.size()) * 0.10, 0.68)
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
	if not waste_tank_built or waste_tank_inventory >= _waste_tank_capacity():
		_set_message("Ground collector is waiting for available waste tank capacity.")
		return
	var bulky := int(rover.get_meta("cargo_bulky", 0)) > 0
	var cargo_items: Array = rover.get_meta("cargo_items", [])
	# Remove an item matching the cargo type being deposited. Removing the
	# first visual item unconditionally could leave a bulky item attached after
	# its two storage slots had already been deducted.
	var cargo_index := -1
	for cargo_i in range(cargo_items.size()):
		var candidate = cargo_items[cargo_i]
		if is_instance_valid(candidate) and candidate.has_meta("bulky") == bulky:
			cargo_index = cargo_i
			break
	if cargo_index < 0 and not cargo_items.is_empty():
		cargo_index = 0
	if cargo_index >= 0:
		var cargo_item = cargo_items.pop_at(cargo_index)
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
	waste_tank_inventory += 1
	factory_waste_deposited_total += 1
	_refresh_waste_tank_inventory_label()
	_update_missions()
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
	if not waste_tank_built or waste_tank_inventory >= _waste_tank_capacity():
		_set_message("Drone is waiting at the factory tank for storage to become available.")
		return
	var cargo_items: Array = drone.get_meta("cargo_items", [])
	# Keep the visible cargo in sync with the bulky/regular storage units
	# removed below; otherwise a regular item could be deleted for a bulky one.
	var cargo_index := -1
	for cargo_i in range(cargo_items.size()):
		var candidate = cargo_items[cargo_i]
		if is_instance_valid(candidate) and candidate.has_meta("bulky") == bulky:
			cargo_index = cargo_i
			break
	if cargo_index < 0 and not cargo_items.is_empty():
		cargo_index = 0
	if cargo_index >= 0:
		var cargo_item = cargo_items.pop_at(cargo_index)
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
	waste_tank_inventory += 1
	factory_waste_deposited_total += 1
	_refresh_waste_tank_inventory_label()
	_update_missions()
	_update_ui()
	_save_game()
	if int(drone.get_meta("cargo_slots", 0)) <= 0:
		drone.set_meta("returning", false)
		drone.set_meta("deposited", false)
		drone.set_meta("scan_cooldown", 0.8)
		_set_message("Drone unloaded its cargo and is collecting again.")

func _process_auto_sell(delta: float) -> void:
	if not is_instance_valid(player):
		return
	# Backpack unloading is fully automatic and must remain available even while
	# factory machinery is under repair. Only horizontal distance matters so
	# small differences in player/collider height cannot block the interaction.
	var player_xz := Vector2(player.global_position.x, player.global_position.z)
	var unloading_point := _factory_waste_drop_point() if waste_tank_built else SELL_POINT
	if not waste_tank_built:
		var startup_xz := Vector2(STARTER_SELL_POINT.x, STARTER_SELL_POINT.z)
		var city_xz := Vector2(SELL_POINT.x, SELL_POINT.z)
		if player_xz.distance_to(startup_xz) < player_xz.distance_to(city_xz):
			unloading_point = STARTER_SELL_POINT
	var unload_xz := Vector2(unloading_point.x, unloading_point.z)
	var inside_zone := player_xz.distance_to(unload_xz) <= 5.5
	if not inside_zone or carried <= 0:
		unload_timer = 0.0
		return
	unload_timer += delta
	# Feed the tank steadily without making the player wait several seconds per piece.
	var seconds_per_item := maxf(0.12, 0.45 - float(unload_upgrade_level - 1) * 0.05)
	if unload_timer >= seconds_per_item:
		unload_timer = 0.0
		if waste_tank_built:
			if waste_tank_inventory >= _waste_tank_capacity():
				_set_message("Factory tank is full. Conveyor will resume when space is available.")
				return
			var deposited_bulky := carried_bulky > 0
			if deposited_bulky:
				carried -= 2
				carried_bulky -= 1
			else:
				carried -= 1
			waste_tank_inventory += 1
			factory_waste_deposited_total += 1
			_update_missions()
			_update_ui()
			_save_game()
			if carried == 0:
				_update_missions()
			_set_message("Waste sent to factory tank. Storage: %d / %d" % [waste_tank_inventory, _waste_tank_capacity()])
			return
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

func _waste_tank_discharge_multiplier() -> float:
	return 1.0 + float(waste_tank_unload_upgrade_level) * 0.25

func _drone_cargo_capacity() -> int:
	return 5 + drone_capacity_upgrade_level * 2


func _upgrade_drone_speed() -> void:
	if drone_speed_upgrade_level >= 3:
		return
	var next_level := drone_speed_upgrade_level + 1
	var cost := _upgrade_cost(42.0, next_level)
	if not await _pay_gradually(cost):
		return
	drone_speed_upgrade_level = next_level
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Helper drones fly %d%% faster." % int((1.0 + float(drone_speed_upgrade_level) * 0.20) * 100.0))


func _upgrade_drone_capacity() -> void:
	if drone_capacity_upgrade_level >= 3:
		return
	var next_level := drone_capacity_upgrade_level + 1
	var cost := _upgrade_cost(48.0, next_level)
	if not await _pay_gradually(cost):
		return
	drone_capacity_upgrade_level = next_level
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Each helper drone can now carry %d waste slots." % _drone_cargo_capacity())


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

func _upgrade_waste_tank_unload() -> void:
	if waste_tank_unload_upgrade_level >= 3:
		_set_message("Waste tank discharge is already at maximum.")
		return
	var next_level := waste_tank_unload_upgrade_level + 1
	var cost := _upgrade_cost(58.0, next_level)
	if not await _pay_gradually(cost):
		return
	waste_tank_unload_upgrade_level = next_level
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Main waste tank discharge speed increased to %d%%." % int(_waste_tank_discharge_multiplier() * 100.0))

func _upgrade_waste_tank_capacity() -> void:
	if waste_tank_capacity_upgrade_level >= 3:
		_set_message("Waste tank capacity is already at maximum.")
		return
	var next_level := waste_tank_capacity_upgrade_level + 1
	var cost := _upgrade_cost(72.0, next_level)
	if not await _pay_gradually(cost):
		return
	waste_tank_capacity_upgrade_level = next_level
	_refresh_waste_tank_inventory_label()
	_update_ui()
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Main waste tank capacity increased to %d units." % _waste_tank_capacity())

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

func _process_machine_maintenance(_delta: float) -> void:
	# Factory breakdowns are disabled: machines never stop because of wear.
	machine_broken = false
	machine_work_timer = 0.0
	machine_repair_timer = 0.0

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
	_set_message("Magnet / vacuum pull power increased!")

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

func _process_trash_respawn(delta: float) -> void:
	if respawn_level <= 0:
		respawn_timer = 0.0
		return
	respawn_timer += delta
	var interval_seconds := _trash_respawn_interval_minutes() * 60.0
	if respawn_timer < interval_seconds:
		return
	respawn_timer = 0.0
	var before_count := _count_regular_trash()
	if before_count >= 1000:
		return
	_spawn_trash(1000 - before_count)
	var after_count := _count_regular_trash()
	if after_count > before_count:
		_set_message("AUTOMATIC CITY REFILL  %d / 1,000" % after_count)
		_save_game()

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
	# Keep the capsule fully inside the invisible boundary walls after recovery.
	# The west/east walls occupy X=-13.4..-12.2 and X=206.2..207.4.
	player.global_position = Vector3(
		clampf(player.global_position.x, -11.8, 205.8),
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
	save.set_value("progress", "final_cleanup_spawned", final_cleanup_spawned)
	save.set_value("progress", "total_trash_collected", total_trash_collected)
	save.set_value("progress", "tutorial_mission_stage", tutorial_mission_stage)
	save.set_value("progress", "tutorial_mission_version", 2)
	save.set_value("progress", "carried", carried)
	save.set_value("progress", "carried_bulky", carried_bulky)
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
	save.set_value("progress", "drone_speed_upgrade_level", drone_speed_upgrade_level)
	save.set_value("progress", "drone_capacity_upgrade_level", drone_capacity_upgrade_level)
	save.set_value("progress", "ground_robot_level", ground_robot_level)
	save.set_value("progress", "sorting_robot_levels", sorting_robot_levels)
	save.set_value("progress", "sorting_bin_counts", sorting_bin_counts)
	save.set_value("progress", "sorting_robot_upgrade_level", sorting_robot_upgrade_level)
	save.set_value("progress", "conveyor_speed_upgrade_level", conveyor_speed_upgrade_level)
	save.set_value("progress", "waste_tank_unload_upgrade_level", waste_tank_unload_upgrade_level)
	save.set_value("progress", "waste_tank_capacity_upgrade_level", waste_tank_capacity_upgrade_level)
	save.set_value("progress", "repair_robot_level", repair_robot_level)
	save.set_value("progress", "machine_work_timer", machine_work_timer)
	save.set_value("progress", "machine_broken", machine_broken)
	save.set_value("progress", "machine_repair_timer", machine_repair_timer)
	save.set_value("progress", "dispatch_upgrade_level", dispatch_upgrade_level)
	save.set_value("progress", "fleet_upgrade_level", fleet_upgrade_level)
	save.set_value("progress", "truck_capacity_upgrade_level", truck_capacity_upgrade_level)
	save.set_value("progress", "packaging_upgrade_level", packaging_upgrade_level)
	save.set_value("progress", "factory_truck_interval_upgrade_level", factory_truck_interval_upgrade_level)
	save.set_value("progress", "yard_stage", yard_stage)
	save.set_value("progress", "factory_stage", factory_stage)
	save.set_value("progress", "factory_build_paid", factory_build_paid)
	save.set_value("progress", "mega_factory_built_count", mega_factory_built_count)
	save.set_value("progress", "factory_row_input_stock", factory_row_input_stock)
	save.set_value("progress", "factory_row_stage1_stock", factory_row_stage1_stock)
	save.set_value("progress", "factory_row_stage2_stock", factory_row_stage2_stock)
	save.set_value("progress", "factory_row_product_stock", factory_row_product_stock)
	save.set_value("progress", "factory_total_products_made", factory_total_products_made)
	save.set_value("progress", "waste_tank_inventory", waste_tank_inventory)
	save.set_value("progress", "factory_waste_deposited_total", factory_waste_deposited_total)
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
	final_cleanup_spawned = bool(save.get_value("progress", "final_cleanup_spawned", false))
	total_trash_collected = int(save.get_value("progress", "total_trash_collected", final_zone_cleaned))
	tutorial_mission_stage = clampi(int(save.get_value("progress", "tutorial_mission_stage", 0)), 0, 30)
	capacity = clampi(int(save.get_value("progress", "capacity", 4)), 4, 40)
	carried = clampi(int(save.get_value("progress", "carried", 0)), 0, capacity)
	carried_bulky = clampi(int(save.get_value("progress", "carried_bulky", 0)), 0, int(carried / 2))
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
	drone_speed_upgrade_level = clampi(int(save.get_value("progress", "drone_speed_upgrade_level", 0)), 0, 3)
	drone_capacity_upgrade_level = clampi(int(save.get_value("progress", "drone_capacity_upgrade_level", 0)), 0, 3)
	ground_robot_level = clampi(int(save.get_value("progress", "ground_robot_level", 0)), 0, 3)
	sorting_robot_levels = save.get_value("progress", "sorting_robot_levels", [0, 0, 0, 0])
	sorting_bin_counts = save.get_value("progress", "sorting_bin_counts", [0, 0, 0, 0])
	while sorting_robot_levels.size() < 4: sorting_robot_levels.append(0)
	while sorting_bin_counts.size() < 4: sorting_bin_counts.append(0)
	sorting_robot_upgrade_level = clampi(int(save.get_value("progress", "sorting_robot_upgrade_level", 0)), 0, 3)
	conveyor_speed_upgrade_level = clampi(int(save.get_value("progress", "conveyor_speed_upgrade_level", 0)), 0, 3)
	waste_tank_unload_upgrade_level = clampi(int(save.get_value("progress", "waste_tank_unload_upgrade_level", 0)), 0, 3)
	waste_tank_capacity_upgrade_level = clampi(int(save.get_value("progress", "waste_tank_capacity_upgrade_level", 0)), 0, 3)
	repair_robot_level = clampi(int(save.get_value("progress", "repair_robot_level", 0)), 0, 3)
	machine_work_timer = float(save.get_value("progress", "machine_work_timer", 0.0))
	machine_broken = false # Ignore old saves that recorded a breakdown.
	machine_repair_timer = float(save.get_value("progress", "machine_repair_timer", 0.0))
	dispatch_upgrade_level = clampi(int(save.get_value("progress", "dispatch_upgrade_level", 0)), 0, 3)
	fleet_upgrade_level = clampi(int(save.get_value("progress", "fleet_upgrade_level", 0)), 0, 3)
	truck_capacity_upgrade_level = clampi(int(save.get_value("progress", "truck_capacity_upgrade_level", 0)), 0, 3)
	packaging_upgrade_level = clampi(int(save.get_value("progress", "packaging_upgrade_level", 0)), 0, 3)
	factory_truck_interval_upgrade_level = clampi(int(save.get_value("progress", "factory_truck_interval_upgrade_level", 0)), 0, 3)
	yard_stage = 4 # All four areas are permanently open in the unified city.
	district_build_paid = 0.0
	factory_stage = clampi(int(save.get_value("progress", "factory_stage", 1)), 1, 5)
	factory_build_paid = clampf(float(save.get_value("progress", "factory_build_paid", 0.0)), 0.0, [0.0, 0.0, 20.0, 55.0, 110.0, 190.0][factory_stage])
	mega_factory_built_count = clampi(int(save.get_value("progress", "mega_factory_built_count", 1)), 1, 15)
	factory_row_input_stock = save.get_value("progress", "factory_row_input_stock", [0, 0, 0, 0, 0])
	factory_row_stage1_stock = save.get_value("progress", "factory_row_stage1_stock", [0, 0, 0, 0, 0])
	factory_row_stage2_stock = save.get_value("progress", "factory_row_stage2_stock", [0, 0, 0, 0, 0])
	factory_row_product_stock = save.get_value("progress", "factory_row_product_stock", [0, 0, 0, 0, 0])
	factory_total_products_made = maxi(0, int(save.get_value("progress", "factory_total_products_made", 0)))
	while factory_row_input_stock.size() < 5: factory_row_input_stock.append(0)
	while factory_row_stage1_stock.size() < 5: factory_row_stage1_stock.append(0)
	while factory_row_stage2_stock.size() < 5: factory_row_stage2_stock.append(0)
	while factory_row_product_stock.size() < 5: factory_row_product_stock.append(0)
	waste_tank_inventory = clampi(int(save.get_value("progress", "waste_tank_inventory", 0)), 0, _waste_tank_capacity())
	factory_waste_deposited_total = maxi(0, int(save.get_value("progress", "factory_waste_deposited_total", waste_tank_inventory)))
	mega_factory_build_paid = clampf(float(save.get_value("progress", "mega_factory_build_paid", 0.0)), 0.0, _mega_factory_machine_cost(mega_factory_built_count))
	waste_tank_built = bool(save.get_value("progress", "waste_tank_built", false))
	teddy_stock_values.clear()
	for stored_value in save.get_value("progress", "teddy_stock_values", []):
		teddy_stock_values.append(float(stored_value))
	collection_range = 2.0 + float(equipment_upgrade_level - 1) * 0.65
	recycling_bonus = 1.0 + float(technology_upgrade_level - 1) * 0.15
	# Migrate old saves to the clearer tutorial order without resetting player progress.
	if int(save.get_value("progress", "tutorial_mission_version", 0)) < 2:
		tutorial_mission_stage = 0
		while tutorial_mission_stage < MISSION_ORDER.size() and _mission_is_complete(MISSION_ORDER[tutorial_mission_stage]):
			tutorial_mission_stage += 1


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

func _factory_row_sell_stage(row: int) -> int:
	if row < 0 or row >= 5:
		return 0
	return mini(3, maxi(0, mega_factory_built_count - row * 3))

func _factory_row_sellable_stock(row: int) -> int:
	match _factory_row_sell_stage(row):
		1: return int(factory_row_stage1_stock[row])
		2: return int(factory_row_stage2_stock[row])
		3: return int(factory_row_product_stock[row])
	return 0

func _factory_row_remove_sellable_stock(row: int, amount: int) -> void:
	match _factory_row_sell_stage(row):
		1: factory_row_stage1_stock[row] = maxi(0, int(factory_row_stage1_stock[row]) - amount)
		2: factory_row_stage2_stock[row] = maxi(0, int(factory_row_stage2_stock[row]) - amount)
		3: factory_row_product_stock[row] = maxi(0, int(factory_row_product_stock[row]) - amount)

func _factory_row_truck_revenue(row: int, stage: int) -> float:
	var stage_multiplier: float = [0.0, 1.0, 1.6, 2.4][clampi(stage, 0, 3)]
	return _factory_row_unit_price(row) * 3.0 * stage_multiplier

func _factory_row_z(row: int) -> float:
	return -26.0 + float(row) * 13.0

func _factory_row_product(row: int) -> String:
	var products := ["PLASTIC BOTTLES & CONTAINERS", "CARDBOARD BOXES", "METAL COMPONENTS", "GLASS BOTTLES & JARS", "REFURBISHED ELECTRONICS"]
	return products[clampi(row, 0, 4)]

func _factory_row_machine_name(row: int, column: int) -> String:
	var machine_names := [
		["PLASTIC SHREDDER", "PLASTIC GRANULATOR", "BOTTLE MOLDER"],
		["PAPER PULPER", "SHEET PRESS", "CARTON FORMER"],
		["METAL SORTER & SHREDDER", "SMELTING FURNACE", "CASTING & PRESS"],
		["GLASS CRUSHER", "GLASS MELTING FURNACE", "GLASS MOLDER"],
		["E-WASTE DISASSEMBLER", "METAL & PARTS RECOVERY", "ELECTRONICS ASSEMBLY"]
	]
	return machine_names[clampi(row, 0, 4)][clampi(column, 0, 2)]

func _remove_legacy_factory_output_products(node: Node) -> void:
	# Remove the old oversized static product display from every production-line exit.
	var legacy_prefixes := [
		"FactoryProductOutputStand", "FinishedPlasticBottle", "PlasticBottleCap",
		"FinishedCardboardBox", "CardboardBoxTape", "FinishedMetalComponent",
		"MetalComponentCore", "FinishedGlassJar", "GlassJarRim",
		"RefurbishedElectronicUnit", "ElectronicDisplay"
	]
	for child in node.get_children():
		var remove_child := false
		for prefix in legacy_prefixes:
			if child.name.begins_with(prefix):
				remove_child = true
				break
		if remove_child:
			child.queue_free()
		else:
			_remove_legacy_factory_output_products(child)

func _build_recycling_mega_factory() -> void:
	_remove_legacy_factory_output_products(self)
	# Clean, open industrial hall: five parallel lines with clear service lanes.
	var steel := Color(0.16, 0.22, 0.24)
	var dark_steel := Color(0.055, 0.085, 0.095)
	var teal := Color(0.08, 0.48, 0.48)
	var safety := Color(0.96, 0.66, 0.12)
	var belt_color := Color(0.035, 0.055, 0.06)
	var concrete := Color(0.39, 0.43, 0.42)

	# Large, uncluttered factory floor and simple perimeter.
	_box("MegaFactoryFoundation", Vector3(172.75, -0.14, 0.0), Vector3(58.5, 0.28, 72.0), concrete, true)
	_box("FactoryServiceLane", Vector3(166.0, 0.025, -31.0), Vector3(65.0, 0.05, 3.0), Color(0.29, 0.33, 0.33), true)
	_box("FactoryFrontApron", Vector3(137.0, -0.14, 0.0), Vector3(13.0, 0.28, 64.0), Color(0.31, 0.35, 0.34), true)

	# Open-air factory: no roof, walls, or structural columns.

	if waste_tank_built:
		_build_waste_feed_conveyor_network()

	mega_factory_machine_labels.clear()
	for row in range(5):
		var z := _factory_row_z(row)
		var row_number := row + 1
		# A clean painted lane with a divider only in the middle of each gap.
		_box("FactoryRowFloor%d" % row, Vector3(174.0, 0.292, z), Vector3(48.0, 0.012, 10.8), Color(0.34, 0.38, 0.37), false)
		_box("FactoryRowDivider%d" % row, Vector3(174.0, 0.14, z + 6.35), Vector3(48.0, 0.10, 0.14), safety, false)
		_box("FactoryRowEdge%d" % row, Vector3(174.0, 0.14, z - 6.35), Vector3(48.0, 0.10, 0.14), teal, false)

		var product_label := Label3D.new()
		product_label.name = "FactoryProductLine%d" % row
		product_label.text = "LINE %d  |  %s" % [row_number, _factory_row_product(row)]
		product_label.position = Vector3(174.0, 5.0, z - 4.8)
		product_label.font_size = 26
		product_label.pixel_size = 0.009
		product_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		product_label.modulate = Color(0.72, 1.0, 0.90)
		add_child(product_label)

		# A production-line conveyor appears only after its first machine is installed.
		if mega_factory_built_count >= row * 3 + 1:
			_build_factory_row_main_conveyor(row)
		for machine_index in range(3):
			var x := 151.0 + float(machine_index) * 13.0
			var station_index := row * 3 + machine_index
			var machine_built := station_index < mega_factory_built_count
			# The row floor top is at Y=0.298; keep every build marker above it.
			_box("MegaProcessBuildPad", Vector3(x, 0.322, z), Vector3(5.8, 0.045, 4.8), dark_steel if machine_built else Color(0.22, 0.25, 0.20), false)
			var pad_edge: Color = Color(0.34, 0.40, 0.36) if machine_built else safety
			# Four thick, high-contrast perimeter rails clearly show the machine footprint.
			_box("MegaProcessPadFront", Vector3(x, 0.365, z + 2.34), Vector3(5.8, 0.055, 0.14), pad_edge, false)
			_box("MegaProcessPadBack", Vector3(x, 0.365, z - 2.34), Vector3(5.8, 0.055, 0.14), pad_edge, false)
			_box("MegaProcessPadLeft", Vector3(x - 2.84, 0.365, z), Vector3(0.14, 0.055, 4.55), pad_edge, false)
			_box("MegaProcessPadRight", Vector3(x + 2.84, 0.365, z), Vector3(0.14, 0.055, 4.55), pad_edge, false)
			# Corner markers remain visible even when the conveyor crosses the footprint.
			if not machine_built:
				for marker_x in [x - 2.52, x + 2.52]:
					for marker_z in [z - 2.02, z + 2.02]:
						_box("MegaProcessBuildCorner", Vector3(marker_x, 0.48, marker_z), Vector3(0.34, 0.24, 0.34), safety, false)
			_box("MegaProcessPadAccent", Vector3(x, 0.385, z - 2.10), Vector3(4.9, 0.025, 0.10), pad_edge, false)
			var build_label := Label3D.new()
			build_label.name = "MegaFactoryMachineLabel%d" % station_index
			build_label.text = ("MACHINE %02d  |  %s" % [station_index + 1, _factory_row_machine_name(row, machine_index)]) if machine_built else ("BUILD MACHINE %02d\n%s\n%.0f ZC" % [station_index + 1, _factory_row_machine_name(row, machine_index), _mega_factory_machine_cost(station_index)])
			build_label.position = Vector3(x, 2.45, z + 3.05)
			build_label.font_size = 28
			build_label.pixel_size = 0.012
			build_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			build_label.modulate = Color(0.55, 1.0, 0.60) if machine_built else Color(1.0, 0.78, 0.12)
			add_child(build_label)
			mega_factory_machine_labels.append(build_label)
			if machine_built:
				_build_mega_factory_machine(station_index)

		# Remove the unnecessary loading portal columns and overhead frames; keep the loading area open.

		# Dedicated output pad on the far end of each production line.
		_box("FactoryProductOutputPad", Vector3(198.0, 0.34, z), Vector3(5.0, 0.22, 4.8), dark_steel, false)
		# Finished goods are represented by the real moving products on the belt.

	# Utility equipment remains grouped in the rear service strip.
	# Decorative recycling storage silos and caps were removed to clear the view beside line one.
	for tank_index in range(3):
		var tx := 181.0 + float(tank_index) * 4.0
		_cylinder("WaterTreatmentTank", Vector3(tx, 1.65, 29.0), 1.35, 3.2, Color(0.18, 0.38, 0.42), false)

	# Shared truck loading yard is placed beside the right-hand ends of all five lines.
	_box("FactoryLoadingDock", Vector3(211.0, 0.22, 0.0), Vector3(14.0, 0.28, 64.0), Color(0.25, 0.29, 0.29), false)
	for z in [-26.0, -13.0, 0.0, 13.0, 26.0]:
		_box("FactoryTruckLane", Vector3(211.0, 0.39, z), Vector3(12.0, 0.035, 0.14), safety, false)

	# Central logistics warehouse: the truck apron remains completely open in front.
	var warehouse_dark := Color(0.055, 0.085, 0.095)
	var warehouse_steel := Color(0.20, 0.28, 0.30)
	var warehouse_light := Color(0.43, 0.52, 0.52)
	var warehouse_teal := Color(0.035, 0.34, 0.35)
	_box("CentralWarehouseFoundation", Vector3(228.5, 0.12, 0.0), Vector3(18.0, 0.24, 68.0), Color(0.22, 0.27, 0.27), false)
	_box("CentralWarehouseRearWall", Vector3(237.2, 4.65, 0.0), Vector3(0.35, 9.0, 67.0), warehouse_dark, false)
	_box("CentralWarehouseNorthWall", Vector3(228.5, 4.65, -33.2), Vector3(17.2, 9.0, 0.35), warehouse_steel, false)
	_box("CentralWarehouseSouthWall", Vector3(228.5, 4.65, 33.2), Vector3(17.2, 9.0, 0.35), warehouse_steel, false)
	_box("CentralWarehouseRoof", Vector3(228.5, 9.25, 0.0), Vector3(18.6, 0.42, 68.8), warehouse_dark, false)
	for roof_rib_z in range(-30, 31, 6):
		_box("CentralWarehouseRoofRib", Vector3(228.5, 9.50, float(roof_rib_z)), Vector3(18.1, 0.10, 0.16), warehouse_light, false)
	_box("CentralWarehouseFrontHeader", Vector3(219.45, 7.55, 0.0), Vector3(0.42, 1.65, 67.0), warehouse_steel, false)
	_box("CentralWarehouseBrandPanel", Vector3(219.18, 8.25, 0.0), Vector3(0.12, 0.72, 10.5), warehouse_teal, false)
	_label_3d("ZEKA // CENTRAL LOGISTICS", Vector3(218.98, 8.28, 0.0), 0.18)
	for bay_index in range(5):
		var bay_z: float = _factory_row_z(bay_index)
		# Five separate roll-up doors align with the five production lines.
		_box("WarehouseLoadingDoorRecess", Vector3(219.30, 2.65, bay_z), Vector3(0.16, 4.85, 6.4), warehouse_dark, false)
		for jamb_z in [-3.35, 3.35]:
			_box("WarehouseLoadingDoorJamb", Vector3(219.08, 2.55, bay_z + jamb_z), Vector3(0.32, 5.0, 0.28), warehouse_light, false)
		_box("WarehouseLoadingDoorHeader", Vector3(219.08, 5.12, bay_z), Vector3(0.32, 0.30, 6.95), warehouse_light, false)
		for shutter_y in range(6):
			_box("WarehouseRollupShutterSlat", Vector3(219.16, 0.72 + float(shutter_y) * 0.68, bay_z), Vector3(0.10, 0.055, 6.15), warehouse_steel, false)
		_box("WarehouseDockCanopy", Vector3(218.35, 5.35, bay_z), Vector3(2.15, 0.18, 7.5), warehouse_dark, false)
		_box("WarehouseDockCanopyEdge", Vector3(217.28, 5.23, bay_z), Vector3(0.12, 0.22, 7.5), safety, false)
		for bumper_z in [-2.65, 2.65]:
			_box("WarehouseDockBumper", Vector3(218.72, 0.62, bay_z + bumper_z), Vector3(0.34, 1.05, 0.42), Color(0.10, 0.14, 0.15), false)
		_box("WarehouseDockNumberPlate", Vector3(218.98, 5.75, bay_z - 2.75), Vector3(0.08, 0.42, 0.78), warehouse_teal, false)
		_label_3d("BAY %02d" % (bay_index + 1), Vector3(218.82, 5.76, bay_z - 2.75), 0.11)
		_box("WarehouseDockSignalHousing", Vector3(218.98, 4.85, bay_z + 2.72), Vector3(0.18, 0.62, 0.38), warehouse_dark, false)
		_box("WarehouseDockSignalGreen", Vector3(218.86, 4.98, bay_z + 2.72), Vector3(0.055, 0.13, 0.22), Color(0.12, 0.88, 0.48), false)
		_box("WarehouseDockSignalAmber", Vector3(218.86, 4.72, bay_z + 2.72), Vector3(0.055, 0.13, 0.22), safety, false)
		# Painted reversing guides and wheel-stop marks on the open truck apron.
		_box("WarehouseTruckGuideLeft", Vector3(211.0, 0.415, bay_z - 3.55), Vector3(12.0, 0.025, 0.09), safety, false)
		_box("WarehouseTruckGuideRight", Vector3(211.0, 0.415, bay_z + 3.55), Vector3(12.0, 0.025, 0.09), safety, false)
		_box("WarehouseTruckStopLine", Vector3(216.0, 0.42, bay_z), Vector3(0.12, 0.025, 5.9), warehouse_light, false)
	# Structural columns and service equipment stay behind the dock face.
	for wall_z in [-31.5, -16.0, 0.0, 16.0, 31.5]:
		_box("CentralWarehouseFrontPier", Vector3(219.65, 4.55, wall_z), Vector3(0.48, 8.9, 0.48), warehouse_dark, false)
	for vent_z in [-27.0, -21.0, 21.0, 27.0]:
		_box("CentralWarehouseVent", Vector3(237.0, 6.2, vent_z), Vector3(0.12, 1.2, 3.6), warehouse_light, false)
		_box("CentralWarehouseVentGrille", Vector3(236.90, 6.2, vent_z), Vector3(0.06, 0.82, 2.8), warehouse_dark, false)
	_box("CentralWarehouseSafetyStripe", Vector3(219.04, 0.34, 0.0), Vector3(0.06, 0.05, 65.0), safety, false)
	_label_3d("RECEIVING  //  SORT  //  DISPATCH", Vector3(218.88, 6.35, 0.0), 0.14)

	# Front loading area is fully open: remove canopy roof and support columns.
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
	factory_machine_status_label = Label3D.new()
	factory_machine_status_label.name = "FactoryMachineStatusLabel"
	factory_machine_status_label.position = Vector3(151.0, 4.8, _factory_row_z(0) + 2.35)
	factory_machine_status_label.font_size = 20
	factory_machine_status_label.pixel_size = 0.009
	factory_machine_status_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	factory_machine_status_label.modulate = Color(0.68, 1.0, 0.82)
	add_child(factory_machine_status_label)
	_refresh_factory_machine_status()

func _on_first_machine_feed_entered(body: Node3D) -> void:
	if body != player or mega_factory_built_count < 1 or carried <= 0:
		return
	var item_count := maxi(0, carried - carried_bulky)
	if item_count <= 0:
		return
	var accepted := mini(item_count, FACTORY_INPUT_CAPACITY_PER_ROW - factory_row_input_stock[0])
	if accepted < item_count:
		_set_message("First machine input is nearly full. Wait for production before unloading.")
		return
	factory_row_input_stock[0] += accepted
	carried = 0
	carried_bulky = 0
	_update_ui()
	_save_game()
	_set_message("Loaded %d pieces directly into the first machine. Input: %d" % [accepted, factory_row_input_stock[0]])

func _create_factory_row_truck(row: int) -> Node3D:
	var truck := Node3D.new()
	truck.name = "FactoryProductTruck%d" % (row + 1)
	truck.position = Vector3(220.0, 0.0, _factory_row_z(row))
	var paint: Color = [Color(0.78, 0.20, 0.12), Color(0.18, 0.43, 0.62), Color(0.78, 0.52, 0.12), Color(0.20, 0.52, 0.39), Color(0.48, 0.36, 0.62)][clampi(row, 0, 4)]
	var dark_paint := paint.darkened(0.38)
	var rubber := Color(0.025, 0.032, 0.038)
	var glass := Color(0.08, 0.20, 0.27)
	var metal := Color(0.48, 0.54, 0.55)

	# Continuous chassis and a more defined cargo body.
	_box_child(truck, "TruckChassis", Vector3(0.05, 0.78, 0.0), Vector3(6.15, 0.34, 2.45), Color(0.12, 0.15, 0.16))
	_box_child(truck, "TruckCargoBed", Vector3(1.15, 1.35, 0.0), Vector3(4.0, 1.35, 2.85), Color(0.70, 0.75, 0.74))
	_box_child(truck, "TruckCargoFrontWall", Vector3(-0.88, 1.72, 0.0), Vector3(0.16, 1.15, 2.9), metal)
	for side_z in [-1.43, 1.43]:
		_box_child(truck, "TruckCargoSideRail", Vector3(1.15, 1.83, side_z), Vector3(4.05, 0.22, 0.12), metal)
		_box_child(truck, "TruckCargoLowerRail", Vector3(1.15, 1.10, side_z), Vector3(4.05, 0.16, 0.12), dark_paint)
	for rail_x in [-0.78, 0.45, 1.75, 3.08]:
		for side_z in [-1.43, 1.43]:
			_box_child(truck, "TruckCargoPost", Vector3(rail_x, 1.52, side_z), Vector3(0.12, 0.85, 0.12), metal)
	_box_child(truck, "TruckCab", Vector3(-2.15, 1.36, 0.0), Vector3(1.72, 1.78, 2.62), paint)
	_box_child(truck, "TruckCabRoof", Vector3(-2.12, 2.30, 0.0), Vector3(1.82, 0.18, 2.72), dark_paint)
	_box_child(truck, "TruckWindshield", Vector3(-3.025, 1.72, 0.0), Vector3(0.055, 0.88, 1.92), glass)
	_box_child(truck, "TruckFrontGrille", Vector3(-3.04, 1.10, 0.0), Vector3(0.08, 0.48, 0.92), Color(0.12, 0.16, 0.17))
	for side_z in [-1.34, 1.34]:
		_box_child(truck, "TruckSideWindow", Vector3(-2.12, 1.78, side_z), Vector3(1.12, 0.72, 0.045), glass)
		_box_child(truck, "TruckDoorPanel", Vector3(-2.10, 1.12, side_z), Vector3(1.18, 0.62, 0.055), dark_paint)
		_box_child(truck, "TruckMirrorArm", Vector3(-2.82, 1.72, side_z * 1.10), Vector3(0.30, 0.07, 0.07), metal)
		_box_child(truck, "TruckMirror", Vector3(-2.96, 1.78, side_z * 1.10), Vector3(0.12, 0.28, 0.20), rubber)
	_box_child(truck, "TruckFrontBumper", Vector3(-3.12, 0.78, 0.0), Vector3(0.24, 0.22, 2.78), metal)
	_box_child(truck, "TruckRearBumper", Vector3(3.22, 0.78, 0.0), Vector3(0.22, 0.22, 2.82), metal)
	for side_z in [-0.94, 0.94]:
		_box_child(truck, "TruckHeadlight", Vector3(-3.09, 1.18, side_z), Vector3(0.07, 0.30, 0.42), Color(1.0, 0.86, 0.48))
		_box_child(truck, "TruckTailLight", Vector3(3.20, 1.12, side_z), Vector3(0.08, 0.38, 0.30), Color(0.82, 0.08, 0.06))
	# Six tires with visible metal hubs and dark wheel arches.
	for wheel_x in [-2.45, 0.0, 2.45]:
		for wheel_z in [-1.48, 1.48]:
			var wheel := MeshInstance3D.new()
			var mesh := CylinderMesh.new()
			mesh.top_radius = 0.48
			mesh.bottom_radius = 0.48
			mesh.height = 0.25
			wheel.mesh = mesh
			wheel.position = Vector3(wheel_x, 0.49, wheel_z)
			wheel.rotation_degrees.x = 90.0
			wheel.material_override = _mat(rubber)
			truck.add_child(wheel)
			var hub := MeshInstance3D.new()
			var hub_mesh := CylinderMesh.new()
			hub_mesh.top_radius = 0.23
			hub_mesh.bottom_radius = 0.23
			hub_mesh.height = 0.27
			hub.mesh = hub_mesh
			hub.position = Vector3(wheel_x, 0.49, wheel_z * 1.012)
			hub.rotation_degrees.x = 90.0
			hub.material_override = _mat(metal)
			truck.add_child(hub)
			var hub_cap := MeshInstance3D.new()
			var cap_mesh := CylinderMesh.new()
			cap_mesh.top_radius = 0.09
			cap_mesh.bottom_radius = 0.09
			cap_mesh.height = 0.29
			hub_cap.mesh = cap_mesh
			hub_cap.position = Vector3(wheel_x, 0.49, wheel_z * 1.025)
			hub_cap.rotation_degrees.x = 90.0
			hub_cap.material_override = _mat(dark_paint)
			truck.add_child(hub_cap)
	_box_child(truck, "TruckFuelTank", Vector3(-0.95, 0.76, 1.18), Vector3(0.90, 0.38, 0.34), metal)
	var sign := Label3D.new()
	sign.text = _factory_row_product(row)
	sign.position = Vector3(1.15, 2.12, 1.48)
	sign.font_size = 16
	sign.pixel_size = 0.010
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sign.modulate = Color(0.12, 0.20, 0.18)
	truck.add_child(sign)
	add_child(truck)
	return truck

func _factory_truck_arrival_interval() -> float:
	var intervals := [45.0, 30.0, 15.0, 5.0]
	return intervals[clampi(factory_truck_interval_upgrade_level, 0, 3)]

func _process_factory_row_shipping(delta: float) -> void:
	# A full three-piece load dispatches immediately; there is no artificial
	# cooldown between trucks. Products stay visible at the end of each belt.
	if mega_factory_built_count < 1 or factory_shipping_busy:
		return
	factory_shipping_timer += delta
	if factory_shipping_timer < 0.12:
		return
	factory_shipping_timer = 0.0
	var selected_row := -1
	for offset in range(5):
		var candidate := (factory_shipping_row + offset) % 5
		if _factory_row_sell_stage(candidate) <= 0:
			continue
		_ensure_factory_row_belt_visuals(candidate)
		if _factory_row_sellable_stock(candidate) >= 3 and factory_row_belt_items[candidate].size() >= 3:
			var first_three_ready := true
			for item_index in range(3):
				var belt_item: Node3D = factory_row_belt_items[candidate][item_index]
				if not is_instance_valid(belt_item) or belt_item.position.x < 196.5:
					first_three_ready = false
					break
			if first_three_ready:
				selected_row = candidate
				break
	if selected_row == -1:
		return
	factory_shipping_row = (selected_row + 1) % 5
	_dispatch_factory_row_truck(selected_row)

func _ensure_factory_row_belt_visuals(row: int) -> void:
	if row < 0 or row >= 5:
		return
	# Remove freed product references before comparing queue length. A stale
	# reference otherwise counts as a product forever and can block dispatch.
	var queue: Array = factory_row_belt_items[row]
	var valid_queue: Array = []
	for item in queue:
		if is_instance_valid(item):
			valid_queue.append(item)
	factory_row_belt_items[row] = valid_queue
	queue = valid_queue
	var expected := _factory_row_sellable_stock(row)
	var stage := maxi(0, _factory_row_sell_stage(row) - 1)
	while queue.size() < expected:
		_spawn_factory_stage_item(row, stage, true)
		queue = factory_row_belt_items[row]

func _reposition_factory_belt_queue(row: int) -> void:
	if row < 0 or row >= 5:
		return
	var queue: Array = factory_row_belt_items[row]
	for item_index in range(queue.size()):
		var item: Node3D = queue[item_index]
		if not is_instance_valid(item):
			continue
		var lane := (item_index % 3) - 1
		var slot := int(item_index / 3)
		var target := Vector3(198.0 - float(slot) * 1.05, 1.42, _factory_row_z(row) + float(lane) * 0.38)
		var slide := create_tween()
		slide.set_trans(Tween.TRANS_SINE)
		slide.set_ease(Tween.EASE_OUT)
		slide.tween_property(item, "position", target, 0.35)

func _append_factory_truck_route_leg(tween: Tween, truck: Node3D, target: Vector3, travel_time: float) -> void:
	# Factory trucks have their cab on local -X. Turn the chassis toward each
	# road segment before moving so every leg is driven nose-first, never sideways
	# or in reverse. Keeping the turn as part of the same tween preserves route order.
	var direction := target - truck.position
	direction.y = 0.0
	if direction.length_squared() <= 0.0001:
		return
	var target_yaw := atan2(direction.z, -direction.x)
	var turn_time := minf(0.32, maxf(0.12, travel_time * 0.22))
	tween.tween_property(truck, "rotation:y", target_yaw, turn_time)
	tween.tween_property(truck, "position", target, travel_time)


func _dispatch_factory_row_truck(row: int) -> void:
	if row < 0 or row >= 5 or mega_factory_built_count < row * 3 + 1:
		return
	var sell_stage := _factory_row_sell_stage(row)
	# A freed visual must never count as cargo or trigger payment for a load
	# that contains fewer than three real products.
	var queue: Array = factory_row_belt_items[row]
	var valid_queue: Array = []
	for item in queue:
		if is_instance_valid(item):
			valid_queue.append(item)
	queue = valid_queue
	factory_row_belt_items[row] = queue
	if _factory_row_sellable_stock(row) < 3 or queue.size() < 3:
		return
	factory_shipping_busy = true
	# Remove exactly three valid product objects from the belt queue.
	var loaded_products: Array[Node3D] = []
	for package_index in range(3):
		var product: Node3D = queue.pop_front()
		loaded_products.append(product)
	factory_row_belt_items[row] = queue
	_factory_row_remove_sellable_stock(row, 3)
	_reposition_factory_belt_queue(row)
	var truck := _create_factory_row_truck(row)
	var z := _factory_row_z(row)
	var stage_names := ["RAW", "PREPARATION", "PROCESSING", "FINISHED"]
	var stage_name: String = stage_names[clampi(sell_stage, 0, 3)]
	var door_left := _box("FactoryDoorMovingLeft", Vector3(207.15, 3.0, z - 1.35), Vector3(0.24, 5.7, 2.7), Color(0.08, 0.48, 0.48), false)
	var door_right := _box("FactoryDoorMovingRight", Vector3(207.15, 3.0, z + 1.35), Vector3(0.24, 5.7, 2.7), Color(0.08, 0.48, 0.48), false)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(door_left, "position:z", z - 3.0, 0.55)
	tween.parallel().tween_property(door_right, "position:z", z + 3.0, 0.55)
	tween.tween_property(truck, "position:x", 210.0, 1.0)
	for package_index in range(loaded_products.size()):
		var product := loaded_products[package_index]
		var target := Vector3(211.15, 2.35, z + float(package_index - 1) * 0.82)
		tween.tween_property(product, "global_position", target, 0.42)
		tween.tween_callback(func(): product.reparent(truck))
	# Pay at the instant the third real product is loaded into the truck.
	tween.tween_callback(func():
		var loading_revenue := _factory_row_truck_revenue(row, sell_stage)
		money += loading_revenue
		_update_ui()
		_save_game()
		_refresh_factory_machine_status()
		_set_message("%s: truck loaded 3 %s products. Payment +%.0f ZC!" % [_factory_row_product(row), stage_name, loading_revenue])
	)
	tween.tween_interval(0.35)
	tween.tween_interval(0.25)
	_append_factory_truck_route_leg(tween, truck, Vector3(220.0, 0.0, z + 5.0), 0.45)
	_append_factory_truck_route_leg(tween, truck, Vector3(234.0, 0.0, z + 5.0), 1.0)
	_append_factory_truck_route_leg(tween, truck, Vector3(234.0, 0.0, 12.0), 0.65)
	_append_factory_truck_route_leg(tween, truck, Vector3(250.0, 0.0, 12.0), 1.2)
	_append_factory_truck_route_leg(tween, truck, Vector3(250.0, 0.0, 22.0), 0.55)
	_append_factory_truck_route_leg(tween, truck, Vector3(266.0, 0.0, 22.0), 1.1)
	_append_factory_truck_route_leg(tween, truck, Vector3(266.0, 0.0, 34.0), 0.65)
	_append_factory_truck_route_leg(tween, truck, Vector3(282.0, 0.0, 34.0), 1.1)
	_append_factory_truck_route_leg(tween, truck, Vector3(282.0, 0.0, 46.0), 0.55)
	_append_factory_truck_route_leg(tween, truck, Vector3(298.0, 0.0, 46.0), 1.2)
	tween.tween_callback(func():
		truck.queue_free()
		door_left.queue_free()
		door_right.queue_free()
		factory_shipping_busy = false
		factory_shipping_cooldown = 0.0
		_set_message("%s truck delivered. Next full load will dispatch immediately." % _factory_row_product(row))
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
	_box("MegaProcessMachineBaseLeft%d" % index, Vector3(x, 0.34, z - 1.48), Vector3(5.0, 0.42, 0.72), dark_steel, false)
	_box("MegaProcessMachineBaseRight%d" % index, Vector3(x, 0.34, z + 1.48), Vector3(5.0, 0.42, 0.72), dark_steel, false)
	_box("MegaProcessMachineBody%d" % index, Vector3(x, 2.46, z), Vector3(4.3, 2.7, 3.4), steel, false)
	_box("MegaProcessMachineTop%d" % index, Vector3(x, 3.89, z), Vector3(4.7, 0.18, 3.8), accent.darkened(0.2), false)
	_box("MegaProcessMachineWindow%d" % index, Vector3(x, 2.56, z - 1.73), Vector3(1.9, 0.8, 0.06), accent, false)
	_box("MegaProcessMachineControl%d" % index, Vector3(x + 1.65, 2.11, z - 1.78), Vector3(0.58, 0.9, 0.12), dark_steel, false)
	_box("MegaProcessMachineScreen%d" % index, Vector3(x + 1.65, 2.42, z - 1.855), Vector3(0.34, 0.22, 0.035), Color(0.08, 0.68, 0.63), false)
	_box("MegaProcessMachineEmergencyStop%d" % index, Vector3(x + 1.65, 1.68, z - 1.86), Vector3(0.20, 0.18, 0.07), Color(0.82, 0.12, 0.08), false)
	_box("MegaProcessMachineServiceLabel%d" % index, Vector3(x, 1.45, z - 1.82), Vector3(0.78, 0.20, 0.055), Color(0.88, 0.61, 0.13), false)
	for vent_i in range(4):
		_box("MegaProcessMachineCoolingVent%d_%d" % [index, vent_i], Vector3(x - 1.18, 2.20 + float(vent_i) * 0.16, z + 1.735), Vector3(1.02, 0.055, 0.045), dark_steel, false)
	for bolt_x in [-1.94, 1.94]:
		for bolt_y in [1.42, 3.50]:
			var bolt := _cylinder("MegaProcessMachineBolt%d" % index, Vector3(x + bolt_x, bolt_y, z - 1.79), 0.055, 0.045, Color(0.66, 0.72, 0.71), false)
			bolt.rotation_degrees.x = 90.0
	var drive_motor := _cylinder("MegaProcessMachineDriveMotor%d" % index, Vector3(x - 1.55, 4.24, z + 1.18), 0.28, 0.78, Color(0.17, 0.25, 0.28), false)
	drive_motor.rotation_degrees.z = 90.0
	_cylinder("MegaProcessMachineMotorCap%d" % index, Vector3(x - 1.55, 4.24, z + 1.60), 0.20, 0.08, Color(0.64, 0.70, 0.68), false)
	_cylinder("MegaProcessMachineBeacon%d" % index, Vector3(x + 1.72, 4.10, z - 1.22), 0.12, 0.22, Color(0.98, 0.56, 0.12), false)
	for wheel_x in [x - 1.5, x + 1.5]:
		_cylinder("MegaProcessMachineDrum%d" % index, Vector3(wheel_x, 0.84, z + 2.0), 0.38, 0.22, accent, true)
	# Machine exterior upgrade: framed access doors, exhaust and warning geometry.
	_box("MegaMachineAccessFrame%d" % index, Vector3(x - 1.45, 2.45, z - 1.76), Vector3(0.88, 1.30, 0.08), accent.darkened(0.22), false)
	_box("MegaMachineAccessDoor%d" % index, Vector3(x - 1.45, 2.45, z - 1.81), Vector3(0.72, 1.12, 0.04), steel.lightened(0.12), false)
	for door_y in [1.95, 2.95]:
		_box("MegaMachineDoorHandle%d" % index, Vector3(x - 1.45, door_y, z - 1.85), Vector3(0.10, 0.16, 0.04), Color(0.72, 0.78, 0.74), false)
	_box("MegaMachineSafetyBand%d" % index, Vector3(x, 0.66, z - 1.55), Vector3(4.5, 0.09, 0.12), accent, false)
	_box("MegaMachineTopRidge%d" % index, Vector3(x, 4.00, z), Vector3(3.8, 0.08, 0.20), Color(0.38, 0.45, 0.46), false)
	for exhaust_x in [-0.85, 0.85]:
		_box("MegaMachineExhaustBase%d" % index, Vector3(x + exhaust_x, 4.13, z + 0.58), Vector3(0.48, 0.18, 0.48), dark_steel, false)
		_box("MegaMachineExhaustStack%d" % index, Vector3(x + exhaust_x, 4.38, z + 0.58), Vector3(0.30, 0.42, 0.30), steel, false)
		_box("MegaMachineExhaustCap%d" % index, Vector3(x + exhaust_x, 4.61, z + 0.58), Vector3(0.40, 0.08, 0.40), accent, false)
	# Physical-looking infeed throat: tapered guide cheeks and a reinforced receiving lip.
	_box("MegaMachineInfeedLip%d" % index, Vector3(x - 2.34, 1.02, z), Vector3(0.34, 0.16, 1.52), accent, false)
	for guide_side in [-1.0, 1.0]:
		var guide := _box("MegaMachineInfeedGuide%d" % index, Vector3(x - 2.18, 1.18, z + guide_side * 0.78), Vector3(0.72, 0.12, 0.12), steel, false)
		guide.rotation_degrees.y = -guide_side * 18.0
	# Short visible roller throat bridges the branch belt to the machine mouth.
	for throat_i in range(3):
		var throat_roller := _cylinder("MegaMachineInfeedRoller%d_%d" % [index, throat_i], Vector3(x - 2.45 + float(throat_i) * 0.22, 1.00, z), 0.075, 1.18, Color(0.55, 0.61, 0.59), false)
		throat_roller.rotation_degrees.x = 90.0
	# The final machine in each row gets a guarded discharge chute toward the product dock.
	if column == 2:
		_box("MegaMachineDischargeNeck%d" % index, Vector3(x + 2.34, 1.65, z), Vector3(0.62, 0.42, 1.34), dark_steel, false)
		_box("MegaMachineDischargeTray%d" % index, Vector3(x + 2.78, 1.12, z), Vector3(0.72, 0.12, 1.50), accent.darkened(0.15), false)
		for discharge_side in [-1.0, 1.0]:
			_box("MegaMachineDischargeGuard%d" % index, Vector3(x + 2.78, 1.30, z + discharge_side * 0.70), Vector3(0.78, 0.30, 0.10), steel, false)
	_label_3d(_factory_row_machine_name(row, column), Vector3(x, 4.31, z - 2.0), 0.13)

func _build_waste_feed_conveyor_network() -> void:
	if waste_feed_conveyor_network_built:
		return
	waste_feed_conveyor_network_built = true
	var steel := Color(0.16, 0.22, 0.24)
	var dark_steel := Color(0.055, 0.085, 0.095)
	var belt_color := Color(0.035, 0.055, 0.06)
	# Dedicated transfer conveyor links the central cross-feed spine directly to the main waste tank.
	# Its left end meets the tank outlet and its right end meets the middle of the five-row feed spine.
	_box("WasteFeedMainFrame", Vector3(137.7, 0.68, 0.0), Vector3(18.6, 0.30, 1.8), dark_steel, false)
	_box("WasteFeedMainBelt", Vector3(137.7, 0.925, 0.0), Vector3(18.35, 0.08, 1.35), belt_color, false)
	# Keep the final section of the trunk open where it meets the distributor.
	for side_z in [-0.78, 0.78]:
		_box("WasteFeedMainRail", Vector3(135.55, 1.08, side_z), Vector3(14.05, 0.28, 0.08), steel, false)
	for transfer_x in range(129, 145, 2):
		var transfer_roller := _cylinder("WasteFeedMainRoller", Vector3(float(transfer_x), 0.88, 0.0), 0.045, 1.05, Color(0.12, 0.16, 0.17), false)
		transfer_roller.rotation_degrees.x = 90.0
		conveyor_rollers.append(transfer_roller)
	# Reinforced intake lip makes the physical connection to the tank outlet visible.
	_box("WasteTankConveyorIntakeFrame", Vector3(128.55, 0.68, 0.0), Vector3(1.25, 0.34, 1.95), dark_steel, false)
	_box("WasteTankConveyorIntakeBelt", Vector3(128.55, 0.925, 0.0), Vector3(1.15, 0.08, 1.42), belt_color, false)
	_box("WasteFeedDistributorFrame", Vector3(147.0, 0.68, 0.0), Vector3(1.65, 0.30, 55.5), dark_steel, false)
	_box("WasteFeedDistributorBelt", Vector3(147.0, 0.925, 0.0), Vector3(1.25, 0.08, 55.0), belt_color, false)
	# Split the distributor guard rails around every branch junction so the belts read as one connected path.
	var distributor_gaps: Array[float] = []
	for row in range(5):
		distributor_gaps.append(_factory_row_z(row))
	var gap_half_width := 1.65
	var rail_cursor := -27.5
	for gap_center in distributor_gaps:
		var gap_start: float = gap_center - gap_half_width
		var segment_length: float = gap_start - rail_cursor
		if segment_length > 0.25:
			for side_x in [146.12, 147.88]:
				_box("WasteFeedDistributorRail", Vector3(side_x, 1.08, rail_cursor + segment_length * 0.5), Vector3(0.08, 0.28, segment_length), steel, false)
		rail_cursor = gap_center + gap_half_width
	var final_length := 27.5 - rail_cursor
	if final_length > 0.25:
		for side_x in [146.12, 147.88]:
			_box("WasteFeedDistributorRail", Vector3(side_x, 1.08, rail_cursor + final_length * 0.5), Vector3(0.08, 0.28, final_length), steel, false)
	
	# Use the existing distributor spine; avoid a duplicate parallel conveyor.
	
	# Keep quarter-turn elbows only at the two outer ends of the distributor.
	# The three middle row connections stay straight; they do not need extra bends.
	for row in range(5):
		var feed_z := _factory_row_z(row)
		if row == 0 or row == 4:
			var bend_radius := 1.15
			var bend_start_x := 147.0
			var bend_start_z := feed_z - bend_radius
			var bend_segments := 24
			var segment_len := (bend_radius * PI * 0.5 / float(bend_segments)) * 1.12
			for bend_i in range(bend_segments):
				var t := (float(bend_i) + 0.5) / float(bend_segments)
				var angle := t * PI * 0.5
				var bend_x := bend_start_x + bend_radius * (1.0 - cos(angle))
				var bend_z := bend_start_z + bend_radius * sin(angle)
				var bend_rotation: float = rad_to_deg(angle) - 90.0
				var bend_frame := _box("FactoryFirstMachineFeedBendFrame%d_%d" % [row, bend_i], Vector3(bend_x, 0.69, bend_z), Vector3(segment_len, 0.28, 1.42), dark_steel, false)
				bend_frame.rotation_degrees.y = bend_rotation
				var bend_belt := _box("FactoryFirstMachineFeedBendBelt%d_%d" % [row, bend_i], Vector3(bend_x, 0.925, bend_z), Vector3(segment_len * 1.04, 0.08, 1.18), belt_color, false)
				bend_belt.rotation_degrees.y = bend_rotation
				for side in [-1.0, 1.0]:
					var rail_x: float = bend_x + cos(angle) * 0.72 * side
					var rail_z: float = bend_z - sin(angle) * 0.72 * side
					var bend_rail := _box("FactoryFirstMachineFeedBendRail%d_%d_%d" % [row, bend_i, int(side)], Vector3(rail_x, 1.075, rail_z), Vector3(segment_len * 1.08, 0.24, 0.085), steel, false)
					bend_rail.rotation_degrees.y = bend_rotation

	# Powered roller beds make the trunk, distributor and all five branches read as one machine.
	for roller_i in range(37):
		var distributor_z := -27.0 + float(roller_i) * 1.5
		var distributor_roller := _cylinder("WasteFeedDistributorRoller", Vector3(147.0, 0.875, distributor_z), 0.065, 1.10, Color(0.38, 0.44, 0.45), false)
		distributor_roller.rotation_degrees.z = 90.0
		conveyor_rollers.append(distributor_roller)
	# Moving cross-cleats follow the distributor's vertical run.
	for cleat_i in range(18):
		var distributor_cleat := _box("WasteFeedDistributorCleat", Vector3(147.0, 0.985, -25.0 + float(cleat_i) * 2.8), Vector3(1.02, 0.035, 0.13), Color(0.12, 0.16, 0.17), false)
		distributor_cleat.set_meta("factory_belt_axis", "z")
		distributor_cleat.set_meta("factory_belt_start", -25.0)
		distributor_cleat.set_meta("factory_belt_length", 50.0)
		distributor_cleat.set_meta("factory_belt_phase", float(cleat_i) * 2.8)
		factory_conveyor_slats.append(distributor_cleat)
	for row in range(5):
		var feed_z := _factory_row_z(row)
		for roller_i in range(3):
			var branch_x := 148.0 + float(roller_i) * 1.25
			var branch_roller := _cylinder("WasteFeedBranchRoller%d" % row, Vector3(branch_x, 0.875, feed_z), 0.055, 1.05, Color(0.38, 0.44, 0.45), false)
			branch_roller.rotation_degrees.x = 90.0
			conveyor_rollers.append(branch_roller)
		for cleat_i in range(2):
			var branch_cleat := _box("WasteFeedBranchCleat%d" % row, Vector3(147.8 + float(cleat_i) * 1.9, 0.985, feed_z), Vector3(0.12, 0.035, 1.02), Color(0.12, 0.16, 0.17), false)
			branch_cleat.set_meta("factory_belt_axis", "x")
			branch_cleat.set_meta("factory_belt_start", 147.35)
			branch_cleat.set_meta("factory_belt_length", 3.8)
			branch_cleat.set_meta("factory_belt_phase", float(cleat_i) * 1.9)
			factory_conveyor_slats.append(branch_cleat)
		# All five branch belts remain straight after leaving the distributor.
		_box("FactoryFirstMachineFeedBranchFrame%d" % row, Vector3(149.35, 0.68, feed_z), Vector3(3.45, 0.30, 1.45), dark_steel, false)
		_box("FactoryFirstMachineFeedBranchBelt%d" % row, Vector3(149.35, 0.925, feed_z), Vector3(3.50, 0.08, 1.22), belt_color, false)
		for side_z in [feed_z - 0.72, feed_z + 0.72]:
			_box("FactoryFirstMachineFeedBranchRail%d" % row, Vector3(149.55, 1.075, side_z), Vector3(2.75, 0.24, 0.085), steel, false)
	


func _build_factory_row_main_conveyor(row: int) -> void:
	var z := _factory_row_z(row)
	# Industrial conveyor palette: graphite rubber, galvanized steel and restrained safety-yellow details.
	var frame_color := Color(0.12, 0.15, 0.16)
	var steel := Color(0.38, 0.43, 0.44)
	var rubber := Color(0.025, 0.032, 0.034)
	var safety_yellow := Color(0.92, 0.61, 0.12)
	var start_x := 148.0
	var end_x := 199.0
	var belt_length := end_x - start_x
	var center_x := (start_x + end_x) * 0.5
	# Deep side frame with a clearly separate moving rubber belt.
	_box("FactoryMainConveyorFrame%d" % row, Vector3(center_x, 0.68, z), Vector3(belt_length, 0.42, 1.66), frame_color, false)
	_box("FactoryMainConveyorBelt%d" % row, Vector3(center_x, 0.925, z), Vector3(belt_length - 0.28, 0.075, 1.30), rubber, false)
	# Rounded discharge nose: the half-disc sits under the straight belt edge
	# and exposes a smooth semicircular return instead of a blunt square cut.
	var nose_center_x := end_x - 0.14
	var nose := _cylinder("FactoryMainConveyorEndNose%d" % row, Vector3(nose_center_x, 0.925, z), 0.65, 0.075, rubber, false)
	# Wrap the two side guards around the rounded nose in short aligned sections.
	var nose_guard_radius := 0.79
	var nose_guard_segments := 12
	for guard_i in range(nose_guard_segments):
		var a0 := -PI * 0.5 + (float(guard_i) / float(nose_guard_segments)) * PI
		var a1 := -PI * 0.5 + (float(guard_i + 1) / float(nose_guard_segments)) * PI
		var p0 := Vector3(nose_center_x + cos(a0) * nose_guard_radius, 1.105, z + sin(a0) * nose_guard_radius)
		var p1 := Vector3(nose_center_x + cos(a1) * nose_guard_radius, 1.105, z + sin(a1) * nose_guard_radius)
		var guard_segment := _box("FactoryMainConveyorNoseGuard%d_%d" % [row, guard_i], (p0 + p1) * 0.5, Vector3(p0.distance_to(p1) + 0.035, 0.27, 0.10), steel, false)
		guard_segment.rotation_degrees.y = -rad_to_deg(atan2(p1.z - p0.z, p1.x - p0.x))
	# Side guards run along the full conveyor, with only a short opening exactly
	# where the incoming branch joins the main belt.
	# Match the opening to the full width of the incoming branch mouth.
	var merge_open_start := start_x
	var merge_open_end := start_x + 1.45
	var guard_segments := [
		[ start_x, merge_open_start ],
		[ merge_open_end, end_x ]
	]
	for side_z in [z - 0.79, z + 0.79]:
		for segment in guard_segments:
			var segment_start: float = segment[0]
			var segment_end: float = segment[1]
			var segment_length := segment_end - segment_start
			if segment_length > 0.05:
				var segment_center := (segment_start + segment_end) * 0.5
				_box("FactoryMainConveyorRail%d" % row, Vector3(segment_center, 1.105, side_z), Vector3(segment_length, 0.27, 0.10), steel, false)
				_box("FactoryMainConveyorSafetyEdge%d" % row, Vector3(segment_center, 1.245, side_z), Vector3(segment_length, 0.025, 0.055), safety_yellow, false)
	# Exposed support stringers and cross-braced legs at regular intervals.
	for side_z in [z - 0.70, z + 0.70]:
		_box("FactoryMainConveyorStringer%d" % row, Vector3(center_x, 0.73, side_z), Vector3(belt_length, 0.20, 0.10), steel, false)
	for support_i in range(9):
		var support_x := start_x + 2.0 + float(support_i) * ((belt_length - 4.0) / 8.0)
		for leg_z in [z - 0.58, z + 0.58]:
			_box("FactoryMainConveyorLeg%d_%d" % [row, support_i], Vector3(support_x, 0.28, leg_z), Vector3(0.16, 0.56, 0.16), frame_color, false)
		_box("FactoryMainConveyorCrossbar%d_%d" % [row, support_i], Vector3(support_x, 0.12, z), Vector3(0.16, 0.12, 1.25), steel, false)
	# Real roller bed: fewer, individually visible steel rollers beneath the belt.
	var roller_count := 36
	for roller_i in range(roller_count):
		var roller_x := start_x + 0.45 + float(roller_i) * ((belt_length - 0.90) / float(roller_count - 1))
		var roller := _cylinder("FactoryMainConveyorRoller%d_%d" % [row, roller_i], Vector3(roller_x, 0.875, z), 0.075, 1.20, steel, false)
		roller.rotation_degrees.x = 90.0
		conveyor_rollers.append(roller)
	# Low-profile transverse cleats move with the belt instead of looking like fixed ribs.
	var cleat_count := 18
	for cleat_i in range(cleat_count):
		var cleat := _box("FactoryMainConveyorCleat%d_%d" % [row, cleat_i], Vector3(start_x + 0.65 + float(cleat_i) * 2.75, 0.985, z), Vector3(0.13, 0.035, 1.08), Color(0.10, 0.13, 0.14), false)
		cleat.set_meta("factory_belt_start", start_x + 0.65)
		cleat.set_meta("factory_belt_length", belt_length - 1.30)
		cleat.set_meta("factory_belt_phase", float(cleat_i) * 2.75)
		factory_conveyor_slats.append(cleat)
	# Keep the conveyor ends flush and the moving belt surface visually continuous.

func _build_mega_factory_machine_connections(index: int) -> void:
	# Legacy hook: the continuous row conveyor is built once for each production row.
	return

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
		# Unlock this line's conveyor only when its first machine is fully built.
		if column == 0 and row > 0:
			_build_factory_row_main_conveyor(row)
		_build_mega_factory_machine_connections(index)
		if column > 0:
			_clear_factory_row_belt_visuals(row)
		mega_factory_built_count += 1
		mega_factory_build_paid = 0.0
		mega_factory_build_timer = 0.0
		if index < mega_factory_machine_labels.size() and is_instance_valid(mega_factory_machine_labels[index]):
			mega_factory_machine_labels[index].text = "BUILT"
		# Do not spawn a second static display of three oversized products at the belt exit.
		_set_message("Machine %d installed. Production and truck delivery updated for its line." % mega_factory_built_count)
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
	_build_drone_station()

func _on_waste_tank_build_entered(body: Node3D) -> void:
	if body != player:
		return
	if waste_tank_built:
		if carried <= 0:
			_set_message("Collect waste first, then return here. The tank loads automatically.")
		else:
			_set_message("Automatic loading started. Stay on the marked tank platform.")
		return
	const BUILD_COST := 120.0
	if money < BUILD_COST:
		_set_message("Build the factory waste tank: 120 ZC required.")
		return
	money -= BUILD_COST
	waste_tank_built = true
	_build_waste_tank_structure()
	_build_waste_feed_conveyor_network()
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
	# Add realistic bunker reinforcement, inspection markings and hydraulic service details.
	for rib_x in [-6.9, -5.8, -4.8, -3.8, -2.7]:
		_box("BunkerFrontReinforcement", Vector3(rib_x, 1.02, -19.25), Vector3(0.12, 1.85, 0.16), Color(0.36, 0.42, 0.42), false)
	for stripe_x in [-7.4, -6.8, -6.2, -5.6, -5.0, -4.4, -3.8, -3.2, -2.6, -2.0]:
		_box("BunkerFrontWarningMark", Vector3(stripe_x, 0.16, -19.25), Vector3(0.22, 0.025, 0.10), Color(0.96, 0.65, 0.16), false)
	_box("BunkerHydraulicServiceBox", Vector3(-7.65, 1.45, -25.30), Vector3(0.62, 0.78, 0.48), Color(0.18, 0.24, 0.25), false)
	_box("BunkerHydraulicPanel", Vector3(-7.65, 1.45, -25.04), Vector3(0.42, 0.50, 0.04), Color(0.43, 0.50, 0.49), false)
	_box("BunkerInspectionPlate", Vector3(-4.8, 1.80, -19.22), Vector3(1.10, 0.30, 0.045), Color(0.12, 0.19, 0.20), false)

	# Industrial receiving hopper: reinforced rim, removable safety grate and inspection lights.
	_box("WasteHopperRimFront", Vector3(-4.8, 2.30, -18.92), Vector3(6.9, 0.18, 0.24), Color(0.39, 0.47, 0.47), false)
	_box("WasteHopperRimBack", Vector3(-4.8, 2.30, -26.08), Vector3(6.9, 0.18, 0.24), Color(0.39, 0.47, 0.47), false)
	for grate_x in [-7.55, -6.65, -5.75, -4.85, -3.95, -3.05, -2.15]:
		_box("WasteHopperSafetyGrate", Vector3(grate_x, 2.20, -19.45), Vector3(0.075, 0.06, 0.92), Color(0.14, 0.20, 0.21), false)
		_box("WasteHopperGrateCrossbar", Vector3(grate_x, 2.20, -19.45), Vector3(0.07, 0.06, 0.92), Color(0.14, 0.20, 0.21), false)
	# Hydraulic ram and its exposed guide rails sit above the rear wall, clear of the player approach.
	_box("WasteCompactorRamColumn", Vector3(-4.8, 2.85, -25.25), Vector3(0.42, 1.30, 0.48), Color(0.16, 0.22, 0.24), false)
	_box("WasteCompactorRamCylinder", Vector3(-4.8, 3.48, -25.25), Vector3(0.25, 0.82, 0.28), Color(0.52, 0.59, 0.58), false)
	_box("WasteCompactorRamPiston", Vector3(-4.8, 2.78, -24.55), Vector3(0.18, 0.70, 0.18), Color(0.73, 0.77, 0.72), false)
	for ram_side in [-1.0, 1.0]:
		_box("WasteCompactorGuideRail", Vector3(-4.8 + ram_side * 0.62, 2.90, -25.15), Vector3(0.10, 1.55, 0.12), Color(0.36, 0.44, 0.45), false)
		_box("WasteCompactorGuideFoot", Vector3(-4.8 + ram_side * 0.62, 2.20, -24.65), Vector3(0.32, 0.16, 0.42), Color(0.22, 0.29, 0.30), false)
	# A short enclosed transfer chute visually joins the bunker outlet to the existing feed conveyor.
	_box("WasteTankOutletCollar", Vector3(-0.72, 0.92, -22.5), Vector3(0.52, 0.72, 1.72), Color(0.12, 0.18, 0.19), false)
	_box("WasteTankTransferChute", Vector3(-0.12, 0.70, -22.5), Vector3(0.92, 0.34, 1.52), Color(0.25, 0.34, 0.35), false)
	_box("WasteTankTransferBelt", Vector3(0.10, 0.91, -22.5), Vector3(0.98, 0.07, 1.16), Color(0.035, 0.055, 0.06), false)
	for chute_rail_z in [-23.18, -21.82]:
		_box("WasteTankTransferRail", Vector3(0.08, 1.12, chute_rail_z), Vector3(1.02, 0.28, 0.08), Color(0.43, 0.51, 0.51), false)
	# Inspection walkway, access ladder and a guarded control station.
	_box("WasteTankInspectionWalkway", Vector3(-4.8, 2.48, -27.10), Vector3(5.8, 0.14, 1.05), Color(0.20, 0.28, 0.29), false)
	for rail_x in [-7.55, -2.05]:
		_box("WasteTankWalkwayRailPost", Vector3(rail_x, 2.95, -27.10), Vector3(0.10, 0.92, 0.10), Color(0.46, 0.54, 0.53), false)
		_box("WasteTankWalkwayHandrail", Vector3(rail_x, 3.40, -27.10), Vector3(0.12, 0.10, 1.05), Color(0.46, 0.54, 0.53), false)
	for ladder_y in range(5):
		_box("WasteTankAccessLadderRung", Vector3(-1.45, 0.55 + float(ladder_y) * 0.42, -26.55), Vector3(0.75, 0.075, 0.09), Color(0.56, 0.63, 0.61), false)
	for ladder_side in [-1.0, 1.0]:
		_box("WasteTankAccessLadderRail", Vector3(-1.45 + ladder_side * 0.39, 1.35, -26.55), Vector3(0.075, 2.25, 0.10), Color(0.31, 0.40, 0.41), false)
	_box("WasteTankLevelGaugeHousing", Vector3(-1.75, 1.45, -22.5), Vector3(0.16, 1.72, 0.48), Color(0.09, 0.14, 0.15), false)
	_box("WasteTankLevelGaugeWindow", Vector3(-1.64, 1.45, -22.5), Vector3(0.05, 1.28, 0.25), Color(0.12, 0.67, 0.58), false)
	_box("WasteTankControlConsole", Vector3(-1.55, 1.25, -24.45), Vector3(0.62, 1.05, 0.55), Color(0.12, 0.19, 0.21), false)
	_box("WasteTankControlScreen", Vector3(-1.22, 1.48, -24.45), Vector3(0.035, 0.38, 0.40), Color(0.10, 0.74, 0.66), false)
	# Move all geometry helpers, which create at scene root, under the tank transform.
	var tank_names := ["WasteHopperRimFront", "WasteHopperRimBack", "WasteHopperSafetyGrate", "WasteHopperGrateCrossbar", "WasteCompactorRamColumn", "WasteCompactorRamCylinder", "WasteCompactorRamPiston", "WasteCompactorGuideRail", "WasteCompactorGuideFoot", "WasteTankOutletCollar", "WasteTankTransferChute", "WasteTankTransferBelt", "WasteTankTransferRail", "WasteTankInspectionWalkway", "WasteTankWalkwayRailPost", "WasteTankWalkwayHandrail", "WasteTankAccessLadderRung", "WasteTankAccessLadderRail", "WasteTankLevelGaugeHousing", "WasteTankLevelGaugeWindow", "WasteTankControlConsole", "WasteTankControlScreen", "CityDumpApproachApron", "CityDumpConcrete", "CityDumpMarking", "DumpBunkerSideRibL", "DumpBunkerSideRibR", "DumpBunkerTopRailBack", "DumpBunkerTopRailLeft", "DumpBunkerTopRailRight", "DumpCompactorHousing", "DumpCompactorServicePanel", "CityDumpBackWall", "CityDumpLeftWall", "CityDumpRightWall", "DepotConcreteJoint", "DepotDrainChannel", "DepotDrainSlot", "CityDumpHazardStripe", "CityDumpSignPostL", "CityDumpSignPostR", "CityDumpSign", "DepotSafetyBollard", "DepotFloodlightHousing", "DepotFloodlightLens", "DepotElectricalCabinet", "DepotCabinetDoor", "BunkerFrontReinforcement", "BunkerFrontWarningMark", "BunkerHydraulicServiceBox", "BunkerHydraulicPanel", "BunkerInspectionPlate"]
	for child in get_children():
		if child is Node3D and tank_names.has(child.name):
			remove_child(child)
			waste_tank_root.add_child(child)
	for child in waste_tank_root.get_children():
		if child is Node3D:
			child.position.x += 129.6
	waste_tank_inventory_label = Label3D.new()
	waste_tank_inventory_label.name = "WasteTankInventoryLabel"
	waste_tank_inventory_label.position = Vector3(124.8, 3.25, -22.5)
	waste_tank_inventory_label.text = "WASTE  %d / %d" % [waste_tank_inventory, _waste_tank_capacity()]
	waste_tank_inventory_label.font_size = 22
	waste_tank_inventory_label.pixel_size = 0.009
	waste_tank_inventory_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	waste_tank_inventory_label.modulate = Color(0.72, 1.0, 0.86)
	waste_tank_root.add_child(waste_tank_inventory_label)

	var intake_process_label := Label3D.new()
	intake_process_label.name = "WasteTankProcessLabel"
	intake_process_label.text = "INTAKE  /  COMPACTION  /  FEED"
	intake_process_label.position = Vector3(124.8, 3.05, -18.82)
	intake_process_label.font_size = 18
	intake_process_label.pixel_size = 0.009
	intake_process_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	intake_process_label.modulate = Color(0.95, 0.98, 0.91)
	waste_tank_root.add_child(intake_process_label)

func _refresh_waste_tank_inventory_label() -> void:
	if is_instance_valid(waste_tank_inventory_label):
		waste_tank_inventory_label.text = "WASTE  %d / %d" % [waste_tank_inventory, _waste_tank_capacity()]

func _refresh_factory_machine_status() -> void:
	if is_instance_valid(factory_machine_status_label):
		var stage := _factory_row_sell_stage(0)
		var output_stock := _factory_row_sellable_stock(0)
		var output_names := ["NO MACHINE", "M1 OUTPUT", "M2 OUTPUT", "FINAL PRODUCT"]
		var output_name: String = output_names[clampi(stage, 0, 3)]
		factory_machine_status_label.text = "RAW %d | M1 %d | M2 %d | %s %d" % [factory_row_input_stock[0], factory_row_stage1_stock[0], factory_row_stage2_stock[0], output_name, output_stock]

func _add_utility_vehicle_box(parent: Node3D, node_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	mesh.name = node_name
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.position = pos
	mesh.material_override = _mat(color)
	parent.add_child(mesh)

func _upgrade_factory_truck_interval() -> void:
	if factory_truck_interval_upgrade_level >= 3:
		_set_message("Factory truck arrival time is already at maximum.")
		return
	var cost := _upgrade_cost(70.0, factory_truck_interval_upgrade_level + 1)
	if not await _pay_gradually(cost):
		return
	factory_truck_interval_upgrade_level = mini(factory_truck_interval_upgrade_level + 1, 3)
	_refresh_upgrade_prices()
	_save_game()
	_set_message("Factory trucks now arrive every %.0f seconds after loading." % _factory_truck_arrival_interval())

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
	# Each interactive salvage bundle represents up to 100 visible landfill units.
	var remaining_units := maxi(0, FINAL_ZONE_TARGET - final_zone_cleaned)
	var remaining_objects := ceili(float(remaining_units) / 100.0)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_build_final_landfill_debris(remaining_units, rng)
	for i in range(remaining_objects):
		var units_in_bundle := mini(100, remaining_units - i * 100)
		var item := Node3D.new()
		item.set_script(TRASH_SCRIPT)
		item.set_meta("final_cleanup_units", units_in_bundle)
		item.position = _random_final_landfill_position(rng)
		add_child(item)
		trash_nodes.append(item)


func _is_safe_final_landfill_position(point: Vector2) -> bool:
	# Keep salvage piles out of vehicle lanes, crossings, machine footprints and service pads.
	if point.x < 112.0:
		if not _is_clear_trash_spawn(Vector3(point.x, 0.05, point.y)):
			return false
		if absf(point.y) < 4.65:
			return false
		for street_x in [16.0, 48.0, 80.0, 104.0]:
			if absf(point.x - street_x) < 3.9:
				return false
		for street_z in [-22.0, 22.0]:
			if absf(point.y - street_z) < 3.35:
				return false
		return true
	if point.x < 135.0:
		return false
	if point.distance_to(Vector2(STARTER_SELL_POINT.x, STARTER_SELL_POINT.z)) < 7.0:
		return false
	for row in range(5):
		var row_z: float = _factory_row_z(row)
		if absf(point.y - row_z) < 3.35:
			return false
		if absf(absf(point.y - row_z) - 4.92) < 0.72:
			return false
	return true


func _random_final_landfill_position(rng: RandomNumberGenerator) -> Vector3:
	# Endgame debris is distributed through open yards and parks, never on roads or machinery.
	var point := Vector2.ZERO
	var accepted := false
	for attempt in range(24):
		if rng.randf() < 0.78:
			var center: Vector2 = FINAL_LANDFILL_CLUSTERS[rng.randi_range(0, FINAL_LANDFILL_CLUSTERS.size() - 1)]
			point = center + Vector2(rng.randfn(0.0, 4.2), rng.randfn(0.0, 3.6))
		else:
			point = Vector2(rng.randf_range(-11.0, 203.0), rng.randf_range(-29.0, 29.0))
		point.x = clampf(point.x, -11.5, 203.0)
		point.y = clampf(point.y, -29.0, 29.0)
		if _is_safe_final_landfill_position(point):
			accepted = true
			break
	if not accepted:
		point = Vector2(8.0, 18.0)
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
		visual.custom_aabb = AABB(Vector3(-12.0, -0.5, -31.0), Vector3(216.0, 6.0, 62.0))
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
		var displayed_total := mini(total_trash_collected, COLLECTION_TARGET)
		final_zone_label.text = "TOTAL RECYCLED  %s / 600,000" % _format_counter(displayed_total)


func _format_counter(value: int) -> String:
	return String.num_int64(value).insert(String.num_int64(value).length() - 3, ",") if value >= 1000 else String.num_int64(value)


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
		var spawn_point := _random_trash_position(rng)
		if spawn_point.y < -100.0:
			break
		item.position = spawn_point
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
		if not _is_clear_trash_spawn(spawn_point):
			continue
		item.position = spawn_point
		add_child(item)
		trash_nodes.append(item)

func _refill_first_district() -> void:
	# Each lever pull adds up to 500 items, while the regular city supply is capped at 1,000.
	var alive_count := _count_regular_trash()
	var manual_refill_capacity := 500 + maxi(0, spawn_upgrade_level - 1) * 6
	var amount := mini(manual_refill_capacity, maxi(0, 1000 - alive_count))
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

func _is_clear_trash_spawn(point: Vector3) -> bool:
	# Public ground is valid spawn space: streets, alleys, sidewalks, parks and shop fronts.
	# Only reject actual building/object footprints so trash never appears on roofs or inside meshes.
	if point.distance_to(SELL_POINT) < 4.0:
		return false
	if point.x < -13.0 or point.x > 111.0 or point.z < -36.0 or point.z > 36.0:
		return false
	# Main residential/civic buildings on the north and south edges of the city.
	for building_x in [6.0, 38.0, 70.0, 96.0]:
		if absf(point.x - building_x) < 5.4 and (absf(point.z + 31.0) < 5.5 or absf(point.z - 31.0) < 5.5):
			return false
	# New homes in the inner city blocks.
	for home_x in [28.0, 60.0]:
		if absf(point.x - home_x) < 4.5 and (absf(point.z - 12.0) < 5.2 or absf(point.z + 12.0) < 5.2):
			return false
	# Park fountain and fixed plaza structures; open lawn and paths remain valid.
	if absf(point.x - 70.0) < 1.8 and absf(point.z - 11.5) < 1.8:
		return false
	if absf(point.x) < 2.5 and absf(point.z - 7.0) < 2.0:
		return false
	# Keep a small clearance around parked vehicles and solid street furniture.
	for car_pos in [Vector3(20.0, 0.0, -15.5), Vector3(44.0, 0.0, 15.5), Vector3(52.0, 0.0, 15.5), Vector3(76.0, 0.0, -15.5), Vector3(22.0, 0.0, -10.0), Vector3(44.0, 0.0, 10.0), Vector3(68.0, 0.0, -10.0), Vector3(92.0, 0.0, 10.0)]:
		if absf(point.x - car_pos.x) < 2.0 and absf(point.z - car_pos.z) < 1.25:
			return false
	return true

func _random_trash_position(rng: RandomNumberGenerator) -> Vector3:
	# Spread the capped supply across the playable city only, never into the empty landfill.
	var point := Vector3(rng.randf_range(-11.5, 107.5), 0.05, rng.randf_range(-29.0, 29.0))
	var attempts := 0
	while not _is_clear_trash_spawn(point) and attempts < 250:
		point = Vector3(rng.randf_range(-11.5, 107.5), 0.05, rng.randf_range(-29.0, 29.0))
		attempts += 1
	if not _is_clear_trash_spawn(point):
		return Vector3(-999.0, -999.0, -999.0)
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
	_refresh_waste_tank_inventory_label()
	_refresh_factory_machine_status()
	_update_missions()
	# Keep upgrade affordability colors in sync whenever the wallet changes.
	_refresh_upgrade_prices()

func _set_message(value: String) -> void:
	# Temporary yellow toast messages below the mission panel are disabled.
	if is_instance_valid(message_label):
		message_label.text = ""
		message_label.visible = false


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
			return final_zone_cleaned >= FINAL_ZONE_MISSION_TARGET
		19:
			return ground_robot_level >= 1
		20:
			return sorting_robot_upgrade_level >= 1
		21:
			return conveyor_speed_upgrade_level >= 1
		22:
			return factory_total_products_made >= 1
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
		31:
			return factory_waste_deposited_total >= 3
	return false


func _update_missions() -> void:
	if not is_instance_valid(mission_label):
		return
	# One clear next action at a time. Completed steps disappear permanently.
	var previous_stage := tutorial_mission_stage
	while tutorial_mission_stage < MISSION_ORDER.size() and _mission_is_complete(MISSION_ORDER[tutorial_mission_stage]):
		tutorial_mission_stage += 1
	if tutorial_mission_stage != previous_stage:
		_save_game()
	if world_initialized and tutorial_mission_stage >= 29 and not final_cleanup_spawned:
		final_cleanup_spawned = true
		_spawn_final_cleanup_trash()
		_set_message("FINAL LANDFILL UNLOCKED — clear the endgame waste piles.")
		_save_game()

	var mission_texts: Array[String] = [
		"Collect 5 pieces of litter.\nUse COLLECT near the rubbish.",
		"Empty your backpack.\nGo to the YELLOW recycling pad and wait until the bag is empty.",
		"Buy your first upgrade.\nOpen UPGRADES and choose one item you can afford.",
		"Recruit a helper drone.\nUPGRADES → FLEET → HELPER DRONES.",
		"Collect 25 pieces of litter.\nProgress: %d / 25" % mini(total_trash_collected, 25),
		"Increase backpack capacity.\nUPGRADES → ROBOT → BACKPACK CAPACITY.",
		"Increase movement speed.\nUPGRADES → ROBOT → MOVEMENT SPEED.",
		"Increase pickup range.\nUPGRADES → ROBOT → PICKUP RANGE.",
		"Unlock automatic pickup.\nUPGRADES → ROBOT → AUTO PICKUP.",
		"Unlock automatic litter respawn.\nUPGRADES → ECONOMY → AUTO RESPAWN.",
		"Improve recycling technology.\nOpen UPGRADES and improve recycling value technology.",
		"",
		"Expand the recycling factory.\nFind the factory upgrade marker and stand on it to pay.",
		"Improve truck dispatch frequency.\nUPGRADES → FLEET → TRUCK FREQUENCY.",
		"Increase delivery truck capacity.\nUPGRADES → FLEET → TRUCK CAPACITY.",
		"Speed up package preparation.\nUPGRADES → FLEET → PACKAGING SPEED.",
		"Build factory waste storage.\nGo to the marked tank pad. It costs 120 ZC.",
		"Collect 100 pieces of litter.\nProgress: %d / 100" % mini(total_trash_collected, 100),
		"Clean the final landfill.\nRecycle 1,000 pieces there. Progress: %d / %d" % [mini(final_zone_cleaned, FINAL_ZONE_MISSION_TARGET), FINAL_ZONE_MISSION_TARGET],
		"Build a ground collector robot.\nUPGRADES → ROBOT → GROUND COLLECTOR.",
		"Improve sorting robots.\nUPGRADES → FACTORY → SORTING ROBOT EFFICIENCY.",
		"Speed up factory conveyors.\nUPGRADES → FACTORY → CONVEYOR & FACTORY SPEED.",
		"Make your first recycled product.\nWait while the conveyor feeds the first machine.",
		"Build the next machine.\nStand on the next marked factory pad until construction finishes.",
		"Expand delivery operations.\nUPGRADES → FLEET → HIRE TRUCKS.",
		"Collect multiple pieces at once.\nUPGRADES → ROBOT → MULTI-PICKUP.",
		"Upgrade your collection tool.\nReach MAGNET POWER level 2 or unlock VACUUM.",
		"Unlock valuable rare finds.\nUPGRADES → ECONOMY → SILVER & GOLD FINDS.",
		"Improve your luck.\nUPGRADES → ECONOMY → LUCK.",
		"Keep litter replenishing.\nUpgrade AUTO RESPAWN to level 2.",
		"Become the MASTER CLEANER.\nCollect 1,000 pieces. Progress: %d / 1,000" % mini(total_trash_collected, 1000),
		"Load the factory.\nCarry litter to the storage tank and deposit at least 3 pieces."
	]
	var mission_title := mission_label.get_parent().get_node_or_null("MissionTitle")
	if tutorial_mission_stage < MISSION_ORDER.size():
		var mission_id: int = MISSION_ORDER[tutorial_mission_stage]
		mission_label.text = mission_texts[mission_id]
		if is_instance_valid(mission_title):
			mission_title.text = "NEXT STEP  •  %d / %d" % [tutorial_mission_stage + 1, MISSION_ORDER.size()]
	else:
		mission_label.text = "All core steps complete!\nKeep expanding your recycling city."
		if is_instance_valid(mission_title):
			mission_title.text = "CITY OPERATIONS"
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
	# Pause new factory input while the machinery is broken.
	if machine_broken or not waste_tank_built or waste_feed_busy or waste_tank_inventory <= 0:
		return
	waste_feed_timer += delta
	if waste_feed_timer < 0.55 / _waste_tank_discharge_multiplier():
		return
	waste_feed_timer = 0.0
	var active_rows: Array[int] = []
	for row in range(5):
		if mega_factory_built_count >= row * 3 + 1 and factory_row_input_stock[row] < FACTORY_INPUT_CAPACITY_PER_ROW:
			active_rows.append(row)
	if active_rows.is_empty():
		return
	var selected_row := active_rows[waste_feed_line_index % active_rows.size()]
	waste_feed_line_index += 1
	waste_tank_inventory -= 1
	_refresh_waste_tank_inventory_label()
	var selected_item := Node3D.new()
	selected_item.name = "FactoryWasteConveyorItem"
	selected_item.set_script(TRASH_SCRIPT)
	# Place litter just above the physical belt surface (top y=0.965).
	selected_item.position = Vector3(128.55, 0.99, 0.0)
	add_child(selected_item)
	waste_feed_busy = true
	var target_z := _factory_row_z(selected_row)
	var belt_y := 0.99
	var has_end_bend := selected_row == 0 or selected_row == 4
	var bend_radius := 1.15
	var bend_start_z := target_z - bend_radius
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	# Follow the physical trunk belt from the tank to the distributor at a steady pace.
	tween.tween_property(selected_item, "global_position", Vector3(137.0, belt_y, 0.0), 0.8 / (_conveyor_speed_multiplier() * _waste_tank_discharge_multiplier()))
	tween.tween_property(selected_item, "global_position", Vector3(146.4, belt_y, 0.0), 0.9 / (_conveyor_speed_multiplier() * _waste_tank_discharge_multiplier()))
	# Travel down the distributor. Only the first and last rows have a physical elbow.
	if has_end_bend:
		tween.tween_property(selected_item, "global_position", Vector3(147.0, belt_y, bend_start_z), maxf(0.35, absf(bend_start_z) / 12.0) / (_conveyor_speed_multiplier() * _waste_tank_discharge_multiplier()))
		for bend_i in range(1, 13):
			var angle := (float(bend_i) / 12.0) * PI * 0.5
			var bend_point := Vector3(147.0 + bend_radius * (1.0 - cos(angle)), belt_y, bend_start_z + bend_radius * sin(angle))
			tween.tween_property(selected_item, "global_position", bend_point, 0.045 / (_conveyor_speed_multiplier() * _waste_tank_discharge_multiplier()))
	else:
		tween.tween_property(selected_item, "global_position", Vector3(147.0, belt_y, target_z), maxf(0.35, absf(target_z) / 12.0) / (_conveyor_speed_multiplier() * _waste_tank_discharge_multiplier()))
	# All rows then use a straight branch belt into the first machine.
	tween.tween_property(selected_item, "global_position", Vector3(148.65, belt_y, target_z), 0.35 / (_conveyor_speed_multiplier() * _waste_tank_discharge_multiplier()))
	tween.tween_callback(_finish_waste_feed_item.bind(selected_item, selected_row))

func _finish_waste_feed_item(item: Node3D, row: int) -> void:
	if not is_instance_valid(item):
		waste_feed_busy = false
		return
	item.queue_free()
	if row >= 0 and row < factory_row_input_stock.size():
		factory_row_input_stock[row] += 1
	waste_feed_busy = false
	_refresh_factory_machine_status()
	_save_game()

func _process_factory_production(delta: float) -> void:
	# A breakdown stops all factory processing until repairs are completed.
	if machine_broken:
		return
	# Each machine has its own input/output stage. A machine only transforms
	# material into the product that belongs to its recycling line.
	factory_production_timer += delta
	if factory_production_timer < 1.2:
		return
	factory_production_timer = 0.0
	for row in range(5):
		var first_machine := row * 3 + 1
		if mega_factory_built_count < first_machine:
			continue
		# Machine 3: turn processed material into the finished line product.
		if mega_factory_built_count >= first_machine + 2 and factory_row_stage2_stock[row] > 0 and factory_row_product_stock[row] < FACTORY_PRODUCT_CAPACITY_PER_ROW:
			factory_row_stage2_stock[row] -= 1
			factory_row_product_stock[row] += 1
			factory_total_products_made += 1
			_animate_factory_stage_item(row, 2)
			_set_message("%s: %s finished and sent to the loading belt. Waiting: %d" % [_factory_row_machine_name(row, 2), _factory_row_product(row), factory_row_product_stock[row]])
			_update_missions()
			_save_game()
		# Machine 2: transform the first machine's output into refined components.
		if mega_factory_built_count >= first_machine + 1 and factory_row_stage1_stock[row] > 0 and factory_row_stage2_stock[row] < FACTORY_PRODUCT_CAPACITY_PER_ROW:
			factory_row_stage1_stock[row] -= 1
			factory_row_stage2_stock[row] += 1
			_animate_factory_stage_item(row, 1)
			_set_message("%s: refined %s into processed components. In process: %d" % [_factory_row_machine_name(row, 1), _factory_row_product(row), factory_row_stage2_stock[row]])
			_save_game()
		# Machine 1: convert three pieces of incoming waste into line-specific raw material.
		if factory_row_input_stock[row] >= 3 and factory_row_stage1_stock[row] < FACTORY_PRODUCT_CAPACITY_PER_ROW:
			factory_row_input_stock[row] -= 3
			factory_row_stage1_stock[row] += 1
			_animate_factory_stage_item(row, 0)
			_set_message("%s: converted 3 waste pieces into %s raw material. Ready: %d" % [_factory_row_machine_name(row, 0), _factory_row_product(row), factory_row_stage1_stock[row]])
			_save_game()
	_refresh_factory_machine_status()

func _clear_factory_row_belt_visuals(row: int) -> void:
	if row < 0 or row >= 5:
		return
	for item in factory_row_belt_items[row]:
		if is_instance_valid(item):
			item.queue_free()
	factory_row_belt_items[row].clear()

func _animate_factory_stage_item(row: int, stage: int) -> void:
	_spawn_factory_stage_item(row, stage, false)

func _spawn_factory_stage_item(row: int, stage: int, at_loading_end: bool = false) -> void:
	if row < 0 or row >= 5:
		return
	var item := Node3D.new()
	item.name = "FactorySpecificProduct_%d_%d" % [row, stage]
	item.position = Vector3(0.0, 0.99, _factory_row_z(row))
	item.scale = Vector3.ONE * 0.78
	_build_factory_specific_product(item, row, stage)
	add_child(item)
	var first_machine := row * 3 + 1
	var next_machine_exists := not at_loading_end and stage < 2 and mega_factory_built_count >= first_machine + stage + 1
	var stage_start_x := 153.8 + float(stage) * 13.0 + 5.0
	var target_x := 198.0
	var target_z := _factory_row_z(row)
	if next_machine_exists:
		# Intermediate material travels to the next machine's input, not to the truck.
		target_x = 151.0 + float(stage + 1) * 13.0 - 2.2
	else:
		var queue: Array = factory_row_belt_items[row]
		var item_index := queue.size()
		queue.append(item)
		factory_row_belt_items[row] = queue
		var lane := (item_index % 3) - 1
		var slot := int(item_index / 3)
		target_x = maxf(150.0, 198.0 - float(slot) * 1.05)
		target_z += float(lane) * 0.38
	var target := Vector3(target_x, 0.99, target_z)
	if at_loading_end:
		item.position = target
	else:
		item.position = Vector3(stage_start_x, 0.99, _factory_row_z(row))
		var travel := create_tween()
		travel.set_trans(Tween.TRANS_SINE)
		travel.set_ease(Tween.EASE_IN_OUT)
		travel.tween_property(item, "position", target, maxf(1.0, absf(target_x - stage_start_x) / (8.0 * _conveyor_speed_multiplier())))
		if next_machine_exists:
			travel.tween_callback(item.queue_free)
		else:
			travel.tween_callback(func():
				if is_instance_valid(item):
					item.position = target
			)

func _build_factory_specific_product(root: Node3D, row: int, stage: int) -> void:
	var body_color := [
		[Color(0.18, 0.72, 0.62), Color(0.12, 0.58, 0.48), Color(0.10, 0.78, 0.66)],
		[Color(0.70, 0.48, 0.25), Color(0.78, 0.61, 0.36), Color(0.62, 0.40, 0.20)],
		[Color(0.42, 0.48, 0.52), Color(0.60, 0.66, 0.68), Color(0.28, 0.36, 0.42)],
		[Color(0.30, 0.70, 0.82), Color(0.16, 0.62, 0.78), Color(0.42, 0.82, 0.90)],
		[Color(0.16, 0.42, 0.30), Color(0.22, 0.52, 0.38), Color(0.12, 0.30, 0.24)]
	]
	var accent: Color = body_color[clampi(row, 0, 4)][clampi(stage, 0, 2)]
	var dark: Color = accent.darkened(0.48)
	match row:
		0:
			if stage == 0:
				for i in range(5):
					var chip := BoxMesh.new()
					chip.size = Vector3(0.30, 0.16, 0.24)
					_factory_product_part(root, chip, Vector3(float(i % 3) * 0.20 - 0.20, 0.05, float(i / 3) * 0.20 - 0.10), accent, Vector3(0.0, float(i) * 0.31, 0.12))
			elif stage == 1:
				for i in range(4):
					var pellet := CylinderMesh.new()
					pellet.top_radius = 0.13
					pellet.bottom_radius = 0.13
					pellet.height = 0.34
					_factory_product_part(root, pellet, Vector3(float(i % 2) * 0.28 - 0.14, 0.05, float(i / 2) * 0.25 - 0.12), accent, Vector3(PI * 0.5, 0.0, 0.0))
			else:
				_factory_add_bottle_product(root, accent, dark)
		1:
			if stage == 0:
				for i in range(3):
					var sheet := BoxMesh.new()
					sheet.size = Vector3(0.78, 0.035, 0.54)
					_factory_product_part(root, sheet, Vector3(0.0, float(i) * 0.06, 0.0), accent, Vector3(0.0, 0.0, float(i - 1) * 0.05))
			elif stage == 1:
				for i in range(4):
					var sheet := BoxMesh.new()
					sheet.size = Vector3(0.82, 0.045, 0.62)
					_factory_product_part(root, sheet, Vector3(0.0, float(i) * 0.07, 0.0), accent, Vector3.ZERO)
			else:
				var carton := BoxMesh.new()
				carton.size = Vector3(0.78, 0.62, 0.72)
				_factory_product_part(root, carton, Vector3.ZERO, accent)
				var seam := BoxMesh.new()
				seam.size = Vector3(0.08, 0.64, 0.74)
				_factory_product_part(root, seam, Vector3(0.0, 0.0, 0.0), dark)
		2:
			if stage == 0:
				for i in range(3):
					var scrap := BoxMesh.new()
					scrap.size = Vector3(0.72, 0.16, 0.18)
					_factory_product_part(root, scrap, Vector3(0.0, float(i) * 0.11, float(i - 1) * 0.16), accent, Vector3(0.0, 0.0, float(i - 1) * 0.18))
			elif stage == 1:
				for i in range(3):
					var ingot := BoxMesh.new()
					ingot.size = Vector3(0.60, 0.22, 0.34)
					_factory_product_part(root, ingot, Vector3(float(i - 1) * 0.18, float(i % 2) * 0.12, 0.0), accent, Vector3(0.0, 0.0, 0.0))
			else:
				var gear := CylinderMesh.new()
				gear.top_radius = 0.36
				gear.bottom_radius = 0.36
				gear.height = 0.20
				_factory_product_part(root, gear, Vector3.ZERO, accent, Vector3(PI * 0.5, 0.0, 0.0))
				var hub := CylinderMesh.new()
				hub.top_radius = 0.12
				hub.bottom_radius = 0.12
				hub.height = 0.24
				_factory_product_part(root, hub, Vector3(0.0, 0.0, -0.02), dark, Vector3(PI * 0.5, 0.0, 0.0))
		3:
			if stage == 0:
				for i in range(4):
					var shard := BoxMesh.new()
					shard.size = Vector3(0.48, 0.10, 0.18)
					_factory_product_part(root, shard, Vector3(float(i % 2) * 0.24 - 0.12, 0.02, float(i / 2) * 0.22 - 0.11), accent, Vector3(0.0, float(i) * 0.4, float(i - 2) * 0.15))
			elif stage == 1:
				var molten := SphereMesh.new()
				molten.radius = 0.32
				molten.height = 0.58
				_factory_product_part(root, molten, Vector3.ZERO, accent)
			else:
				_factory_add_bottle_product(root, accent, dark)
		4:
			if stage == 0:
				var board := BoxMesh.new()
				board.size = Vector3(0.78, 0.08, 0.58)
				_factory_product_part(root, board, Vector3.ZERO, accent)
				for i in range(4):
					var chip := BoxMesh.new()
					chip.size = Vector3(0.16, 0.12, 0.14)
					_factory_product_part(root, chip, Vector3(float(i % 2) * 0.32 - 0.16, 0.08, float(i / 2) * 0.22 - 0.11), dark)
			elif stage == 1:
				var module := BoxMesh.new()
				module.size = Vector3(0.68, 0.28, 0.52)
				_factory_product_part(root, module, Vector3.ZERO, accent)
				var chip := BoxMesh.new()
				chip.size = Vector3(0.24, 0.12, 0.22)
				_factory_product_part(root, chip, Vector3(0.0, 0.18, 0.0), dark)
			else:
				var device := BoxMesh.new()
				device.size = Vector3(0.82, 0.46, 0.62)
				_factory_product_part(root, device, Vector3.ZERO, dark)
				var screen := BoxMesh.new()
				screen.size = Vector3(0.60, 0.035, 0.40)
				_factory_product_part(root, screen, Vector3(0.0, 0.25, 0.0), accent)

func _factory_product_part(parent: Node3D, mesh: Mesh, local_position: Vector3, color: Color, local_rotation: Vector3 = Vector3.ZERO) -> void:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.position = local_position
	part.rotation = local_rotation
	part.material_override = _mat(color)
	parent.add_child(part)

func _factory_add_bottle_product(parent: Node3D, color: Color, cap_color: Color) -> void:
	for bottle_index in range(2):
		var offset := Vector3(float(bottle_index) * 0.34 - 0.17, 0.0, 0.0)
		var body := CylinderMesh.new()
		body.top_radius = 0.17
		body.bottom_radius = 0.20
		body.height = 0.56
		_factory_product_part(parent, body, offset, color)
		var neck := CylinderMesh.new()
		neck.top_radius = 0.075
		neck.bottom_radius = 0.09
		neck.height = 0.16
		_factory_product_part(parent, neck, offset + Vector3(0.0, 0.34, 0.0), color)
		var cap := CylinderMesh.new()
		cap.top_radius = 0.085
		cap.bottom_radius = 0.085
		cap.height = 0.07
		_factory_product_part(parent, cap, offset + Vector3(0.0, 0.45, 0.0), cap_color)

func _animate_conveyor(delta: float) -> void:
	var conveyor_speed := _conveyor_speed_multiplier()
	conveyor_time += delta * conveyor_speed
	for roller in conveyor_rollers:
		if is_instance_valid(roller):
			# The cylinder's local Y axis is its axle after its placement rotation.
			roller.rotate_object_local(Vector3.UP, delta * 5.0 * conveyor_speed)
	for slat in factory_conveyor_slats:
		if is_instance_valid(slat):
			var belt_start := float(slat.get_meta("factory_belt_start", 148.0))
			var belt_length := float(slat.get_meta("factory_belt_length", 49.0))
			var phase := float(slat.get_meta("factory_belt_phase", 0.0))
			var travel_position := belt_start + fposmod(phase + conveyor_time * 2.6, belt_length)
			if str(slat.get_meta("factory_belt_axis", "x")) == "z":
				slat.position.z = travel_position
			else:
				slat.position.x = travel_position
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
	for truck in delivery_trucks:
		if not is_instance_valid(truck):
			continue
		var previous_position: Vector3 = truck.get_meta("previous_position", truck.global_position)
		var travel_distance := truck.global_position.distance_to(previous_position)
		if travel_distance > 0.0001:
			for wheel in truck.get_meta("wheels", []):
				if is_instance_valid(wheel):
					wheel.rotate_object_local(Vector3.UP, travel_distance * 2.1)
		truck.set_meta("previous_position", truck.global_position)
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
	# Add maintenance-access and structural detail without cluttering the belt path.
	for side in [-1.0, 1.0]:
		_box_child(base, "ConveyorOuterFrame", Vector3(side * 0.53, -0.02, 0), Vector3(0.08, 0.12, length - 0.22), Color(0.38, 0.44, 0.45))
		_box_child(base, "ConveyorSafetyStripe", Vector3(side * 0.68, 0.50, 0), Vector3(0.055, 0.025, length * 0.82), Color(0.96, 0.65, 0.17))
		for support_i in range(0, 9, 2):
			var brace_z := -length * 0.5 + length * float(support_i + 1) / 10.0
			_box_child(base, "SupportBrace", Vector3(side * 0.40, -0.55, brace_z), Vector3(0.10, 0.10, 0.22), Color(0.35, 0.40, 0.42))
	_box_child(base, "ConveyorServicePlate", Vector3(0, 0.16, -length * 0.40), Vector3(0.48, 0.04, 0.24), Color(0.44, 0.51, 0.51))

func _delivery_truck_box(parent: Node3D, part_name: String, local_position: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = part_name
	var part_mesh := BoxMesh.new()
	part_mesh.size = size
	part.mesh = part_mesh
	part.position = local_position
	part.material_override = _mat(color)
	parent.add_child(part)
	return part


func _delivery_truck_cylinder(parent: Node3D, part_name: String, local_position: Vector3, radius: float, height: float, color: Color, rotation: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = part_name
	var part_mesh := CylinderMesh.new()
	part_mesh.top_radius = radius
	part_mesh.bottom_radius = radius
	part_mesh.height = height
	part_mesh.radial_segments = 10
	part.mesh = part_mesh
	part.position = local_position
	part.rotation_degrees = rotation
	part.material_override = _mat(color)
	parent.add_child(part)
	return part


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
	cargo.material_override = _mat(Color(0.61, 0.68, 0.68))
	truck.add_child(cargo)
	var cab := MeshInstance3D.new()
	var cab_mesh := BoxMesh.new()
	cab_mesh.size = Vector3(1.65, 1.65, 2.8)
	cab.mesh = cab_mesh
	cab.position = Vector3(-2.1, 1.35, 0.0)
	cab.material_override = _mat(Color(0.91, 0.55, 0.13))
	truck.add_child(cab)
	var windshield := MeshInstance3D.new()
	var windshield_mesh := BoxMesh.new()
	windshield_mesh.size = Vector3(0.06, 0.72, 1.55)
	windshield.mesh = windshield_mesh
	windshield.position = Vector3(-3.0, 1.65, 0.0)
	windshield.material_override = _mat(Color(0.12, 0.23, 0.29))
	truck.add_child(windshield)
	var truck_wheels: Array[Node3D] = []
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
			truck_wheels.append(wheel)
			_delivery_truck_cylinder(truck, "DeliveryTruckWheelHub", Vector3(wheel_x, 0.48, wheel_z + signf(wheel_z) * 0.13), 0.18, 0.055, Color(0.54, 0.60, 0.58), Vector3(90.0, 0.0, 0.0))
			_delivery_truck_box(truck, "DeliveryTruckMudguard", Vector3(wheel_x, 0.96, wheel_z), Vector3(0.94, 0.10, 0.20), Color(0.23, 0.30, 0.32))
	_delivery_truck_box(truck, "DeliveryTruckChassis", Vector3(0.0, 0.48, 0.0), Vector3(6.45, 0.28, 2.50), Color(0.10, 0.15, 0.17))
	for side in [-1.0, 1.0]:
		_delivery_truck_box(truck, "DeliveryTruckCargoRail", Vector3(0.0, 2.37, side * 1.54), Vector3(3.55, 0.12, 0.10), Color(0.29, 0.37, 0.39))
		_delivery_truck_box(truck, "DeliveryTruckReflectiveStripe", Vector3(0.0, 0.78, side * 1.56), Vector3(3.22, 0.16, 0.045), Color(0.96, 0.65, 0.15))
		_delivery_truck_box(truck, "DeliveryTruckSideStep", Vector3(-1.85, 0.48, side * 1.55), Vector3(0.78, 0.12, 0.25), Color(0.16, 0.22, 0.24))
		for rib_x in [-1.45, -0.72, 0.0, 0.72, 1.45]:
			_delivery_truck_box(truck, "DeliveryTruckCargoRib", Vector3(rib_x, 1.45, side * 1.54), Vector3(0.075, 1.48, 0.065), Color(0.39, 0.47, 0.48))
		_delivery_truck_box(truck, "DeliveryTruckMirrorArm", Vector3(-2.45, 1.78, side * 1.52), Vector3(0.12, 0.06, 0.32), Color(0.18, 0.25, 0.27))
		_delivery_truck_box(truck, "DeliveryTruckMirror", Vector3(-2.45, 1.88, side * 1.70), Vector3(0.20, 0.25, 0.08), Color(0.10, 0.17, 0.19))
		_delivery_truck_box(truck, "DeliveryTruckDoorPlate", Vector3(-2.05, 1.36, side * 1.43), Vector3(0.86, 0.70, 0.045), Color(0.98, 0.66, 0.18))
		_delivery_truck_box(truck, "DeliveryTruckDoorHandle", Vector3(-1.74, 1.43, side * 1.47), Vector3(0.16, 0.055, 0.035), Color(0.15, 0.20, 0.22))
	_delivery_truck_box(truck, "DeliveryTruckFrontGrille", Vector3(-3.02, 1.05, 0.0), Vector3(0.08, 0.48, 1.15), Color(0.08, 0.12, 0.14))
	_delivery_truck_box(truck, "DeliveryTruckFrontBumper", Vector3(-3.13, 0.54, 0.0), Vector3(0.24, 0.18, 2.35), Color(0.28, 0.35, 0.37))
	_delivery_truck_box(truck, "DeliveryTruckFrontPlate", Vector3(-3.26, 0.43, 0.0), Vector3(0.035, 0.13, 0.55), Color(0.13, 0.56, 0.53))
	for headlight_z in [-0.94, 0.94]:
		_delivery_truck_box(truck, "DeliveryTruckHeadlight", Vector3(-3.05, 1.56, headlight_z), Vector3(0.08, 0.22, 0.34), Color(0.96, 0.86, 0.58))
		_delivery_truck_box(truck, "DeliveryTruckRearLight", Vector3(1.82, 0.78, headlight_z), Vector3(0.08, 0.30, 0.22), Color(0.80, 0.12, 0.08))
	_delivery_truck_box(truck, "DeliveryTruckRearDoor", Vector3(1.79, 1.44, 0.0), Vector3(0.08, 1.55, 2.55), Color(0.40, 0.48, 0.48))
	_delivery_truck_box(truck, "DeliveryTruckRearDoorSplit", Vector3(1.84, 1.44, 0.0), Vector3(0.035, 1.45, 0.045), Color(0.12, 0.19, 0.21))
	_delivery_truck_box(truck, "DeliveryTruckRearHazardStripe", Vector3(1.86, 0.68, 0.0), Vector3(0.035, 0.16, 2.38), Color(0.95, 0.64, 0.14))
	# Premium fleet finish: reinforced cargo locks, tie-down rails, reflective
	# corner guards and service hardware make the loading body read as real machinery.
	for side in [-1.0, 1.0]:
		_delivery_truck_box(truck, "DeliveryTruckUpperCornerGuard", Vector3(0.0, 2.25, side * 1.60), Vector3(3.35, 0.08, 0.08), Color(0.48, 0.56, 0.56))
		_delivery_truck_box(truck, "DeliveryTruckLowerRubRail", Vector3(0.0, 0.93, side * 1.61), Vector3(3.25, 0.10, 0.08), Color(0.16, 0.24, 0.26))
		for lock_x in [-1.48, 1.48]:
			_delivery_truck_box(truck, "DeliveryTruckCargoLatch", Vector3(lock_x, 1.18, side * 1.64), Vector3(0.13, 0.24, 0.07), Color(0.70, 0.75, 0.70))
		for marker_x in [-1.15, -0.38, 0.38, 1.15]:
			_delivery_truck_box(truck, "DeliveryTruckReflector", Vector3(marker_x, 0.83, side * 1.665), Vector3(0.24, 0.07, 0.025), Color(0.98, 0.72, 0.20))
	for tie_x in [-1.18, 1.18]:
		_delivery_truck_box(truck, "DeliveryTruckCargoTieDown", Vector3(tie_x, 2.12, 0.0), Vector3(0.10, 0.07, 2.85), Color(0.12, 0.18, 0.20))
		_delivery_truck_box(truck, "DeliveryTruckTieDownAnchor", Vector3(tie_x, 0.90, 0.0), Vector3(0.16, 0.10, 0.16), Color(0.72, 0.76, 0.70))
	_delivery_truck_box(truck, "DeliveryTruckCabRoofPanel", Vector3(-2.08, 2.20, 0.0), Vector3(1.20, 0.08, 1.85), Color(0.70, 0.39, 0.10))
	_delivery_truck_box(truck, "DeliveryTruckFrontStep", Vector3(-2.10, 0.52, 1.58), Vector3(0.85, 0.12, 0.18), Color(0.24, 0.31, 0.33))
	_delivery_truck_box(truck, "DeliveryTruckFrontStep", Vector3(-2.10, 0.52, -1.58), Vector3(0.85, 0.12, 0.18), Color(0.24, 0.31, 0.33))
	_delivery_truck_cylinder(truck, "DeliveryTruckRoofBeacon", Vector3(-2.0, 2.25, 0.0), 0.14, 0.22, Color(0.98, 0.58, 0.12))
	var sign := Label3D.new()
	sign.text = "ZEKA LOGISTICS  #%d" % (index + 1)
	sign.position = Vector3(0.0, 2.45, 1.52)
	sign.font_size = 22
	sign.pixel_size = 0.012
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sign.modulate = Color(0.12, 0.20, 0.18)
	truck.add_child(sign)
	truck.set_meta("wheels", truck_wheels)
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
		# Trucks face local -X. Reset their heading before driving into the dock.
		truck.rotation.y = 0.0
		dispatch_trucks_remaining += 1
		var dock_z := 30.25 + (float(index) - float(_truck_fleet_size() - 1) * 0.5) * 3.1
		var arrive := create_tween()
		arrive.set_trans(Tween.TRANS_SINE)
		arrive.set_ease(Tween.EASE_OUT)
		arrive.tween_property(truck, "position", Vector3(12.2, 0.0, dock_z), 1.8)
		arrive.tween_callback(_load_next_teddy_package.bind(index, 0))
	# A stale fleet array must not leave shipping permanently locked.
	if dispatch_trucks_remaining == 0:
		shipping_active = false

func _finish_delivery_truck_dispatch() -> void:
	dispatch_trucks_remaining = maxi(0, dispatch_trucks_remaining - 1)
	if dispatch_trucks_remaining == 0:
		shipping_active = false

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
	# Spawn each package at the conveyor exit aligned with its own truck dock.
	# A fixed Z coordinate made upgraded fleet trucks receive packages diagonally.
	var dock_z := 30.25 + (float(truck_index) - float(_truck_fleet_size() - 1) * 0.5) * 3.1
	package.position = Vector3(9.45, 1.05, dock_z)
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
		_finish_delivery_truck_dispatch()
		return
	var truck := delivery_trucks[truck_index]
	if is_instance_valid(truck):
		var depart := create_tween()
		depart.set_trans(Tween.TRANS_SINE)
		depart.set_ease(Tween.EASE_IN_OUT)
		# The truck arrived facing -X; turn it around before moving toward +X.
		depart.tween_property(truck, "rotation:y", PI, 0.75)
		depart.set_ease(Tween.EASE_IN)
		depart.tween_property(truck, "position:x", 17.4, 2.0)
		depart.tween_callback(_finish_delivery_truck_dispatch)
	else:
		_finish_delivery_truck_dispatch()

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
	# Heavy municipal steel bin with replaceable panels and reinforced corners.
	_box("StreetBinBody", pos + Vector3(0, 0.58, 0), Vector3(0.92, 1.12, 0.88), color.darkened(0.08), true)
	_box("StreetBinFront", pos + Vector3(0, 0.62, -0.455), Vector3(0.72, 0.72, 0.035), color.lightened(0.08), false)
	for x in [-0.40, 0.40]:
		_box("StreetBinCornerGuard", pos + Vector3(x, 0.60, -0.48), Vector3(0.075, 1.04, 0.07), Color(0.30, 0.37, 0.37), false)
	for y in [0.34, 0.70, 1.02]:
		_box("StreetBinReinforcementRib", pos + Vector3(0, y, -0.49), Vector3(0.80, 0.055, 0.045), Color(0.12, 0.19, 0.20), false)
	_box("StreetBinHazardBand", pos + Vector3(0, 0.36, -0.515), Vector3(0.76, 0.11, 0.025), Color(0.94, 0.62, 0.13), false)
	var lid := _box("StreetBinLid", pos + Vector3(0, 1.18, 0.0), Vector3(1.02, 0.16, 0.96), Color(0.055, 0.08, 0.09), false)
	lid.rotation_degrees.x = -3.0
	_box("StreetBinHingeBar", pos + Vector3(0, 1.20, 0.40), Vector3(0.72, 0.09, 0.10), Color(0.42, 0.49, 0.48), false)
	_box("StreetBinHandle", pos + Vector3(0, 1.28, -0.34), Vector3(0.34, 0.07, 0.12), Color(0.12, 0.15, 0.14), false)
	_box("StreetBinServicePlate", pos + Vector3(0, 0.88, -0.515), Vector3(0.42, 0.18, 0.025), Color(0.045, 0.08, 0.09), false)
	for x in [-0.34, 0.34]:
		var wheel := _cylinder("StreetBinWheel", pos + Vector3(x, 0.16, 0.36), 0.14, 0.11, Color(0.035, 0.04, 0.04), true)
		wheel.rotation_degrees.z = 90.0
		var hub := _cylinder("StreetBinWheelHub", pos + Vector3(x + signf(x) * 0.07, 0.16, 0.36), 0.065, 0.035, Color(0.48, 0.54, 0.52), false)
		hub.rotation_degrees.z = 90.0

func _make_bin(pos: Vector3, color: Color, label_text: String) -> void:
	# Wheeled commercial recycling container with sloped lid, molded ribs and handle.
	_box("BinBody", pos + Vector3(0, 0.72, 0), Vector3(1.42, 1.42, 1.35), color.darkened(0.06), true)
	_box("BinFrontPanel", pos + Vector3(0, 0.83, -0.69), Vector3(1.12, 0.86, 0.045), color.lightened(0.12), false)
	_box("BinHazardBand", pos + Vector3(0, 0.37, -0.72), Vector3(1.18, 0.12, 0.045), Color(0.94, 0.62, 0.13), false)
	_box("BinIntakeSlot", pos + Vector3(0, 1.57, -0.34), Vector3(0.82, 0.045, 0.68), Color(0.025, 0.04, 0.045), false)
	for side_x in [-0.70, 0.70]:
		_box("BinCornerArmor", pos + Vector3(side_x, 0.78, -0.64), Vector3(0.10, 1.35, 0.10), Color(0.36, 0.43, 0.43), false)
	for x in [-0.52, -0.26, 0.0, 0.26, 0.52]:
		_box("BinMoldedRib", pos + Vector3(x, 0.72, -0.725), Vector3(0.035, 1.05, 0.035), color.darkened(0.18), false)
	var lid := _box("BinLid", pos + Vector3(0, 1.48, 0.02), Vector3(1.58, 0.18, 1.48), Color(0.075, 0.11, 0.12), false)
	lid.rotation_degrees.x = -4
	_box("BinLidGrip", pos + Vector3(0, 1.60, -0.48), Vector3(0.55, 0.09, 0.16), Color(0.18, 0.22, 0.22), false)
	for x in [-0.53, 0.53]:
		var wheel := _cylinder("BinWheel", pos + Vector3(x, 0.20, 0.57), 0.23, 0.16, Color(0.035, 0.045, 0.05), true)
		wheel.rotation_degrees.z = 90.0
		var hub := _cylinder("BinWheelHub", pos + Vector3(x + signf(x) * 0.09, 0.20, 0.57), 0.10, 0.04, Color(0.50, 0.56, 0.55), false)
		hub.rotation_degrees.z = 90.0
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
		_build_neighborhood_tree(Vector3(district_x - 2.5, 0.0, park_z + 1.8))
		_build_neighborhood_tree(Vector3(district_x + 2.5, 0.0, park_z + 1.8))
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
		# Intersection cross-street paint removed; keep the curb stones only.



func _build_city_life_details() -> void:
	# Traffic signals at the main connected-road junctions; crosswalk paint is generated once elsewhere.
	for crossing_x in [16.0, 48.0, 80.0, 104.0]:
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
	var plaza := Vector3(94.5, 0, 13.0)
	_box("MarketSquareBase", plaza + Vector3(0, 0.055, 0), Vector3(6.0, 0.11, 10.0), Color(0.61, 0.59, 0.51), false)
	for x in range(92, 97, 2):
		_box("MarketSquarePaverLine", Vector3(float(x), 0.116, 13), Vector3(0.025, 0.008, 9.6), Color(0.45, 0.46, 0.42), false)
	for z in [8.0, 18.0]:
		_box("MarketSquareBorder", Vector3(94.5, 0.14, z), Vector3(6.0, 0.08, 0.12), Color(0.34, 0.37, 0.34), false)
	_cylinder("FountainLowerBasin", Vector3(94.5, 0.32, 13), 2.0, 0.48, Color(0.43, 0.48, 0.47), false)
	_cylinder("FountainWater", Vector3(94.5, 0.57, 13), 1.72, 0.06, Color(0.18, 0.55, 0.68), false)
	_cylinder("FountainColumn", Vector3(94.5, 0.92, 13), 0.34, 0.72, Color(0.68, 0.67, 0.60), false)
	_cylinder("FountainTopBowl", Vector3(94.5, 1.34, 13), 0.82, 0.18, Color(0.55, 0.61, 0.59), false)
	_cylinder("FountainJet", Vector3(94.5, 1.70, 13), 0.10, 0.62, Color(0.26, 0.66, 0.78), false)
	for corner in [Vector3(92.5, 0, 9), Vector3(96.5, 0, 9), Vector3(92.5, 0, 17), Vector3(96.5, 0, 17)]:
		_box("MarketPlanterStone", corner + Vector3(0, 0.35, 0), Vector3(1.8, 0.7, 1.5), Color(0.36, 0.38, 0.34), false)
		_cylinder("MarketPlanterShrub", corner + Vector3(0, 0.95, 0), 0.62, 0.9, Color(0.17, 0.37, 0.20), false)
	for bench in [Vector3(92, 0, 13), Vector3(96.5, 0, 13)]:
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
		for side_z in [-6.0, 6.0]:
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
