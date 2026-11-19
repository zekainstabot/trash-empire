extends CharacterBody3D
class_name TrashPlayer

@export var move_speed: float = 5.0
var move_input := Vector2.ZERO
var camera_pivot: Node3D

func _physics_process(_delta: float) -> void:
	var input_dir := move_input
	if input_dir.length() < 0.01:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3(input_dir.x, 0.0, input_dir.y)
	if camera_pivot:
		direction = camera_pivot.global_basis.x * direction.x + camera_pivot.global_basis.z * direction.z
	direction.y = 0.0
	direction = direction.normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	if not is_on_floor():
		velocity.y -= 22.0 * _delta
	else:
		velocity.y = -0.5
	move_and_slide()
	if direction.length() > 0.1:
		look_at(global_position + direction, Vector3.UP)

func set_touch_move(value: Vector2) -> void:
	move_input = value.limit_length(1.0)
