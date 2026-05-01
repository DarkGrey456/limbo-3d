extends Node3D


@onready var player: CharacterBody3D = $"../player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir_to= (player.global_position-global_position).normalized()
	look_at(dir_to*2000.0 + global_position,Vector3.UP)
