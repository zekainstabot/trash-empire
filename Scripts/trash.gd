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
		3, 4, 13, 21, 22, 28:
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
		5, 14, 15, 17, 26, 31:
			var crate := BoxMesh.new()
			crate.size = Vector3(0.42, 0.18, 0.32)
			shape = crate
			base_color = {
				5: Color(0.59, 0.40, 0.23),
				14: Color(0.68, 0.49, 0.27),
				15: Color(0.72, 0.31, 0.14),
				17: Color(0.08, 0.34, 0.25),
				26: Color(0.18, 0.46, 0.82),
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
			elif item_roll == 26:
				crate.size = Vector3(0.26, 0.20, 0.24)
		6, 20, 25:
			var canister := CylinderMesh.new()
			canister.top_radius = 0.15 if item_roll != 25 else 0.16
			canister.bottom_radius = 0.15 if item_roll != 25 else 0.14
			canister.height = 0.38 if item_roll != 25 else 0.34
			canister.radial_segments = 8
			shape = canister
			base_color = Color(0.18, 0.20, 0.22) if item_roll == 6 else (Color(0.20, 0.29, 0.27) if item_roll == 20 else Color(0.73, 0.32, 0.16))
			visual_position.y = 0.19 if item_roll != 25 else 0.17
			metallic = 0.36
		7:
			var shard := BoxMesh.new()
			shard.size = Vector3(0.32, 0.025, 0.22)
			shape = shard
			base_color = Color(0.44, 0.72, 0.76, 0.72)
			transparent = true
			visual_position.y = 0.035
			visual_rotation.y = rng.randf_range(0.0, TAU)
		9:
			var shoe := BoxMesh.new()
			shoe.size = Vector3(0.50, 0.17, 0.26)
			shape = shoe
			base_color = Color(0.27, 0.23, 0.19)
			visual_position.y = 0.09
			visual_rotation.y = rng.randf_range(0.0, TAU)
		10, 24, 27, 29:
			var ring := TorusMesh.new()
			ring.inner_radius = 0.20 if item_roll != 24 else 0.25
			ring.outer_radius = 0.34 if item_roll != 24 else 0.43
			ring.rings = 8
			ring.ring_segments = 12
			shape = ring
			base_color = {
				10: Color(0.48, 0.43, 0.34),
				24: Color(0.055, 0.065, 0.067),
				27: Color(0.45, 0.70, 0.64, 0.78),
				29: Color(0.13, 0.16, 0.18)
			}[item_roll]
			visual_position.y = 0.12 if item_roll != 24 else 0.40
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
		30:
			var helmet := SphereMesh.new()
			helmet.radius = 0.25
			helmet.height = 0.32
			helmet.radial_segments = 8
			helmet.rings = 5
			shape = helmet
			base_color = Color(0.92, 0.66, 0.12)
			visual_position.y = 0.15
			visual_scale = Vector3(1.25, 0.70, 1.0)

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
	if item_roll in [0, 1, 2, 8]:
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
	var wrapper := _flat_box(Vector3(0.52, 0.025, 0.30), Vector3(0, 0.035, 0), [Color(0.88, 0.22, 0.12), Color(0.16, 0.48, 0.82), Color(0.92, 0.68, 0.12)][rng.randi_range(0, 2)])
	add_child(wrapper)
	var folded_left := _flat_box(Vector3(0.13, 0.035, 0.24), Vector3(-0.28, 0.055, 0), Color(0.82, 0.82, 0.72))
	folded_left.rotation.y = -0.35
	add_child(folded_left)
	var folded_right := _flat_box(Vector3(0.13, 0.035, 0.24), Vector3(0.28, 0.055, 0), Color(0.90, 0.88, 0.78))
	folded_right.rotation.y = 0.35
	add_child(folded_right)
	var print_mark := _flat_box(Vector3(0.18, 0.012, 0.08), Vector3(0, 0.058, -0.02), Color(0.96, 0.88, 0.62))
	add_child(print_mark)
	rotation.z = rng.randf_range(-0.08, 0.08)

func _make_crumpled_paper(rng: RandomNumberGenerator) -> void:
	for i in range(5):
		var ball := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = rng.randf_range(0.10, 0.17)
		sphere.height = sphere.radius * 1.45
		sphere.radial_segments = 7
		sphere.rings = 4
		ball.mesh = sphere
		ball.position = Vector3(rng.randf_range(-0.14, 0.14), rng.randf_range(0.04, 0.13), rng.randf_range(-0.12, 0.12))
		ball.scale = Vector3(1.0, 0.72, 0.88)
		ball.material_override = _material([Color(0.88, 0.84, 0.72), Color(0.72, 0.68, 0.58), Color(0.94, 0.91, 0.82)][rng.randi_range(0, 2)])
		add_child(ball)

func _make_cardboard_scrap(rng: RandomNumberGenerator) -> void:
	var sheet := _flat_box(Vector3(0.56, 0.045, 0.42), Vector3(0, 0.035, 0), Color(0.58, 0.39, 0.22))
	add_child(sheet)
	var flap := _flat_box(Vector3(0.22, 0.055, 0.40), Vector3(0.20, 0.075, 0), Color(0.70, 0.49, 0.29))
	flap.rotation.z = rng.randf_range(-0.22, 0.22)
	add_child(flap)
	for x in [-0.17, 0.0, 0.17]:
		var corrugation := _flat_box(Vector3(0.025, 0.012, 0.34), Vector3(x, 0.065, 0), Color(0.42, 0.28, 0.16))
		add_child(corrugation)


func _make_battery(rng: RandomNumberGenerator) -> void:
	var body := _cylinder_piece(0.12, 0.12, 0.42, Vector3(0, 0.21, 0), Color(0.18, 0.19, 0.22))
	body.rotation_degrees.z = rng.randf_range(-15.0, 15.0)
	add_child(body)
	add_child(_flat_box(Vector3(0.20, 0.12, 0.025), Vector3(0, 0.22, -0.13), Color(0.88, 0.25, 0.12)))
	add_child(_flat_box(Vector3(0.08, 0.025, 0.06), Vector3(0, 0.44, 0), Color(0.72, 0.75, 0.74)))

func _make_broken_glass(rng: RandomNumberGenerator) -> void:
	for i in range(4):
		var shard := _flat_box(Vector3(rng.randf_range(0.16, 0.30), 0.025, rng.randf_range(0.10, 0.22)), Vector3(rng.randf_range(-0.22, 0.22), 0.04, rng.randf_range(-0.18, 0.18)), Color(0.45, 0.75, 0.78, 0.75))
		shard.rotation.y = rng.randf_range(0, TAU)
		add_child(shard)

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
	add_child(_flat_box(Vector3(0.48, 0.16, 0.25), Vector3(0.03, 0.10, 0), Color(0.25, 0.22, 0.18)))
	add_child(_flat_box(Vector3(0.24, 0.20, 0.23), Vector3(-0.10, 0.23, 0), Color(0.38, 0.32, 0.25)))
	# Distinct toe cap, layered rubber sole, heel and worn lace eyelets.
	add_child(_flat_box(Vector3(0.54, 0.055, 0.27), Vector3(0.03, 0.025, 0), Color(0.12, 0.12, 0.11)))
	add_child(_flat_box(Vector3(0.18, 0.07, 0.24), Vector3(-0.19, 0.16, 0), Color(0.30, 0.27, 0.23)))
	for i in range(4):
		var lace := _flat_box(Vector3(0.13, 0.018, 0.025), Vector3(-0.12 + i * 0.045, 0.285, -0.13), Color(0.82, 0.78, 0.68))
		lace.rotation.z = -0.12
		add_child(lace)
	for side in [-1.0, 1.0]:
		add_child(_cylinder_piece(0.018, 0.018, 0.025, Vector3(-0.13, 0.27, side * 0.13), Color(0.68, 0.64, 0.56)))
	rotation.z = rng.randf_range(-0.15, 0.15)

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
	var body := _flat_box(Vector3(0.46, 0.055, 0.38), Vector3(0, 0.12, 0), Color(0.74, 0.82, 0.78, 0.78))
	body.rotation.y = rng.randf_range(-0.35, 0.35)
	add_child(body)
	for side in [-1.0, 1.0]:
		var handle := _flat_box(Vector3(0.10, 0.22, 0.055), Vector3(side * 0.14, 0.23, 0), Color(0.82, 0.88, 0.82, 0.82))
		handle.rotation.z = side * 0.25
		add_child(handle)

func _make_milk_carton(rng: RandomNumberGenerator) -> void:
	var body := _flat_box(Vector3(0.34, 0.42, 0.28), Vector3(0, 0.23, 0), Color(0.82, 0.84, 0.77))
	body.rotation.y = rng.randf_range(-0.18, 0.18)
	add_child(body)
	add_child(_flat_box(Vector3(0.36, 0.10, 0.30), Vector3(0, 0.49, 0), Color(0.30, 0.55, 0.72)))
	add_child(_cylinder_piece(0.045, 0.045, 0.07, Vector3(0.08, 0.57, 0), Color(0.94, 0.91, 0.76)))

func _make_old_tire(rng: RandomNumberGenerator) -> void:
	# A clean, recognizable discarded tire. Keep the center hollow and avoid
	# detached tread blocks or bolts that look like extra debris around it.
	var tire := MeshInstance3D.new()
	tire.name = "DiscardedTire"
	var torus := TorusMesh.new()
	torus.inner_radius = 0.25
	torus.outer_radius = 0.43
	torus.rings = 16
	torus.ring_segments = 32
	tire.mesh = torus
	tire.position.y = 0.43
	tire.rotation_degrees.x = 90.0
	tire.material_override = _material(Color(0.055, 0.065, 0.067))
	add_child(tire)
	rotation.y = rng.randf_range(0.0, TAU)

func _make_paint_bucket(rng: RandomNumberGenerator) -> void:
	add_child(_cylinder_piece(0.19, 0.16, 0.36, Vector3(0, 0.19, 0), Color(0.72, 0.31, 0.16)))
	add_child(_cylinder_piece(0.20, 0.20, 0.045, Vector3(0, 0.38, 0), Color(0.58, 0.62, 0.61)))
	add_child(_flat_box(Vector3(0.20, 0.12, 0.025), Vector3(0, 0.20, -0.16), Color(0.92, 0.84, 0.62)))
	rotation.y = rng.randf_range(0.0, TAU)

func _make_toy_blocks(rng: RandomNumberGenerator) -> void:
	var colors := [Color(0.86, 0.18, 0.13), Color(0.16, 0.43, 0.82), Color(0.92, 0.70, 0.12), Color(0.18, 0.62, 0.38)]
	for i in range(4):
		var block := _flat_box(Vector3(0.20, 0.18, 0.20), Vector3(rng.randf_range(-0.20, 0.20), 0.09 + float(i % 2) * 0.18, rng.randf_range(-0.18, 0.18)), colors[i])
		block.rotation.y = rng.randf_range(0.0, TAU)
		add_child(block)

func _make_glass_jar(rng: RandomNumberGenerator) -> void:
	var jar := _cylinder_piece(0.14, 0.16, 0.34, Vector3(0, 0.18, 0), Color(0.48, 0.72, 0.65))
	jar.rotation_degrees.z = rng.randf_range(-12.0, 12.0)
	add_child(jar)
	add_child(_cylinder_piece(0.075, 0.075, 0.08, Vector3(0, 0.37, 0), Color(0.72, 0.76, 0.72)))

func _make_takeaway_tray(rng: RandomNumberGenerator) -> void:
	var tray := _flat_box(Vector3(0.48, 0.07, 0.36), Vector3(0, 0.07, 0), Color(0.72, 0.73, 0.68))
	tray.rotation.y = rng.randf_range(0.0, TAU)
	add_child(tray)
	for x in [-0.16, 0.0, 0.16]:
		add_child(_flat_box(Vector3(0.12, 0.045, 0.25), Vector3(x, 0.12, 0), Color(0.83, 0.82, 0.75)))

func _make_cable_bundle(rng: RandomNumberGenerator) -> void:
	for i in range(3):
		var cable := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = 0.10
		torus.outer_radius = 0.15
		torus.rings = 8
		torus.ring_segments = 16
		cable.mesh = torus
		cable.position = Vector3(rng.randf_range(-0.10, 0.10), 0.13 + float(i) * 0.035, rng.randf_range(-0.08, 0.08))
		cable.rotation_degrees.x = 90.0
		cable.rotation.z = rng.randf_range(-0.35, 0.35)
		cable.material_override = _material([Color(0.12, 0.14, 0.16), Color(0.72, 0.24, 0.13), Color(0.12, 0.38, 0.62)][i])
		add_child(cable)


func _make_old_television(rng: RandomNumberGenerator) -> void:
	# Abandoned CRT television: deep rear cabinet, curved-looking glass face,
	# thick bezel, side controls, ventilation slots and a snapped aerial.
	var cabinet := _flat_box(Vector3(0.78, 0.58, 0.48), Vector3(0, 0.32, 0.02), Color(0.23, 0.25, 0.24))
	cabinet.rotation.y = rng.randf_range(-0.12, 0.12)
	add_child(cabinet)
	var screen := _flat_box(Vector3(0.59, 0.40, 0.035), Vector3(-0.035, 0.35, -0.235), Color(0.055, 0.075, 0.08))
	add_child(screen)
	var glass := _flat_box(Vector3(0.54, 0.35, 0.012), Vector3(-0.035, 0.35, -0.258), Color(0.12, 0.19, 0.20, 0.88))
	add_child(glass)
	for x in [-0.36, 0.29]:
		add_child(_flat_box(Vector3(0.055, 0.48, 0.055), Vector3(x, 0.35, -0.255), Color(0.37, 0.38, 0.35)))
	for y in [0.11, 0.59]:
		add_child(_flat_box(Vector3(0.70, 0.055, 0.055), Vector3(-0.035, y, -0.255), Color(0.37, 0.38, 0.35)))
	# Broken glass cracks on the screen.
	for i in range(4):
		var crack := _flat_box(Vector3(rng.randf_range(0.12, 0.25), 0.008, 0.006), Vector3(rng.randf_range(-0.20, 0.14), rng.randf_range(0.22, 0.48), -0.268), Color(0.63, 0.72, 0.70))
		crack.rotation.z = rng.randf_range(-0.9, 0.9)
		add_child(crack)
	var control_panel := _flat_box(Vector3(0.12, 0.34, 0.045), Vector3(0.34, 0.34, -0.25), Color(0.18, 0.19, 0.18))
	add_child(control_panel)
	for y in [0.25, 0.39, 0.49]:
		var knob := _cylinder_piece(0.035, 0.035, 0.025, Vector3(0.34, y, -0.282), Color(0.72, 0.70, 0.62))
		knob.rotation_degrees.x = 90
		add_child(knob)
	for i in range(5):
		add_child(_flat_box(Vector3(0.018, 0.24, 0.018), Vector3(-0.20 + i * 0.09, 0.32, 0.27), Color(0.10, 0.11, 0.10)))
	add_child(_flat_box(Vector3(0.22, 0.045, 0.18), Vector3(0, 0.025, 0.02), Color(0.16, 0.17, 0.16)))
	rotation.y = rng.randf_range(0.0, TAU)

func _make_safety_helmet(rng: RandomNumberGenerator) -> void:
	var shell := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.27
	sphere.height = 0.34
	sphere.radial_segments = 12
	sphere.rings = 6
	shell.mesh = sphere
	shell.position.y = 0.16
	shell.scale = Vector3(1.25, 0.70, 1.0)
	shell.material_override = _material(Color(0.91, 0.66, 0.12))
	add_child(shell)
	add_child(_flat_box(Vector3(0.62, 0.055, 0.34), Vector3(0, 0.055, 0), Color(0.88, 0.61, 0.10)))
	rotation.y = rng.randf_range(0.0, TAU)


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
