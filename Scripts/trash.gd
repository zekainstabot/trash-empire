extends Node3D
class_name TrashItem

var spin_speed := 0.0

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	spin_speed = rng.randf_range(-0.45, 0.45)
	match rng.randi_range(0, 5):
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
		_:
			_make_cardboard_scrap(rng)
	rotation.y = rng.randf_range(0.0, TAU)

func _process(delta: float) -> void:
	rotation.y += spin_speed * delta

func _make_plastic_bottle(rng: RandomNumberGenerator) -> void:
	var body := MeshInstance3D.new()
	var shape := CylinderMesh.new()
	shape.top_radius = 0.125
	shape.bottom_radius = 0.17
	shape.height = 0.48
	shape.radial_segments = 9
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
	shape.radial_segments = 10
	mesh.mesh = shape
	mesh.position = pos
	mesh.material_override = _material(color)
	return mesh

func _material(color: Color, transparent := false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.62
	if transparent:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material
