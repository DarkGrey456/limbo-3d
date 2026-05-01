extends Node3D
var _is_dead: bool = false
const SPEED := 40.0
var direction :Vector3 = Vector3.FORWARD
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@onready var root: MeshInstance3D = $root
@onready var collision_shape_3d: CollisionShape3D = $Hitbox3D/CollisionShape3D

func _physics_process(delta: float) -> void:
	global_position += direction.normalized() * SPEED * delta
	
func _die() -> void:
	if _is_dead:
		return
	_is_dead = true
	root.hide()
	collision_shape_3d.set_deferred(&"disabled", true)
	#death.emitting = true
	#await death.finished
	queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_hitbox_3d_area_entered(area: Area3D) -> void:
	_die() # Replace with function body.
