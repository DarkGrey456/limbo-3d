#*
#* hurtbox.gd
#* =============================================================================
#* Copyright (c) 2023-present Serhii Snitsaruk and the LimboAI contributors.
#*
#* Use of this source code is governed by an MIT-style
#* license that can be found in the LICENSE file or at
#* https://opensource.org/licenses/MIT.
#* =============================================================================
#*
class_name Hurtbox3D
extends Area3D
## Area that registers damage.

@export var health: Health3D

var last_attack_vector: Vector3


func take_damage(amount: float, knockback: Vector3, source: Hitbox3D) -> void:
	last_attack_vector = owner.global_position - source.owner.global_position
	health.take_damage(amount, knockback)
