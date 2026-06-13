# game_config.gd - グローバル設定シングルトン
extends Node

signal play_hints_changed(enabled: bool)
signal language_changed(language: String)
signal card_style_changed(style_id: String)

var num_decks: int = 2
var sound_enabled: bool = true
var play_hints_enabled: bool = true
var card_style: String = "default"
var language: String = "en"
var total_plays: int = 0
var wins: int = 0

const SHENGJI_MODE_EASY = "easy"
const SHENGJI_MODE_HARD = "hard"

const CARD_STYLES = {
	"default": {
		"folder": "classic",
		"name_key": "card_style_default",
	},
	"minimal": {
		"folder": "minimal",
		"name_key": "card_style_minimal",
	},
	"illustrated": {
		"folder": "illustrated_ai",
		"name_key": "card_style_illustrated",
	},
}

const CARD_SET_ROOT = "res://assets/common/card_sets"

const TEXT = {
	"en": {
		"settings": "Settings",
		"app_title": "World Card Games",
		"plays": "Plays",
		"wins": "Wins",
		"win_rate": "Win Rate",
		"play_game": "Play",
		"how_to_play": "How to Play",
		"coming_soon": "Coming Soon",
		"quit": "Quit",
		"game_shengji_name": "Shengji / Tractor",
		"game_shengji_sub": "Shengji - Tractor",
		"game_shengji_desc": "4 players - 2 teams\nChinese trick-taking",
		"game_hearts_name": "Hearts",
		"game_hearts_sub": "Hearts",
		"game_hearts_desc": "4 players - Solo\nAvoid hearts and the queen of spades",
		"game_bridge_name": "Bridge",
		"game_bridge_sub": "Contract Bridge",
		"game_bridge_desc": "4 players - 2 teams\nBid and win tricks",
		"game_poker_name": "Poker",
		"game_poker_sub": "Texas Hold'em",
		"game_poker_desc": "2-9 players - Solo\nWin with odds and bluffing",
		"sound": "Sound",
		"hints": "Hints",
		"card_design": "Card Design",
		"card_style_default": "Classic",
		"card_style_minimal": "Minimal",
		"card_style_illustrated": "Illustrated",
		"language": "Language",
		"english": "English",
		"japanese": "Japanese",
		"chinese": "Chinese",
		"close": "Close",
		"current_level": "Current Level: %s",
		"game_mode": "Mode: %s",
		"shengji_mode_easy": "Easy (%d decks)",
		"shengji_mode_hard": "Hard (%d decks)",
		"trump_suit": "Trump Suit: %s",
		"team_a": "Team A",
		"team_b": "Team B",
		"points": "%d pts",
		"your_turn": "Your turn",
		"selected": "Selected: %d/%d",
		"play": "Play Selected",
		"confirm_bury": "Confirm Bury",
		"action_hint_select_play": "Select cards to play",
		"action_hint_ready_play": "Ready to play",
		"action_hint_select_bury": "Select exactly %d cards",
		"action_hint_ready_bury": "Ready to bury",
		"previous_trick": "Previous Trick",
		"you": "You",
		"left": "Player 2",
		"opposite": "Player 3",
		"right": "Player 4",
		"game_over": "Game Over",
		"team_wins": "Team %s Wins!",
		"final_level": "Final Level",
		"total_rounds": "Total %d rounds",
		"restart": "Restart",
		"title": "Title",
		"quit_game": "Quit Game",
		"shengji_title": "Shengji - Tractor",
		"bidding_phase": "Bidding Phase",
		"no_bid_yet": "No bid yet",
		"bid_card_count": "%s (%d cards)",
		"pass": "Pass",
		"skip_bid_suit": "Skip This Suit",
		"skip_all_bidding_prompts": "Skip All Prompts",
		"skip_bidding_prompts": "Skip All Prompts",
		"player_name": "Player %d",
		"team_name": "Team %d",
		"turn_play_cards": "Turn: %s",
		"dealing": "Dealing...",
		"dealing_progress": "Dealing... (%d/%d)",
		"final_bid_opportunity": "Final bid opportunity!",
		"dealing_final_bid": "Dealing complete. Final bid opportunity...",
		"player_bidding": "%s is bidding...",
		"invalid_bid": "Invalid bid!",
		"player_bids": "%s bids %s",
		"current_bid_none": "Current bid: none",
		"current_bid": "Current: %s - %s",
		"team_bid_trump": "%s bid trump: %s",
		"suit_spade": "Spade",
		"suit_heart": "Heart",
		"suit_club": "Club",
		"suit_diamond": "Diamond",
		"suit_no_trump": "No Trump",
		"bury_hint": "Bury cards: red=avoid / yellow=points / green=safe",
		"suggested_bury": "Hints show safer cards to bury.",
		"select_exact_bury": "Please select exactly %d cards!",
		"bury_complete": "Bury complete",
		"ai_burying": "AI dealer is burying cards...",
		"not_your_turn": "It is not your turn yet",
		"select_cards_first": "Please select cards to play first!",
		"selected_cards_invalid": "Selected cards do not match the play rules!",
		"invalid_play": "Invalid play!",
		"throw_failed": "Throw failed. Forced to play the smallest valid part.",
		"cards_played": "Cards played!",
		"play_failed": "Play failed!",
		"follow_invalid": "Follow play does not match the rules!",
		"follow_accepted": "Follow play accepted!",
		"trick_won": "%s wins this trick and scores %d points",
		"dealer_captures_bottom": "Dealer team captures bottom! +%d points (x%d)",
		"opponent_captures_bottom": "Opponent team captures bottom! +%d points (x%d)",
		"team_dominates_levels": "%s dominates! +%d levels!",
		"team_wins_levels": "%s wins! +%d levels!",
		"team_holds_levels": "%s holds! +%d levels!",
		"team_takes_dealer": "%s takes dealer side!",
	},
	"ja": {
		"settings": "設定",
		"app_title": "世界のカードゲーム",
		"plays": "プレイ数",
		"wins": "勝利数",
		"win_rate": "勝率",
		"play_game": "プレイ",
		"how_to_play": "遊び方",
		"coming_soon": "準備中",
		"quit": "終了",
		"game_shengji_name": "升级 / Tractor",
		"game_shengji_sub": "シェンジー - トラクター",
		"game_shengji_desc": "4人 - 2チーム\n中国のトリックテイキング",
		"game_hearts_name": "ハーツ",
		"game_hearts_sub": "ハーツ",
		"game_hearts_desc": "4人 - 個人戦\nハートとスペードQを避ける",
		"game_bridge_name": "ブリッジ",
		"game_bridge_sub": "コントラクトブリッジ",
		"game_bridge_desc": "4人 - 2チーム\nビッドしてトリックを取る",
		"game_poker_name": "ポーカー",
		"game_poker_sub": "テキサスホールデム",
		"game_poker_desc": "2-9人 - 個人戦\n確率と駆け引きで勝つ",
		"sound": "サウンド",
		"hints": "ヒント表示",
		"card_design": "カードデザイン",
		"card_style_default": "クラシック",
		"card_style_minimal": "ミニマル",
		"card_style_illustrated": "イラスト",
		"language": "言語",
		"english": "英語",
		"japanese": "日本語",
		"chinese": "中国語",
		"close": "閉じる",
		"current_level": "現在レベル: %s",
		"game_mode": "モード: %s",
		"shengji_mode_easy": "Easy (%dデック)",
		"shengji_mode_hard": "Hard (%dデック)",
		"trump_suit": "切り札スート: %s",
		"team_a": "チームA",
		"team_b": "チームB",
		"points": "%d点",
		"your_turn": "あなたの番",
		"selected": "選択: %d/%d",
		"play": "出す",
		"confirm_bury": "底札を確定",
		"action_hint_select_play": "出すカードを選択",
		"action_hint_ready_play": "出せます",
		"action_hint_select_bury": "ちょうど%d枚選択",
		"action_hint_ready_bury": "底札を確定できます",
		"previous_trick": "前の手",
		"you": "あなた",
		"left": "プレイヤー2",
		"opposite": "プレイヤー3",
		"right": "プレイヤー4",
		"game_over": "ゲーム終了",
		"team_wins": "チーム%s が勝利!",
		"final_level": "最終レベル",
		"total_rounds": "合計 %d ラウンド",
		"restart": "もう一度",
		"title": "タイトルへ",
		"quit_game": "ゲームを終了",
		"shengji_title": "シェンジー - トラクター",
		"bidding_phase": "入札フェーズ",
		"no_bid_yet": "まだ入札なし",
		"bid_card_count": "%s (%d枚)",
		"pass": "パス",
		"skip_bid_suit": "この花色をスキップ",
		"skip_all_bidding_prompts": "すべて停止",
		"skip_bidding_prompts": "すべて停止",
		"player_name": "プレイヤー%d",
		"team_name": "チーム%d",
		"turn_play_cards": "%s の番",
		"dealing": "配札中...",
		"dealing_progress": "配札中... (%d/%d)",
		"final_bid_opportunity": "最後の入札チャンス!",
		"dealing_final_bid": "配札完了。最後の入札チャンス...",
		"player_bidding": "%s が入札中...",
		"invalid_bid": "無効な入札です!",
		"player_bids": "%s が %s で入札",
		"current_bid_none": "現在の入札: なし",
		"current_bid": "現在: %s - %s",
		"team_bid_trump": "%s が主を宣言: %s",
		"suit_spade": "スペード",
		"suit_heart": "ハート",
		"suit_club": "クラブ",
		"suit_diamond": "ダイヤ",
		"suit_no_trump": "ノートランプ",
		"bury_hint": "底札選択: 赤=避ける / 黄=点数 / 緑=安全",
		"suggested_bury": "底札にしやすいカードを色で表示しています。",
		"select_exact_bury": "ちょうど%d枚選択してください!",
		"bury_complete": "底札の確定完了",
		"ai_burying": "AIディーラーが底札を選択中...",
		"not_your_turn": "まだあなたの番ではありません",
		"select_cards_first": "先に出すカードを選択してください!",
		"selected_cards_invalid": "選択したカードはルールに合いません!",
		"invalid_play": "無効な出し方です!",
		"throw_failed": "まとめ出し失敗。出せる最小の形を強制的に出します。",
		"cards_played": "カードを出しました!",
		"play_failed": "出せませんでした!",
		"follow_invalid": "フォローの出し方がルールに合いません!",
		"follow_accepted": "フォローを受け付けました!",
		"trick_won": "%s がこの手に勝ち、%d点を獲得",
		"dealer_captures_bottom": "親チームが底札を獲得! +%d点 (x%d)",
		"opponent_captures_bottom": "相手チームが底札を獲得! +%d点 (x%d)",
		"team_dominates_levels": "%s が圧勝! +%dレベル!",
		"team_wins_levels": "%s が勝利! +%dレベル!",
		"team_holds_levels": "%s が防衛! +%dレベル!",
		"team_takes_dealer": "%s が親側になります!",
	},
	"zh": {
		"settings": "设置",
		"app_title": "世界纸牌游戏",
		"plays": "局数",
		"wins": "胜场",
		"win_rate": "胜率",
		"play_game": "开始",
		"how_to_play": "玩法",
		"coming_soon": "即将推出",
		"quit": "退出",
		"game_shengji_name": "升级 / 拖拉机",
		"game_shengji_sub": "升级 - 拖拉机",
		"game_shengji_desc": "4人 - 2队\n中国式吃墩游戏",
		"game_hearts_name": "红心大战",
		"game_hearts_sub": "红心大战",
		"game_hearts_desc": "4人 - 个人战\n避开红心和黑桃Q",
		"game_bridge_name": "桥牌",
		"game_bridge_sub": "合约桥牌",
		"game_bridge_desc": "4人 - 2队\n叫牌并赢得牌墩",
		"game_poker_name": "扑克",
		"game_poker_sub": "德州扑克",
		"game_poker_desc": "2-9人 - 个人战\n用概率和诈唬取胜",
		"sound": "声音",
		"hints": "提示",
		"card_design": "牌面设计",
		"card_style_default": "经典",
		"card_style_minimal": "极简",
		"card_style_illustrated": "插画",
		"language": "语言",
		"english": "英语",
		"japanese": "日语",
		"chinese": "中文",
		"close": "关闭",
		"current_level": "当前等级：%s",
		"game_mode": "模式：%s",
		"shengji_mode_easy": "简单（%d副牌）",
		"shengji_mode_hard": "困难（%d副牌）",
		"trump_suit": "主花色：%s",
		"team_a": "A队",
		"team_b": "B队",
		"points": "%d分",
		"your_turn": "轮到你",
		"selected": "已选：%d/%d",
		"play": "出牌",
		"confirm_bury": "确认埋底",
		"action_hint_select_play": "请选择要出的牌",
		"action_hint_ready_play": "可以出牌",
		"action_hint_select_bury": "请选择正好%d张",
		"action_hint_ready_bury": "可以确认埋底",
		"previous_trick": "上一手",
		"you": "你",
		"left": "玩家2",
		"opposite": "玩家3",
		"right": "玩家4",
		"game_over": "游戏结束",
		"team_wins": "%s队获胜！",
		"final_level": "最终等级",
		"total_rounds": "共 %d 局",
		"restart": "再来一局",
		"title": "返回标题",
		"quit_game": "退出游戏",
		"shengji_title": "升级",
		"bidding_phase": "叫主阶段",
		"no_bid_yet": "尚未叫主",
		"bid_card_count": "%s（%d张）",
		"pass": "不叫",
		"skip_bid_suit": "跳过此花色",
		"skip_all_bidding_prompts": "本局不再提示",
		"skip_bidding_prompts": "本局不再提示",
		"player_name": "玩家%d",
		"team_name": "%d队",
		"turn_play_cards": "轮到 %s",
		"dealing": "发牌中...",
		"dealing_progress": "发牌中... (%d/%d)",
		"final_bid_opportunity": "最后叫主机会！",
		"dealing_final_bid": "发牌完成，最后叫主机会...",
		"player_bidding": "%s 正在叫主...",
		"invalid_bid": "叫主无效！",
		"player_bids": "%s 叫主：%s",
		"current_bid_none": "当前叫主：无",
		"current_bid": "当前：%s - %s",
		"team_bid_trump": "%s 叫主：%s",
		"suit_spade": "黑桃",
		"suit_heart": "红桃",
		"suit_club": "梅花",
		"suit_diamond": "方块",
		"suit_no_trump": "无主",
		"bury_hint": "埋底：红=避免 / 黄=分牌 / 绿=安全",
		"suggested_bury": "颜色提示较适合埋底的牌。",
		"select_exact_bury": "请选择正好%d张牌！",
		"bury_complete": "埋底完成",
		"ai_burying": "AI庄家正在埋底...",
		"not_your_turn": "还没轮到你",
		"select_cards_first": "请先选择要出的牌！",
		"selected_cards_invalid": "所选牌不符合出牌规则！",
		"invalid_play": "出牌无效！",
		"throw_failed": "甩牌失败，将强制打出可出的最小牌型。",
		"cards_played": "已出牌！",
		"play_failed": "出牌失败！",
		"follow_invalid": "跟牌不符合规则！",
		"follow_accepted": "跟牌成功！",
		"trick_won": "%s 赢得本手并获得 %d 分",
		"dealer_captures_bottom": "庄家队抠底！+%d分 (x%d)",
		"opponent_captures_bottom": "闲家队抠底！+%d分 (x%d)",
		"team_dominates_levels": "%s 大胜！+%d级！",
		"team_wins_levels": "%s 获胜！+%d级！",
		"team_holds_levels": "%s 保庄！+%d级！",
		"team_takes_dealer": "%s 上台坐庄！",
	},
}

func set_play_hints_enabled(enabled: bool):
	if play_hints_enabled == enabled:
		return
	play_hints_enabled = enabled
	play_hints_changed.emit(enabled)

func set_language(value: String):
	if not TEXT.has(value):
		value = "en"
	if language == value:
		return
	language = value
	language_changed.emit(language)

func set_card_style(style_id: String):
	var styles = get_card_styles()
	if not styles.has(style_id):
		style_id = "default"
	if card_style == style_id:
		return
	card_style = style_id
	card_style_changed.emit(card_style)

func get_card_asset_path(card_name: String) -> String:
	var styles = get_card_styles()
	var active_style = card_style if styles.has(card_style) else "default"
	var style = styles.get(active_style, styles["default"])
	var folder = style.get("folder", "classic")
	return "%s/%s/%s.png" % [CARD_SET_ROOT, folder, card_name]

func get_card_style_name(style_id: String) -> String:
	var styles = get_card_styles()
	var style = styles.get(style_id, styles["default"])
	if style.has("name_key"):
		return text(style["name_key"])
	return String(style_id).capitalize()

func get_card_style_ids() -> Array:
	return get_card_styles().keys()

func get_card_styles() -> Dictionary:
	var styles = {}
	var registered_folders = {}
	for style_id in CARD_STYLES.keys():
		var style = CARD_STYLES[style_id].duplicate(true)
		var folder = style.get("folder", style_id)
		registered_folders[folder] = true
		if is_complete_card_set(folder):
			styles[style_id] = style

	var dir = DirAccess.open(CARD_SET_ROOT)
	if dir == null:
		return ensure_default_card_style(styles)

	dir.list_dir_begin()
	var folder = dir.get_next()
	while folder != "":
		if dir.current_is_dir() and not folder.begins_with(".") and not registered_folders.has(folder):
			if is_complete_card_set(folder):
				styles[folder] = {"folder": folder}
		folder = dir.get_next()
	dir.list_dir_end()
	return ensure_default_card_style(styles)

func ensure_default_card_style(styles: Dictionary) -> Dictionary:
	if styles.has("default"):
		return styles
	if is_complete_card_set("classic"):
		styles["default"] = {
			"folder": "classic",
			"name_key": "card_style_default",
		}
	return styles

func is_complete_card_set(folder: String) -> bool:
	for card_name in get_required_card_asset_names():
		if not ResourceLoader.exists("%s/%s/%s.png" % [CARD_SET_ROOT, folder, card_name]):
			return false
	return true

func get_required_card_asset_names() -> Array[String]:
	var names: Array[String] = ["card_back", "card_empty", "small_joker", "big_joker"]
	for suit in ["spade", "heart", "club", "diamond"]:
		for rank in range(2, 15):
			names.append("%s_%02d" % [suit, rank])
	return names

func get_shengji_mode() -> String:
	return SHENGJI_MODE_HARD if num_decks >= 4 else SHENGJI_MODE_EASY

func get_shengji_bottom_card_count() -> int:
	return 12 if get_shengji_mode() == SHENGJI_MODE_HARD else 8

func text(key: String) -> String:
	var table = TEXT.get(language, TEXT["en"])
	if table.has(key):
		return table[key]
	return TEXT["en"].get(key, key)
