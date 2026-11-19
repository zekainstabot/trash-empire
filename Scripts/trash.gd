extends Node3D
class_name TrashItem

func _ready() -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.55, 0.55, 0.55)
	mesh.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = [Color(0.7, 0.78, 0.25), Color(0.25, 0.65, 0.55), Color(0.72, 0.48, 0.28)][randi() % 3]
	mesh.material_override = material
	add_child(mesh)
	var collision := StaticBody3D.new()
	var shape_node := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.55, 0.55, 0.55)
	shape_node.shape = shape
	collision.add_child(shape_node)
	add_child(collision)
