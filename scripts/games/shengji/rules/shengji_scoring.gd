# shengji_scoring.gd - Shengji scoring and level progression helpers
extends RefCounted
class_name ShengjiScoring

const GAME_OVER_LEVEL = 14

static func calculate_bottom_multiplier(winning_play: Dictionary) -> int:
	var pattern = winning_play.get("pattern", null)
	if pattern == null:
		return 2

	match pattern.pattern_type:
		GameRules.CardPattern.TRACTOR:
			return int(pow(2, pattern.sequence_length + 1))
		GameRules.CardPattern.PAIR, GameRules.CardPattern.TRIPLE, GameRules.CardPattern.QUADRUPLE:
			return 4
		GameRules.CardPattern.SINGLE, GameRules.CardPattern.THROW:
			return 2
		_:
			return 2

static func get_bottom_multiplier_label(winning_play: Dictionary) -> String:
	var pattern = winning_play.get("pattern", null)
	if pattern == null:
		return "Single"
	match pattern.pattern_type:
		GameRules.CardPattern.TRACTOR:
			return "%d-link Tractor" % pattern.sequence_length
		GameRules.CardPattern.PAIR:
			return "Pair"
		GameRules.CardPattern.TRIPLE:
			return "Triple"
		GameRules.CardPattern.QUADRUPLE:
			return "Quadruple"
		GameRules.CardPattern.THROW:
			return "Throw"
		GameRules.CardPattern.SINGLE:
			return "Single"
		_:
			return "Single"

static func get_round_result(dealer_team: int, attacker_score: int) -> Dictionary:
	var attacker_team = 1 - dealer_team
	if attacker_score >= 200:
		return {"winning_team": attacker_team, "levels": 3, "dealer_rotates": true, "dominant": true, "dealer_takeover": true}
	if attacker_score >= 160:
		return {"winning_team": attacker_team, "levels": 2, "dealer_rotates": true, "dominant": false, "dealer_takeover": true}
	if attacker_score >= 120:
		return {"winning_team": attacker_team, "levels": 1, "dealer_rotates": true, "dominant": false, "dealer_takeover": true}
	if attacker_score >= 80:
		return {"winning_team": attacker_team, "levels": 0, "dealer_rotates": true, "dominant": false, "dealer_takeover": true}
	if attacker_score >= 40:
		return {"winning_team": dealer_team, "levels": 1, "dealer_rotates": false, "dominant": false, "dealer_takeover": false}
	if attacker_score >= 1:
		return {"winning_team": dealer_team, "levels": 2, "dealer_rotates": false, "dominant": false, "dealer_takeover": false}
	return {"winning_team": dealer_team, "levels": 3, "dealer_rotates": false, "dominant": true, "dealer_takeover": false}

static func is_game_over(team_levels: Array[int]) -> bool:
	return team_levels[0] >= GAME_OVER_LEVEL or team_levels[1] >= GAME_OVER_LEVEL

static func get_winner_team(team_levels: Array[int]) -> int:
	return 0 if team_levels[0] >= GAME_OVER_LEVEL else 1
