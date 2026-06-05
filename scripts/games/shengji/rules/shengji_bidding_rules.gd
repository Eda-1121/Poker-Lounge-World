# shengji_bidding_rules.gd - Shengji bid legality helpers
extends RefCounted
class_name ShengjiBiddingRules

static func can_make_bid(player_team: int, suit: Card.Suit, count: int, current_bid: Dictionary) -> bool:
	if count < 1:
		return false

	var current_count = current_bid.get("count", 0)
	var current_suit = current_bid.get("suit", Card.Suit.SPADE)
	var is_no_trump_bid = suit == Card.Suit.JOKER or suit == Card.Suit.NO_TRUMP
	var current_is_no_trump = current_suit == Card.Suit.JOKER or current_suit == Card.Suit.NO_TRUMP

	if current_count == 0:
		return true

	# Once no-trump has been called, it can only be covered by a stronger
	# no-trump call. A larger set of ordinary level cards cannot take it back.
	if current_is_no_trump:
		return is_no_trump_bid and count > current_count

	if is_no_trump_bid:
		return count > current_count

	if player_team == current_bid["team"]:
		return count > current_count

	if player_team != current_bid["team"]:
		return count > current_count

	return false
