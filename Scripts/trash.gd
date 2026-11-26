extends Node3D
class_name TrashItem

var spin_speed := 0.0

func _ready() -> void:
	# Endgame pickups remain full visible TrashItems so the player can
	# actually approach and collect the marked 100-unit bundles.
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	spin_speed = rng.randf_range(-0.45, 0.45)
	# A subset of litter is bulky: it occupies two backpack slots and pays double.
	var is_bulky := rng.randf() < 0.10
	if is_bulky:
		set_meta("bulky", true)
		scale = Vector3(1.45, 1.45, 1.45)

	# Android uses one low-poly mesh per litter item to reduce draw calls.
	var item_roll := rng.randi_range(0, 31)
	_set_recycle_category(item_roll)
	if OS.get_name() == "Android":
		_make_mobile_trash(rng, item_roll)
		rotation.y = rng.randf_range(0.0, TAU)
		if has_meta("rare_type"):
			_add_rare_visual(String(get_meta("rare_type")))
		# Keep mobile litter static: 1,000 per-item _process callbacks add
		# avoidable CPU work on Android, while the low-poly meshes remain readable.
		spin_speed = 0.0
		set_process(false)
		return

	match item_roll:
		0:
			_make_plastic_bottle(rng)
		1:
			_make_crushed_can(rng)
		2:
			_make_paper_cup(rng)
		3:
			_make_food_wrapper(rng)
		4:
			_make_crumpled_paper(rng)
		5:
			_make_cardboard_scrap(rng)
		6:
			_make_battery(rng)
		7:
			_make_broken_glass(rng)
		8:
			_make_soda_bottle(rng)
		9:
			_make_old_shoe(rng)
		10:
			_make_gear(rng)
		11:
			_make_screws(rng)
		12:
			_make_wrench(rng)
		13:
			_make_newspaper(rng)
		14:
			_make_crushed_carton(rng)
		15:
			_make_food_box(rng)
		16:
			_make_rusted_pipe(rng)
		17:
			_make_circuit_board(rng)
		18:
			_make_broken_fan(rng)
		19:
			_make_scrap_spring(rng)
		20:
			_make_oil_can(rng)
		21:
			_make_banana_peel(rng)
		22:
			_make_plastic_bag(rng)
		23:
			_make_milk_carton(rng)
		24:
			_make_old_tire(rng)
		25:
			_make_paint_bucket(rng)
		26:
			_make_toy_blocks(rng)
		27:
			_make_glass_jar(rng)
		28:
			_make_takeaway_tray(rng)
		29:
			_make_cable_bundle(rng)
		30:
			_make_safety_helmet(rng)
		31:
			_make_old_television(rng)
	rotation.y = rng.randf_range(0.0, TAU)
	if has_meta("rare_type"):
		_add_rare_visual(String(get_meta("rare_type")))
	# The endgame contains 600 detailed clusters; keep them static to avoid
	# spending mobile frame time rotating every piece in the huge landfill.
	if has_meta("final_cleanup_units"):
		spin_speed = 0.0
		set_process(false)

func _set_recycle_category(item_roll: int) -> void:
	# The four color-coded recycling stations use material categories.
	if item_roll in [0, 3, 8, 22, 23, 26]:
		set_meta("recycle_category", "plastic")
	elif item_roll in [2, 4, 5, 13, 14, 15, 21, 28]:
		set_meta("recycle_category", "paper")
	elif item_roll in [7, 27]:
		set_meta("recycle_category", "glass")
	else:
		set_meta("recycle_category", "metal")


func _make_mobile_trash(rng: RandomNumberGenerator, item_roll: int) -> void:
	# One low-poly MeshInstance per item on Android keeps the city readable
	# without multiplying draw calls across the large live litter pool.
	var shape: Mesh
	var base_color := Color(0.48, 0.52, 0.50)
	var transparent := false
	var metallic := 0.16
	var visual_position := Vector3(0.0, 0.08, 0.0)
	var visual_rotation := Vector3.ZERO
	var visual_scale := Vector3.ONE

	match item_roll:
		0, 8:
			# A custom low-poly bottle profile keeps the mobile version recognisable:
			# molded shoulder, narrow neck, cap and a contrasting wrap label.
			shape = _mobile_bottle_mesh(item_roll)
			base_color = Color.WHITE
			visual_position.y = 0.18
		1:
			# Crushed aluminum can with pinched ends and irregular folded sidewalls.
			shape = _mobile_crushed_can_mesh(rng)
			base_color = Color.WHITE
			visual_position.y = 0.115
			visual_rotation.z = rng.randf_range(-0.16, 0.16)
			metallic = 0.68
		2:
			# Single-surface tapered takeaway cup with a rolled lip and paper sleeve.
			shape = _mobile_paper_cup_mesh()
			base_color = Color.WHITE
			visual_position.y = 0.015
			visual_rotation.z = rng.randf_range(-0.10, 0.10)
		3:
			shape = _mobile_food_wrapper_mesh(rng)
			base_color = Color.WHITE
			visual_position.y = 0.065
			visual_rotation.y = rng.randf_range(-0.45, 0.45)
		22:
			shape = _mobile_plastic_bag_mesh()
			base_color = Color.WHITE
			transparent = true
			visual_position.y = 0.025
			visual_rotation.y = rng.randf_range(0.0, TAU)
		4:
			shape = _mobile_crumpled_paper_mesh(rng)
			base_color = Color.WHITE
			visual_position.y = 0.025
			visual_rotation.y = rng.randf_range(0.0, TAU)
		13, 21, 28:
			var sheet := BoxMesh.new()
			sheet.size = Vector3(0.46, 0.045, 0.30)
			shape = sheet
			base_color = {
				3: Color(0.86, 0.26, 0.13),
				4: Color(0.83, 0.80, 0.68),
				13: Color(0.76, 0.73, 0.62),
				21: Color(0.88, 0.72, 0.13),
				22: Color(0.64, 0.78, 0.73, 0.76),
				28: Color(0.70, 0.72, 0.67)
			}[item_roll]
			transparent = item_roll == 22
			visual_position.y = 0.045
			visual_rotation.y = rng.randf_range(-0.5, 0.5)
		5:
			shape = _mobile_cardboard_scrap_mesh(rng)
			base_color = Color.WHITE
			visual_position.y = 0.035
			visual_rotation.y = rng.randf_range(0.0, TAU)
		26:
			shape = _mobile_toy_blocks_mesh(rng)
			base_color = Color.WHITE
			visual_position.y = 0.025
			visual_rotation.y = rng.randf_range(0.0, TAU)
		14, 15, 17:
			var crate := BoxMesh.new()
			crate.size = Vector3(0.42, 0.18, 0.32)
			shape = crate
			base_color = {
				14: Color(0.68, 0.49, 0.27),
				15: Color(0.72, 0.31, 0.14),
				17: Color(0.08, 0.34, 0.25),
				31: Color(0.22, 0.25, 0.25)
			}[item_roll]
			visual_position.y = 0.10
			if item_roll == 31:
				crate.size = Vector3(0.72, 0.48, 0.42)
				visual_position.y = 0.24
			elif item_roll == 17:
				crate.size = Vector3(0.48, 0.045, 0.34)
				visual_position.y = 0.045
				metallic = 0.32
		6:
			shape = _mobile_battery_mesh(rng)
			base_color = Color.WHITE
			visual_position.y = 0.025
			visual_rotation.z = rng.randf_range(-0.12, 0.12)
		20:
			var canister := CylinderMesh.new()
			canister.top_radius = 0.15
			canister.bottom_radius = 0.15
			canister.height = 0.38
			canister.radial_segments = 8
			shape = canister
			base_color = Color(0.20, 0.29, 0.27)
			visual_position.y = 0.19
			metallic = 0.36
		25:
			shape = _mobile_paint_bucket_mesh(rng)
			base_color = Color.WHITE
			visual_position.y = 0.015
			visual_rotation.y = rng.randf_range(0.0, TAU)
		7:
			shape = _mobile_broken_glass_mesh(rng)
			base_color = Color.WHITE
			transparent = true
			visual_position.y = 0.008
			visual_rotation.y = rng.randf_range(0.0, TAU)
		9:
			shape = _mobile_old_shoe_mesh()
			base_color = Color.WHITE
			visual_position.y = 0.015
			visual_rotation.y = rng.randf_range(0.0, TAU)
		24:
			shape = _mobile_tire_mesh()
			base_color = Color.WHITE
			visual_position.y = 0.40
			visual_rotation.x = PI * 0.5
			visual_rotation.z = rng.randf_range(-0.08, 0.08)
		10, 27, 29:
			var ring := TorusMesh.new()
			ring.inner_radius = 0.20 if item_roll != 27 else 0.25
			ring.outer_radius = 0.34 if item_roll != 27 else 0.43
			ring.rings = 8
			ring.ring_segments = 12
			shape = ring
			base_color = {
				10: Color(0.48, 0.43, 0.34),
				27: Color(0.45, 0.70, 0.64, 0.78),
				29: Color(0.13, 0.16, 0.18)
			}[item_roll]
			visual_position.y = 0.12
			visual_rotation.x = PI * 0.5
			transparent = item_roll == 27
			metallic = 0.30
		11, 12, 16:
			var tool := CylinderMesh.new()
			tool.top_radius = 0.055 if item_roll == 11 else 0.11
			tool.bottom_radius = tool.top_radius
			tool.height = 0.24 if item_roll == 11 else 0.62
			tool.radial_segments = 8
			shape = tool
			base_color = Color(0.62, 0.66, 0.65) if item_roll != 16 else Color(0.48, 0.29, 0.18)
			visual_position.y = 0.12
			visual_rotation.z = PI * 0.5
			metallic = 0.42
			if item_roll == 12:
				tool.height = 0.50
				tool.top_radius = 0.07
				tool.bottom_radius = 0.07
		18:
			var fan := CylinderMesh.new()
			fan.top_radius = 0.22
			fan.bottom_radius = 0.22
			fan.height = 0.08
			fan.radial_segments = 10
			shape = fan
			base_color = Color(0.51, 0.56, 0.55)
			visual_position.y = 0.06
			metallic = 0.38
		19:
			var spring := TorusMesh.new()
			spring.inner_radius = 0.075
			spring.outer_radius = 0.15
			spring.rings = 8
			spring.ring_segments = 10
			shape = spring
			base_color = Color(0.50, 0.54, 0.54)
			visual_position.y = 0.14
			visual_rotation.x = PI * 0.5
			metallic = 0.48
		23:
			var carton := BoxMesh.new()
			carton.size = Vector3(0.30, 0.42, 0.26)
			shape = carton
			base_color = Color(0.84, 0.85, 0.78)
			visual_position.y = 0.21
		27:
			shape = _mobile_glass_jar_mesh()
			base_color = Color(0.58, 0.80, 0.73, 0.42)
			transparent = true
			visual_position.y = 0.015
			visual_rotation.z = rng.randf_range(-0.10, 0.10)
		29:
			shape = _mobile_cable_bundle_mesh()
			base_color = Color.WHITE
			visual_position.y = 0.02
			visual_rotation.y = rng.randf_range(0.0, TAU)
		30:
			shape = _mobile_safety_helmet_mesh()
			base_color = Color.WHITE
			visual_position.y = 0.015
			visual_rotation.y = rng.randf_range(0.0, TAU)
		31:
			shape = _mobile_old_television_mesh(rng)
			base_color = Color.WHITE
			visual_position.y = 0.015
			visual_rotation.y = rng.randf_range(-0.12, 0.12)

	var visual := MeshInstance3D.new()
	visual.name = "MobileTrashVisual"
	visual.mesh = shape
	visual.position = visual_position
	visual.rotation = visual_rotation
	visual.scale = visual_scale
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := _material(base_color, transparent)
	material.metallic = metallic
	material.roughness = 0.72
	if item_roll in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 22, 24, 27, 29, 30, 31]:
		material.vertex_color_use_as_albedo = true
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
	visual.material_override = material
	add_child(visual)


func _mobile_bottle_mesh(item_roll: int) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var profile: Array[Vector2] = [
		Vector2(-0.39, 0.105), Vector2(-0.36, 0.14), Vector2(-0.29, 0.15),
		Vector2(-0.24, 0.17), Vector2(-0.12, 0.17), Vector2(0.12, 0.17),
		Vector2(0.20, 0.145), Vector2(0.24, 0.105), Vector2(0.29, 0.078),
		Vector2(0.35, 0.078), Vector2(0.36, 0.088), Vector2(0.43, 0.088)
	]
	var bottle_color := Color(0.13, 0.48, 0.36) if item_roll == 0 else Color(0.68, 0.16, 0.075)
	var label_color := Color(0.91, 0.88, 0.70) if item_roll == 0 else Color(0.96, 0.76, 0.43)
	var cap_color := Color(0.91, 0.70, 0.12)
	const SIDES := 8
	for ring in range(profile.size() - 1):
		var section_color := bottle_color
		if ring == 4 or ring == 5:
			section_color = label_color
		elif ring >= 9:
			section_color = cap_color
		for side in range(SIDES):
			var a0 := TAU * float(side) / float(SIDES)
			var a1 := TAU * float(side + 1) / float(SIDES)
			var p00 := Vector3(profile[ring].x, cos(a0) * profile[ring].y, sin(a0) * profile[ring].y)
			var p01 := Vector3(profile[ring].x, cos(a1) * profile[ring].y, sin(a1) * profile[ring].y)
			var p10 := Vector3(profile[ring + 1].x, cos(a0) * profile[ring + 1].y, sin(a0) * profile[ring + 1].y)
			var p11 := Vector3(profile[ring + 1].x, cos(a1) * profile[ring + 1].y, sin(a1) * profile[ring + 1].y)
			surface.set_color(section_color)
			surface.add_vertex(p00)
			surface.add_vertex(p01)
			surface.add_vertex(p10)
			surface.add_vertex(p01)
			surface.add_vertex(p11)
			surface.add_vertex(p10)
	surface.generate_normals()
	return surface.commit()


func _mobile_crushed_can_mesh(rng: RandomNumberGenerator) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	const SIDES := 10
	var phase := rng.randf_range(0.0, TAU)
	var rings: Array[Vector2] = [
		Vector2(-0.235, 0.045), Vector2(-0.205, 0.105),
		Vector2(-0.155, 0.125), Vector2(-0.085, 0.105),
		Vector2(-0.015, 0.092), Vector2(0.065, 0.115),
		Vector2(0.125, 0.082), Vector2(0.175, 0.065),
		Vector2(0.205, 0.105), Vector2(0.235, 0.045)
	]
	var palette: Array[Color] = [
		Color(0.43, 0.49, 0.52), Color(0.79, 0.83, 0.83),
		Color(0.59, 0.65, 0.67), Color(0.91, 0.92, 0.88)
	]
	for ring in range(rings.size() - 1):
		for side in range(SIDES):
			var a0 := TAU * float(side) / float(SIDES) + phase
			var a1 := TAU * float(side + 1) / float(SIDES) + phase
			var deform0 := 1.0 + 0.20 * sin(a0 * 3.0 + float(ring) * 1.7) + 0.10 * cos(a0 * 5.0 - float(ring))
			var deform1 := 1.0 + 0.20 * sin(a1 * 3.0 + float(ring) * 1.7) + 0.10 * cos(a1 * 5.0 - float(ring))
			var p00 := Vector3(rings[ring].x, cos(a0) * rings[ring].y * deform0, sin(a0) * rings[ring].y * deform0)
			var p01 := Vector3(rings[ring].x, cos(a1) * rings[ring].y * deform1, sin(a1) * rings[ring].y * deform1)
			var p10 := Vector3(rings[ring + 1].x, cos(a0) * rings[ring + 1].y * deform0, sin(a0) * rings[ring + 1].y * deform0)
			var p11 := Vector3(rings[ring + 1].x, cos(a1) * rings[ring + 1].y * deform1, sin(a1) * rings[ring + 1].y * deform1)
			var shade := palette[(ring + side + int(rng.randi_range(0, 1))) % palette.size()]
			surface.set_color(shade)
			surface.add_vertex(p00)
			surface.add_vertex(p01)
			surface.add_vertex(p10)
			surface.set_color(palette[(ring + side + 2) % palette.size()])
			surface.add_vertex(p01)
			surface.add_vertex(p11)
			surface.add_vertex(p10)
	surface.generate_normals()
	return surface.commit()


func _mobile_food_wrapper_mesh(rng: RandomNumberGenerator) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Sealed snack packet with a puffed centre, pinched crimped ends and foil folds.
	var profile: Array[Vector2] = [
		Vector2(-0.31, 0.035), Vector2(-0.275, 0.075),
		Vector2(-0.225, 0.105), Vector2(-0.13, 0.115),
		Vector2(0.045, 0.105), Vector2(0.19, 0.095),
		Vector2(0.255, 0.070), Vector2(0.31, 0.032)
	]
	const SIDES := 8
	var phase := rng.randf_range(0.0, TAU)
	var wrapper_colors: Array[Color] = [Color(0.88, 0.24, 0.12), Color(0.12, 0.43, 0.78), Color(0.91, 0.68, 0.12)]
	var wrapper_color: Color = wrapper_colors[rng.randi_range(0, 2)]
	for ring in range(profile.size() - 1):
		for side in range(SIDES):
			var a0 := TAU * float(side) / float(SIDES) + phase
			var a1 := TAU * float(side + 1) / float(SIDES) + phase
			var fold0: float = 1.0 + 0.13 * sin(a0 * 3.0 + float(ring) * 1.4)
			var fold1: float = 1.0 + 0.13 * sin(a1 * 3.0 + float(ring) * 1.4)
			var p00 := Vector3(profile[ring].x, cos(a0) * profile[ring].y * fold0, sin(a0) * profile[ring].y * fold0)
			var p01 := Vector3(profile[ring].x, cos(a1) * profile[ring].y * fold1, sin(a1) * profile[ring].y * fold1)
			var p10 := Vector3(profile[ring + 1].x, cos(a0) * profile[ring + 1].y * fold0, sin(a0) * profile[ring + 1].y * fold0)
			var p11 := Vector3(profile[ring + 1].x, cos(a1) * profile[ring + 1].y * fold1, sin(a1) * profile[ring + 1].y * fold1)
			var color: Color = Color(0.76, 0.79, 0.78) if ring == 0 or ring == profile.size() - 2 else wrapper_color
			if side % 3 == 0 and ring > 1 and ring < profile.size() - 2:
				color = color.lightened(0.16)
			surface.set_color(color)
			surface.add_vertex(p00)
			surface.add_vertex(p01)
			surface.add_vertex(p10)
			surface.add_vertex(p01)
			surface.add_vertex(p11)
			surface.add_vertex(p10)
	surface.generate_normals()
	return surface.commit()


func _mobile_plastic_bag_mesh() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	# One translucent, wrinkled sheet mesh with integrated loop handles.
	const GRID := 6
	for z_index in range(GRID):
		for x_index in range(GRID):
			var x0 := -0.245 + float(x_index) * 0.49 / float(GRID)
			var x1 := x0 + 0.49 / float(GRID)
			var z0 := -0.19 + float(z_index) * 0.38 / float(GRID)
			var z1 := z0 + 0.38 / float(GRID)
			var p00 := Vector3(x0, 0.055 + 0.025 * sin(x0 * 31.0 + z0 * 17.0), z0)
			var p01 := Vector3(x1, 0.055 + 0.025 * sin(x1 * 31.0 + z0 * 17.0), z0)
			var p10 := Vector3(x0, 0.055 + 0.025 * sin(x0 * 31.0 + z1 * 17.0), z1)
			var p11 := Vector3(x1, 0.055 + 0.025 * sin(x1 * 31.0 + z1 * 17.0), z1)
			var shade := Color(0.70, 0.84, 0.80, 0.72) if (x_index + z_index) % 3 else Color(0.88, 0.94, 0.89, 0.80)
			surface.set_color(shade)
			surface.add_vertex(p00)
			surface.add_vertex(p10)
			surface.add_vertex(p01)
			surface.add_vertex(p01)
			surface.add_vertex(p10)
			surface.add_vertex(p11)
	# Two raised, loop-shaped handles are part of the same mesh/surface.
	for side in [-1.0, 1.0]:
		var previous := Vector3(side * 0.12, 0.075, -0.11)
		for step in range(1, 13):
			var angle := PI * float(step) / 12.0
			var current := Vector3(side * (0.12 + 0.075 * sin(angle)), 0.075 + 0.16 * sin(angle), -0.11)
			var width := 0.018
			var a := previous + Vector3(-width, 0.0, 0.0)
			var b := previous + Vector3(width, 0.0, 0.0)
			var c := current + Vector3(-width, 0.0, 0.0)
			var d := current + Vector3(width, 0.0, 0.0)
			surface.set_color(Color(0.78, 0.90, 0.85, 0.82))
			surface.add_vertex(a)
			surface.add_vertex(c)
			surface.add_vertex(b)
			surface.add_vertex(b)
			surface.add_vertex(c)
			surface.add_vertex(d)
			previous = current
	surface.generate_normals()
	return surface.commit()


func _append_box_surface(surface: SurfaceTool, center: Vector3, size: Vector3, color: Color) -> void:
	var half: Vector3 = size * 0.5
	var corners: Array[Vector3] = [
		center + Vector3(-half.x, -half.y, -half.z), center + Vector3(half.x, -half.y, -half.z),
		center + Vector3(-half.x, half.y, -half.z), center + Vector3(half.x, half.y, -half.z),
		center + Vector3(-half.x, -half.y, half.z), center + Vector3(half.x, -half.y, half.z),
		center + Vector3(-half.x, half.y, half.z), center + Vector3(half.x, half.y, half.z)
	]
	var faces := [[0, 2, 1, 1, 2, 3], [4, 5, 6, 5, 7, 6], [0, 1, 4, 1, 5, 4], [2, 6, 3, 3, 6, 7], [0, 4, 2, 2, 4, 6], [1, 3, 5, 3, 7, 5]]
	for face_index in range(faces.size()):
		var face_color: Color = color
		if face_index == 1:
			face_color = color.lightened(0.14)
		elif face_index == 3:
			face_color = color.darkened(0.16)
		surface.set_color(face_color)
		for vertex_index in faces[face_index]:
			surface.add_vertex(corners[vertex_index])


func _mobile_glass_jar_mesh() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	const SIDES := 12
	var rings: Array[Vector2] = [
		Vector2(0.025, 0.145), Vector2(0.045, 0.16), Vector2(0.29, 0.16),
		Vector2(0.32, 0.145), Vector2(0.34, 0.105), Vector2(0.37, 0.085),
		Vector2(0.405, 0.085), Vector2(0.42, 0.10)
	]
	for ring_index in range(rings.size() - 1):
		var tint := Color(0.60, 0.83, 0.76, 0.42) if ring_index < 5 else Color(0.48, 0.69, 0.62, 0.58)
		surface.set_color(tint)
		for side in range(SIDES):
			var a0: float = TAU * float(side) / float(SIDES)
			var a1: float = TAU * float(side + 1) / float(SIDES)
			var p00 := Vector3(cos(a0) * rings[ring_index].y, rings[ring_index].x, sin(a0) * rings[ring_index].y)
			var p01 := Vector3(cos(a1) * rings[ring_index].y, rings[ring_index].x, sin(a1) * rings[ring_index].y)
			var p10 := Vector3(cos(a0) * rings[ring_index + 1].y, rings[ring_index + 1].x, sin(a0) * rings[ring_index + 1].y)
			var p11 := Vector3(cos(a1) * rings[ring_index + 1].y, rings[ring_index + 1].x, sin(a1) * rings[ring_index + 1].y)
			surface.add_vertex(p00)
			surface.add_vertex(p10)
			surface.add_vertex(p01)
			surface.add_vertex(p01)
			surface.add_vertex(p10)
			surface.add_vertex(p11)
	# Heavy glass base and rolled mouth rim.
	_append_box_surface(surface, Vector3(0.0, 0.035, 0.0), Vector3(0.25, 0.035, 0.25), Color(0.48, 0.70, 0.63, 0.62))
	surface.generate_normals()
	return surface.commit()


func _mobile_cable_bundle_mesh() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cable_colors: Array[Color] = [Color(0.10, 0.12, 0.14), Color(0.76, 0.22, 0.12), Color(0.12, 0.34, 0.62)]
	for cable_index in range(3):
		var center := Vector3(-0.09 + float(cable_index) * 0.09, 0.10 + float(cable_index) * 0.025, 0.0)
		var major_radius: float = 0.105 + float(cable_index % 2) * 0.012
		var minor_radius: float = 0.026
		for ring_index in range(16):
			var a0: float = TAU * float(ring_index) / 16.0
			var a1: float = TAU * float(ring_index + 1) / 16.0
			for side in range(6):
				var b0: float = TAU * float(side) / 6.0
				var b1: float = TAU * float(side + 1) / 6.0
				var p00 := center + Vector3(cos(a0) * (major_radius + cos(b0) * minor_radius), sin(b0) * minor_radius, sin(a0) * (major_radius + cos(b0) * minor_radius))
				var p01 := center + Vector3(cos(a1) * (major_radius + cos(b0) * minor_radius), sin(b0) * minor_radius, sin(a1) * (major_radius + cos(b0) * minor_radius))
				var p10 := center + Vector3(cos(a0) * (major_radius + cos(b1) * minor_radius), sin(b1) * minor_radius, sin(a0) * (major_radius + cos(b1) * minor_radius))
				var p11 := center + Vector3(cos(a1) * (major_radius + cos(b1) * minor_radius), sin(b1) * minor_radius, sin(a1) * (major_radius + cos(b1) * minor_radius))
				surface.set_color(cable_colors[cable_index])
				surface.add_vertex(p00)
				surface.add_vertex(p01)
				surface.add_vertex(p10)
				surface.add_vertex(p01)
				surface.add_vertex(p11)
				surface.add_vertex(p10)
	# Three visible cut cable ends with colored insulation cores.
	for end_index in range(3):
		var x: float = -0.16 + float(end_index) * 0.16
		_append_box_surface(surface, Vector3(x, 0.045, 0.12), Vector3(0.07, 0.055, 0.07), cable_colors[end_index])
	surface.generate_normals()
	return surface.commit()


func _mobile_safety_helmet_mesh() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var yellow := Color(0.94, 0.65, 0.08)
	# Low-poly domed shell built from stacked elliptical rings.
	var rings: Array[Vector2] = [Vector2(0.065, 0.255), Vector2(0.12, 0.24), Vector2(0.19, 0.19), Vector2(0.245, 0.105), Vector2(0.265, 0.025)]
	const SIDES := 12
	for ring_index in range(rings.size() - 1):
		for side in range(SIDES):
			var a0: float = TAU * float(side) / float(SIDES)
			var a1: float = TAU * float(side + 1) / float(SIDES)
			var p00 := Vector3(cos(a0) * rings[ring_index].y, rings[ring_index].x, sin(a0) * rings[ring_index].y)
			var p01 := Vector3(cos(a1) * rings[ring_index].y, rings[ring_index].x, sin(a1) * rings[ring_index].y)
			var p10 := Vector3(cos(a0) * rings[ring_index + 1].y, rings[ring_index + 1].x, sin(a0) * rings[ring_index + 1].y)
			var p11 := Vector3(cos(a1) * rings[ring_index + 1].y, rings[ring_index + 1].x, sin(a1) * rings[ring_index + 1].y)
			surface.set_color(yellow.lightened(0.08) if side % 4 == 0 else yellow)
			surface.add_vertex(p00)
			surface.add_vertex(p10)
			surface.add_vertex(p01)
			surface.add_vertex(p01)
			surface.add_vertex(p10)
			surface.add_vertex(p11)
	# Full brim, reinforced front lip, central ridge and suspension rails.
	_append_box_surface(surface, Vector3(0.0, 0.055, 0.0), Vector3(0.63, 0.035, 0.40), Color(0.84, 0.54, 0.045))
	_append_box_surface(surface, Vector3(0.0, 0.073, -0.18), Vector3(0.34, 0.018, 0.035), Color(1.0, 0.79, 0.20))
	_append_box_surface(surface, Vector3(0.0, 0.20, 0.0), Vector3(0.045, 0.035, 0.37), Color(1.0, 0.78, 0.20))
	surface.generate_normals()
	return surface.commit()


func _mobile_old_shoe_mesh() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Layered rubber outsole, leather upper, toe cap and raised heel counter.
	_append_box_surface(surface, Vector3(0.025, 0.035, 0.0), Vector3(0.55, 0.07, 0.29), Color(0.10, 0.105, 0.10))
	_append_box_surface(surface, Vector3(0.025, 0.105, 0.0), Vector3(0.49, 0.14, 0.26), Color(0.25, 0.21, 0.17))
	_append_box_surface(surface, Vector3(-0.14, 0.205, 0.0), Vector3(0.25, 0.17, 0.245), Color(0.35, 0.29, 0.22))
	_append_box_surface(surface, Vector3(0.205, 0.14, 0.0), Vector3(0.16, 0.13, 0.245), Color(0.31, 0.26, 0.20))
	_append_box_surface(surface, Vector3(-0.12, 0.295, 0.0), Vector3(0.19, 0.025, 0.16), Color(0.18, 0.16, 0.14))
	# Four crossed fabric laces and eyelet rows.
	for lace_index in range(4):
		var x: float = -0.20 + float(lace_index) * 0.052
		var lace := Vector3(x, 0.315 - float(lace_index) * 0.012, -0.085 if lace_index % 2 == 0 else 0.085)
		_append_box_surface(surface, lace, Vector3(0.095, 0.012, 0.018), Color(0.78, 0.74, 0.65))
		_append_box_surface(surface, Vector3(x, 0.305 - float(lace_index) * 0.012, 0.0), Vector3(0.018, 0.012, 0.17), Color(0.72, 0.67, 0.57))
	# Worn stitching and scuffed toe panels.
	_append_box_surface(surface, Vector3(0.22, 0.19, -0.13), Vector3(0.11, 0.025, 0.012), Color(0.57, 0.48, 0.36))
	surface.generate_normals()
	return surface.commit()


func _mobile_old_television_mesh(rng: RandomNumberGenerator) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Deep CRT cabinet and a recessed dark screen with a thick molded bezel.
	_append_box_surface(surface, Vector3(0.0, 0.30, 0.02), Vector3(0.76, 0.55, 0.46), Color(0.22, 0.245, 0.23))
	_append_box_surface(surface, Vector3(-0.035, 0.34, -0.218), Vector3(0.62, 0.41, 0.035), Color(0.38, 0.39, 0.35))
	_append_box_surface(surface, Vector3(-0.035, 0.34, -0.241), Vector3(0.53, 0.33, 0.012), Color(0.045, 0.075, 0.085))
	_append_box_surface(surface, Vector3(-0.035, 0.34, -0.25), Vector3(0.49, 0.29, 0.008), Color(0.12, 0.22, 0.24))
	# Control panel, rotary knobs, ventilation ribs and short broken antenna.
	_append_box_surface(surface, Vector3(0.30, 0.31, -0.235), Vector3(0.075, 0.22, 0.025), Color(0.16, 0.18, 0.17))
	for knob_index in range(3):
		var knob_x: float = 0.30
		var knob_y: float = 0.25 + float(knob_index) * 0.07
		_append_box_surface(surface, Vector3(knob_x, knob_y, -0.255), Vector3(0.035, 0.035, 0.018), Color(0.66, 0.63, 0.52))
	for vent_index in range(5):
		_append_box_surface(surface, Vector3(-0.25 + float(vent_index) * 0.09, 0.045, -0.215), Vector3(0.055, 0.012, 0.018), Color(0.09, 0.11, 0.105))
	_append_box_surface(surface, Vector3(-0.25, 0.60, 0.05), Vector3(0.018, 0.23, 0.018), Color(0.48, 0.50, 0.47))
	# A few bright fractured lines across the damaged glass face.
	for crack_index in range(4):
		var crack_x: float = rng.randf_range(-0.22, 0.18)
		var crack_y: float = rng.randf_range(0.20, 0.47)
		_append_box_surface(surface, Vector3(crack_x, crack_y, -0.258), Vector3(rng.randf_range(0.08, 0.20), 0.006, 0.004), Color(0.58, 0.73, 0.72))
	surface.generate_normals()
	return surface.commit()


func _mobile_toy_blocks_mesh(rng: RandomNumberGenerator) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var colors: Array[Color] = [Color(0.86, 0.16, 0.12), Color(0.12, 0.39, 0.82), Color(0.94, 0.67, 0.10), Color(0.13, 0.58, 0.32)]
	var centers: Array[Vector3] = [
		Vector3(-0.115, 0.075, -0.075), Vector3(0.105, 0.065, -0.055),
		Vector3(-0.065, 0.055, 0.115), Vector3(0.12, 0.12, 0.105)
	]
	var sizes: Array[Vector3] = [
		Vector3(0.19, 0.14, 0.17), Vector3(0.17, 0.12, 0.18),
		Vector3(0.20, 0.10, 0.15), Vector3(0.14, 0.22, 0.14)
	]
	for block_index in range(centers.size()):
		var center: Vector3 = centers[block_index]
		var half: Vector3 = sizes[block_index] * 0.5
		var angle: float = rng.randf_range(-0.22, 0.22)
		var corners: Array[Vector3] = []
		for corner_index in range(8):
			var point := Vector3(
				 half.x if (corner_index & 1) != 0 else -half.x,
				 half.y if (corner_index & 2) != 0 else -half.y,
				 half.z if (corner_index & 4) != 0 else -half.z
			)
			point = Vector3(point.x * cos(angle) - point.z * sin(angle), point.y, point.x * sin(angle) + point.z * cos(angle))
			corners.append(point + center)
		var faces: Array[Array] = [[0, 2, 1, 1, 2, 3], [4, 5, 6, 5, 7, 6], [0, 1, 4, 1, 5, 4], [2, 6, 3, 3, 6, 7], [0, 4, 2, 2, 4, 6], [1, 3, 5, 3, 7, 5]]
		for face_index in range(faces.size()):
			var face_color: Color = colors[block_index]
			if face_index == 1:
				face_color = face_color.lightened(0.16)
			elif face_index == 3:
				face_color = face_color.darkened(0.18)
			surface.set_color(face_color)
			for vertex_index in faces[face_index]:
				surface.add_vertex(corners[vertex_index])
	# Small molded studs on the toy bricks make their identity immediately readable.
	for stud_index in range(4):
		var x: float = -0.12 + float(stud_index % 2) * 0.22
		var z: float = -0.07 + float(stud_index / 2) * 0.17
		var y: float = 0.205 if stud_index == 3 else 0.145
		var radius: float = 0.027
		for side in range(8):
			var a0: float = TAU * float(side) / 8.0
			var a1: float = TAU * float(side + 1) / 8.0
			surface.set_color(colors[stud_index])
			surface.add_vertex(Vector3(x, y, z))
			surface.add_vertex(Vector3(x + cos(a0) * radius, y, z + sin(a0) * radius))
			surface.add_vertex(Vector3(x + cos(a1) * radius, y, z + sin(a1) * radius))
	surface.generate_normals()
	return surface.commit()


func _mobile_paint_bucket_mesh(rng: RandomNumberGenerator) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	const SIDES := 12
	var bottom_radius: float = 0.145
	var top_radius: float = 0.185
	var bucket_colors: Array[Color] = [Color(0.67, 0.25, 0.12), Color(0.76, 0.32, 0.16), Color(0.53, 0.20, 0.11)]
	# Tapered, slightly dented steel shell with alternating worn panels.
	for side in range(SIDES):
		var a0: float = TAU * float(side) / float(SIDES)
		var a1: float = TAU * float(side + 1) / float(SIDES)
		var dent0: float = 1.0 - (0.055 if side in [2, 3] else 0.0)
		var dent1: float = 1.0 - (0.055 if (side + 1) % SIDES in [2, 3] else 0.0)
		var b0 := Vector3(cos(a0) * bottom_radius * dent0, 0.025, sin(a0) * bottom_radius * dent0)
		var b1 := Vector3(cos(a1) * bottom_radius * dent1, 0.025, sin(a1) * bottom_radius * dent1)
		var t0 := Vector3(cos(a0) * top_radius * dent0, 0.335, sin(a0) * top_radius * dent0)
		var t1 := Vector3(cos(a1) * top_radius * dent1, 0.335, sin(a1) * top_radius * dent1)
		surface.set_color(bucket_colors[side % bucket_colors.size()])
		surface.add_vertex(b0)
		surface.add_vertex(t0)
		surface.add_vertex(b1)
		surface.add_vertex(b1)
		surface.add_vertex(t0)
		surface.add_vertex(t1)
	# Rolled steel rim and lower reinforcing bead.
	for ring_radius in [top_radius, bottom_radius * 1.04]:
		var ring_y: float = 0.335 if ring_radius == top_radius else 0.055
		var tube_radius: float = 0.012
		for side in range(SIDES):
			var a0: float = TAU * float(side) / float(SIDES)
			var a1: float = TAU * float(side + 1) / float(SIDES)
			var p0 := Vector3(cos(a0) * ring_radius, ring_y, sin(a0) * ring_radius)
			var p1 := Vector3(cos(a1) * ring_radius, ring_y, sin(a1) * ring_radius)
			var q0 := Vector3(cos(a0) * (ring_radius + tube_radius), ring_y, sin(a0) * (ring_radius + tube_radius))
			var q1 := Vector3(cos(a1) * (ring_radius + tube_radius), ring_y, sin(a1) * (ring_radius + tube_radius))
			surface.set_color(Color(0.57, 0.59, 0.57))
			surface.add_vertex(p0)
			surface.add_vertex(q0)
			surface.add_vertex(p1)
			surface.add_vertex(p1)
			surface.add_vertex(q0)
			surface.add_vertex(q1)
	# Wire handle, built as faceted segments, attached to both sides of the rim.
	var handle_points: Array[Vector3] = []
	for point_index in range(13):
		var t: float = float(point_index) / 12.0
		handle_points.append(Vector3(-0.17 + 0.34 * t, 0.34 + sin(t * PI) * 0.19, 0.0))
	for point_index in range(handle_points.size() - 1):
		var p0: Vector3 = handle_points[point_index]
		var p1: Vector3 = handle_points[point_index + 1]
		var direction := (p1 - p0).normalized()
		var side_axis := Vector3(0.0, 0.0, 0.009)
		var offset := direction.cross(side_axis).normalized() * 0.009
		surface.set_color(Color(0.60, 0.62, 0.60))
		surface.add_vertex(p0 - offset)
		surface.add_vertex(p0 + offset)
		surface.add_vertex(p1 - offset)
		surface.add_vertex(p1 - offset)
		surface.add_vertex(p0 + offset)
		surface.add_vertex(p1 + offset)
	# Dried paint drips and splashes on the front of the bucket.
	for drip_index in range(4):
		var x: float = -0.105 + float(drip_index) * 0.065
		var drip_length: float = rng.randf_range(0.045, 0.12)
		var paint_color: Color = Color(0.88, 0.77, 0.48) if drip_index % 2 == 0 else Color(0.20, 0.42, 0.55)
		surface.set_color(paint_color)
		surface.add_vertex(Vector3(x - 0.012, 0.20, -0.151))
		surface.add_vertex(Vector3(x + 0.012, 0.20, -0.151))
		surface.add_vertex(Vector3(x + 0.006, 0.20 - drip_length, -0.153))
	surface.generate_normals()
	return surface.commit()


func _mobile_tire_mesh() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	const MAJOR := 0.335
	const MINOR := 0.095
	const RINGS := 36
	const SIDES := 12
	# Continuous rubber carcass, with a rounded shoulder and dark sidewall.
	for ring_index in range(RINGS):
		var u0: float = TAU * float(ring_index) / float(RINGS)
		var u1: float = TAU * float(ring_index + 1) / float(RINGS)
		for side_index in range(SIDES):
			var v0: float = TAU * float(side_index) / float(SIDES)
			var v1: float = TAU * float(side_index + 1) / float(SIDES)
			var p00 := Vector3((MAJOR + MINOR * cos(v0)) * cos(u0), MINOR * sin(v0), (MAJOR + MINOR * cos(v0)) * sin(u0))
			var p10 := Vector3((MAJOR + MINOR * cos(v0)) * cos(u1), MINOR * sin(v0), (MAJOR + MINOR * cos(v0)) * sin(u1))
			var p01 := Vector3((MAJOR + MINOR * cos(v1)) * cos(u0), MINOR * sin(v1), (MAJOR + MINOR * cos(v1)) * sin(u0))
			var p11 := Vector3((MAJOR + MINOR * cos(v1)) * cos(u1), MINOR * sin(v1), (MAJOR + MINOR * cos(v1)) * sin(u1))
			var tread_zone: bool = absf(sin(v0)) < 0.48
			surface.set_color(Color(0.075, 0.082, 0.083) if tread_zone else Color(0.035, 0.041, 0.043))
			surface.add_vertex(p00)
			surface.add_vertex(p01)
			surface.add_vertex(p10)
			surface.add_vertex(p10)
			surface.add_vertex(p01)
			surface.add_vertex(p11)
	# Raised tread lugs across the crown: angled blocks with narrow gaps.
	for block_index in range(32):
		var angle: float = TAU * float(block_index) / 32.0
		var tangent := Vector3(-sin(angle), 0.0, cos(angle))
		var radial := Vector3(cos(angle), 0.0, sin(angle))
		for row in range(3):
			var y_offset: float = (float(row) - 1.0) * 0.052
			var center := radial * 0.435 + Vector3(0.0, y_offset, 0.0) + tangent * (0.012 if row == 1 else -0.012)
			var half_tangent: float = 0.026
			var half_y: float = 0.018
			var outer := center + radial * 0.012
			var a := outer - tangent * half_tangent - Vector3(0.0, half_y, 0.0)
			var b := outer + tangent * half_tangent - Vector3(0.0, half_y, 0.0)
			var c := outer - tangent * half_tangent + Vector3(0.0, half_y, 0.0)
			var d := outer + tangent * half_tangent + Vector3(0.0, half_y, 0.0)
			surface.set_color(Color(0.105, 0.112, 0.112))
			surface.add_vertex(a)
			surface.add_vertex(c)
			surface.add_vertex(b)
			surface.add_vertex(b)
			surface.add_vertex(c)
			surface.add_vertex(d)
	# Sidewall raised bead rings and worn rubber scuff patches.
	for side_sign in [-1.0, 1.0]:
		for ring_radius in [0.255, 0.405]:
			for segment in range(48):
				var a0: float = TAU * float(segment) / 48.0
				var a1: float = TAU * float(segment + 1) / 48.0
				var y: float = side_sign * 0.084
				var p0 := Vector3(cos(a0) * ring_radius, y, sin(a0) * ring_radius)
				var p1 := Vector3(cos(a1) * ring_radius, y, sin(a1) * ring_radius)
				var p2 := Vector3(cos(a0) * (ring_radius + 0.008), y + side_sign * 0.004, sin(a0) * (ring_radius + 0.008))
				var p3 := Vector3(cos(a1) * (ring_radius + 0.008), y + side_sign * 0.004, sin(a1) * (ring_radius + 0.008))
				surface.set_color(Color(0.16, 0.17, 0.16))
				surface.add_vertex(p0)
				surface.add_vertex(p2)
				surface.add_vertex(p1)
				surface.add_vertex(p1)
				surface.add_vertex(p2)
				surface.add_vertex(p3)
	surface.generate_normals()
	return surface.commit()


func _mobile_broken_glass_mesh(rng: RandomNumberGenerator) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Five individually shaped shards overlap slightly like a real broken bottle.
	for shard_index in range(5):
		var center_x: float = rng.randf_range(-0.16, 0.16)
		var center_z: float = rng.randf_range(-0.12, 0.12)
		var length: float = rng.randf_range(0.13, 0.25)
		var width: float = rng.randf_range(0.07, 0.15)
		var angle: float = rng.randf_range(0.0, TAU)
		var direction := Vector2(cos(angle), sin(angle))
		var side := Vector2(-direction.y, direction.x)
		var tip := Vector3(center_x + direction.x * length, rng.randf_range(0.018, 0.035), center_z + direction.y * length)
		var rear := Vector3(center_x - direction.x * length * 0.55, 0.012, center_z - direction.y * length * 0.55)
		var left := Vector3(center_x + side.x * width, 0.014, center_z + side.y * width)
		var right := Vector3(center_x - side.x * width, 0.014, center_z - side.y * width)
		var glass_color: Color = [Color(0.42, 0.72, 0.74, 0.64), Color(0.62, 0.84, 0.82, 0.58), Color(0.31, 0.58, 0.62, 0.72)][shard_index % 3]
		# Broad translucent face with a raised pointed tip.
		surface.set_color(glass_color)
		surface.add_vertex(rear)
		surface.add_vertex(left)
		surface.add_vertex(tip)
		surface.add_vertex(rear)
		surface.add_vertex(tip)
		surface.add_vertex(right)
		# A narrow bright facet catches light along one sharp edge.
		surface.set_color(Color(0.83, 0.96, 0.91, 0.82))
		surface.add_vertex(left)
		surface.add_vertex(Vector3(center_x + direction.x * length * 0.82, 0.025, center_z + direction.y * length * 0.82))
		surface.add_vertex(tip)
	surface.generate_normals()
	return surface.commit()


func _mobile_battery_mesh(rng: RandomNumberGenerator) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	const SIDES := 10
	var levels: Array[Vector2] = [
		Vector2(0.105, 0.025), Vector2(0.125, 0.055),
		Vector2(0.132, 0.095), Vector2(0.132, 0.335),
		Vector2(0.122, 0.375), Vector2(0.105, 0.395)
	]
	var body_colors: Array[Color] = [Color(0.20, 0.22, 0.23), Color(0.28, 0.29, 0.27), Color(0.13, 0.15, 0.16)]
	for ring_index in range(levels.size() - 1):
		for side in range(SIDES):
			var angle0: float = TAU * float(side) / float(SIDES)
			var angle1: float = TAU * float(side + 1) / float(SIDES)
			var p0 := Vector3(cos(angle0) * levels[ring_index].x, levels[ring_index].y, sin(angle0) * levels[ring_index].x)
			var p1 := Vector3(cos(angle1) * levels[ring_index].x, levels[ring_index].y, sin(angle1) * levels[ring_index].x)
			var p2 := Vector3(cos(angle0) * levels[ring_index + 1].x, levels[ring_index + 1].y, sin(angle0) * levels[ring_index + 1].x)
			var p3 := Vector3(cos(angle1) * levels[ring_index + 1].x, levels[ring_index + 1].y, sin(angle1) * levels[ring_index + 1].x)
			surface.set_color(body_colors[(side + ring_index) % body_colors.size()])
			surface.add_vertex(p0)
			surface.add_vertex(p2)
			surface.add_vertex(p1)
			surface.add_vertex(p1)
			surface.add_vertex(p2)
			surface.add_vertex(p3)
	# Raised positive terminal and smaller negative terminal are modeled into the same mesh.
	for terminal_index in range(2):
		var terminal_x: float = -0.045 if terminal_index == 0 else 0.045
		var terminal_radius: float = 0.032 if terminal_index == 0 else 0.024
		var terminal_height: float = 0.055 if terminal_index == 0 else 0.028
		var terminal_color: Color = Color(0.72, 0.73, 0.68) if terminal_index == 0 else Color(0.48, 0.50, 0.49)
		for side in range(SIDES):
			var a0: float = TAU * float(side) / float(SIDES)
			var a1: float = TAU * float(side + 1) / float(SIDES)
			var bottom0 := Vector3(terminal_x + cos(a0) * terminal_radius, 0.394, sin(a0) * terminal_radius)
			var bottom1 := Vector3(terminal_x + cos(a1) * terminal_radius, 0.394, sin(a1) * terminal_radius)
			var top0 := Vector3(terminal_x + cos(a0) * terminal_radius * 0.86, 0.394 + terminal_height, sin(a0) * terminal_radius * 0.86)
			var top1 := Vector3(terminal_x + cos(a1) * terminal_radius * 0.86, 0.394 + terminal_height, sin(a1) * terminal_radius * 0.86)
			surface.set_color(terminal_color)
			surface.add_vertex(bottom0)
			surface.add_vertex(top0)
			surface.add_vertex(bottom1)
			surface.add_vertex(bottom1)
			surface.add_vertex(top0)
			surface.add_vertex(top1)
	# Corrosion scars on the front face, colored as part of the same mesh.
	for scar_index in range(5):
		var scar_x: float = rng.randf_range(-0.085, 0.085)
		var scar_y: float = rng.randf_range(0.10, 0.31)
		var scar_size: float = rng.randf_range(0.012, 0.027)
		var front_z: float = -0.132
		var scar_color: Color = Color(0.57, 0.34, 0.18) if scar_index % 2 == 0 else Color(0.67, 0.56, 0.36)
		surface.set_color(scar_color)
		surface.add_vertex(Vector3(scar_x - scar_size, scar_y, front_z))
		surface.add_vertex(Vector3(scar_x, scar_y + scar_size * 1.4, front_z - 0.002))
		surface.add_vertex(Vector3(scar_x + scar_size * 0.8, scar_y - scar_size * 0.5, front_z))
	surface.generate_normals()
	return surface.commit()


func _mobile_cardboard_scrap_mesh(rng: RandomNumberGenerator) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Single corrugated sheet with torn, uneven edges and visible flute ridges.
	const SEGMENTS := 12
	var points: Array[Vector3] = []
	for i in range(SEGMENTS + 1):
		var x := -0.29 + 0.58 * float(i) / float(SEGMENTS)
		var torn := 0.018 * sin(float(i) * 2.7 + rng.seed * 0.00001)
		var z_front := -0.21 + torn
		var z_back := 0.21 - torn * 0.65
		points.append(Vector3(x, 0.035 + 0.012 * sin(float(i) * 1.9), z_front))
		points.append(Vector3(x, 0.035 + 0.012 * cos(float(i) * 1.7), z_back))
	for i in range(SEGMENTS):
		var p0 := points[i * 2]
		var p1 := points[i * 2 + 1]
		var p2 := points[(i + 1) * 2]
		var p3 := points[(i + 1) * 2 + 1]
		var corrugation := 0.008 * sin(float(i) * 2.4)
		var ridge0 := Vector3(p0.x, p0.y + corrugation, (p0.z + p1.z) * 0.5)
		var ridge1 := Vector3(p2.x, p2.y - corrugation, (p2.z + p3.z) * 0.5)
		var brown := Color(0.62, 0.43, 0.27) if i % 3 else Color(0.72, 0.54, 0.35)
		surface.set_color(brown)
		surface.add_vertex(p0)
		surface.add_vertex(ridge0)
		surface.add_vertex(p2)
		surface.add_vertex(p2)
		surface.add_vertex(ridge0)
		surface.add_vertex(ridge1)
		surface.add_vertex(ridge0)
		surface.add_vertex(p1)
		surface.add_vertex(ridge1)
		surface.add_vertex(ridge1)
		surface.add_vertex(p1)
		surface.add_vertex(p3)
	# Ragged folded flap across one corner, integrated into the same surface.
	var flap_a := Vector3(-0.12, 0.058, -0.13)
	var flap_b := Vector3(0.27, 0.052, -0.16)
	var flap_c := Vector3(0.20, 0.085, 0.18)
	var flap_d := Vector3(-0.08, 0.075, 0.15)
	surface.set_color(Color(0.78, 0.60, 0.40))
	surface.add_vertex(flap_a)
	surface.add_vertex(flap_c)
	surface.add_vertex(flap_b)
	surface.add_vertex(flap_a)
	surface.add_vertex(flap_d)
	surface.add_vertex(flap_c)
	surface.generate_normals()
	return surface.commit()


func _mobile_crumpled_paper_mesh(rng: RandomNumberGenerator) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Triangulated paper sheet folded into an irregular compact wad.
	const GRID := 7
	var heights: Array[float] = []
	for z_index in range(GRID + 1):
		for x_index in range(GRID + 1):
			var x := -0.19 + 0.38 * float(x_index) / float(GRID)
			var z := -0.16 + 0.32 * float(z_index) / float(GRID)
			var ridge := absf(sin(x * 27.0 + z * 11.0 + 0.7) * cos(z * 31.0 - x * 9.0))
			var mound := maxf(0.0, 1.0 - (x * x / 0.045 + z * z / 0.032))
			heights.append(0.025 + ridge * 0.11 + mound * 0.09)
	var paper_colors: Array[Color] = [Color(0.91, 0.88, 0.78), Color(0.79, 0.76, 0.67), Color(0.97, 0.94, 0.85)]
	for z_index in range(GRID):
		for x_index in range(GRID):
			var i := z_index * (GRID + 1) + x_index
			var p00 := Vector3(-0.19 + 0.38 * float(x_index) / float(GRID), heights[i], -0.16 + 0.32 * float(z_index) / float(GRID))
			var p10 := Vector3(-0.19 + 0.38 * float(x_index + 1) / float(GRID), heights[i + 1], p00.z)
			var p01 := Vector3(p00.x, heights[i + GRID + 1], -0.16 + 0.32 * float(z_index + 1) / float(GRID))
			var p11 := Vector3(p10.x, heights[i + GRID + 2], p01.z)
			surface.set_color(paper_colors[(x_index * 3 + z_index + rng.randi_range(0, 2)) % paper_colors.size()])
			surface.add_vertex(p00)
			surface.add_vertex(p01)
			surface.add_vertex(p10)
			surface.add_vertex(p10)
			surface.add_vertex(p01)
			surface.add_vertex(p11)
	surface.generate_normals()
	return surface.commit()


func _mobile_paper_cup_mesh() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	const SIDES := 10
	# Radius / height profile: tapered paper wall, broad rolled rim and inner lip.
	var profile: Array[Vector2] = [
		Vector2(0.125, 0.015), Vector2(0.132, 0.045),
		Vector2(0.145, 0.105), Vector2(0.177, 0.285),
		Vector2(0.190, 0.325), Vector2(0.204, 0.337),
		Vector2(0.204, 0.350), Vector2(0.181, 0.350),
		Vector2(0.179, 0.331)
	]
	var paper := Color(0.88, 0.83, 0.70)
	var sleeve := Color(0.48, 0.29, 0.16)
	var rim := Color(0.97, 0.94, 0.84)
	for ring in range(profile.size() - 1):
		var section := paper
		if ring == 1 or ring == 2:
			section = sleeve
		elif ring >= 4:
			section = rim
		for side in range(SIDES):
			var a0 := TAU * float(side) / float(SIDES)
			var a1 := TAU * float(side + 1) / float(SIDES)
			var p00 := Vector3(cos(a0) * profile[ring].x, profile[ring].y, sin(a0) * profile[ring].x)
			var p01 := Vector3(cos(a1) * profile[ring].x, profile[ring].y, sin(a1) * profile[ring].x)
			var p10 := Vector3(cos(a0) * profile[ring + 1].x, profile[ring + 1].y, sin(a0) * profile[ring + 1].x)
			var p11 := Vector3(cos(a1) * profile[ring + 1].x, profile[ring + 1].y, sin(a1) * profile[ring + 1].x)
			surface.set_color(section)
			# Reverse winding for outward-facing normals on a vertical surface of revolution.
			surface.add_vertex(p00)
			surface.add_vertex(p10)
			surface.add_vertex(p01)
			surface.add_vertex(p01)
			surface.add_vertex(p10)
			surface.add_vertex(p11)
	surface.generate_normals()
	return surface.commit()


func _add_rare_visual(rare_type: String) -> void:
	var gold := rare_type == "gold"
	var color := Color(1.0, 0.72, 0.12) if gold else Color(0.72, 0.84, 0.92)
	var badge := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.19
	sphere.height = 0.38
	sphere.radial_segments = 10
	badge.mesh = sphere
	badge.position = Vector3(0, 0.38, 0)
	badge.material_override = _material(color)
	add_child(badge)
	var glint := _flat_box(Vector3(0.055, 0.22, 0.055), Vector3(0, 0.39, -0.16), Color.WHITE)
	add_child(glint)

func _process(delta: float) -> void:
	rotation.y += spin_speed * delta

func _make_plastic_bottle(rng: RandomNumberGenerator) -> void:
	var body := MeshInstance3D.new()
	var shape := CylinderMesh.new()
	shape.top_radius = 0.125
	shape.bottom_radius = 0.17
	shape.height = 0.48
	shape.radial_segments = 16
	body.mesh = shape
	body.position.y = 0.02
	body.rotation_degrees.z = 90
	body.material_override = _material(Color(0.20, 0.62, 0.48, 0.82), true)
	add_child(body)
	var neck := _cylinder_piece(0.10, 0.17, 0.12, Vector3(0.27, 0.02, 0), Color(0.24, 0.68, 0.52))
	neck.rotation_degrees.z = 90
	add_child(neck)
	var cap := _cylinder_piece(0.075, 0.075, 0.09, Vector3(0.38, 0.02, 0), Color(0.92, 0.70, 0.12))
	cap.rotation_degrees.z = 90
	add_child(cap)
	# Raised molded grip rings and a recessed base make the bottle silhouette less toy-like.
	for x in [-0.15, -0.08, 0.08, 0.15]:
		var ridge := _cylinder_piece(0.132, 0.145, 0.018, Vector3(x, 0.02, 0), Color(0.17, 0.54, 0.42, 0.88))
		ridge.rotation_degrees.z = 90
		add_child(ridge)
	var base_ring := _cylinder_piece(0.15, 0.15, 0.025, Vector3(-0.22, 0.02, 0), Color(0.12, 0.43, 0.34))
	base_ring.rotation_degrees.z = 90
	add_child(base_ring)
	var label := _flat_box(Vector3(0.13, 0.09, 0.018), Vector3(-0.02, 0.02, -0.135), Color(0.90, 0.94, 0.82))
	add_child(label)
	rotation.z = rng.randf_range(-0.12, 0.12)

func _make_crushed_can(rng: RandomNumberGenerator) -> void:
	var can := _cylinder_piece(0.14, 0.17, 0.38, Vector3(0, 0.02, 0), Color(0.68, 0.73, 0.75))
	can.rotation_degrees.z = 90
	can.scale = Vector3(1.0, 0.78, 0.82)
	add_child(can)
	var stripe := _cylinder_piece(0.145, 0.145, 0.10, Vector3(-0.08, 0.02, 0), Color(0.82, 0.20, 0.14))
	stripe.rotation_degrees.z = 90
	add_child(stripe)
	var rim := _cylinder_piece(0.14, 0.14, 0.025, Vector3(0.19, 0.02, 0), Color(0.88, 0.89, 0.84))
	rim.rotation_degrees.z = 90
	add_child(rim)
	rotation.z = rng.randf_range(-0.18, 0.18)

func _make_paper_cup(rng: RandomNumberGenerator) -> void:
	var cup := _cylinder_piece(0.13, 0.19, 0.34, Vector3(0, 0.17, 0), Color(0.88, 0.82, 0.66))
	cup.rotation_degrees.z = rng.randf_range(-12.0, 12.0)
	add_child(cup)
	var rim := _cylinder_piece(0.195, 0.195, 0.035, Vector3(0, 0.34, 0), Color(0.96, 0.94, 0.86))
	add_child(rim)
	var sleeve := _cylinder_piece(0.16, 0.175, 0.10, Vector3(0, 0.14, 0), Color(0.58, 0.36, 0.20))
	add_child(sleeve)
	var logo := _flat_box(Vector3(0.075, 0.09, 0.012), Vector3(0, 0.18, -0.17), Color(0.24, 0.48, 0.35))
	add_child(logo)

func _make_food_wrapper(rng: RandomNumberGenerator) -> void:
	var packet := MeshInstance3D.new()
	packet.name = "CrimpedSnackWrapper"
	packet.mesh = _mobile_food_wrapper_mesh(rng)
	packet.position.y = 0.075
	packet.rotation.y = rng.randf_range(0.0, TAU)
	var material := _material(Color.WHITE)
	material.vertex_color_use_as_albedo = true
	material.metallic = 0.22
	material.roughness = 0.34
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	packet.material_override = material
	add_child(packet)


func _make_crumpled_paper(rng: RandomNumberGenerator) -> void:
	var paper := MeshInstance3D.new()
	paper.name = "CrumpledPaperWad"
	paper.mesh = _mobile_crumpled_paper_mesh(rng)
	paper.position.y = 0.025
	paper.rotation.y = rng.randf_range(0.0, TAU)
	var material := _material(Color.WHITE)
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.94
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	paper.material_override = material
	add_child(paper)

func _make_cardboard_scrap(rng: RandomNumberGenerator) -> void:
	var cardboard := MeshInstance3D.new()
	cardboard.name = "TornCorrugatedCardboard"
	cardboard.mesh = _mobile_cardboard_scrap_mesh(rng)
	cardboard.position.y = 0.035
	cardboard.rotation.y = rng.randf_range(0.0, TAU)
	var material := _material(Color.WHITE)
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.96
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	cardboard.material_override = material
	add_child(cardboard)

func _make_battery(rng: RandomNumberGenerator) -> void:
	var battery := MeshInstance3D.new()
	battery.name = "CorrodedIndustrialBattery"
	battery.mesh = _mobile_battery_mesh(rng)
	battery.position.y = 0.025
	battery.rotation.y = rng.randf_range(0.0, TAU)
	battery.rotation.z = rng.randf_range(-0.12, 0.12)
	var material := _material(Color.WHITE)
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.82
	material.metallic = 0.24
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	battery.material_override = material
	add_child(battery)

func _make_broken_glass(rng: RandomNumberGenerator) -> void:
	var glass := MeshInstance3D.new()
	glass.name = "BrokenGlassShards"
	glass.mesh = _mobile_broken_glass_mesh(rng)
	glass.position.y = 0.008
	glass.rotation.y = rng.randf_range(0.0, TAU)
	var material := _material(Color.WHITE, true)
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.12
	material.metallic = 0.08
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	glass.material_override = material
	add_child(glass)

func _make_soda_bottle(rng: RandomNumberGenerator) -> void:
	var body := _cylinder_piece(0.17, 0.16, 0.40, Vector3(0, 0.20, 0), Color(0.82, 0.26, 0.12))
	body.rotation_degrees.z = 90
	add_child(body)
	var neck := _cylinder_piece(0.07, 0.08, 0.13, Vector3(0.30, 0.20, 0), Color(0.82, 0.26, 0.12))
	neck.rotation_degrees.z = 90
	add_child(neck)
	var cap := _cylinder_piece(0.065, 0.065, 0.07, Vector3(0.40, 0.20, 0), Color(0.95, 0.78, 0.12))
	cap.rotation_degrees.z = 90
	add_child(cap)
	add_child(_flat_box(Vector3(0.14, 0.08, 0.02), Vector3(-0.02, 0.20, -0.14), Color(0.95, 0.80, 0.48)))

func _make_old_shoe(rng: RandomNumberGenerator) -> void:
	var shoe := MeshInstance3D.new()
	shoe.name = "WornWorkBoot"
	shoe.mesh = _mobile_old_shoe_mesh()
	shoe.position.y = 0.015
	shoe.rotation.y = rng.randf_range(0.0, TAU)
	shoe.rotation.z = rng.randf_range(-0.15, 0.15)
	var material := _material(Color.WHITE)
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.91
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	shoe.material_override = material
	add_child(shoe)

func _make_gear(rng: RandomNumberGenerator) -> void:
	# Rusty steel cogwheel with a central opening and chunky teeth.
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.22
	torus.outer_radius = 0.42
	ring.mesh = torus
	ring.position.y = 0.12
	ring.rotation_degrees.x = 90.0
	ring.material_override = _material(Color(0.48, 0.43, 0.34))
	add_child(ring)
	for i in range(8):
		var tooth := _flat_box(Vector3(0.16, 0.10, 0.13), Vector3(0, 0.12, -0.40), Color(0.52, 0.48, 0.39))
		tooth.rotation.y = float(i) * TAU / 8.0
		add_child(tooth)
	var hub := _cylinder_piece(0.14, 0.14, 0.12, Vector3(0, 0.13, 0), Color(0.34, 0.39, 0.40))
	hub.rotation_degrees.x = 90.0
	add_child(hub)
	rotation.y = rng.randf_range(0.0, TAU)

func _make_screws(rng: RandomNumberGenerator) -> void:
	for i in range(3):
		var screw := _cylinder_piece(0.045, 0.045, 0.24, Vector3(rng.randf_range(-0.18, 0.18), 0.05, rng.randf_range(-0.16, 0.16)), Color(0.60, 0.64, 0.65))
		screw.rotation.z = rng.randf_range(-0.4, 0.4)
		add_child(screw)
		var head := _flat_box(Vector3(0.11, 0.045, 0.11), screw.position + Vector3(0, 0.12, 0), Color(0.70, 0.72, 0.68))
		add_child(head)

func _make_wrench(rng: RandomNumberGenerator) -> void:
	# A small discarded metal wrench, with a shaft and open jaw.
	var shaft := _flat_box(Vector3(0.48, 0.10, 0.12), Vector3(0, 0.12, 0), Color(0.56, 0.60, 0.61))
	shaft.rotation.y = rng.randf_range(-0.35, 0.35)
	add_child(shaft)
	var jaw_base := _flat_box(Vector3(0.18, 0.12, 0.16), Vector3(0.24, 0.12, 0), Color(0.64, 0.67, 0.67))
	add_child(jaw_base)
	var jaw_gap := _flat_box(Vector3(0.11, 0.08, 0.10), Vector3(0.34, 0.12, 0), Color(0.20, 0.23, 0.24))
	add_child(jaw_gap)
	rotation.y = rng.randf_range(0.0, TAU)

func _make_newspaper(rng: RandomNumberGenerator) -> void:
	var paper := _flat_box(Vector3(0.46, 0.025, 0.34), Vector3(0, 0.035, 0), Color(0.78, 0.75, 0.64))
	paper.rotation.y = rng.randf_range(-0.25, 0.25)
	add_child(paper)
	for i in range(3):
		add_child(_flat_box(Vector3(0.27, 0.008, 0.018), Vector3(-0.04, 0.052, -0.09 + i * 0.075), Color(0.25, 0.27, 0.25)))

func _make_crushed_carton(rng: RandomNumberGenerator) -> void:
	var carton := _flat_box(Vector3(0.40, 0.20, 0.28), Vector3(0, 0.11, 0), Color(0.68, 0.48, 0.26))
	carton.rotation.y = rng.randf_range(-0.5, 0.5)
	add_child(carton)
	add_child(_flat_box(Vector3(0.42, 0.035, 0.30), Vector3(0, 0.21, 0), Color(0.78, 0.62, 0.38)))

func _make_food_box(rng: RandomNumberGenerator) -> void:
	var box := _flat_box(Vector3(0.38, 0.22, 0.32), Vector3(0, 0.12, 0), Color(0.72, 0.30, 0.13))
	box.rotation.y = rng.randf_range(-0.4, 0.4)
	add_child(box)
	add_child(_flat_box(Vector3(0.18, 0.015, 0.33), Vector3(0, 0.24, 0), Color(0.92, 0.78, 0.46)))

func _make_rusted_pipe(rng: RandomNumberGenerator) -> void:
	var pipe := _cylinder_piece(0.12, 0.12, 0.72, Vector3(0, 0.10, 0), Color(0.48, 0.29, 0.18))
	pipe.rotation_degrees.z = 90
	pipe.rotation.y = rng.randf_range(-0.2, 0.2)
	add_child(pipe)
	for x in [-0.25, 0.25]:
		var collar := _cylinder_piece(0.15, 0.15, 0.07, Vector3(x, 0.10, 0), Color(0.30, 0.32, 0.30))
		collar.rotation_degrees.z = 90
		add_child(collar)

func _make_circuit_board(rng: RandomNumberGenerator) -> void:
	var board := _flat_box(Vector3(0.48, 0.045, 0.34), Vector3(0, 0.055, 0), Color(0.08, 0.34, 0.25))
	board.rotation.y = rng.randf_range(0, TAU)
	add_child(board)
	for i in range(5):
		add_child(_flat_box(Vector3(0.075, 0.055, 0.07), Vector3(-0.16 + i * 0.08, 0.10, 0.04), [Color(0.12, 0.13, 0.14), Color(0.72, 0.62, 0.30)][i % 2]))
	for x in [-0.18, 0.0, 0.18]:
		add_child(_flat_box(Vector3(0.018, 0.012, 0.23), Vector3(x, 0.085, -0.05), Color(0.82, 0.68, 0.30)))

func _make_broken_fan(rng: RandomNumberGenerator) -> void:
	var hub := _cylinder_piece(0.13, 0.13, 0.10, Vector3(0, 0.10, 0), Color(0.36, 0.40, 0.41))
	hub.rotation_degrees.x = 90
	add_child(hub)
	for i in range(4):
		var blade := _flat_box(Vector3(0.42, 0.045, 0.13), Vector3(0.22, 0.10, 0), Color(0.55, 0.59, 0.58))
		blade.rotation.y = float(i) * PI / 2.0
		blade.rotation.z = rng.randf_range(-0.12, 0.12)
		add_child(blade)

func _make_scrap_spring(rng: RandomNumberGenerator) -> void:
	for i in range(5):
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = 0.07
		torus.outer_radius = 0.13
		ring.mesh = torus
		ring.position = Vector3(0, 0.12 + i * 0.045, 0)
		ring.material_override = _material(Color(0.48, 0.52, 0.52))
		add_child(ring)
	add_child(_flat_box(Vector3(0.52, 0.055, 0.07), Vector3(0, 0.10, 0), Color(0.34, 0.38, 0.39)))

func _make_oil_can(rng: RandomNumberGenerator) -> void:
	var can := _cylinder_piece(0.18, 0.18, 0.42, Vector3(0, 0.21, 0), Color(0.20, 0.28, 0.27))
	can.rotation_degrees.z = rng.randf_range(65.0, 90.0)
	add_child(can)
	add_child(_flat_box(Vector3(0.19, 0.12, 0.025), Vector3(0, 0.22, -0.17), Color(0.86, 0.61, 0.16)))
	add_child(_cylinder_piece(0.055, 0.055, 0.10, Vector3(0.18, 0.40, 0), Color(0.62, 0.66, 0.62)))

func _make_banana_peel(rng: RandomNumberGenerator) -> void:
	for side in [-1.0, 1.0]:
		var peel := _flat_box(Vector3(0.34, 0.045, 0.12), Vector3(side * 0.13, 0.035, 0), Color(0.88, 0.72, 0.12))
		peel.rotation.y = side * 0.28
		add_child(peel)
	add_child(_flat_box(Vector3(0.14, 0.05, 0.10), Vector3(0, 0.055, 0), Color(0.43, 0.31, 0.12)))
	rotation.y = rng.randf_range(0.0, TAU)

func _make_plastic_bag(rng: RandomNumberGenerator) -> void:
	var bag := MeshInstance3D.new()
	bag.name = "WrinkledPlasticShoppingBag"
	bag.mesh = _mobile_plastic_bag_mesh()
	bag.position.y = 0.025
	bag.rotation.y = rng.randf_range(0.0, TAU)
	var material := _material(Color.WHITE, true)
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.30
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	bag.material_override = material
	add_child(bag)


func _make_milk_carton(rng: RandomNumberGenerator) -> void:
	var body := _flat_box(Vector3(0.34, 0.42, 0.28), Vector3(0, 0.23, 0), Color(0.82, 0.84, 0.77))
	body.rotation.y = rng.randf_range(-0.18, 0.18)
	add_child(body)
	add_child(_flat_box(Vector3(0.36, 0.10, 0.30), Vector3(0, 0.49, 0), Color(0.30, 0.55, 0.72)))
	add_child(_cylinder_piece(0.045, 0.045, 0.07, Vector3(0.08, 0.57, 0), Color(0.94, 0.91, 0.76)))

func _make_old_tire(rng: RandomNumberGenerator) -> void:
	var tire := MeshInstance3D.new()
	tire.name = "WornIndustrialTire"
	tire.mesh = _mobile_tire_mesh()
	tire.position.y = 0.40
	tire.rotation_degrees.x = 90.0
	tire.rotation.y = rng.randf_range(0.0, TAU)
	var material := _material(Color.WHITE)
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.94
	material.metallic = 0.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	tire.material_override = material
	add_child(tire)

func _make_paint_bucket(rng: RandomNumberGenerator) -> void:
	var bucket := MeshInstance3D.new()
	bucket.name = "WornPaintBucket"
	bucket.mesh = _mobile_paint_bucket_mesh(rng)
	bucket.position.y = 0.015
	bucket.rotation.y = rng.randf_range(0.0, TAU)
	bucket.rotation.z = rng.randf_range(-0.06, 0.06)
	var material := _material(Color.WHITE)
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.78
	material.metallic = 0.38
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	bucket.material_override = material
	add_child(bucket)

func _make_toy_blocks(rng: RandomNumberGenerator) -> void:
	var blocks := MeshInstance3D.new()
	blocks.name = "BrokenPlasticToyBlocks"
	blocks.mesh = _mobile_toy_blocks_mesh(rng)
	blocks.position.y = 0.025
	blocks.rotation.y = rng.randf_range(0.0, TAU)
	var material := _material(Color.WHITE)
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.48
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	blocks.material_override = material
	add_child(blocks)

func _make_glass_jar(rng: RandomNumberGenerator) -> void:
	var jar := MeshInstance3D.new()
	jar.name = "ThickGlassPreserveJar"
	jar.mesh = _mobile_glass_jar_mesh()
	jar.position.y = 0.015
	jar.rotation.z = rng.randf_range(-0.10, 0.10)
	var material := _material(Color(0.58, 0.80, 0.73, 0.42), true)
	material.roughness = 0.18
	material.metallic = 0.05
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	jar.material_override = material
	add_child(jar)

func _make_takeaway_tray(rng: RandomNumberGenerator) -> void:
	var tray := _flat_box(Vector3(0.48, 0.07, 0.36), Vector3(0, 0.07, 0), Color(0.72, 0.73, 0.68))
	tray.rotation.y = rng.randf_range(0.0, TAU)
	add_child(tray)
	for x in [-0.16, 0.0, 0.16]:
		add_child(_flat_box(Vector3(0.12, 0.045, 0.25), Vector3(x, 0.12, 0), Color(0.83, 0.82, 0.75)))

func _make_cable_bundle(rng: RandomNumberGenerator) -> void:
	var bundle := MeshInstance3D.new()
	bundle.name = "RecoveredPowerCableBundle"
	bundle.mesh = _mobile_cable_bundle_mesh()
	bundle.position.y = 0.02
	bundle.rotation.y = rng.randf_range(0.0, TAU)
	var material := _material(Color.WHITE)
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.56
	material.metallic = 0.12
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	bundle.material_override = material
	add_child(bundle)


func _make_old_television(rng: RandomNumberGenerator) -> void:
	var television := MeshInstance3D.new()
	television.name = "BrokenCRT_Television"
	television.mesh = _mobile_old_television_mesh(rng)
	television.position.y = 0.015
	television.rotation.y = rng.randf_range(-0.12, 0.12)
	var material := _material(Color.WHITE)
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.68
	material.metallic = 0.12
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	television.material_override = material
	add_child(television)

func _make_safety_helmet(rng: RandomNumberGenerator) -> void:
	var helmet := MeshInstance3D.new()
	helmet.name = "IndustrialSafetyHelmet"
	helmet.mesh = _mobile_safety_helmet_mesh()
	helmet.position.y = 0.015
	helmet.rotation.y = rng.randf_range(0.0, TAU)
	var material := _material(Color.WHITE)
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.42
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	helmet.material_override = material
	add_child(helmet)


func _flat_box(size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.position = pos
	mesh.material_override = _material(color)
	return mesh

func _cylinder_piece(top: float, bottom: float, height: float, pos: Vector3, color: Color) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var shape := CylinderMesh.new()
	shape.top_radius = top
	shape.bottom_radius = bottom
	shape.height = height
	shape.radial_segments = 16
	mesh.mesh = shape
	mesh.position = pos
	mesh.material_override = _material(color)
	return mesh

func _material(color: Color, transparent := false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.48
	material.metallic = 0.12
	if transparent:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.roughness = 0.28
	return material
