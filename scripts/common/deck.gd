# deck.gd - Shared deck management
extends Node
class_name Deck

var cards: Array[Card] = []
var num_decks: int = 2

func _init(decks: int = 2):
	num_decks = decks

func create_deck(_parent_node: Node = null):
	cards.clear()
	
	for _deck_num in num_decks:
		# Create the four standard suits.
		for suit in [Card.Suit.SPADE, Card.Suit.HEART, Card.Suit.CLUB, Card.Suit.DIAMOND]:
			for rank in range(Card.Rank.TWO, Card.Rank.ACE + 1):
				var card = Card.new(suit, rank)
				cards.append(card)
		
		# Add both jokers.
		var small_joker = Card.new(Card.Suit.JOKER, Card.Rank.SMALL_JOKER)
		var big_joker = Card.new(Card.Suit.JOKER, Card.Rank.BIG_JOKER)
		cards.append(small_joker)
		cards.append(big_joker)

func shuffle():
	cards.shuffle()

func deal(num_cards: int) -> Array[Card]:
	var dealt_cards: Array[Card] = []
	for _i in num_cards:
		if cards.size() > 0:
			dealt_cards.append(cards.pop_back())
	return dealt_cards

func get_remaining_count() -> int:
	return cards.size()
