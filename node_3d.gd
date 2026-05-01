#*
#* showcase.gd
#* =============================================================================
#* Copyright 2024 Serhii Snitsaruk
#*
#* Use of this source code is governed by an MIT-style
#* license that can be found in the LICENSE file or at
#* https://opensource.org/licenses/MIT.
#* =============================================================================
#*

extends Node3D



var bt_player: BTPlayer
var selected_tree_index: int = -1
var agent_files: Array[String]
var agents_dir: String
var is_tutorial: bool = false


func _ready() -> void:
	bt_player = $ranged.find_child("BTPlayer")



func _physics_process(_delta: float) -> void:
	
	pass


func _initialize() -> void:
	if is_tutorial:
		_populate_agent_files("res://demo/agents/tutorial/")
		_on_agent_selection_id_pressed(0)
	else:
		_populate_agent_files("res://demo/agents/")

		_on_agent_selection_id_pressed(0)


func _attach_camera(agent: CharacterBody2D) -> void:
	await get_tree().process_frame


func _populate_agent_files(p_path: String = "res://demo/agents/") -> void:

	agent_files.clear()
	agents_dir = p_path

	var dir := DirAccess.open(p_path)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() or file_name.begins_with("agent_base"):
				file_name = dir.get_next()
				continue
			agent_files.append(file_name.get_file().trim_suffix(".remap"))
			file_name = dir.get_next()
	dir.list_dir_end()

	agent_files.sort()


func _load_agent(file_name: String) -> void:
	var agent_res := load(file_name) as PackedScene
	assert(agent_res != null)

	for child in get_children():
		if child is CharacterBody2D and child.name != "Dummy":
			child.die()

	var agent: CharacterBody2D = agent_res.instantiate()
	add_child(agent)
	bt_player = agent.find_child("BTPlayer")
	_attach_camera(agent)


func _parse_description(p_desc: String) -> String:
	return p_desc \
			.replace("[SUCCESS]", "[color=PaleGreen]SUCCESS[/color]") \
			.replace("[FAILURE]", "[color=IndianRed]FAILURE[/color]") \
			.replace("[RUNNING]", "[color=orange]RUNNING[/color]") \
			.replace("[comp]", "[color=CornflowerBlue][b]") \
			.replace("[/comp]", "[/b][/color]") \
			.replace("[act]", "[color=white][b]") \
			.replace("[/act]", "[/b][/color]") \
			.replace("[dec]", "[color=MediumOrchid][b]") \
			.replace("[/dec]", "[/b][/color]") \
			.replace("[con]", "[color=orange][b]") \
			.replace("[/con]", "[/b][/color]")


func _on_agent_selection_id_pressed(id: int) -> void:
	assert(id >= 0 and id < agent_files.size())
	selected_tree_index = id
	_load_agent(agents_dir.path_join(agent_files[id]))
		# Treat filename as a title


func _on_switch_to_game_pressed() -> void:
	get_tree().change_scene_to_file("res://demo/scenes/game.tscn")


func _on_minimize_description_button_down() -> void:
	pass

func _on_tutorial_pressed() -> void:
	is_tutorial = not is_tutorial
	_initialize()


func _on_behavior_tree_view_task_selected(_type_name: String, p_script_path: String) -> void:
	if not p_script_path.is_empty():
		var sc: Script = load(p_script_path)
