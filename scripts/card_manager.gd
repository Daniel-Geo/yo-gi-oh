extends Node2D

@export var card_collision_mask: int = 1
@export var card_slot_collision_mask: int = 2

@onready var player_hand: Node2D = $"../PlayerHand"
@onready var camera_2d: Camera2D = $"../Camera2D"

var screen_size: Vector2
var card_being_dragged: Node2D
var is_hovering_on_card: bool

func _ready() -> void:
	screen_size = get_viewport_rect().size / camera_2d.zoom

func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_position = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_position.x, -screen_size.x/2, screen_size.x/2), clamp(mouse_position.y, -screen_size.y/2, screen_size.y/2))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var card = raycast_check(card_collision_mask)
			if card:
				start_drag(card)
		else:
			if card_being_dragged:
				finish_drag()

func start_drag(card) -> void:
	card_being_dragged = card
	card.scale = Vector2(1, 1)


func finish_drag() -> void:
	card_being_dragged.scale = Vector2(1.05, 1.05)
	var card_slot_found = raycast_check(card_slot_collision_mask)
	if card_slot_found and not card_slot_found.card_in_slot:
		player_hand.remove_card_from_hand(card_being_dragged)
		card_being_dragged.position = card_slot_found.position
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		card_slot_found.card_in_slot = true
	else:
		player_hand.add_card_to_hand(card_being_dragged)
	card_being_dragged = null


func connect_card_signals(card) -> void:
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_over_card(card) -> void:
	if !is_hovering_on_card:
		highlight_card(card, true)
		is_hovering_on_card = true

func on_hovered_off_card(card) -> void:
	if !card_being_dragged:
		highlight_card(card, false)
		var new_card_hovered = raycast_check(card_collision_mask)
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false

func highlight_card(card, hovered) -> void:
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1

func raycast_check(collision_mask):
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = collision_mask
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		if collision_mask == card_collision_mask:
			return result[0].collider.get_parent()
		else:
			return get_card_with_highest_z_index(result)
	return null

func  get_card_with_highest_z_index(cards) -> Node2D:
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card
