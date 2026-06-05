# help_screen.gd - ゲーム内遊び方ガイド
extends Control
class_name HelpScreen

signal closed

const HELP = {
	"en": {
		"title": "How to Play - Shengji / Tractor",
		"sections": ["Goal", "Round Flow", "Your Turn", "Trump", "Scoring", "Cheat Sheet"],
		"content": [
			["Goal", "[b]Shengji is a team trick-taking game.[/b]\n\nYou play as Player 1. Player 3 is your partner. Players 2 and 4 are the other team.\n\nEach team has a level, starting at 2. A round is played at the dealer side's current level. Teams try to climb from 2 toward A; the first team to pass A wins the game.\n\nCards with points: 5 = 5 points, 10 = 10 points, K = 10 points. Other cards are 0 points."],
			["Round Flow", "[b]One round has five steps.[/b]\n\n1. Cards are dealt.\n2. Players may bid to choose trump.\n3. The dealer side receives the bottom cards and buries cards.\n4. Players take turns playing tricks until all hands are empty.\n5. Scores decide whether the dealer side keeps control or the attacking side takes over.\n\nEasy mode uses 2 decks and 8 bottom cards. Hard mode uses 4 decks and 12 bottom cards."],
			["Your Turn", "[b]When it is your turn, select cards and press Play Selected.[/b]\n\nIf you lead the trick, you may start with a single, a pair, a tractor, or a throw.\n\nIf another player already led, you must follow that shape when your hand allows it. If the lead is a pair and you have a pair in that suit or trump group, you must play a pair. If the lead is a tractor and you have a matching tractor, you must play a tractor.\n\nWhen you are unsure, use the hint dots and choose the suggested cards."],
			["Trump", "[b]Trump cards beat normal suit cards.[/b]\n\nTrump includes jokers, all current-level cards, and the declared trump suit.\n\nA joker bid creates No Trump. No-trump bid cards must be the same joker type: two Big Jokers or two Small Jokers can make a 2-card No Trump bid, but one Big Joker plus one Small Joker cannot. In No Trump, jokers and all four level-card suits are trump, and the four level-card suits have equal strength.\n\nDuring dealing and after dealing, a player may bid with one or more level cards. A later bid must use more cards than the current bid."],
			["Scoring", "[b]The attacking side is the team that did not win the bid.[/b]\n\nIf attackers get 80 or more points, they become the dealer side next round. 80-119 only changes dealer side. 120-159 gives attackers +1 level, 160-199 gives +2, and 200+ gives +3.\n\nIf attackers stay under 80, the dealer side holds and levels up. 40-79 gives dealer side +1, 1-39 gives +2, and 0 gives +3.\n\nThe final trick can capture bottom-card points with a multiplier: single or throw x2, set x4, tractor length 2 x8, then doubles for each extra link."],
			["Cheat Sheet", "[b]Beginner priorities[/b]\n\n1. Follow suit or trump group when possible.\n2. If the lead is a pair, play a pair if you have one.\n3. If the lead is a tractor, play a tractor if you have one.\n4. Save strong trump for valuable tricks.\n5. Avoid burying trump and point cards unless you have a reason.\n6. When unsure, trust the hint dots first."],
		],
	},
	"ja": {
		"title": "遊び方 - シェンジー / トラクター",
		"sections": ["目的", "流れ", "自分の番", "切り札", "点数", "早見表"],
		"content": [
			["目的", "[b]シェンジーは、4人2チームのトリックテイキングゲームです。[/b]\n\nあなたは Player 1 です。Player 3 が味方、Player 2 と Player 4 が相手です。\n\n各チームにはレベルがあり、最初は2から始まります。ラウンドは親側チームの現在レベルで行います。2からAへ進み、Aを超えたチームがゲームに勝ちます。\n\n点数札は 5 = 5点、10 = 10点、K = 10点です。それ以外は0点です。"],
			["流れ", "[b]1ラウンドはこの順番で進みます。[/b]\n\n1. カードが配られます。\n2. レベルカードで切り札を宣言します。\n3. 親側が底札を受け取り、同じ枚数を埋めます。\n4. 全員の手札がなくなるまで、順番にカードを出します。\n5. 攻撃側の点数で、親交代やレベルアップを決めます。\n\nEasyは2デックで底札8枚、Hardは4デックで底札12枚です。"],
			["自分の番", "[b]自分の番では、カードを選んで Play Selected を押します。[/b]\n\n自分が最初に出す場合は、単牌、ペア、トラクター、まとめ出しを選べます。\n\nすでに誰かが出している場合は、できるだけ同じ種類で返します。相手がペアを出し、自分も同じスートまたは切り札グループのペアを持っていれば、ペアで返す必要があります。相手がトラクターを出し、自分も返せるトラクターを持っていれば、トラクターで返す必要があります。\n\n迷ったときは、まず光点のヒントが付いているカードを選んでください。"],
			["切り札", "[b]切り札は、普通のスートより強いカードです。[/b]\n\n切り札には、ジョーカー、現在レベルのカード、宣言された切り札スートが含まれます。\n\nジョーカーで入札するとノートランプになります。ノートランプ叫牌の枚数は同じ種類のジョーカーだけで数えます。Big Joker 2枚、または Small Joker 2枚なら2枚叫牌にできますが、Big Joker 1枚 + Small Joker 1枚は2枚叫牌にはできません。ノートランプでは、ジョーカーと4花色すべてのレベルカードが切り札になり、4花色のレベルカードは同じ強さです。\n\n配札中と配札後に、1枚以上のレベルカードで入札できます。後から上書きするには、現在の入札より多い枚数が必要です。"],
			["点数", "[b]攻撃側は、入札を取らなかったチームです。[/b]\n\n攻撃側が80点以上取ると、次のラウンドで親側になります。80-119点は親交代のみです。120-159点は攻撃側+1、160-199点は+2、200点以上は+3です。\n\n攻撃側を80点未満に抑えた場合は、親側が防衛成功です。40-79点なら親側+1、1-39点なら+2、0点なら+3です。\n\n最後のトリックでは底札点に倍率がかかります。単牌またはまとめ出しはx2、ペアなどの組はx4、長さ2のトラクターはx8、以降は1段ごとに倍になります。"],
			["早見表", "[b]初めて遊ぶときの優先順位[/b]\n\n1. 出されたスート、または切り札グループにできるだけ従う。\n2. ペアで出されたら、持っているペアで返す。\n3. トラクターで出されたら、持っているトラクターで返す。\n4. 強い切り札は、大事なトリックまで温存する。\n5. 底札には、できるだけ切り札と点数札を入れない。\n6. 迷ったら、まずヒントの光点を信じる。"],
		],
	},
	"zh": {
		"title": "玩法 - 升级 / 拖拉机",
		"sections": ["目标", "流程", "出牌", "主牌", "计分", "速查"],
		"content": [
			["目标", "[b]升级是四人两队的吃墩游戏。[/b]\n\n你是玩家1，玩家3是你的队友，玩家2和玩家4是对手。\n\n每队都有等级，最初从2开始。每局按庄家队当前等级进行。队伍从2升到A，先超过A的一方获胜。\n\n分牌是 5 = 5分，10 = 10分，K = 10分。其他牌不计分。"],
			["流程", "[b]一局按这个顺序进行。[/b]\n\n1. 发牌。\n2. 用等级牌叫主。\n3. 庄家队拿底牌，并埋回同样张数的牌。\n4. 轮流出牌，直到所有手牌出完。\n5. 根据闲家队得分，决定换庄或升级。\n\n简单模式使用2副牌，底牌8张。困难模式使用4副牌，底牌12张。"],
			["出牌", "[b]轮到你时，选择手牌并按 Play Selected。[/b]\n\n如果你是首家，可以出单张、对子、拖拉机或甩牌。\n\n如果别人已经首出，你要尽量跟相同类型。首家出对子时，如果你有同花色或同主牌组的对子，就必须跟对子。首家出拖拉机时，如果你有能跟的拖拉机，就必须跟拖拉机。\n\n不知道出什么时，先选择带提示光点的牌。"],
			["主牌", "[b]主牌比普通花色更强。[/b]\n\n主牌包括大小王、当前等级牌、以及叫出的主花色。\n\n用王叫主时为无主。无主叫牌张数只计算同一种王：两张大王或两张小王可以作为两张无主叫牌，但一张大王加一张小王不能作为两张无主叫牌。无主时，大小王和四种花色的等级牌都是主牌，四种等级牌强度相同。\n\n发牌中和发牌后都可以用一张或多张等级牌叫主。后叫必须比当前叫主张数更多。"],
			["计分", "[b]闲家队就是没有叫到主的一方。[/b]\n\n闲家队拿到80分以上，下一局就上台坐庄。80-119分只换庄不升级，120-159分闲家+1级，160-199分+2级，200分以上+3级。\n\n如果闲家低于80分，庄家保庄成功。40-79分庄家+1级，1-39分+2级，0分+3级。\n\n最后一墩可能抠底，底牌分会按倍率加入。单张或甩牌x2，对子等组合x4，长度2的拖拉机x8，之后每多一节翻倍。"],
			["速查", "[b]第一次玩时优先记这些[/b]\n\n1. 尽量跟首家的花色或主牌组。\n2. 首家出对子时，有对子就跟对子。\n3. 首家出拖拉机时，有拖拉机就跟拖拉机。\n4. 大主牌留到重要牌墩再用。\n5. 埋底时尽量不要埋主牌和分牌。\n6. 不确定时，先相信提示光点。"],
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
