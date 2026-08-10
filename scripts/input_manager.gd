extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

@export var player_card_collision_mask: int = 1
@export var deck_collision_mask: int = 4
@export var opponent_card_collision_mask: int = 8

@onready var card_manager: Node2D = $"../CardManager"
@onready var deck: Node2D = $"../PlayerDeck"
@onready var battle_manager: Node = $"../BattleManager"

var input_disabled: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			emit_signal("left_mouse_button_clicked")
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_button_released")

func raycast_at_cursor():
	if input_disabled:
		return
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == player_card_collision_mask:
			var card = result[0].collider.get_parent()
			if card:
				card_manager.card_clicked(card)
		elif result_collision_mask == deck_collision_mask:
			deck.draw_card()
		elif result_collision_mask == opponent_card_collision_mask:
			battle_manager.opponent_card_selected(result[0].collider.get_parent())
	return null
