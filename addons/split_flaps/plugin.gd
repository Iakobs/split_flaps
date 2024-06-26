@tool
extends EditorPlugin

const NODE_NAME := "SplitFlapLabel"

func _enter_tree() -> void:
	add_custom_type(
		NODE_NAME,
		"HBoxContainer",
		preload("res://addons/split_flaps/split_flap_label.gd"),
		preload("res://addons/split_flaps/SplitFlapLabel.svg")
	)

func _exit_tree() -> void:
	remove_custom_type(NODE_NAME)
