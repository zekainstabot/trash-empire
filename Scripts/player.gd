extends CharacterBody3D
class_name TrashPlayer

@export var move_speed: float = 5.0
@export var acceleration: float = 24.0
@export var braking: float = 30.0
@export var turn_speed: float = 12.0

var move_input := Vector2.ZERO
var camera_pivot: Node3D

func _ready() -> void:
	# Keep the capsule grounded and allow it to slide cleanly around corners
	# instead of catching on tiny seams between nearby collision shapes.
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	up_direction = Vector3.UP
	floor_snap_length = 0.28
	max_slides = 8
	safe_margin = 0.02

func _physics_process(delta: float) -> void:
	var input_dir := move_input
	if input_dir.length_squared() < 0.0001:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	input_dir = input_dir.limit_length(1.0)

	var direction := Vector3(input_dir.x, 0.0, input_dir.y)
	if is_instance_valid(camera_pivot):
		# Use the camera rig's flattened axes so joystick movement stays on the
		# ground plane and remains consistent with the camera's screen direction.
		var camera_right := camera_pivot.global_basis.x
		var camera_forward := camera_pivot.global_basis.z
		camera_right.y = 0.0
		camera_forward.y = 0.0
		if camera_right.length_squared() > 0.0001:
			camera_right = camera_right.normalized()
		if camera_forward.length_squared() > 0.0001:
			camera_forward = camera_forward.normalized()
		direction = camera_right * input_dir.x + camera_forward * input_dir.y

	direction.y = 0.0
	if direction.length_squared() > 0.0001:
		direction = direction.normalized()

	var target_velocity := direction * move_speed * input_dir.length()
	var response := acceleration if direction.length_squared() > 0.0001 else braking
	var horizontal := Vector3(velocity.x, 0.0, velocity.z).move_toward(target_velocity, response * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z

	if not is_on_floor():
		velocity.y -= 22.0 * delta
	else:
		velocity.y = -0.5

	move_and_slide()

	# The robot's face and chest point along local -Z.
	if direction.length_squared() > 0.0025:
		var target_yaw := atan2(-direction.x, -direction.z)
		rotation.y = rotate_toward(rotation.y, target_yaw, turn_speed * delta)

func set_touch_move(value: Vector2) -> void:
	move_input = value.limit_length(1.0)
