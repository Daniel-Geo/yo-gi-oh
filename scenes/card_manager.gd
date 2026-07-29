extends Node2D

@export var camera_2d: Camera2D
@export var card_collision_mask = 1

var screen_size
var card_being_dragged

func _ready() -> void:
	screen_size = get_viewport_rect().size / camera_2d.zoom

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_position = get_global_mouse_position()
		card_being_dragged.position = mouse_position
		card_being_dragged.position = Vector2(clamp(mouse_position.x, -screen_size.x/2, screen_size.x/2), clamp(mouse_position.y, -screen_size.y/2, screen_size.y/2))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var card = raycast_card_check()
			if card:
				card_being_dragged = card
		else:
			card_being_dragged = null

func raycast_card_check():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = card_collision_mask
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
