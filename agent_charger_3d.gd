#*
#* agent_base.gd
#* =============================================================================
#* Copyright (c) 2023-present Serhii Snitsaruk and the LimboAI contributors.
#*
#* Use of this source code is governed by an MIT-style
#* license that can be found in the LICENSE file or at
#* https://opensource.org/licenses/MIT.
#* =============================================================================
#*
extends CharacterBody3D
## Base agent script that is shared by all agents.

signal death

# Resource file to use in summon_minion() method.
const MINION_RESOURCE := "res://demo/agents/03_agent_imp.tscn"

# Projectile resource.
const NinjaStar := preload("res://demo/agents/ninja_star/ninja_star.tscn")
const Fireball := preload("res://demo/agents/fireball/fireball.tscn")
const NINJASTAR_3D = preload("uid://dovg4befljlgq")

var summon_count: int = 0

var _frames_since_facing_update: int = 0
var _is_dead: bool = false
var _moved_this_frame: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var health: Health3D = $Health3D
@onready var root: Node3D = $Root
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D2
var ray_cast_3d: RayCast3D = RayCast3D.new()
@onready var label_3d: Label3D = %Label3D

func set_text(text:String):
	if label_3d:
		label_3d.text = text

func _ready() -> void:
	health.damaged.connect(_damaged)
	health.death.connect(die)
	ray_cast_3d.set_collision_mask_value(2,true)


func _physics_process(_delta: float) -> void:
	_post_physics_process.call_deferred()


func _post_physics_process() -> void:
	if not _moved_this_frame:
		velocity = lerp(velocity, Vector3.ZERO, 0.5)
	_moved_this_frame = false


func move(p_velocity: Vector3) -> void:
	#ray_cast_3d.position = self.global_position
	#ray_cast_3d.target_position = Vector3(0.0,0.0,2.0)
	#ray_cast_3d.force_raycast_update()
	#if ray_cast_3d.is_colliding():
	#
		#velocity = lerp(velocity, 3.0*root.global_basis.x, 0.2)
	#else:
	velocity = lerp(velocity, p_velocity, 0.2)
	move_and_slide()
	_moved_this_frame = true


## Update agent's facing in the velocity direction.
func update_facing() -> void:
	_frames_since_facing_update += 1
	if _frames_since_facing_update > 3:
		face_dir(velocity)

## Face specified direction.
func face_dir(dir:Vector3) -> void:
	look_at((dir*100  + global_position))

## Returns 1.0 when agent is facing right.
## Returns -1.0 when agent is facing left.
func get_facing() -> Vector3:
	return -global_basis.z


func throw_ninja_star() -> void:
	var ninja_star := NINJASTAR_3D.instantiate()
	ninja_star.direction = get_facing()
	
	get_parent().add_child(ninja_star)
	ninja_star.global_position = global_position +4.0 * get_facing()
	ninja_star.look_at(ninja_star.direction + ninja_star.global_position)

func spit_fire() -> void:
	var fireball := Fireball.instantiate()
	fireball.dir = get_facing()
	get_parent().add_child(fireball)
	fireball.global_position = global_position + Vector3.RIGHT * 100.0 * get_facing()


func summon_minion(p_position: Vector3) -> void:
	var minion: CharacterBody3D = load(MINION_RESOURCE).instantiate()
	get_parent().add_child(minion)
	minion.position = p_position
	minion.play_summoning_effect()
	summon_count += 1
	minion.death.connect(func(): summon_count -= 1)


## Method is used when this agent is summoned from the dungeons of the castle AaaAaaAAAAAaaAAaaaaaa
func play_summoning_effect() -> void:
	pass#	summoning_effect.emitting = true


## Is specified position inside the arena (not inside an obstacle)?
func is_good_position(p_position: Vector3) -> bool:
	var space_state := get_world_3d().direct_space_state
	var params := PhysicsPointQueryParameters3D.new()
	params.position = p_position
	params.collision_mask = 1 # Obstacle layer has value 1
	var collision := space_state.intersect_point(params)
	if collision.is_empty():
		print("Is good position!")
	else:
		print ("is not good position")
	return collision.is_empty()


## When agent is damaged...
func _damaged(_amount: float, knockback: Vector3) -> void:
	apply_knockback(knockback)
	animation_player.play(&"hurt")
	var btplayer := get_node_or_null(^"BTPlayer") as BTPlayer
	if btplayer:
		btplayer.set_active(false)
	var hsm := get_node_or_null(^"LimboHSM")
	if hsm:
		hsm.set_active(false)
	#await animation_player.animation_finished
	if btplayer and not _is_dead:
		btplayer.restart()
	if hsm and not _is_dead:
		hsm.set_active(true)


## Push agent in the knockback direction for the specified number of physics frames.
func apply_knockback(knockback: Vector3, frames: int = 10) -> void:
	if knockback.is_zero_approx():
		return
	for i in range(frames):
		move(knockback)
		await get_tree().physics_frame


func die() -> void:
	if _is_dead:
		return
	set_text("DEAD")

	death.emit()
	_is_dead = true
	root.process_mode = Node.PROCESS_MODE_DISABLED
	animation_player.play(&"death")
	collision_shape_3d.set_deferred(&"disabled", true)

	for child in get_children():
		if child is BTPlayer or child is LimboHSM:
			child.set_active(false)

	if get_tree():
		await get_tree().create_timer(10.0).timeout
		queue_free()


func get_health() -> Health3D:
	return health

func idle_animation():
	print("idle animation")
	
func walk_animation():
	print("walk animation")

func attack_animation():
	print("attack animation")
	
func charge_animation():
	print("charge animation")	

func charge_prepare_animation():
	print("charge prepare animation")	

func throw_animation():
	print("throw animation")

func throw_prepare_animation():
	print("throw prepare animation")
