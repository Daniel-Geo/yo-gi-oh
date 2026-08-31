extends Node

@export var ability_trigger_event: String = "card_attacked"

var has_activated: bool = false

func trigger_ability(battle_manager, input_manager, card_with_ability, trigger_event) -> void:
	if ability_trigger_event != trigger_event:
		return
	
	if card_with_ability in battle_manager.player_cards_attacked_this_turn and not has_activated:
		battle_manager.player_cards_attacked_this_turn.erase(card_with_ability)
		has_activated = true

func reset_ability() -> void:
	has_activated = false
