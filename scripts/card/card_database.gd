extends Node2D

# card: [attack, health, type, ability, ability script]
const CARDS: Dictionary = {
	"knight": [2, 3, CardTypes.MONSTER, "Attacks twice", "res://scripts/abilities/double_strike.gd"],
	"archer": [1, 1, CardTypes.MONSTER, "Deal damage to opponent", "res://scripts/abilities/arrow.gd"],
	"demon": [5, 7, CardTypes.MONSTER, null, null],
	"tornado": [null, null, CardTypes.MAGIC, "Deal 1 damage to all opponent cards", "res://scripts/abilities/tornado.gd"]
}

enum CardTypes { MONSTER, MAGIC }
