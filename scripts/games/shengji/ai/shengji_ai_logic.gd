# shengji_ai_logic.gd - Shengji AI card evaluation helpers
extends RefCounted
class_name ShengjiAiLogic

const VOID_TRUMP = -1
const ShengjiCardLogic = preload("res://scripts/games/shengji/rules/shengji_card_logic.gd")

static func normalize_card_list(cards: Array) -> Array[Card]:
	var typed_cards: Array[Card] = []
	for card in cards:
		if card is Card and not typed_cards.has(card):
			typed_cards.append(card)
	return typed_cards

static func has_same_cards(cards_a: Array, cards_b: Array) -> bool:
	if cards_a.size() != cards_b.size():
		return false
	for card in cards_a:
		if not cards_b.has(card):
			return false
	return true

static func append_unique_candidate(candidates: Array, cards: Array[Card]):
	for candidate in candidates:
		if has_same_cards(candidate, cards):
			return
	candidates.append(cards)

static func get_same_suit_cards_for_lead(hand: Array[Card], lead_pattern: GameRules.PlayPattern, trump_suit: Card.Suit, current_level: int) -> Array[Card]:
	var same_suit_cards: Array[Card] = []
	var lead_card = lead_pattern.cards[0]
	ShengjiCardLogic.apply_trump(lead_card, trump_suit, current_level)

	for card in hand:
		ShengjiCardLogic.apply_trump(card, trump_suit, current_level)
		if lead_card.is_trump:
			if card.is_trump:
				same_suit_cards.append(card)
		elif not card.is_trump and card.suit == lead_card.suit:
			same_suit_cards.append(card)

	return same_suit_cards

static func sort_cards_by_strength(cards: Array, ascending: bool, trump_suit: Card.Suit, current_level: int) -> Array:
	var sorted_cards = cards.duplicate()
	for card in sorted_cards:
		ShengjiCardLogic.apply_trump(card, trump_suit, current_level)

	sorted_cards.sort_custom(func(a, b):
		var result = ShengjiCardLogic.compare_cards(a, b, trump_suit, current_level)
		if result == 0:
			if a.suit != b.suit:
				return a.suit < b.suit if ascending else a.suit > b.suit
			return a.rank < b.rank if ascending else a.rank > b.rank
		return result < 0 if ascending else result > 0
	)
	return sorted_cards

static func sort_candidate_list_by_cost(candidates: Array, trump_suit: Card.Suit, current_level: int):
	candidates.sort_custom(func(a, b):
		return get_play_cost(a, trump_suit, current_level) < get_play_cost(b, trump_suit, current_level)
	)

static func take_low_cards(cards: Array, count: int, trump_suit: Card.Suit, current_level: int) -> Array:
	if count <= 0:
		return []
	return sort_cards_by_strength(cards, true, trump_suit, current_level).slice(0, min(count, cards.size()))

static func take_high_cards(cards: Array, count: int, trump_suit: Card.Suit, current_level: int) -> Array:
	if count <= 0:
		return []
	return sort_cards_by_strength(cards, false, trump_suit, current_level).slice(0, min(count, cards.size()))

static func take_point_heavy_cards(cards: Array, count: int, trump_suit: Card.Suit, current_level: int) -> Array:
	if count <= 0:
		return []

	var sorted_cards = cards.duplicate()
	sorted_cards.sort_custom(func(a, b):
		if a.points != b.points:
			return a.points > b.points
		return get_card_cost(a, trump_suit, current_level) < get_card_cost(b, trump_suit, current_level)
	)
	return sorted_cards.slice(0, min(count, sorted_cards.size()))

static func get_cards_except(cards: Array[Card], excluded: Array) -> Array[Card]:
	var result: Array[Card] = []
	for card in cards:
		if not excluded.has(card):
			result.append(card)
	return result

static func build_pair_preferred_candidate(cards: Array[Card], needed: int, trump_suit: Card.Suit, current_level: int) -> Array:
	var result = []
	var pairs = GameRules.find_pairs_in_cards(cards)
	sort_candidate_list_by_cost(pairs, trump_suit, current_level)

	for pair in pairs:
		if result.size() + pair.size() <= needed:
			result.append_array(pair)
		if result.size() >= needed:
			return result.slice(0, needed)

	for card in sort_cards_by_strength(cards, true, trump_suit, current_level):
		if not result.has(card):
			result.append(card)
		if result.size() >= needed:
			break

	return result

static func get_card_cost(card: Card, trump_suit: Card.Suit, current_level: int) -> float:
	ShengjiCardLogic.apply_trump(card, trump_suit, current_level)
	var cost = float(card.rank)

	if card.suit == Card.Suit.JOKER:
		cost += 55.0
	elif card.rank == current_level:
		cost += 30.0
	elif card.is_trump:
		cost += 18.0

	cost += float(card.points) * 0.8
	return cost

static func get_play_cost(cards: Array, trump_suit: Card.Suit, current_level: int) -> float:
	var cost = 0.0
	for card in cards:
		if card is Card:
			cost += get_card_cost(card, trump_suit, current_level)
	return cost

static func is_all_trump_cards(cards: Array, trump_suit: Card.Suit, current_level: int) -> bool:
	if cards.is_empty():
		return false
	for card in cards:
		ShengjiCardLogic.apply_trump(card, trump_suit, current_level)
		if not card.is_trump:
			return false
	return true

static func score_lead_candidate(
	cards: Array,
	ai_player_id: int,
	trump_suit: Card.Suit,
	current_level: int,
	opponent_void_checker: Callable
) -> float:
	var pattern = GameRules.identify_pattern(normalize_card_list(cards), trump_suit, current_level)
	var score = get_play_cost(cards, trump_suit, current_level)
	var points = float(GameRules.calculate_points(cards))
	score += points * 3.5
	score -= float(cards.size() - 1) * 5.5

	if is_all_trump_cards(cards, trump_suit, current_level):
		score += 42.0
	else:
		score -= 16.0

	match pattern.pattern_type:
		GameRules.CardPattern.PAIR:
			score -= 11.0
		GameRules.CardPattern.TRIPLE:
			score -= 18.0
		GameRules.CardPattern.QUADRUPLE:
			score -= 22.0
		GameRules.CardPattern.TRACTOR:
			score -= 18.0 + float(pattern.sequence_length) * 5.0
		GameRules.CardPattern.THROW:
			score -= 14.0

	if not cards.is_empty() and cards[0] is Card:
		var lead_c: Card = cards[0]
		ShengjiCardLogic.apply_trump(lead_c, trump_suit, current_level)
		var void_key = VOID_TRUMP if lead_c.is_trump else lead_c.suit
		if opponent_void_checker.call(ai_player_id, void_key):
			score += 35.0

	if points == 0.0:
		score -= 6.0

	return score

static func score_follow_candidate(
	cards: Array,
	teammate_winning: bool,
	has_winning_candidate: bool,
	can_beat: bool,
	trick_points: int,
	trump_suit: Card.Suit,
	current_level: int
) -> float:
	var cost = get_play_cost(cards, trump_suit, current_level)
	var points = float(GameRules.calculate_points(cards))

	if teammate_winning:
		var score = cost - points * 8.0
		if can_beat:
			score += 140.0 + cost
		return score

	if has_winning_candidate:
		if can_beat:
			return cost - float(trick_points) * 4.0 - points * 2.0
		return 10000.0 + cost + points * 7.0

	return cost + points * 7.0
