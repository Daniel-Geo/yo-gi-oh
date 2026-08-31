extends Node

@export var ability_trigger_event: String = "card_placed"
@export var arrow_damage: int = 1

func trigger_ability(battle_manager, input_manager, card_with_ability, trigger_event) -> void:
	if ability_trigger_event != trigger_event:
		return
	
	input_manager.input_disabled = true
	battle_manager.enable_end_turn_button(false)
	
	await battle_manager.wait(1)
	battle_manager.opponent_health = max(0, battle_manager.opponent_health - arrow_damage)
	battle_manager.opponent_health_label.text = str(battle_manager.opponent_health)
	await battle_manager.wait(1)
	
	battle_manager.enable_end_turn_button(true)
	input_manager.input_disabled = false

func reset_ability() -> void:
	pass
