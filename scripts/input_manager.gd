extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

@export var card_collision_mask: int = 1
@export var deck_collision_mask: int = 4

@onready var card_manager: Node2D = $"../CardManager"
@onready var deck: Node2D = $"../Deck"

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			emit_signal("left_mouse_button_clicked")
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_button_released")

func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == card_collision_mask:
			var card_found = result[0].collider.get_parent()
			if card_found:
				card_manager.start_drag(card_found)
		elif result_collision_mask == deck_collision_mask:
			deck.draw_card()
	return null
