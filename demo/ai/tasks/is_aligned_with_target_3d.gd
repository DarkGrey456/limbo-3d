#*
#* is_aligned_with_target.gd
#* =============================================================================
#* Copyright (c) 2023-present Serhii Snitsaruk and the LimboAI contributors.
#*
#* Use of this source code is governed by an MIT-style
#* license that can be found in the LICENSE file or at
#* https://opensource.org/licenses/MIT.
#* =============================================================================
#*
@tool
extends BTCondition
## Checks if the agent is horizontally aligned with the target. [br]
## Returns [code]SUCCESS[/code] if the agent is horizontally aligned with the target.
## Returns [code]FAILURE[/code] if not aligned or if target is not a valid node instance.


@export var target_var: StringName = &"target"
@export var tolerance: float = 30.0


# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "IsAlignedWithTarget " + LimboUtility.decorate_var(target_var)


# Called each time this task is ticked (aka executed).
func _tick(_delta: float) -> Status:
	
	var target := blackboard.get_var(target_var) as Node3D
	if not is_instance_valid(target):
		agent.set_text("FAILED: FACE TARGET")
		return FAILURE
	var dir = -agent.global_basis.z
	
	var dir_to_target: Vector3 = (target.global_position - agent.global_position).normalized()
	var dprod = dir_to_target.dot(dir)
	if dprod > 0.8 or dprod < -0.8:
		agent.set_text("SUCCEEDED: FACE TARGET")
		return SUCCESS
	
	return FAILURE
