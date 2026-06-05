# shengji_card_logic.gd - Shengji-specific card state and comparison helpers
extends RefCounted
class_name ShengjiCardLogic

static func apply_trump(card: Card, trump_suit: Card.Suit, current_rank: int):
	card.is_trump = is_trump(card, trump_suit, current_rank)

static func apply_trump_to_cards(cards: Array, trump_suit: Card.Suit, current_rank: int):
	for card in cards:
		apply_trump(card, trump_suit, current_rank)

static func is_trump(card: Card, trump_suit: Card.Suit, current_rank: int) -> bool:
	if trump_suit == Card.Suit.NO_TRUMP:
		return card.rank == current_rank or card.suit == Card.Suit.JOKER
	return card.suit == trump_suit or card.rank == current_rank or card.suit == Card.Suit.JOKER

static func compare_cards(card1: Card, card2: Card, trump_suit: Card.Suit, current_rank: int) -> int:
	apply_trump(card1, trump_suit, current_rank)
	apply_trump(card2, trump_suit, current_rank)

	if card1.is_trump and not card2.is_trump:
		return 1
	elif not card1.is_trump and card2.is_trump:
		return -1

	if card1.suit == Card.Suit.JOKER and card2.suit == Card.Suit.JOKER:
		return 1 if card1.rank > card2.rank else (-1 if card1.rank < card2.rank else 0)
	elif card1.suit == Card.Suit.JOKER:
		return 1
	elif card2.suit == Card.Suit.JOKER:
		return -1

	if card1.rank == current_rank and card2.rank == current_rank:
		if trump_suit == Card.Suit.NO_TRUMP:
			return 0
		if card1.suit == trump_suit and card2.suit != trump_suit:
			return 1
		elif card1.suit != trump_suit and card2.suit == trump_suit:
			return -1
		return 0
	elif card1.rank == current_rank:
		return 1
	elif card2.rank == current_rank:
		return -1

	if card1.rank > card2.rank:
		return 1
	elif card1.rank < card2.rank:
		return -1
	return 0
