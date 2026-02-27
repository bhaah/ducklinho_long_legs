extends ColorRect

@export var follow_node: Node2D

func _process(_delta: float) -> void:
	if follow_node:
		global_position.x = follow_node.global_position.x - (size.x / 2.0)
