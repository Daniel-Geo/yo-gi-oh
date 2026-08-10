extends Control

@onready var label: Label = $MarginContainer/Panel/VBoxContainer/VSplitContainer/Label
@onready var button: Button = $MarginContainer/Panel/VBoxContainer/VSplitContainer/Button

func show_end_screen(game_state: String) -> void:
	visible = true
	label.text = "You Win" if game_state == "win" else "You Lose"


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
