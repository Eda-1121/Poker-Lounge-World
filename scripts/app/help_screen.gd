# help_screen.gd - ゲーム内遊び方ガイド
extends Control
class_name HelpScreen

signal closed

const HELP = {
	"en": {
		"title": "How to Play - Shengji / Tractor",
		"sections": ["Basics", "Round Flow", "Card Plays", "Following", "Trump", "Scoring"],
		"content": [
			["Basics", "[b]Shengji is a four-player team trick-taking game.[/b]\n\nYou are Player 1. Player 3 is your partner. Players 2 and 4 are the other team.\n\nA trick means each player plays cards once. The strongest legal play wins that trick and leads the next trick.\n\nEach team has a level. Both teams start at 2. A round is played at the dealer side's level. The first team to pass A wins the game.\n\nPoint cards are 5, 10, and K. 5 is worth 5 points. 10 and K are worth 10 points. Other cards are worth 0."],
			["Round Flow", "[b]One round has six steps.[/b]\n\n1. Cards are dealt.\n2. Players may bid to choose trump.\n3. The dealer receives the bottom cards.\n4. The dealer buries the same number of cards.\n5. Players play tricks until all hands are empty.\n6. The attacking side's points decide who is dealer next round and who levels up.\n\nEasy mode uses 2 decks and 8 bottom cards. Hard mode uses 4 decks and 12 bottom cards."],
			["Card Plays", "[b]You may lead with different shapes of cards.[/b]\n\nSingle: one card. Example: 9♦.\n\nPair: two identical cards. Example: 7♠ + 7♠.\n\nTriple: three identical cards. Example: 3♦ + 3♦ + 3♦.\n\nQuadruple: four identical cards. Example: Q♥ + Q♥ + Q♥ + Q♥.\n\nTractor: consecutive identical sets. Example: 6♣+6♣ and 7♣+7♣ is a pair tractor. In Hard mode, triples and quadruples can also form tractors.\n\nThrow: several cards from one suit or trump group played together. A throw only works if no opponent can beat any part of it. If it fails, the game forces the smallest valid part to be played."],
			["Following", "[b]When another player leads, you must follow the same suit or trump group when you can.[/b]\n\nIf the lead is 9♦ and you have diamonds, you must play a diamond. If you have no diamonds, you may play any card.\n\nIf the lead is 7♠+7♠ and you have a spade pair, you must play a pair. If you have only one spade, play that one spade and any other card.\n\nIf the lead is 3♦+3♦+3♦ and you have a diamond pair but not three diamonds, you must play the pair and add one card.\n\nIf the lead is Q♥+Q♥+Q♥+Q♥ and you have four hearts, you must preserve the strongest structure you can: four identical cards first, then triple, then as many pairs as possible. If you have fewer than four hearts, play all hearts you can and fill the rest freely.\n\nThe hint dots mark recommended cards when you are unsure."],
			["Trump", "[b]Trump beats normal suits.[/b]\n\nTrump includes jokers, all current-level cards, and the declared trump suit.\n\nExample: if the level is 2 and hearts are trump, all 2s are trump, all hearts are trump, and both jokers are trump.\n\nA joker bid creates No Trump. No-trump bid cards must use the same joker type. Two Big Jokers can bid No Trump, and two Small Jokers can bid No Trump, but one Big Joker plus one Small Joker cannot make a two-card No Trump bid.\n\nBidding chooses trump only. The bidder does not become dealer."],
			["Scoring", "[b]The dealer side tries to keep attackers under 80 points.[/b]\n\nThe attacking side is the team opposite the dealer side.\n\nIf attackers get 80 or more points, they become the dealer side next round. 80-119 changes dealer only. 120-159 gives attackers +1 level, 160-199 gives +2, and 200+ gives +3.\n\nIf attackers stay below 80, the dealer side holds. The dealer seat passes to the dealer's partner next round. 40-79 gives dealer side +1 level, 1-39 gives +2, and 0 gives +3.\n\nThe last trick may capture bottom-card points. Bottom points are multiplied: single or throw x2, pair/triple/quad x4, tractor length 2 x8, then doubles for each extra link."],
		],
	},
	"ja": {
		"title": "遊び方 - シェンジー / トラクター",
		"sections": ["基本", "流れ", "出し方", "跟牌", "切り札", "点数"],
		"content": [
			["基本", "[b]シェンジーは、4人2チームのトリックテイキングゲームです。[/b]\n\nあなたは Player 1 です。Player 3 が味方、Player 2 と Player 4 が相手です。\n\n1回ずつカードを出すまとまりをトリックと呼びます。そのトリックで一番強い合法な出し方をした人が勝ち、次のトリックを最初に出します。\n\n各チームにはレベルがあります。最初は両チームとも2です。1ラウンドは親側チームのレベルで行います。2からAへ進み、Aを超えたチームが勝ちです。\n\n点数札は 5、10、K です。5は5点、10とKは10点です。それ以外は0点です。"],
			["流れ", "[b]1ラウンドは6つの手順で進みます。[/b]\n\n1. カードが配られます。\n2. 切り札を決めるために叫主します。\n3. 親が底札を受け取ります。\n4. 親は同じ枚数のカードを埋めます。\n5. 全員の手札がなくなるまでトリックを行います。\n6. 攻撃側の点数で、次の親とレベルアップを決めます。\n\nEasyは2デックで底札8枚、Hardは4デックで底札12枚です。"],
			["出し方", "[b]自分が最初に出すときは、いくつかの形を選べます。[/b]\n\n単牌: 1枚。例: 9♦。\n\nペア: 完全に同じカード2枚。例: 7♠ + 7♠。\n\n三張: 完全に同じカード3枚。例: 3♦ + 3♦ + 3♦。\n\n四張: 完全に同じカード4枚。例: Q♥ + Q♥ + Q♥ + Q♥。\n\nトラクター: 連続した同じ組。例: 6♣+6♣ と 7♣+7♣ はペアのトラクターです。Hardでは三張や四張のトラクターも使えます。\n\n甩牌: 同じスート、または切り札グループのカードをまとめて出す形です。相手がどの部分も上回れない場合だけ成功します。失敗した場合は、出せる一番小さい部分だけが強制的に出されます。"],
			["跟牌", "[b]誰かが先に出したら、出されたスートまたは切り札グループにできるだけ従います。[/b]\n\n先出しが 9♦ で、自分が♦を持っているなら、♦を出す必要があります。♦が1枚もなければ、何を出しても構いません。\n\n先出しが 7♠+7♠ で、自分が♠のペアを持っているなら、ペアで返す必要があります。♠が1枚しかないなら、その♠1枚と他のカード1枚を出します。\n\n先出しが 3♦+3♦+3♦ で、自分が♦の三張はないが♦のペアを持っているなら、そのペアを出して、あと1枚を足します。\n\n先出しが Q♥+Q♥+Q♥+Q♥ で、自分が♥を4枚以上持っているなら、作れる一番強い形を守ります。四張、三張、できるだけ多くのペア、の順です。♥が4枚未満なら、持っている♥をすべて出し、残りは自由に補えます。\n\n迷ったときは、光点のヒントが付いているカードを選んでください。"],
			["切り札", "[b]切り札は普通のスートより強いカードです。[/b]\n\n切り札には、ジョーカー、現在レベルのカード、宣言された切り札スートが含まれます。\n\n例: レベルが2で、♥が切り札なら、すべての2、すべての♥、そして両方のジョーカーが切り札です。\n\nジョーカーで叫主するとノートランプになります。ノートランプの叫主は同じ種類のジョーカーだけで数えます。Big Joker 2枚、または Small Joker 2枚なら2枚叫主になりますが、Big Joker 1枚 + Small Joker 1枚は2枚叫主にはできません。\n\n叫主は切り札を決めるだけです。叫主した人が親になるわけではありません。"],
			["点数", "[b]親側は攻撃側を80点未満に抑えることを目指します。[/b]\n\n攻撃側は、親側ではないチームです。\n\n攻撃側が80点以上取ると、次のラウンドで親側になります。80-119点は親交代のみ、120-159点は攻撃側+1、160-199点は+2、200点以上は+3です。\n\n攻撃側を80点未満に抑えると、親側が防衛成功です。次の親は現在の親の味方に移ります。40-79点なら親側+1、1-39点なら+2、0点なら+3です。\n\n最後のトリックでは底札点に倍率がかかることがあります。単牌または甩牌はx2、ペア/三張/四張はx4、長さ2のトラクターはx8、以降は1段ごとに倍になります。"],
		],
	},
	"zh": {
		"title": "玩法 - 升级 / 拖拉机",
		"sections": ["基础", "流程", "牌型", "跟牌", "主牌", "计分"],
		"content": [
			["基础", "[b]升级是四人两队的吃墩游戏。[/b]\n\n你是玩家1，玩家3是你的队友，玩家2和玩家4是对手。\n\n每人出一次牌叫做一墩。一墩里，合法牌型中最大的玩家赢下这一墩，并由他下一墩先出。\n\n每队都有等级，最初都从2开始。每局按庄家队当前等级进行。队伍从2升到A，先超过A的一方获胜。\n\n分牌是5、10、K。5是5分，10和K是10分，其他牌0分。"],
			["流程", "[b]一局按六步进行。[/b]\n\n1. 发牌。\n2. 叫主，决定本局主牌。\n3. 庄家拿底牌。\n4. 庄家埋回同样张数的牌。\n5. 轮流出牌，直到所有手牌出完。\n6. 按闲家队得分，决定下一局谁坐庄、谁升级。\n\n简单模式使用2副牌，底牌8张。困难模式使用4副牌，底牌12张。"],
			["牌型", "[b]你先出时，可以选择不同牌型。[/b]\n\n单张：一张牌。例：9♦。\n\n对子：两张完全相同的牌。例：7♠ + 7♠。\n\n三张：三张完全相同的牌。例：3♦ + 3♦ + 3♦。\n\n四张：四张完全相同的牌。例：Q♥ + Q♥ + Q♥ + Q♥。\n\n拖拉机：连续的相同组合。例：6♣+6♣ 和 7♣+7♣ 是对子拖拉机。困难模式中，三张和四张也可以组成拖拉机。\n\n甩牌：把同一花色，或同一主牌组的多张牌一起甩出。只有别人不能压住其中任何一部分时才成功。甩牌失败时，系统会强制打出能出的最小结构。"],
			["跟牌", "[b]别人先出后，你要尽量跟同花色或同主牌组。[/b]\n\n首家出 9♦，如果你有♦，必须出♦。如果你没有♦，可以任意出牌。\n\n首家出 7♠+7♠，如果你有♠对子，必须跟对子。如果你只有一张♠，就出这一张♠，再补一张任意牌。\n\n首家出 3♦+3♦+3♦，如果你没有♦三张，但有♦对子，必须出这个对子，再补一张。\n\n首家出 Q♥+Q♥+Q♥+Q♥，如果你有4张以上♥，要尽量保留牌型结构：先跟四张，再跟三张，再尽量把对子都跟出。如果你不足4张♥，就把能跟的♥都出掉，剩下随便补。\n\n不知道怎么选时，先看提示光点。"],
			["主牌", "[b]主牌比普通花色更强。[/b]\n\n主牌包括大小王、当前等级牌、以及叫出的主花色。\n\n例：当前等级是2，主花色是♥，那么所有2、所有♥、大小王都是主牌。\n\n用王叫主时为无主。无主叫牌只计算同一种王：两张大王可以叫两张无主，两张小王也可以叫两张无主，但一张大王加一张小王不能算两张无主。\n\n叫主只决定主牌，不会让叫主的人变成庄家。"],
			["计分", "[b]庄家队目标是把闲家压到80分以下。[/b]\n\n闲家队是庄家队以外的一方。\n\n闲家拿到80分以上，下一局上台坐庄。80-119分只换庄不升级，120-159分闲家+1级，160-199分+2级，200分以上+3级。\n\n闲家低于80分，庄家保庄成功。下一局由当前庄家的队友坐庄。40-79分庄家+1级，1-39分+2级，0分+3级。\n\n最后一墩可能抠底，底牌分会按倍率加入。单张或甩牌x2，对子/三张/四张x4，长度2的拖拉机x8，之后每多一节翻倍。"],
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
