extends CharacterBody3D

@onready var camera_3d: Camera3D = $SpringArmPivot/SpringArm3D/Camera3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var attack:bool = false
var got_hurt = false
var hurt_time = 0.0
func anim_timer(a:float,delta:float):
	a+= delta
	return a

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_pressed("attack"):
		attack = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (camera_3d.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if got_hurt:
		velocity += hit_velocity
		
		hurt_time = anim_timer(hurt_time,delta)
		if hurt_time > 0.15:
			hurt_time = 0.0
			got_hurt = false

	move_and_slide()

var hit_velocity:Vector3 = Vector3.ZERO
func _on_hurtbox_3d_body_entered(body: Node3D) -> void:
	if body != self:
		var dir = body.global_position - global_position
		var move_dir = dir.normalized()*4.0 #dir.cross(Vector3.UP)
		hit_velocity = move_dir*SPEED
		hit_velocity.y = 0.0
		label_3d.text = var_to_str(hurtbox_3d.health._current)
	
@onready var label_3d: Label3D = %Label3D

@onready var hurtbox_3d: Hurtbox3D = $Hurtbox3D

func _on_hurtbox_3d_area_entered(area: Area3D) -> void:
	if area is Hitbox3D:
		if (area as Hitbox3D).owner == self:
			return
		hurtbox_3d.take_damage((area as Hitbox3D).damage, (area as Hitbox3D).get_knockback(), (area as Hitbox3D))
		label_3d.text = var_to_str(hurtbox_3d.health._current)
