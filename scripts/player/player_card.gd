extends Node2D

signal hovered
signal hovered_off

var starting_position: Vector2
var card_type: CardDatabase.CardTypes
var card_slot_card_is_in: Node2D
var is_in_card_slot: bool = false
var defeated: bool = false
var health: int
var attack: int
var ability_script: Node

func _ready() -> void:
	get_parent().connect_card_signals(self)


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
