# game_rules.gd - Shengji rules
extends RefCounted
class_name GameRules

const ShengjiCardLogic = preload("res://scripts/games/shengji/rules/shengji_card_logic.gd")

enum CardPattern {
	INVALID,      # Invalidpattern
	SINGLE,       # Single
	PAIR,         # Pair
	TRIPLE,
	QUADRUPLE,
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
	var set_size: int = 1
	var sequence_length: int = 1
	
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

static func identify_pattern(cards: Array[Card], trump_suit: Card.Suit, current_rank: int, rule_mode: String = "") -> PlayPattern:
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
	
	var set_pattern = identify_same_card_set(sorted_cards, get_rule_mode(rule_mode))
	if set_pattern != null:
		return set_pattern
	
	if sorted_cards.size() >= 4:
		var tractor = check_tractor(sorted_cards, trump_suit, current_rank, rule_mode)
		if tractor != null:
			return tractor
	
	# Throw
	return PlayPattern.new(CardPattern.THROW, sorted_cards)

static func _get_trump_order(card: Card, trump_suit: Card.Suit, current_rank: int) -> int:
	if card.suit == Card.Suit.JOKER:
		return 1000 + card.rank
	if trump_suit == Card.Suit.NO_TRUMP and card.rank == current_rank:
		return 800
	if card.rank == current_rank and card.suit == trump_suit:
		return 900
	if card.rank == current_rank:
		return 800 + int(card.suit)
	return card.rank

static func get_rule_mode(rule_mode: String = "") -> String:
	if rule_mode != "":
		return rule_mode
	return GameConfig.get_shengji_mode()

static func get_allowed_tractor_set_sizes(rule_mode: String = "") -> Array[int]:
	if get_rule_mode(rule_mode) == GameConfig.SHENGJI_MODE_HARD:
		return [4, 3, 2]
	return [2]

static func identify_same_card_set(sorted_cards: Array[Card], rule_mode: String = "") -> PlayPattern:
	var card_count = sorted_cards.size()
	if card_count < 2 or card_count > 4:
		return null
	if not are_identical_cards(sorted_cards):
		return null
	if card_count == 2:
		var pair_pattern = PlayPattern.new(CardPattern.PAIR, sorted_cards)
		pair_pattern.set_size = 2
		return pair_pattern
	if get_rule_mode(rule_mode) != GameConfig.SHENGJI_MODE_HARD:
		return null
	if card_count == 3:
		var triple_pattern = PlayPattern.new(CardPattern.TRIPLE, sorted_cards)
		triple_pattern.set_size = 3
		return triple_pattern
	if card_count == 4:
		var quad_pattern = PlayPattern.new(CardPattern.QUADRUPLE, sorted_cards)
		quad_pattern.set_size = 4
		return quad_pattern
	return null

static func are_identical_cards(cards: Array[Card]) -> bool:
	if cards.is_empty():
		return false
	var first = cards[0]
	for card in cards:
		if card.rank != first.rank or card.suit != first.suit:
			return false
	return true

static func _are_ranks_adjacent(rank1: int, rank2: int, current_rank: int, _is_trump: bool) -> bool:
	var low = min(rank1, rank2)
	var high = max(rank1, rank2)
	if high - low == 1:
		return true
	if high - low == 2 and current_rank == low + 1:
		return true
	return false

static func check_tractor(sorted_cards: Array[Card], trump_suit: Card.Suit, current_rank: int, rule_mode: String = "") -> PlayPattern:
	for card in sorted_cards:
		ShengjiCardLogic.apply_trump(card, trump_suit, current_rank)

	for set_size in get_allowed_tractor_set_sizes(rule_mode):
		if sorted_cards.size() % set_size != 0:
			continue
		var sequence_length = int(sorted_cards.size() / set_size)
		if sequence_length < 2:
			continue
		var tractor_sets = build_exact_sets(sorted_cards, set_size, trump_suit, current_rank)
		if tractor_sets.size() != sequence_length:
			continue
		if are_sets_valid_tractor_sequence(tractor_sets, current_rank):
			var pattern = PlayPattern.new(CardPattern.TRACTOR, sorted_cards)
			pattern.set_size = set_size
			pattern.sequence_length = sequence_length
			return pattern
	return null

static func build_exact_sets(cards: Array[Card], set_size: int, trump_suit: Card.Suit, current_rank: int) -> Array:
	if cards.size() % set_size != 0:
		return []
	var sets = []
	for i in range(0, cards.size(), set_size):
		var set_cards: Array[Card] = []
		for offset in range(set_size):
			var card = cards[i + offset]
			ShengjiCardLogic.apply_trump(card, trump_suit, current_rank)
			set_cards.append(card)
		if not are_identical_cards(set_cards):
			return []
		var first = set_cards[0]
		if first.suit == Card.Suit.JOKER:
			return []
		if first.rank == current_rank:
			return []
		sets.append({
			"rank": first.rank,
			"suit": first.suit,
			"is_trump": first.is_trump,
			"cards": set_cards
		})
	return sets

static func are_sets_valid_tractor_sequence(sets: Array, current_rank: int) -> bool:
	for i in range(sets.size() - 1):
		var curr_set = sets[i]
		var next_set = sets[i + 1]

		if curr_set["is_trump"] != next_set["is_trump"]:
			return false

		if not curr_set["is_trump"] and curr_set["suit"] != next_set["suit"]:
			return false

		if not _are_ranks_adjacent(curr_set["rank"], next_set["rank"], current_rank, curr_set["is_trump"]):
			return false

	return true

# ============================================
# Follow suitrules
# ============================================

static func can_follow(follow_pattern: PlayPattern, lead_pattern: PlayPattern, hand: Array[Card], trump_suit: Card.Suit, current_rank: int) -> bool:
	"""Check whether the follow play is legal."""
	if follow_pattern.length != lead_pattern.length:
		return false
	
	for card in hand:
		ShengjiCardLogic.apply_trump(card, trump_suit, current_rank)
	for card in follow_pattern.cards:
		ShengjiCardLogic.apply_trump(card, trump_suit, current_rank)
	
	var same_kind_cards = get_same_kind_cards_for_lead(hand, lead_pattern, trump_suit, current_rank)
	if same_kind_cards.is_empty():
		return true

	var followed_same_kind_count = count_same_kind_cards_for_lead(follow_pattern.cards, lead_pattern, trump_suit, current_rank)
	var followed_same_kind_cards = get_same_kind_cards_for_lead(follow_pattern.cards, lead_pattern, trump_suit, current_rank)
	
	match lead_pattern.pattern_type:
		CardPattern.SINGLE:
			return followed_same_kind_count == 1
		
		CardPattern.PAIR:
			return can_follow_same_rank_set(follow_pattern, lead_pattern, same_kind_cards, followed_same_kind_count, 2)

		CardPattern.TRIPLE:
			return can_follow_triple_set(follow_pattern, lead_pattern, same_kind_cards, followed_same_kind_cards, followed_same_kind_count)

		CardPattern.QUADRUPLE:
			return can_follow_quad_set(follow_pattern, lead_pattern, same_kind_cards, followed_same_kind_cards, followed_same_kind_count)
		
		CardPattern.TRACTOR:
			var set_size = max(2, lead_pattern.set_size)
			var tractors = find_tractors_in_cards(same_kind_cards, lead_pattern.length, trump_suit, current_rank, "", set_size)
			if tractors.size() > 0:
				return follow_pattern.pattern_type == CardPattern.TRACTOR and \
					   follow_pattern.set_size == set_size and \
					   follow_pattern.sequence_length == lead_pattern.sequence_length and \
					   followed_same_kind_count == lead_pattern.length
			
			var available_sets = find_sets_in_cards(same_kind_cards, set_size)
			var followed_sets = find_sets_in_cards(get_same_kind_cards_for_lead(follow_pattern.cards, lead_pattern, trump_suit, current_rank), set_size)
			if available_sets.size() > 0:
				var required_set_count = min(available_sets.size(), int(lead_pattern.length / set_size))
				var required_same_kind_count = min(lead_pattern.length, same_kind_cards.size())
				return followed_sets.size() >= required_set_count and followed_same_kind_count == required_same_kind_count
			
			return followed_same_kind_count == min(lead_pattern.length, same_kind_cards.size())
		
		CardPattern.THROW:
			return true
	
	return true

static func can_follow_same_rank_set(
	follow_pattern: PlayPattern,
	lead_pattern: PlayPattern,
	same_kind_cards: Array[Card],
	followed_same_kind_count: int,
	set_size: int
) -> bool:
	var available_sets = find_sets_in_cards(same_kind_cards, set_size)
	if available_sets.size() > 0:
		return follow_pattern.pattern_type == lead_pattern.pattern_type and followed_same_kind_count == lead_pattern.length
	return followed_same_kind_count == min(lead_pattern.length, same_kind_cards.size())

static func can_follow_triple_set(
	follow_pattern: PlayPattern,
	lead_pattern: PlayPattern,
	same_kind_cards: Array[Card],
	followed_same_kind_cards: Array[Card],
	followed_same_kind_count: int
) -> bool:
	var required_same_kind_count = min(lead_pattern.length, same_kind_cards.size())
	if followed_same_kind_count != required_same_kind_count:
		return false

	var available_triples = find_sets_in_cards(same_kind_cards, 3)
	if available_triples.size() > 0:
		return follow_pattern.pattern_type == CardPattern.TRIPLE

	var available_pairs = find_sets_in_cards(same_kind_cards, 2)
	if available_pairs.size() > 0:
		return find_sets_in_cards(followed_same_kind_cards, 2).size() > 0

	return true

static func can_follow_quad_set(
	follow_pattern: PlayPattern,
	lead_pattern: PlayPattern,
	same_kind_cards: Array[Card],
	followed_same_kind_cards: Array[Card],
	followed_same_kind_count: int
) -> bool:
	var required_same_kind_count = min(lead_pattern.length, same_kind_cards.size())
	if followed_same_kind_count != required_same_kind_count:
		return false
	if same_kind_cards.size() < lead_pattern.length:
		return true

	var available_quads = find_sets_in_cards(same_kind_cards, 4)
	if available_quads.size() > 0:
		return follow_pattern.pattern_type == CardPattern.QUADRUPLE

	var available_triples = find_sets_in_cards(same_kind_cards, 3)
	if available_triples.size() > 0:
		return find_sets_in_cards(followed_same_kind_cards, 3).size() > 0

	var available_pairs = find_sets_in_cards(same_kind_cards, 2)
	if available_pairs.size() > 0:
		var followed_pairs = find_sets_in_cards(followed_same_kind_cards, 2)
		var required_pair_count = min(available_pairs.size(), int(lead_pattern.length / 2))
		return followed_pairs.size() >= required_pair_count

	return true

static func get_same_kind_cards_for_lead(cards: Array, lead_pattern: PlayPattern, trump_suit: Card.Suit, current_rank: int) -> Array[Card]:
	var same_kind_cards: Array[Card] = []
	var lead_card = lead_pattern.cards[0]
	ShengjiCardLogic.apply_trump(lead_card, trump_suit, current_rank)
	for card in cards:
		if not (card is Card):
			continue
		ShengjiCardLogic.apply_trump(card, trump_suit, current_rank)
		if lead_card.is_trump:
			if card.is_trump:
				same_kind_cards.append(card)
		elif not card.is_trump and card.suit == lead_card.suit:
			same_kind_cards.append(card)
	return same_kind_cards

static func count_same_kind_cards_for_lead(cards: Array, lead_pattern: PlayPattern, trump_suit: Card.Suit, current_rank: int) -> int:
	return get_same_kind_cards_for_lead(cards, lead_pattern, trump_suit, current_rank).size()

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
	
	var same_suit_cards = get_same_kind_cards_for_lead(hand, lead_pattern, trump_suit, current_rank)
	
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

		CardPattern.TRIPLE:
			return build_triple_follow_candidates(hand, same_suit_cards, lead_pattern.length)

		CardPattern.QUADRUPLE:
			return build_quad_follow_candidates(hand, same_suit_cards, lead_pattern.length)
		
		CardPattern.TRACTOR:
			var set_size = max(2, lead_pattern.set_size)
			var tractors = find_tractors_in_cards(same_suit_cards, lead_pattern.length, trump_suit, current_rank, "", set_size)
			if tractors.size() > 0:
				return tractors
			
			var same_kind_sets = find_sets_in_cards(same_suit_cards, set_size)
			if same_kind_sets.size() > 0:
				var result = []
				var needed_sets = min(same_kind_sets.size(), int(lead_pattern.length / set_size))
				for i in range(needed_sets):
					result.append_array(same_kind_sets[i])
				if result.size() < lead_pattern.length:
					result.append_array(take_cards_except(same_suit_cards, result, lead_pattern.length - result.size()))
				if result.size() < lead_pattern.length:
					result.append_array(take_cards_except(hand, result, lead_pattern.length - result.size()))
				return [result.slice(0, lead_pattern.length)]

			if same_suit_cards.size() >= lead_pattern.length:
				return [same_suit_cards.slice(0, lead_pattern.length)]
			if hand.size() >= lead_pattern.length:
				var base = same_suit_cards.duplicate()
				base.append_array(take_cards_except(hand, base, lead_pattern.length - base.size()))
				return [base.slice(0, lead_pattern.length)]
			return []
		
		CardPattern.THROW:
			if same_suit_cards.size() >= lead_pattern.length:
				return [same_suit_cards.slice(0, lead_pattern.length)]
			if hand.size() >= lead_pattern.length:
				return [hand.slice(0, lead_pattern.length)]
			return []
	
	return []

static func build_set_follow_candidates(hand: Array[Card], same_kind_cards: Array[Card], needed: int, set_size: int) -> Array:
	var sets = find_sets_in_cards(same_kind_cards, set_size)
	if sets.size() > 0:
		return sets
	if same_kind_cards.size() >= needed:
		return [same_kind_cards.slice(0, needed)]
	var result = same_kind_cards.duplicate()
	result.append_array(take_cards_except(hand, result, needed - result.size()))
	if result.size() >= needed:
		return [result.slice(0, needed)]
	return []

static func build_triple_follow_candidates(hand: Array[Card], same_kind_cards: Array[Card], needed: int) -> Array:
	var triples = find_sets_in_cards(same_kind_cards, 3)
	if triples.size() > 0:
		return triples

	var pairs = find_sets_in_cards(same_kind_cards, 2)
	if pairs.size() > 0:
		var result: Array[Card] = []
		result.append_array(pairs[0])
		result.append_array(take_cards_except(same_kind_cards, result, needed - result.size()))
		result.append_array(take_cards_except(hand, result, needed - result.size()))
		if result.size() >= needed:
			return [result.slice(0, needed)]

	if same_kind_cards.size() >= needed:
		return [same_kind_cards.slice(0, needed)]
	var result = same_kind_cards.duplicate()
	result.append_array(take_cards_except(hand, result, needed - result.size()))
	if result.size() >= needed:
		return [result.slice(0, needed)]
	return []

static func build_quad_follow_candidates(hand: Array[Card], same_kind_cards: Array[Card], needed: int) -> Array:
	if same_kind_cards.size() < needed:
		var partial = same_kind_cards.duplicate()
		partial.append_array(take_cards_except(hand, partial, needed - partial.size()))
		if partial.size() >= needed:
			return [partial.slice(0, needed)]
		return []

	var quads = find_sets_in_cards(same_kind_cards, 4)
	if quads.size() > 0:
		return quads

	var triples = find_sets_in_cards(same_kind_cards, 3)
	if triples.size() > 0:
		var result: Array[Card] = []
		result.append_array(triples[0])
		result.append_array(take_cards_except(same_kind_cards, result, needed - result.size()))
		result.append_array(take_cards_except(hand, result, needed - result.size()))
		if result.size() >= needed:
			return [result.slice(0, needed)]

	var pairs = find_sets_in_cards(same_kind_cards, 2)
	if pairs.size() > 0:
		var result: Array[Card] = []
		var needed_pairs = min(pairs.size(), int(needed / 2))
		for i in range(needed_pairs):
			result.append_array(pairs[i])
		result.append_array(take_cards_except(same_kind_cards, result, needed - result.size()))
		result.append_array(take_cards_except(hand, result, needed - result.size()))
		if result.size() >= needed:
			return [result.slice(0, needed)]

	if same_kind_cards.size() >= needed:
		return [same_kind_cards.slice(0, needed)]
	var result = same_kind_cards.duplicate()
	result.append_array(take_cards_except(hand, result, needed - result.size()))
	if result.size() >= needed:
		return [result.slice(0, needed)]
	return []

static func take_cards_except(cards: Array[Card], excluded: Array, count: int) -> Array[Card]:
	var result: Array[Card] = []
	if count <= 0:
		return result
	for card in cards:
		if excluded.has(card):
			continue
		result.append(card)
		if result.size() >= count:
			break
	return result

static func find_pairs_in_cards(cards: Array[Card]) -> Array:
	"""Find all pairs in a card list."""
	return find_sets_in_cards(cards, 2)

static func find_sets_in_cards(cards: Array[Card], set_size: int) -> Array:
	"""Find all identical card sets of the requested size."""
	var sorted_cards: Array[Card] = []
	sorted_cards.assign(cards)
	sorted_cards.sort_custom(func(a, b): 
		if a.suit != b.suit:
			return a.suit < b.suit
		return a.rank < b.rank
	)
	
	var sets = []
	var i = 0
	while i <= sorted_cards.size() - set_size:
		var candidate: Array[Card] = []
		for offset in range(set_size):
			candidate.append(sorted_cards[i + offset])
		if are_identical_cards(candidate):
			sets.append(candidate)
			i += set_size
		else:
			i += 1
	
	return sets

static func find_tractors_in_cards(
	cards: Array[Card],
	min_length: int,
	trump_suit: Card.Suit,
	current_rank: int,
	rule_mode: String = "",
	set_size_filter: int = 0
) -> Array:
	"""Find tractors in a card list."""
	for card in cards:
		ShengjiCardLogic.apply_trump(card, trump_suit, current_rank)
	
	var tractors = []
	for set_size in get_allowed_tractor_set_sizes(rule_mode):
		if set_size_filter > 0 and set_size != set_size_filter:
			continue
		if min_length % set_size != 0:
			continue
		var required_sets = int(min_length / set_size)
		if required_sets < 2:
			continue

		var sets = find_sets_in_cards(cards, set_size)
		if sets.size() < required_sets:
			continue

		for i in range(sets.size() - required_sets + 1):
			var tractor_cards = []
			for j in range(required_sets):
				tractor_cards.append_array(sets[i + j])

			var pattern = check_tractor(tractor_cards, trump_suit, current_rank, rule_mode)
			if pattern != null and pattern.length == min_length:
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

	if not have_same_play_structure(play1, play2):
		return 1
	
	if play1_is_trump and not play2_is_trump:
		return 1
	elif not play1_is_trump and play2_is_trump:
		return -1
	
	if not play1_is_trump and not play2_is_trump:
		if play1.cards[0].suit != play2.cards[0].suit:
			return 1
	
	var card1 = get_largest_card_for_structure(play1, trump_suit, current_rank)
	var card2 = get_largest_card_for_structure(play2, trump_suit, current_rank)
	
	return ShengjiCardLogic.compare_cards(card1, card2, trump_suit, current_rank)

static func have_same_play_structure(play1: PlayPattern, play2: PlayPattern) -> bool:
	if play1.pattern_type != play2.pattern_type:
		return false
	if play1.length != play2.length:
		return false
	if play1.pattern_type == CardPattern.TRACTOR:
		return play1.set_size == play2.set_size and play1.sequence_length == play2.sequence_length
	if play1.pattern_type == CardPattern.PAIR:
		return play1.set_size == play2.set_size
	if play1.pattern_type == CardPattern.TRIPLE:
		return play1.set_size == play2.set_size
	if play1.pattern_type == CardPattern.QUADRUPLE:
		return play1.set_size == play2.set_size
	if play1.pattern_type == CardPattern.THROW:
		return 0
	return true

static func get_largest_card_for_structure(play: PlayPattern, trump_suit: Card.Suit, current_rank: int) -> Card:
	if play.pattern_type == CardPattern.TRACTOR:
		var sets = build_exact_sets(play.cards, max(2, play.set_size), trump_suit, current_rank)
		if not sets.is_empty():
			var largest_set_card: Card = sets[0]["cards"][0]
			for set_data in sets:
				var card: Card = set_data["cards"][0]
				if ShengjiCardLogic.compare_cards(card, largest_set_card, trump_suit, current_rank) > 0:
					largest_set_card = card
			return largest_set_card
	return get_largest_card(play.cards, trump_suit, current_rank)

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

static func decompose_throw(cards: Array[Card], trump_suit: Card.Suit, current_rank: int, rule_mode: String = "") -> Array:
	var remaining: Array[Card] = []
	remaining.assign(cards)
	var components = []

	for set_size in get_allowed_tractor_set_sizes(rule_mode):
		for tractor_length in range(int(remaining.size() / set_size), 1, -1):
			var target_length = tractor_length * set_size
			var found = true
			while found:
				found = false
				var tractors = find_tractors_in_cards(remaining, target_length, trump_suit, current_rank, rule_mode, set_size)
				if tractors.is_empty():
					continue
				var tractor_cards = tractors[0]
				var pattern = identify_pattern(tractor_cards, trump_suit, current_rank, rule_mode)
				components.append({"cards": tractor_cards, "pattern": pattern})
				remove_cards_by_identity(remaining, tractor_cards)
				found = true

	for set_size in get_allowed_tractor_set_sizes(rule_mode):
		var found_set = true
		while found_set:
			found_set = false
			var sets = find_sets_in_cards(remaining, set_size)
			if sets.is_empty():
				continue
			var set_cards = sets[0]
			var pattern = identify_pattern(set_cards, trump_suit, current_rank, rule_mode)
			components.append({"cards": set_cards, "pattern": pattern})
			remove_cards_by_identity(remaining, set_cards)
			found_set = true

	for card in remaining:
		var single_cards: Array[Card] = [card]
		components.append({
			"cards": single_cards,
			"pattern": PlayPattern.new(CardPattern.SINGLE, single_cards)
		})

	components.sort_custom(func(a, b):
		return get_component_strength_score(a["pattern"], trump_suit, current_rank) < get_component_strength_score(b["pattern"], trump_suit, current_rank)
	)
	return components

static func get_component_strength_score(pattern: PlayPattern, trump_suit: Card.Suit, current_rank: int) -> float:
	var base = 0.0
	match pattern.pattern_type:
		CardPattern.SINGLE:
			base = 1.0
		CardPattern.PAIR:
			base = 2.0
		CardPattern.TRIPLE:
			base = 3.0
		CardPattern.QUADRUPLE:
			base = 4.0
		CardPattern.TRACTOR:
			base = 10.0 + float(pattern.sequence_length)
		_:
			base = 0.0
	var largest = get_largest_card_for_structure(pattern, trump_suit, current_rank)
	var card_score = 0.0 if largest == null else float(_get_trump_order(largest, trump_suit, current_rank))
	return base * 10000.0 + card_score

static func remove_cards_by_identity(source: Array[Card], cards_to_remove: Array):
	for card in cards_to_remove:
		var idx = source.find(card)
		if idx >= 0:
			source.remove_at(idx)

static func find_same_structure_beaters(hand: Array[Card], component_pattern: PlayPattern, trump_suit: Card.Suit, current_rank: int, rule_mode: String = "") -> Array:
	var candidates = []
	match component_pattern.pattern_type:
		CardPattern.SINGLE:
			for card in hand:
				var single_cards: Array[Card] = [card]
				var pattern = PlayPattern.new(CardPattern.SINGLE, single_cards)
				if compare_plays(component_pattern, pattern, trump_suit, current_rank) < 0:
					candidates.append(single_cards)

		CardPattern.PAIR, CardPattern.TRIPLE, CardPattern.QUADRUPLE:
			var set_size = component_pattern.set_size
			for set_cards in find_sets_in_cards(hand, set_size):
				var pattern = identify_pattern(set_cards, trump_suit, current_rank, rule_mode)
				if have_same_play_structure(component_pattern, pattern) and compare_plays(component_pattern, pattern, trump_suit, current_rank) < 0:
					candidates.append(set_cards)

		CardPattern.TRACTOR:
			for tractor_cards in find_tractors_in_cards(hand, component_pattern.length, trump_suit, current_rank, rule_mode, component_pattern.set_size):
				var pattern = identify_pattern(tractor_cards, trump_suit, current_rank, rule_mode)
				if have_same_play_structure(component_pattern, pattern) and compare_plays(component_pattern, pattern, trump_suit, current_rank) < 0:
					candidates.append(tractor_cards)

	return candidates

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
