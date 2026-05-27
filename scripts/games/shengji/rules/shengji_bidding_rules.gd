# shengji_bidding_rules.gd - Shengji bid legality helpers
extends RefCounted
class_name ShengjiBiddingRules

static func can_make_bid(player_team: int, suit: Card.Suit, count: int, current_bid: Dictionary) -> bool:
	if current_bid["count"] == 0:
		return count >= 1

	if suit == Card.Suit.JOKER:
		return count > current_bid["count"]

	if player_team == current_bid["team"]:
		return suit == current_bid["suit"] and count > current_bid["count"]

	if player_team != current_bid["team"]:
		return count > current_bid["count"]

	return false

