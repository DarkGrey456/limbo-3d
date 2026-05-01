#*
#* arrive_pos.gd
#* =============================================================================
#* Copyright (c) 2023-present Serhii Snitsaruk and the LimboAI contributors.
#*
#* Use of this source code is governed by an MIT-style
#* license that can be found in the LICENSE file or at
#* https://opensource.org/licenses/MIT.
#* =============================================================================
#*
@tool
extends BTAction
## Moves the agent to the specified position, favoring horizontal movement. [br]
## Returns [code]SUCCESS[/code] when close to the target position (see [member tolerance]);
## otherwise returns [code]RUNNING[/code].

## Blackboard variable that stores the target position (Vector2)
@export var target_position_var := &"pos"

## Variable that stores desired speed (float)
@export var speed_var := &"speed"

## How close should the agent be to the target position to return SUCCESS.
@export var tolerance := 50.0

## Specifies the node to avoid (valid Node2D is expected).
## If not empty, agent will circle around the node while moving into position.
@export var avoid_var: StringName


func _generate_name() -> String:
	return "Arrive  pos: %s%s" % [
		LimboUtility.decorate_var(target_position_var),
		"" if avoid_var.is_empty() else "  avoid: " + LimboUtility.decorate_var(avoid_var)
	]


func _tick(_delta: float) -> Status:

	var target_pos: Vector3 = blackboard.get_var(target_position_var, Vector3.ZERO)
	if target_pos.distance_to(agent.global_position) < tolerance:
		return SUCCESS

	var speed: float = blackboard.get_var(speed_var, 10.0)
	var dist: float = agent.global_position.distance_to(target_pos)
	var dir: Vector3 = agent.global_position.direction_to(target_pos)

	# Prefer horizontal movement:


	# Avoid the node specified by `avoid_var`.
	# I.e., if `avoid_var` is set, agent will circle around that node while moving into position.
	if not avoid_var.is_empty():
		var avoid_node: Node3D = blackboard.get_var(avoid_var)
		if is_instance_valid(avoid_node):
			var distance_vector: Vector3 = avoid_node.global_position - agent.global_position
			if dir.dot(distance_vector) > 0.0:
				var side := dir.rotated(Vector3.UP,PI * 0.5).normalized()
				# The closer we are to the avoid target, the stronger is the avoidance.
				var strength: float = remap(distance_vector.length(), 2.0, 4.0, 1.0, 0.0)
				strength = clampf(strength, 0.0, 1.0)
				var avoidance := side * signf(-side.dot(distance_vector)) * strength
				dir += avoidance

	var desired_velocity: Vector3 = dir.normalized() * speed
	agent.set_text("ARRIVE POS " + var_to_str(desired_velocity))
	agent.move(desired_velocity)
	agent.update_facing()
	return RUNNING
