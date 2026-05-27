# shengji_scoring.gd - Shengji scoring and level progression helpers
extends RefCounted
class_name ShengjiScoring

const GAME_OVER_LEVEL = 14

static func calculate_bottom_multiplier(winning_play: Dictionary) -> int:
	var small_joker_count = 0
	var big_joker_count = 0
	for card in winning_play.get("cards", []):
		if card.suit == Card.Suit.JOKER:
			if card.rank == Card.Rank.BIG_JOKER:
				big_joker_count += 1
			else:
				small_joker_count += 1
	if big_joker_count >= 2 and small_joker_count >= 2:
		return 16
	if big_joker_count >= 2:
		return 8
	if small_joker_count >= 2:
		return 4
	return 2

static func get_round_result(dealer_team: int, attacker_score: int) -> Dictionary:
	var attacker_team = 1 - dealer_team
	if attacker_score >= 200:
		return {"winning_team": attacker_team, "levels": 4, "dealer_rotates": true, "dominant": true}
	if attacker_score >= 160:
		return {"winning_team": attacker_team, "levels": 3, "dealer_rotates": true, "dominant": false}
	if attacker_score >= 120:
		return {"winning_team": attacker_team, "levels": 2, "dealer_rotates": true, "dominant": false}
	if attacker_score >= 80:
		return {"winning_team": attacker_team, "levels": 1, "dealer_rotates": true, "dominant": false}
	if attacker_score >= 40:
		return {"winning_team": dealer_team, "levels": 1, "dealer_rotates": false, "dominant": false}
	if attacker_score >= 1:
		return {"winning_team": dealer_team, "levels": 2, "dealer_rotates": false, "dominant": false}
	return {"winning_team": dealer_team, "levels": 3, "dealer_rotates": false, "dominant": true}

static func is_game_over(team_levels: Array[int]) -> bool:
	return team_levels[0] >= GAME_OVER_LEVEL or team_levels[1] >= GAME_OVER_LEVEL

static func get_winner_team(team_levels: Array[int]) -> int:
	return 0 if team_levels[0] >= GAME_OVER_LEVEL else 1

