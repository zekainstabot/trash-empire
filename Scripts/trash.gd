extends Node3D
class_name TrashItem

var spin_speed := 0.0

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	spin_speed = rng.randf_range(-0.7, 0.7)
	var kind := rng.randi_range(0, 3)
	match kind:
		0:
			_make_bottle()
		1:
			_make_box(Color(0.72, 0.48, 0.24), Vector3(0.62, 0.48, 0.48))
		2:
			_make_can()
		_:
			_make_box(Color(0.24, 0.58, 0.49), Vector3(0.52, 0.58, 0.52))
	rotation.y = rng.randf_range(0.0, TAU)

func _process(delta: float) -> void:
	rotation.y += spin_speed * delta

func _make_box(color: Color, size: Vector3) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = _material(color)
	add_child(mesh)

func _make_bottle() -> void:
	var body := MeshInstance3D.new()
	var shape := CylinderMesh.new()
	shape.top_radius = 0.13
	shape.bottom_radius = 0.19
	shape.height = 0.55
	body.mesh = shape
	body.material_override = _material(Color(0.23, 0.68, 0.48))
	body.rotation_degrees.z = 90
	add_child(body)
	var cap := MeshInstance3D.new()
	var cap_mesh := CylinderMesh.new()
	cap_mesh.top_radius = 0.075
	cap_mesh.bottom_radius = 0.075
	cap_mesh.height = 0.12
	cap.mesh = cap_mesh
	cap.position.x = 0.31
	cap.rotation_degrees.z = 90
	cap.material_override = _material(Color(0.9, 0.72, 0.16))
	add_child(cap)

func _make_can() -> void:
	var mesh := MeshInstance3D.new()
	var can := CylinderMesh.new()
	can.top_radius = 0.19
	can.bottom_radius = 0.19
	can.height = 0.52
	mesh.mesh = can
	mesh.material_override = _material(Color(0.72, 0.75, 0.77))
	mesh.rotation_degrees.z = 90
	add_child(mesh)
	var stripe := MeshInstance3D.new()
	var stripe_mesh := CylinderMesh.new()
	stripe_mesh.top_radius = 0.195
	stripe_mesh.bottom_radius = 0.195
	stripe_mesh.height = 0.13
	stripe.mesh = stripe_mesh
	stripe.rotation_degrees.z = 90
	stripe.material_override = _material(Color(0.78, 0.24, 0.18))
	add_child(stripe)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.62
	return material
