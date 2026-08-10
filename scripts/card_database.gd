extends Node2D

# card: [attack, health, type, ability, ability script]
const CARDS: Dictionary = {
	"knight": [2, 3, CardTypes.MONSTER, null, null],
	"archer": [1, 1, CardTypes.MONSTER, null, null],
	"demon": [5, 7, CardTypes.MONSTER, null, null],
	"tornado": [null, null, CardTypes.MAGIC, "Deal 1 damage to all opponent cards", "res://scripts/tornado.gd"]
}

enum CardTypes { MONSTER, MAGIC }
