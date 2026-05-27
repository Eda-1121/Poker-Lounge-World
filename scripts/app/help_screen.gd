# help_screen.gd - ゲーム内遊び方ガイド
extends Control
class_name HelpScreen

signal closed

const HELP = {
	"en": {
		"title": "How to Play - Shengji / Tractor",
		"sections": ["Overview", "Teams", "Cards", "Trump", "Flow", "Play Rules", "Scoring", "Tips"],
		"content": [
			["Shengji / Tractor", "A four-player trick-taking game played by two teams. Teams advance levels from 2 toward A; the first team to pass A wins."],
			["Teams", "Players sitting opposite each other are partners. Team A is you and the opposite player; Team B is left and right."],
			["Cards", "The game uses standard cards with jokers. 5 is worth 5 points, 10 and K are worth 10 points, and other cards are worth 0 points."],
			["Trump", "Jokers, the current level cards, and the declared trump suit are trump. Trump beats non-trump cards."],
			["Game Flow", "Deal cards, bid for trump, bury 8 bottom cards, play tricks, then score and level up."],
			["Play Rules", "Lead with a single, pair, tractor, or throw. Other players must follow suit when possible and match the lead pattern as closely as their hand allows."],
			["Scoring", "The attacking team needs at least 80 points to win the round. The final trick can capture bottom-card points with a multiplier."],
			["Tips", "Avoid burying trump and point cards. Track void suits, protect your partner, and use high trump to draw opponents' trump cards."],
		],
	},
	"ja": {
		"title": "遊び方 - シェンジー / トラクター",
		"sections": ["概要", "チーム", "カード", "切り札", "流れ", "出し方", "点数", "コツ"],
		"content": [
			["シェンジー / トラクター", "4人2チームで遊ぶトリックテイキングゲームです。各チームは2からAへレベルを上げ、先にAを超えたチームが勝利します。"],
			["チーム", "向かい合う2人が味方です。チームAはあなたと向かい、チームBは左と右のプレイヤーです。"],
			["カード", "ジョーカーを含む標準トランプを使います。5は5点、10とKは10点、それ以外は0点です。"],
			["切り札", "ジョーカー、現在レベルのカード、宣言された切り札スートが切り札です。切り札は通常スートより強くなります。"],
			["ゲームの流れ", "配札、切り札の宣言、底札8枚の選択、トリックのプレイ、得点計算とレベルアップの順に進みます。"],
			["出し方", "最初の人は単牌、ペア、トラクター、まとめ出しで出せます。以降の人は可能な限り同じスートと形に従います。"],
			["点数", "攻撃側は80点以上でラウンド勝利です。最後のトリックでは底札の点数に倍率がかかることがあります。"],
			["コツ", "切り札と点数札を底札に入れすぎないこと。切れたスートを覚え、味方に点数札を渡し、高い切り札で相手の切り札を引き出します。"],
		],
	},
	"zh": {
		"title": "玩法 - 升级 / 拖拉机",
		"sections": ["概览", "队伍", "纸牌", "主牌", "流程", "出牌", "计分", "技巧"],
		"content": [
			["升级 / 拖拉机", "四人两队的吃墩游戏。队伍从2开始升级到A，先超过A的一方获胜。"],
			["队伍", "对家的两名玩家是一队。A队是你和对家，B队是左家和右家。"],
			["纸牌", "使用含大小王的标准扑克牌。5计5分，10和K各计10分，其他牌不计分。"],
			["主牌", "大小王、当前等级牌、以及叫出的主花色都是主牌。主牌大于非主牌。"],
			["游戏流程", "发牌、叫主、埋8张底牌、出牌吃墩、计分并升级。"],
			["出牌规则", "首家可以出单张、对子、拖拉机或甩牌。其他玩家必须尽量跟同花色，并尽量匹配首家牌型。"],
			["计分", "闲家队拿到80分以上即可赢得本局。最后一墩可能抠底，底牌分会按倍率加入。"],
			["技巧", "不要轻易埋主牌和分牌。记住断门花色，配合队友送分，用大主牌消耗对手主牌。"],
		],
	},
}

const C_TITLE   = "#ffd700"  # 金：大見出し
const C_HEAD    = "#7ec8e3"  # 水色：小見出し
const C_CARD    = "#ffb347"  # オレンジ：カード名
const C_KEY     = "#90ee90"  # 緑：キーワード
const C_WARN    = "#ffff88"  # 黄：注意
const C_DIM     = "#8899aa"  # グレー：補足
const C_GOOD    = "#66dd66"  # 明るい緑
const C_BAD     = "#ff7777"  # 赤

var _section_btns: Array[Button] = []
var _rich: RichTextLabel
var _scroll: ScrollContainer
var _active_section: int = 0

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()

# ================================================================
#  UI構築
# ================================================================

func _build_ui():
	# 背景オーバーレイ
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.80)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# ── パネル本体 ──────────────────────────────────────
	var vp  = get_viewport_rect().size
	var mx  = int(vp.x * 0.021)   # 横マージン（≈30px @1440）
	var my  = int(vp.y * 0.015)   # 縦マージン（≈12px @810）
	var PW  = int(vp.x - mx * 2)
	var PH  = int(vp.y - my * 2)

	var panel = Control.new()
	panel.position = Vector2(mx, my)
	panel.size     = Vector2(PW, PH)
	add_child(panel)

	# パネル背景
	var ps = StyleBoxFlat.new()
	ps.bg_color = Color(0.051, 0.106, 0.165)
	ps.border_color = Color(0.941, 0.788, 0.416, 0.38)
	ps.set_border_width_all(1)
	ps.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", ps) if panel is Panel else null
	var pbg = ColorRect.new()
	pbg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pbg.color = Color(0.051, 0.106, 0.165)
	pbg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(pbg)

	# ── ヘッダーバー ──────────────────────────────────
	var hdr = ColorRect.new()
	hdr.position = Vector2(0, 0)
	hdr.size     = Vector2(PW, 52)
	hdr.color    = Color(0.035, 0.070, 0.110)
	hdr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(hdr)

	# ヘッダーゴールドライン
	var accent = ColorRect.new()
	accent.position = Vector2(0, 0)
	accent.size     = Vector2(4, 52)
	accent.color    = Color(0.941, 0.788, 0.416)
	accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(accent)

	var title_lbl = Label.new()
	title_lbl.text = "  %s" % _help_title()
	title_lbl.position = Vector2(8, 8)
	title_lbl.size = Vector2(1100, 36)
	title_lbl.add_theme_font_size_override("font_size", 26)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.38))
	title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(title_lbl)

	var close_btn = Button.new()
	close_btn.text = "✕  %s" % GameConfig.text("close")
	close_btn.position = Vector2(PW - 144, 9)
	close_btn.size = Vector2(132, 34)
	close_btn.add_theme_font_size_override("font_size", 16)
	close_btn.pressed.connect(_on_close)
	panel.add_child(close_btn)

	# ── タブ行 ────────────────────────────────────────
	var tab_bg = ColorRect.new()
	tab_bg.position = Vector2(0, 52)
	tab_bg.size     = Vector2(PW, 38)
	tab_bg.color    = Color(0.035, 0.070, 0.110)
	tab_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(tab_bg)

	var sections = _help_sections()
	var tab_w = float(PW) / sections.size()
	for i in sections.size():
		var btn = Button.new()
		btn.text     = sections[i]
		btn.position = Vector2(i * tab_w, 52)
		btn.size     = Vector2(tab_w - 1, 38)
		btn.add_theme_font_size_override("font_size", 15)
		btn.pressed.connect(func(): _switch_section(i))
		panel.add_child(btn)
		_section_btns.append(btn)

	# ヘッダー下の仕切り
	var sep = ColorRect.new()
	sep.position = Vector2(0, 90)
	sep.size     = Vector2(PW, 1)
	sep.color    = Color(0.941, 0.788, 0.416, 0.30)
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(sep)

	# ── コンテンツ（スクロール） ─────────────────────
	_scroll = ScrollContainer.new()
	_scroll.position = Vector2(0, 92)
	_scroll.size     = Vector2(PW, PH - 92)
	panel.add_child(_scroll)

	_rich = RichTextLabel.new()
	_rich.custom_minimum_size = Vector2(PW - 20, 0)
	_rich.size = Vector2(PW - 20, 0)
	_rich.fit_content = true
	_rich.bbcode_enabled = true
	_rich.scroll_active = false
	_rich.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rich.add_theme_constant_override("line_separation", 4)
	var rich_style = StyleBoxFlat.new()
	rich_style.content_margin_left  = 20
	rich_style.content_margin_right = 20
	rich_style.content_margin_top   = 8
	rich_style.bg_color = Color(0, 0, 0, 0)
	_rich.add_theme_stylebox_override("normal", rich_style)
	_scroll.add_child(_rich)

	# パネル外枠
	for r in [
		[Vector2(0,    0),      Vector2(PW,  1)],
		[Vector2(0,    PH - 1), Vector2(PW,  1)],
		[Vector2(0,    0),      Vector2(1,   PH)],
		[Vector2(PW-1, 0),      Vector2(1,   PH)],
	]:
		var b = ColorRect.new()
		b.position = r[0]; b.size = r[1]
		b.color = Color(0.941, 0.788, 0.416, 0.35)
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(b)

	_switch_section(0)

# ================================================================
#  タブ切り替え
# ================================================================

func _switch_section(idx: int):
	_active_section = idx
	for i in _section_btns.size():
		var s = StyleBoxFlat.new()
		var active = (i == idx)
		s.bg_color     = Color(0.08, 0.14, 0.10, 0.90) if active else Color(0.035, 0.070, 0.110)
		s.border_color = Color(0.941, 0.788, 0.416, 0.80) if active else Color(0.941, 0.788, 0.416, 0.18)
		s.set_border_width_all(0)
		s.border_width_bottom = 3 if active else 1
		s.set_corner_radius_all(0)
		_section_btns[i].add_theme_stylebox_override("normal", s)
		_section_btns[i].add_theme_stylebox_override("hover",  s if active else _hover_style())
		var fc = Color(1.0, 0.92, 0.38) if active else Color(0.75, 0.87, 1.00)
		_section_btns[i].add_theme_color_override("font_color", fc)
	_rich.text = _get_content(idx)
	_scroll.scroll_vertical = 0

func _hover_style() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color(0.05, 0.10, 0.16)
	s.border_width_bottom = 1
	s.border_color = Color(0.941, 0.788, 0.416, 0.30)
	return s

# ================================================================
#  BBCode ヘルパー
# ================================================================

func H(text: String) -> String:
	return "\n[bgcolor=#0d1e35][color=%s][b]  %s  [/b][/color][/bgcolor]\n" % [C_TITLE, text]

func H2(text: String) -> String:
	return "\n[color=%s][b]▌ %s[/b][/color]\n" % [C_HEAD, text]

func T(text: String) -> String:
	return "[indent]%s[/indent]\n" % text

func Bullet(items: Array) -> String:
	var s = ""
	for item in items:
		s += "[indent]  •  %s[/indent]\n" % item
	return s

func card(t: String) -> String:
	return "[color=%s][b]%s[/b][/color]" % [C_CARD, t]

func key(t: String) -> String:
	return "[color=%s][b]%s[/b][/color]" % [C_KEY, t]

func warn(t: String) -> String:
	return "[indent][bgcolor=#2a2800][color=%s]  ⚠  %s  [/color][/bgcolor][/indent]\n" % [C_WARN, t]

func dim(t: String) -> String:
	return "[color=%s]%s[/color]" % [C_DIM, t]

# ================================================================
#  セクション別コンテンツ
# ================================================================

func _get_content(idx: int) -> String:
	var content = _help_content()
	if idx < 0 or idx >= content.size():
		return ""
	var section = content[idx]
	var t = H(section[0])
	t += T(section[1])
	return t

func _help_table() -> Dictionary:
	return HELP.get(GameConfig.language, HELP["en"])

func _help_title() -> String:
	return _help_table()["title"]

func _help_sections() -> Array:
	return _help_table()["sections"]

func _help_content() -> Array:
	return _help_table()["content"]

# ================================================================
#  Callbacks
# ================================================================

func _on_close():
	SoundManager.play_card_click()
	closed.emit()
	queue_free()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_on_close()
