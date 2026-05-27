# game_rules.gd - Shengji rules
extends RefCounted
class_name GameRules

const ShengjiCardLogic = preload("res://scripts/games/shengji/rules/shengji_card_logic.gd")

enum CardPattern {
	INVALID,      # Invalidpattern
	SINGLE,       # Single
	PAIR,         # Pair
	TRACTOR,
	THROW
}

class PlayPattern:
	var pattern_type: CardPattern
	var cards: Array[Card]
	var suit: Card.Suit
	var length: int
	var rank_start: int
	var is_trump: bool = false
	
	func _init(type: CardPattern, card_list: Array[Card]):
		pattern_type = type
		cards = card_list
		if cards.size() > 0:
			suit = cards[0].suit
			rank_start = cards[0].rank
			is_trump = cards[0].is_trump
		length = cards.size()

# ============================================
# ============================================

static func identify_pattern(cards: Array[Card], trump_suit: Card.Suit, current_rank: int) -> PlayPattern:
	"""Identify the card pattern."""
	if cards.is_empty():
		return PlayPattern.new(CardPattern.INVALID, [])
	
	for card in cards:
		ShengjiCardLogic.apply_trump(card, trump_suit, current_rank)
	
	var sorted_cards = cards.duplicate()
	sorted_cards.sort_custom(func(a, b):
		if a.is_trump != b.is_trump:
			return a.is_trump
		if a.is_trump:
			return _get_trump_order(a, trump_suit, current_rank) < _get_trump_order(b, trump_suit, current_rank)
		if a.suit != b.suit:
			return a.suit < b.suit
		return a.rank < b.rank
	)
	
	# Single
	if sorted_cards.size() == 1:
		return PlayPattern.new(CardPattern.SINGLE, sorted_cards)
	
	# Pair
	if sorted_cards.size() == 2:
		# In multi-deck play, a pair must be two identical cards.
		if sorted_cards[0].rank == sorted_cards[1].rank and sorted_cards[0].suit == sorted_cards[1].suit:
			return PlayPattern.new(CardPattern.PAIR, sorted_cards)
		else:
			return PlayPattern.new(CardPattern.THROW, sorted_cards)
	
	if sorted_cards.size() >= 4:
		var tractor = check_tractor(sorted_cards, trump_suit, current_rank)
		if tractor != null:
			return tractor
	
	# Throw
	return PlayPattern.new(CardPattern.THROW, sorted_cards)

static func _get_trump_order(card: Card, trump_suit: Card.Suit, current_rank: int) -> int:
	if card.suit == Card.Suit.JOKER:
		return 1000 + card.rank
	if card.rank == current_rank and card.suit == trump_suit:
		return 900
	if card.rank == current_rank:
		return 800 + int(card.suit)
	return card.rank

static func _are_ranks_adjacent(rank1: int, rank2: int, current_rank: int, is_trump: bool) -> bool:
	var low = min(rank1, rank2)
	var high = max(rank1, rank2)
	if high - low == 1:
		return true
	if is_trump and high - low == 2 and current_rank == low + 1:
		return true
	return false

static func check_tractor(sorted_cards: Array[Card], trump_suit: Card.Suit, current_rank: int) -> PlayPattern:
	if sorted_cards.size() % 2 != 0:
		return null

	for card in sorted_cards:
		ShengjiCardLogic.apply_trump(card, trump_suit, current_rank)

	var pairs = []
	for i in range(0, sorted_cards.size(), 2):
		if i + 1 >= sorted_cards.size():
			return null
		var card1 = sorted_cards[i]
		var card2 = sorted_cards[i + 1]

		if card1.rank != card2.rank or card1.suit != card2.suit:
			return null

		if card1.is_trump != card2.is_trump:
			return null

		pairs.append({
			"rank": card1.rank,
			"suit": card1.suit,
			"is_trump": card1.is_trump
		})

	for i in range(pairs.size() - 1):
		var curr_pair = pairs[i]
		var next_pair = pairs[i + 1]

		if curr_pair["is_trump"] != next_pair["is_trump"]:
			return null

		if not curr_pair["is_trump"] and curr_pair["suit"] != next_pair["suit"]:
			return null

		if curr_pair["rank"] == current_rank or next_pair["rank"] == current_rank:
			return null

		if not _are_ranks_adjacent(curr_pair["rank"], next_pair["rank"], current_rank, curr_pair["is_trump"]):
			return null

	return PlayPattern.new(CardPattern.TRACTOR, sorted_cards)

# ============================================
# Follow suitrules
# ============================================

static func can_follow(follow_pattern: PlayPattern, lead_pattern: PlayPattern, hand: Array[Card], trump_suit: Card.Suit, current_rank: int) -> bool:
	"""Check whether the follow play is legal."""
	if follow_pattern.length != lead_pattern.length:
		return false
	
	for card in hand:
		ShengjiCardLogic.apply_trump(card, trump_suit, current_rank)
	
	var lead_is_trump = lead_pattern.cards[0].is_trump
	var lead_suit = lead_pattern.cards[0].suit
	
	var same_suit_cards: Array[Card] = []
	for card in hand:
		if lead_is_trump:
			if card.is_trump:
				same_suit_cards.append(card)
		else:
			if not card.is_trump and card.suit == lead_suit:
				same_suit_cards.append(card)
	
	if same_suit_cards.is_empty():
		return true
	
	match lead_pattern.pattern_type:
		CardPattern.SINGLE:
			return is_same_suit_as_lead(follow_pattern.cards[0], lead_pattern.cards[0], trump_suit, current_rank)
		
		CardPattern.PAIR:
			# followPairrules：

			var pairs = find_pairs_in_cards(same_suit_cards)
			if pairs.size() > 0:
				return follow_pattern.pattern_type == CardPattern.PAIR and \
					   is_same_suit_as_lead(follow_pattern.cards[0], lead_pattern.cards[0], trump_suit, current_rank)

			if same_suit_cards.size() >= 2:
				var all_same_suit = true
				for card in follow_pattern.cards:
					if not is_same_suit_as_lead(card, lead_pattern.cards[0], trump_suit, current_rank):
						all_same_suit = false
						break
				return all_same_suit
			elif same_suit_cards.size() == 1:
				var has_one_same_suit = false
				for card in follow_pattern.cards:
					if is_same_suit_as_lead(card, lead_pattern.cards[0], trump_suit, current_rank):
						has_one_same_suit = true
						break
				return has_one_same_suit
			else:
				return true
		
		CardPattern.TRACTOR:
			var tractors = find_tractors_in_cards(same_suit_cards, lead_pattern.length, trump_suit, current_rank)
			if tractors.size() > 0:
				return follow_pattern.pattern_type == CardPattern.TRACTOR and \
					   is_same_suit_as_lead(follow_pattern.cards[0], lead_pattern.cards[0], trump_suit, current_rank)
			
			var pairs = find_pairs_in_cards(same_suit_cards)
			if pairs.size() > 0:
				return true
			
			return true
		
		CardPattern.THROW:
			return true
	
	return true

static func is_same_suit_as_lead(card: Card, lead_card: Card, trump_suit: Card.Suit, current_rank: int) -> bool:
	"""Check whether two cards match suit, accounting for trump."""
	ShengjiCardLogic.apply_trump(card, trump_suit, current_rank)
	ShengjiCardLogic.apply_trump(lead_card, trump_suit, current_rank)
	
	if lead_card.is_trump:
		return card.is_trump
	else:
		return not card.is_trump and card.suit == lead_card.suit

static func get_valid_follow_cards(hand: Array[Card], lead_pattern: PlayPattern, trump_suit: Card.Suit, current_rank: int) -> Array:
	"""Return all legal follow-card combinations."""
	if lead_pattern.pattern_type == CardPattern.INVALID:
		return []
	
	for card in hand:
		ShengjiCardLogic.apply_trump(card, trump_suit, current_rank)
	
	var lead_is_trump = lead_pattern.cards[0].is_trump
	var lead_suit = lead_pattern.cards[0].suit
	
	var same_suit_cards: Array[Card] = []
	for card in hand:
		if lead_is_trump:
			if card.is_trump:
				same_suit_cards.append(card)
		else:
			if not card.is_trump and card.suit == lead_suit:
				same_suit_cards.append(card)
	
	if same_suit_cards.is_empty():
		if hand.size() >= lead_pattern.length:
			return [hand.slice(0, lead_pattern.length)]
		return []
	
	match lead_pattern.pattern_type:
		CardPattern.SINGLE:
			var valid_plays = []
			for card in same_suit_cards:
				valid_plays.append([card])
			return valid_plays
		
		CardPattern.PAIR:

			var pairs = find_pairs_in_cards(same_suit_cards)
			if pairs.size() > 0:
				return pairs

			if same_suit_cards.size() >= 2:
				return [[same_suit_cards[0], same_suit_cards[1]]]

			if same_suit_cards.size() == 1:
				var other_cards: Array[Card] = []
				for card in hand:
					if not same_suit_cards.has(card):
						other_cards.append(card)
				if other_cards.size() > 0:
					return [[same_suit_cards[0], other_cards[0]]]

			if hand.size() >= 2:
				return [hand.slice(0, 2)]
			return []
		
		CardPattern.TRACTOR:
			var tractors = find_tractors_in_cards(same_suit_cards, lead_pattern.length, trump_suit, current_rank)
			if tractors.size() > 0:
				return tractors
			
			var pairs = find_pairs_in_cards(same_suit_cards)
			if pairs.size() > 0:
				var result = []
				var needed = lead_pattern.length
				for pair in pairs:
					result.append_array(pair)
					needed -= 2
					if needed <= 0:
						break
				if result.size() >= lead_pattern.length:
					return [result.slice(0, lead_pattern.length)]
			
			if same_suit_cards.size() >= lead_pattern.length:
				return [same_suit_cards.slice(0, lead_pattern.length)]
			
			if hand.size() >= lead_pattern.length:
				return [hand.slice(0, lead_pattern.length)]
			return []
		
		CardPattern.THROW:
			if same_suit_cards.size() >= lead_pattern.length:
				return [same_suit_cards.slice(0, lead_pattern.length)]
			if hand.size() >= lead_pattern.length:
				return [hand.slice(0, lead_pattern.length)]
			return []
	
	return []

static func find_pairs_in_cards(cards: Array[Card]) -> Array:
	"""Find all pairs in a card list."""
	var sorted_cards: Array[Card] = []
	sorted_cards.assign(cards)
	sorted_cards.sort_custom(func(a, b): 
		if a.suit != b.suit:
			return a.suit < b.suit
		return a.rank < b.rank
	)
	
	var pairs = []
	var i = 0
	while i < sorted_cards.size() - 1:
		if sorted_cards[i].rank == sorted_cards[i + 1].rank and \
		   sorted_cards[i].suit == sorted_cards[i + 1].suit:
			pairs.append([sorted_cards[i], sorted_cards[i + 1]])
			i += 2
		else:
			i += 1
	
	return pairs

static func find_tractors_in_cards(cards: Array[Card], min_length: int, trump_suit: Card.Suit, current_rank: int) -> Array:
	"""Find tractors in a card list."""
	for card in cards:
		ShengjiCardLogic.apply_trump(card, trump_suit, current_rank)
	
	var pairs = find_pairs_in_cards(cards)
	var required_pairs = int(min_length / 2)
	if pairs.size() < required_pairs:
		return []
	
	var tractors = []
	for i in range(pairs.size() - required_pairs + 1):
		var tractor_cards = []
		var is_valid = true
		
		for j in range(required_pairs):
			var pair_idx = i + j
			if pair_idx >= pairs.size():
				is_valid = false
				break
			
			if j > 0:
				var prev_pair = pairs[i + j - 1]
				var curr_pair = pairs[pair_idx]
				
				if prev_pair[0].is_trump != curr_pair[0].is_trump:
					is_valid = false
					break

				if not prev_pair[0].is_trump and prev_pair[0].suit != curr_pair[0].suit:
					is_valid = false
					break

				if prev_pair[0].rank == current_rank or curr_pair[0].rank == current_rank:
					is_valid = false
					break

				if not _are_ranks_adjacent(prev_pair[0].rank, curr_pair[0].rank, current_rank, prev_pair[0].is_trump):
					is_valid = false
					break
			
			tractor_cards.append_array(pairs[pair_idx])
		
		if is_valid and tractor_cards.size() == min_length:
			tractors.append(tractor_cards)
	
	return tractors

# ============================================
# play comparisonlogic
# ============================================

static func compare_plays(play1: PlayPattern, play2: PlayPattern, trump_suit: Card.Suit, current_rank: int) -> int:
	"""
	return 1: play1 larger
	return -1: play2 larger
	return 0: equal
	"""
	# updateTrumpstate
	for card in play1.cards:
		ShengjiCardLogic.apply_trump(card, trump_suit, current_rank)
	for card in play2.cards:
		ShengjiCardLogic.apply_trump(card, trump_suit, current_rank)
	
	var play1_is_trump = play1.cards[0].is_trump
	var play2_is_trump = play2.cards[0].is_trump
	
	if play1_is_trump and not play2_is_trump:
		return 1
	elif not play1_is_trump and play2_is_trump:
		return -1
	
	# ifsuitdifferent（bothis notTrump），lead playerlarger
	if not play1_is_trump and not play2_is_trump:
		if play1.cards[0].suit != play2.cards[0].suit:
			return 1  # lead playerlarger
	
	# patterndifferent，based onpriority levelcompare
	if play1.pattern_type != play2.pattern_type:
		# Tractor > Pair > Single > Throw
		var priority = {
			CardPattern.TRACTOR: 3,
			CardPattern.PAIR: 2,
			CardPattern.SINGLE: 1,
			CardPattern.THROW: 0
		}
		var p1 = priority.get(play1.pattern_type, 0)
		var p2 = priority.get(play2.pattern_type, 0)
		if p1 > p2:
			return 1
		elif p1 < p2:
			return -1
		return 0
	
	var card1 = get_largest_card(play1.cards, trump_suit, current_rank)
	var card2 = get_largest_card(play2.cards, trump_suit, current_rank)
	
	return ShengjiCardLogic.compare_cards(card1, card2, trump_suit, current_rank)

static func get_largest_card(cards: Array[Card], trump_suit: Card.Suit, current_rank: int) -> Card:
	"""Return the largest card in a card list."""
	if cards.is_empty():
		return null
	
	var largest = cards[0]
	for card in cards:
		ShengjiCardLogic.apply_trump(card, trump_suit, current_rank)
		ShengjiCardLogic.apply_trump(largest, trump_suit, current_rank)
		if ShengjiCardLogic.compare_cards(card, largest, trump_suit, current_rank) > 0:
			largest = card
	
	return largest

# ============================================
# ============================================

static func calculate_points(cards: Array) -> int:
	"""Calculate points for a card list."""
	var total = 0
	for card in cards:
		if card is Card:
			total += card.points
	return total

# ============================================
# validatePlay cards
# ============================================

static func validate_play(cards: Array[Card], hand: Array[Card]) -> bool:
	"""Validate whether these cards can be played."""
	for card in cards:
		if not hand.has(card):
			return false
	return true
