extends Node

@export var tornado_damage: int = 1

@onready var input_manager: Node2D = $InputManager

func trigger_ability(battle_manager, input_manager, card_with_ability) -> void:
	input_manager.input_disabled = true
	battle_manager.enable_end_turn_button(false)
	await battle_manager.wait(1)
	
	var cards_to_destroy: Array
	for card in battle_manager.opponent_cards_on_battlefield:
		card.health = max(0, card.health - tornado_damage)
		card.get_node("%Health").text = str(card.health)
		if card.health == 0:
			cards_to_destroy.append(card)
	await battle_manager.wait(1)
	
	if cards_to_destroy.size() > 0:
		for card in cards_to_destroy:
			battle_manager.destroy_card(card, "opponent")
	
	battle_manager.destroy_card(card_with_ability, "player")
	await battle_manager.wait(1)
	battle_manager.enable_end_turn_button(true)
	input_manager.input_disabled = false
