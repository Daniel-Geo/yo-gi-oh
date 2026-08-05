extends Node2D

# card: [attack, health, type]
const CARDS: Dictionary = {
	"knight": [2, 3, CardTypes.MONSTER],
	"archer": [1, 1, CardTypes.MONSTER],
	"demon": [5, 7, CardTypes.MONSTER]
}

enum CardTypes { MONSTER, MAGIC }
