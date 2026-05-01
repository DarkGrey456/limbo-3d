#*
#* hitbox.gd
#* =============================================================================
#* Copyright (c) 2023-present Serhii Snitsaruk and the LimboAI contributors.
#*
#* Use of this source code is governed by an MIT-style
#* license that can be found in the LICENSE file or at
#* https://opensource.org/licenses/MIT.
#* =============================================================================
#*
class_name Hitbox3D
extends Area3D
## Area that deals damage.

## Damage value to apply.
@export var damage: float = 1.0

## Push back the victim.
@export var knockback_enabled: bool = false

## Desired pushback speed.
@export var knockback_strength: float = 500.0


func _ready() -> void:
	area_entered.connect(_area_entered)


func _area_entered(hurtbox: Hurtbox3D) -> void:
	if hurtbox.owner == owner:
		return
	hurtbox.take_damage(damage, get_knockback(), self)


func get_knockback() -> Vector3:
	var knockback: Vector3
	if knockback_enabled:
		knockback = Vector3.RIGHT.rotated(Vector3.UP,global_rotation.z) * knockback_strength
	return knockback


func _on_area_entered(area: Area3D) -> void:
	if area is Hurtbox3D:
		_area_entered(area as Hurtbox3D) 
