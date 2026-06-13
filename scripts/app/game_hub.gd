# game_hub.gd - Pixel card lounge game selection hub
extends Control

const HelpScreenScene = preload("res://scripts/app/help_screen.gd")
const SettingsScreenScene = preload("res://scripts/app/settings_screen.gd")

const LOBBY_ASSET_DIR = "res://assets/ui/lobby/"
const TEX_FELT = LOBBY_ASSET_DIR + "felt_background_clean.png"
const TEX_STACK_LEFT = LOBBY_ASSET_DIR + "corner_card_stack_left.png"
const TEX_STACK_RIGHT = LOBBY_ASSET_DIR + "corner_card_stack_right.png"
const TEX_COIN_SPADE = LOBBY_ASSET_DIR + "coin_spade.png"
const TEX_COIN_CLUB = LOBBY_ASSET_DIR + "coin_club.png"
const TEX_SPARKLE = LOBBY_ASSET_DIR + "sparkle.png"
const TEX_DIVIDER = LOBBY_ASSET_DIR + "ornament_divider.png"
const TEX_SHADOW_SPADE = LOBBY_ASSET_DIR + "suit_shadow_spade.png"
const TEX_SHADOW_HEART = LOBBY_ASSET_DIR + "suit_shadow_heart.png"
const TEX_SHADOW_CLUB = LOBBY_ASSET_DIR + "suit_shadow_club.png"
const TEX_SHADOW_DIAMOND = LOBBY_ASSET_DIR + "suit_shadow_diamond.png"
const TEX_CORNER_TL = LOBBY_ASSET_DIR + "corner_ornament_tl.png"
const TEX_CORNER_TR = LOBBY_ASSET_DIR + "corner_ornament_tr.png"
const TEX_CORNER_BL = LOBBY_ASSET_DIR + "corner_ornament_bl.png"
const TEX_CORNER_BR = LOBBY_ASSET_DIR + "corner_ornament_br.png"

const C_FELT = Color(0.027, 0.114, 0.090)
const C_FELT_DARK = Color(0.012, 0.045, 0.036)
const C_PANEL_GREEN = Color(0.055, 0.200, 0.153)
const C_PANEL_GREEN_LIGHT = Color(0.086, 0.290, 0.220)
const C_GOLD = Color(0.945, 0.768, 0.353)
const C_GOLD_DARK = Color(0.610, 0.416, 0.145)
const C_PAPER = Color(0.945, 0.905, 0.796)
const C_PAPER_DARK = Color(0.720, 0.660, 0.510)
const C_INK = Color(0.165, 0.141, 0.098)
const C_MUTED = Color(0.720, 0.705, 0.650)
const C_RED = Color(0.713, 0.290, 0.208)
const C_BLUE = Color(0.129, 0.267, 0.353)

const DISPLAY_FONT_CANDIDATES = [
	"/System/Library/Fonts/Supplemental/Songti.ttc",
	"/System/Library/Fonts/Hiragino Sans GB.ttc",
	"/System/Library/Fonts/STHeiti Medium.ttc",
]
const UI_FONT_CANDIDATES = [
	"/System/Library/Fonts/Hiragino Sans GB.ttc",
	"/System/Library/Fonts/STHeiti Medium.ttc",
	"/System/Library/Fonts/Supplemental/AppleGothic.ttf",
]
const PIXEL_FONT_BY_LANGUAGE = {
	"en": "res://resources/fonts/fusion-pixel-12px-proportional-latin.ttf",
	"ja": "res://resources/fonts/fusion-pixel-12px-proportional-ja.ttf",
	"zh": "res://resources/fonts/fusion-pixel-12px-proportional-zh_hans.ttf",
}

const GAMES = [
	{
		"name_key": "game_shengji_name",
		"sub_key": "game_shengji_sub",
		"desc_key": "game_shengji_desc",
		"icons": [TEX_SHADOW_SPADE, TEX_SHADOW_HEART],
		"scene": "res://scenes/shengji/main.tscn",
		"available": true,
		"has_help": true,
		"deck_options": [2, 4],
		"preview": ["spade_09", "club_10", "heart_11", "big_joker"],
		"accent": C_GOLD,
	},
	{
		"name_key": "game_hearts_name",
		"sub_key": "game_hearts_sub",
		"desc_key": "game_hearts_desc",
		"icons": [TEX_SHADOW_HEART],
		"scene": "",
		"available": false,
		"preview": ["heart_12", "heart_03", "heart_08", "heart_11", "big_joker"],
		"accent": C_RED,
	},
	{
		"name_key": "game_bridge_name",
		"sub_key": "game_bridge_sub",
		"desc_key": "game_bridge_desc",
		"icons": [TEX_SHADOW_CLUB],
		"scene": "",
		"available": false,
		"preview": ["spade_14", "heart_13", "diamond_12", "club_11", "big_joker"],
		"accent": Color(0.090, 0.180, 0.220),
	},
	{
		"name_key": "game_poker_name",
		"sub_key": "game_poker_sub",
		"desc_key": "game_poker_desc",
		"icons": [TEX_SHADOW_DIAMOND],
		"scene": "",
		"available": false,
		"preview": ["diamond_14", "club_13", "heart_12", "club_11", "big_joker"],
		"accent": C_RED,
	},
]

var _sw: float
var _sh: float
var _content_w: float
var _card_y: float
var _card_gap: float
var _selected_w: float
var _normal_w: float
var _selected_h: float
var _normal_h: float
var _display_font: Font
var _ui_font: Font

func _ready():
	_load_lobby_fonts()
	if not is_web_build():
		var window_size = get_target_window_size()
		get_window().size = window_size
		get_window().min_size = Vector2i(1280, 720)
		center_window(window_size)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not GameConfig.language_changed.is_connected(_on_language_changed):
		GameConfig.language_changed.connect(_on_language_changed)
	if not get_viewport().size_changed.is_connected(_build):
		get_viewport().size_changed.connect(_build)
	_build()

func _build():
	for child in get_children():
		child.queue_free()

	var vp = get_viewport_rect().size
	_sw = vp.x
	_sh = vp.y
	var content_ratio = 0.94 if _sw < 1280.0 else 0.84
	_content_w = clamp(_sw * content_ratio, min(760.0, _sw * 0.96), 1360.0)
	_card_gap = clamp(_sw * 0.014, 14.0, 40.0)
	_selected_w = clamp(_content_w * 0.24, 210.0, 320.0)
	_normal_w = clamp((_content_w - _selected_w - _card_gap * 3.0) / 3.0, 170.0, 300.0)
	_selected_h = clamp(_sh * 0.50, 320.0, 500.0)
	_normal_h = clamp(_selected_h * 0.89, 286.0, 440.0)
	_card_y = clamp(_sh * 0.255, 140.0, 228.0)

	_build_background()
	_build_decorations()
	_build_header()
	_build_stats()
	_build_game_cards()
	_build_card_style_selector()
	_build_footer()

func _build_background():
	var bg_texture = _create_texture_rect(TEX_FELT, Vector2.ZERO, Vector2(_sw, _sh), TextureRect.STRETCH_SCALE)
	bg_texture.modulate = Color(0.68, 0.88, 0.78, 1.0)
	add_child(bg_texture)

	var vignette = ColorRect.new()
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.color = Color(C_FELT_DARK, 0.48)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)

func _build_decorations():
	_create_corner_stack(Vector2(-22, -22), Vector2(220, 220), TEX_STACK_LEFT, -10.0, 0.58)
	_create_corner_stack(Vector2(_sw - 170, 16), Vector2(190, 190), TEX_STACK_RIGHT, 10.0, 0.54)
	_create_corner_stack(Vector2(_sw - 220, _sh - 178), Vector2(260, 260), TEX_STACK_RIGHT, -16.0, 0.55)
	_create_asset_coin(Vector2(208, 34), TEX_COIN_SPADE, 76.0, 0.88)
	_create_asset_coin(Vector2(_sw - 214, 84), TEX_COIN_CLUB, 78.0, 0.86)
	_create_asset_suit_shadow(Vector2(48, _sh - 138), TEX_SHADOW_SPADE, 118.0, 0.14)
	_create_asset_suit_shadow(Vector2(_sw - 190, _sh - 128), TEX_SHADOW_DIAMOND, 118.0, 0.10)
	_create_asset_suit_shadow(Vector2(_sw - 144, 194), TEX_SHADOW_CLUB, 94.0, 0.10)
	_create_asset_suit_shadow(Vector2(118, 166), TEX_SHADOW_HEART, 86.0, 0.09)
	_create_sparkles()

func _create_corner_stack(pos: Vector2, size: Vector2, texture_path: String, rotation_deg: float, alpha: float):
	var stack = _create_texture_rect(texture_path, pos, size)
	stack.rotation_degrees = rotation_deg
	stack.modulate = Color(1, 1, 1, alpha)
	add_child(stack)

func _create_asset_coin(pos: Vector2, texture_path: String, diameter: float, alpha: float):
	var coin = _create_texture_rect(texture_path, pos, Vector2(diameter, diameter))
	coin.modulate = Color(1, 1, 1, alpha)
	add_child(coin)

func _create_asset_suit_shadow(pos: Vector2, texture_path: String, size: float, alpha: float):
	var shadow = _create_texture_rect(texture_path, pos, Vector2(size, size))
	shadow.modulate = Color(1, 1, 1, alpha)
	add_child(shadow)

func _create_sparkles():
	var points = [
		Vector2(150, 160), Vector2(320, 92), Vector2(_sw - 170, 150),
		Vector2(_sw - 128, 270), Vector2(72, _sh - 138), Vector2(165, _sh - 86),
		Vector2(_sw - 92, _sh - 182), Vector2(_sw * 0.72, _sh - 78),
	]
	for p in points:
		if p.x < 0 or p.x > _sw or p.y < 0 or p.y > _sh:
			continue
		var s = _create_texture_rect(TEX_SPARKLE, p, Vector2(22, 22))
		s.modulate = Color(1, 1, 1, 0.86)
		add_child(s)

func _build_header():
	var title = Label.new()
	title.text = GameConfig.text("app_title")
	title.position = Vector2(0, 24)
	title.size = Vector2(_sw, 58)
	title.add_theme_font_size_override("font_size", 46)
	title.add_theme_color_override("font_color", C_GOLD)
	_apply_display_font(title)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title)

	var sub = Label.new()
	sub.text = GameConfig.text("game_shengji_sub")
	sub.position = Vector2(0, 90)
	sub.size = Vector2(_sw, 30)
	sub.add_theme_font_size_override("font_size", 24)
	sub.add_theme_color_override("font_color", Color(C_MUTED, 0.90))
	_apply_ui_font(sub)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sub)

	var div = _create_texture_rect(TEX_DIVIDER, Vector2((_sw - 340.0) * 0.5, 126), Vector2(340, 28))
	div.modulate = Color(1, 1, 1, 0.72)
	add_child(div)

func _build_stats():
	var total_plays = GameConfig.total_plays
	var wins_count = GameConfig.wins
	var win_rate_str = "-"
	if total_plays > 0:
		win_rate_str = "%d%%" % int(float(wins_count) / float(total_plays) * 100.0)

	var items = [
		[str(total_plays), GameConfig.text("plays")],
		[str(wins_count), GameConfig.text("wins")],
		[win_rate_str, GameConfig.text("win_rate")],
	]
	var item_w = 180.0
	var start_x = (_sw - item_w * 3.0) * 0.5
	var y = 164.0

	for i in range(items.size()):
		var value = Label.new()
		value.text = items[i][0]
		value.position = Vector2(start_x + item_w * i, y)
		value.size = Vector2(item_w, 34)
		value.add_theme_font_size_override("font_size", 28)
		value.add_theme_color_override("font_color", C_GOLD)
		_apply_display_font(value)
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		value.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(value)

		var label = Label.new()
		label.text = items[i][1]
		label.position = Vector2(start_x + item_w * i, y + 36)
		label.size = Vector2(item_w, 28)
		label.add_theme_font_size_override("font_size", 19)
		label.add_theme_color_override("font_color", Color(C_MUTED, 0.92))
		_apply_ui_font(label)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(label)

func _build_game_cards():
	var total = _selected_w + _normal_w * 3.0 + _card_gap * 3.0
	var x = (_sw - total) * 0.5
	for i in range(GAMES.size()):
		var selected = i == 0
		var w = _selected_w if selected else _normal_w
		var h = _selected_h if selected else _normal_h
		var y = _card_y + (0.0 if selected else 20.0)
		_build_game_card(GAMES[i], Vector2(x, y), Vector2(w, h), selected)
		x += w + _card_gap

func _build_game_card(game: Dictionary, pos: Vector2, size: Vector2, selected: bool):
	var panel = Panel.new()
	panel.position = pos
	panel.size = size
	panel.clip_contents = true
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if selected:
		panel.add_theme_stylebox_override("panel", _style_box(C_PANEL_GREEN, C_GOLD, 4, 4))
	else:
		panel.add_theme_stylebox_override("panel", _style_box(C_PAPER, C_PAPER_DARK, 3, 4))
		if not game["available"]:
			panel.modulate = Color(1, 1, 1, 0.84)
	add_child(panel)

	_add_card_corner_ornaments(panel, selected)
	_add_game_card_content(panel, game, size, selected)

func _add_card_corner_ornaments(panel: Panel, selected: bool):
	var ornament_size = Vector2(32, 32) if selected else Vector2(28, 28)
	var offset = Vector2(13, 13) if selected else Vector2(10, 10)
	var alpha = 0.88 if selected else 0.48
	var items = [
		[TEX_CORNER_TL, offset],
		[TEX_CORNER_TR, Vector2(panel.size.x - offset.x - ornament_size.x, offset.y)],
		[TEX_CORNER_BL, Vector2(offset.x, panel.size.y - offset.y - ornament_size.y)],
		[TEX_CORNER_BR, Vector2(panel.size.x - offset.x - ornament_size.x, panel.size.y - offset.y - ornament_size.y)],
	]
	for item in items:
		var rect = _create_texture_rect(item[0], item[1], ornament_size)
		rect.modulate = Color(1, 1, 1, alpha)
		panel.add_child(rect)

func _add_game_card_content(panel: Panel, game: Dictionary, size: Vector2, selected: bool):
	var accent: Color = game["accent"]
	var text_col = C_GOLD if selected else C_INK
	var muted_col = Color(0.88, 0.84, 0.70) if selected else Color(C_INK, 0.86)
	var deck_y = size.y - 150.0 if selected else size.y - 100.0
	var action_y = size.y - 104.0 if selected else size.y - 64.0
	var help_y = size.y - 54.0

	_add_game_icon_row(panel, game.get("icons", []), size.x, selected)

	var title = Label.new()
	title.text = GameConfig.text(game["name_key"])
	title.position = Vector2(18, 60)
	title.size = Vector2(size.x - 36, 58)
	title.add_theme_font_size_override("font_size", _get_card_title_font_size(title.text, selected))
	title.add_theme_color_override("font_color", text_col)
	_apply_display_font(title)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(title)

	var sep = ColorRect.new()
	sep.position = Vector2(52, 122)
	sep.size = Vector2(size.x - 104, 2)
	sep.color = Color(C_GOLD if selected else C_PAPER_DARK, 0.80)
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(sep)

	var preview_y = 158.0 if selected else 142.0
	_add_card_preview(panel, game["preview"], Vector2(size.x * 0.5, preview_y), selected)

	var meta = Label.new()
	meta.text = _first_line(GameConfig.text(game["desc_key"]))
	meta.position = Vector2(24, deck_y - 78.0 if selected else size.y - 132)
	meta.size = Vector2(size.x - 48, 30)
	meta.add_theme_font_size_override("font_size", 19 if selected else 17)
	meta.add_theme_color_override("font_color", muted_col)
	_apply_ui_font(meta)
	meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	meta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(meta)

	var desc = Label.new()
	desc.text = _second_line(GameConfig.text(game["desc_key"]))
	desc.position = Vector2(26, deck_y - 48.0 if selected else size.y - 104)
	desc.size = Vector2(size.x - 52, 44)
	desc.add_theme_font_size_override("font_size", 17 if selected else 15)
	desc.add_theme_color_override("font_color", muted_col)
	_apply_ui_font(desc)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(desc)

	if game["available"]:
		_add_deck_selector(panel, game, Vector2((size.x - 186.0) * 0.5, deck_y))
		_add_primary_game_button(panel, GameConfig.text("play_game"), Vector2(44, action_y), Vector2(size.x - 88, 40), game["scene"])
		if game.get("has_help", false):
			_add_help_button(panel, Vector2(70, help_y), Vector2(size.x - 140, 22))
	else:
		_add_disabled_button(panel, Vector2((size.x - 132) * 0.5, size.y - 64), Vector2(132, 36))

func _add_card_preview(parent: Control, card_names: Array, center: Vector2, selected: bool):
	var card_w = 50.0 if selected else 44.0
	var card_h = 70.0 if selected else 62.0
	var overlap = 29.0 if selected else 25.0
	var start_x = center.x - ((card_names.size() - 1) * overlap + card_w) * 0.5

	for i in range(card_names.size()):
		var rect = TextureRect.new()
		rect.position = Vector2(start_x + i * overlap, center.y + abs(i - card_names.size() / 2.0) * 3.0)
		rect.size = Vector2(card_w, card_h)
		rect.rotation_degrees = (float(i) - float(card_names.size() - 1) * 0.5) * 5.0
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var tex = load(GameConfig.get_card_asset_path(card_names[i]))
		if tex:
			rect.texture = tex
		parent.add_child(rect)

func _add_game_icon_row(parent: Control, icon_paths: Array, width: float, selected: bool):
	if icon_paths.is_empty():
		return
	var icon_size = 28.0 if selected else 24.0
	var gap = 8.0
	var total_w = icon_paths.size() * icon_size + max(0, icon_paths.size() - 1) * gap
	var row = HBoxContainer.new()
	row.position = Vector2((width - total_w) * 0.5, 24)
	row.size = Vector2(total_w, icon_size)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", int(gap))
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(row)

	for path in icon_paths:
		var icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(icon_size, icon_size)
		icon.size = Vector2(icon_size, icon_size)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = _load_png_texture_for_size(path, Vector2i(icon_size, icon_size))
		icon.modulate = Color(1, 1, 1, 0.96)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(icon)

func _add_deck_selector(parent: Control, game: Dictionary, pos: Vector2):
	var opts: Array = game["deck_options"]
	var buttons: Array[Button] = []
	var x = pos.x
	for opt in opts:
		var btn = Button.new()
		btn.text = "x%d" % opt
		btn.position = Vector2(x, pos.y)
		btn.size = Vector2(78, 28)
		btn.add_theme_font_size_override("font_size", 18)
		_apply_button_font(btn)
		parent.add_child(btn)
		buttons.append(btn)
		x += 108

	var refresh = func():
		for i in range(buttons.size()):
			var active = GameConfig.num_decks == opts[i]
			buttons[i].add_theme_stylebox_override("normal", _button_style(C_GOLD if active else C_PANEL_GREEN_LIGHT, C_GOLD, active))
			buttons[i].add_theme_stylebox_override("hover", _button_style(Color(C_GOLD, 0.90), C_GOLD, true))
			buttons[i].add_theme_color_override("font_color", C_INK if active else Color(C_GOLD, 0.72))

	for i in range(buttons.size()):
		var deck_value = opts[i]
		buttons[i].pressed.connect(func():
			SoundManager.play_card_click()
			GameConfig.num_decks = deck_value
			refresh.call()
		)
	refresh.call()

func _add_primary_game_button(parent: Control, text: String, pos: Vector2, size: Vector2, scene_path: String):
	var btn = Button.new()
	btn.text = "%s" % text
	btn.position = pos
	btn.size = size
	btn.add_theme_font_size_override("font_size", 24)
	btn.add_theme_color_override("font_color", C_INK)
	_apply_button_font(btn)
	btn.add_theme_stylebox_override("normal", _button_style(C_GOLD, C_GOLD_DARK, true))
	btn.add_theme_stylebox_override("hover", _button_style(C_GOLD.lightened(0.10), C_GOLD_DARK, true))
	btn.add_theme_stylebox_override("pressed", _button_style(C_GOLD.darkened(0.12), C_GOLD_DARK, true))
	btn.pressed.connect(func(): _on_play_pressed(scene_path))
	parent.add_child(btn)

func _add_help_button(parent: Control, pos: Vector2, size: Vector2):
	var btn = Button.new()
	btn.text = "%s" % GameConfig.text("how_to_play")
	btn.position = pos
	btn.size = size
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", Color(C_PAPER, 0.92))
	_apply_button_font(btn)
	btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	btn.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	btn.pressed.connect(_on_help_pressed)
	parent.add_child(btn)

func _add_disabled_button(parent: Control, pos: Vector2, size: Vector2):
	var btn = Button.new()
	btn.text = GameConfig.text("coming_soon")
	btn.position = pos
	btn.size = size
	btn.disabled = true
	btn.add_theme_font_size_override("font_size", 17)
	btn.add_theme_color_override("font_disabled_color", Color(C_INK, 0.55))
	_apply_button_font(btn)
	btn.add_theme_stylebox_override("disabled", _button_style(Color(C_PAPER_DARK, 0.20), Color(C_INK, 0.36), false))
	parent.add_child(btn)

func _build_card_style_selector():
	var style_ids = GameConfig.get_card_style_ids()
	if style_ids.is_empty():
		return
	if not style_ids.has(GameConfig.card_style):
		GameConfig.set_card_style("default")

	var btn_w = 150.0
	var btn_h = 42.0
	var label_w = 158.0
	var gap = 10.0
	var total_w = label_w + style_ids.size() * btn_w + style_ids.size() * gap
	var x = (_sw - total_w) * 0.5
	var y = min(_sh - 136.0, _card_y + _selected_h + 16.0)

	var label = Label.new()
	label.text = GameConfig.text("card_design")
	label.position = Vector2(x, y + 7)
	label.size = Vector2(label_w, btn_h)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", C_GOLD)
	_apply_ui_font(label)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)

	var style_divider = _create_texture_rect(TEX_DIVIDER, Vector2(x - 68, y + 6), Vector2(58, 30))
	style_divider.modulate = Color(1, 1, 1, 0.72)
	add_child(style_divider)

	x += label_w + gap
	for style_id in style_ids:
		var style_to_set = String(style_id)
		var btn = Button.new()
		btn.text = GameConfig.get_card_style_name(style_to_set)
		btn.position = Vector2(x, y)
		btn.size = Vector2(btn_w, btn_h)
		btn.add_theme_font_size_override("font_size", 20)
		_apply_button_font(btn)
		_style_card_style_button(btn, style_to_set == GameConfig.card_style)
		btn.pressed.connect(func():
			SoundManager.play_card_click()
			GameConfig.set_card_style(style_to_set)
			_build()
		)
		add_child(btn)
		x += btn_w + gap

func _style_card_style_button(btn: Button, active: bool):
	if active:
		btn.add_theme_stylebox_override("normal", _button_style(C_GOLD, C_GOLD_DARK, true))
		btn.add_theme_stylebox_override("hover", _button_style(C_GOLD.lightened(0.10), C_GOLD_DARK, true))
		btn.add_theme_stylebox_override("pressed", _button_style(C_GOLD.darkened(0.12), C_GOLD_DARK, true))
		btn.add_theme_color_override("font_color", C_INK)
	else:
		btn.add_theme_stylebox_override("normal", _button_style(Color(C_FELT_DARK, 0.92), Color(C_GOLD, 0.32), false))
		btn.add_theme_stylebox_override("hover", _button_style(Color(C_PANEL_GREEN_LIGHT, 0.82), Color(C_GOLD, 0.54), false))
		btn.add_theme_stylebox_override("pressed", _button_style(Color(C_FELT_DARK, 1.0), Color(C_GOLD, 0.62), false))
		btn.add_theme_color_override("font_color", Color(C_GOLD, 0.74))

func _build_footer():
	var btn_w = 280.0
	var btn_h = 54.0
	var gap = 30.0
	var x = (_sw - btn_w * 2.0 - gap) * 0.5
	var y = _sh - 70.0
	_add_footer_button("%s" % GameConfig.text("settings"), Vector2(x, y), Vector2(btn_w, btn_h), C_BLUE, _on_settings_pressed)
	_add_footer_button("%s" % GameConfig.text("quit"), Vector2(x + btn_w + gap, y), Vector2(btn_w, btn_h), C_RED, _on_quit_pressed)

func _add_footer_button(text: String, pos: Vector2, size: Vector2, accent: Color, callback: Callable):
	var btn = Button.new()
	btn.text = text
	btn.position = pos
	btn.size = size
	btn.add_theme_font_size_override("font_size", 24)
	btn.add_theme_color_override("font_color", C_PAPER)
	_apply_button_font(btn)
	btn.add_theme_stylebox_override("normal", _button_style(accent, accent.darkened(0.45), true))
	btn.add_theme_stylebox_override("hover", _button_style(accent.lightened(0.10), accent.darkened(0.40), true))
	btn.add_theme_stylebox_override("pressed", _button_style(accent.darkened(0.12), accent.darkened(0.55), true))
	btn.pressed.connect(callback)
	add_child(btn)

func _style_box(bg: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0, 0, 0, 0.38)
	style.shadow_size = 10
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _button_style(bg: Color, border: Color, strong: bool) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(2 if strong else 1)
	style.set_corner_radius_all(2)
	style.shadow_color = Color(0, 0, 0, 0.42)
	style.shadow_size = 5 if strong else 2
	style.content_margin_left = 10
	style.content_margin_right = 10
	return style

func _get_card_title_font_size(text: String, selected: bool) -> int:
	var base = 24 if selected else 21
	if GameConfig.language == "ja":
		base -= 2
	if text.length() >= 9:
		base -= 2
	if text.length() >= 12:
		base -= 2
	return max(16, base)

func _load_lobby_fonts():
	var pixel_font = _load_project_font(PIXEL_FONT_BY_LANGUAGE.get(GameConfig.language, PIXEL_FONT_BY_LANGUAGE["en"]))
	_display_font = pixel_font if pixel_font else _load_first_font(DISPLAY_FONT_CANDIDATES)
	_ui_font = pixel_font if pixel_font else _load_first_font(UI_FONT_CANDIDATES)

func _load_first_font(paths: Array) -> Font:
	for path in paths:
		if not FileAccess.file_exists(path):
			continue
		var font = FontFile.new()
		var err = font.load_dynamic_font(path)
		if err == OK:
			return font
	return null

func _load_project_font(path: String) -> Font:
	if not FileAccess.file_exists(ProjectSettings.globalize_path(path)):
		return null
	var font = FontFile.new()
	var err = font.load_dynamic_font(ProjectSettings.globalize_path(path))
	return font if err == OK else null

func _apply_display_font(control: Control):
	if _display_font:
		control.add_theme_font_override("font", _display_font)
		control.add_theme_constant_override("outline_size", 1)
		control.add_theme_color_override("font_outline_color", Color(0.18, 0.11, 0.02, 0.62))

func _apply_ui_font(control: Control):
	if _ui_font:
		control.add_theme_font_override("font", _ui_font)

func _apply_button_font(button: Button):
	_apply_ui_font(button)
	button.add_theme_constant_override("outline_size", 0)

func _create_texture_rect(texture_path: String, pos: Vector2, size: Vector2, stretch_mode: TextureRect.StretchMode = TextureRect.STRETCH_SCALE) -> TextureRect:
	var rect = TextureRect.new()
	rect.texture = _load_png_texture_for_size(texture_path, Vector2i(max(1, int(size.x)), max(1, int(size.y))))
	rect.position = pos
	rect.size = size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = stretch_mode
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

func _load_png_texture_for_size(texture_path: String, target_size: Vector2i) -> Texture2D:
	var image = Image.new()
	var err = image.load(ProjectSettings.globalize_path(texture_path))
	if err != OK:
		push_warning("Unable to load lobby texture: %s" % texture_path)
		return null
	if target_size.x > 0 and target_size.y > 0 and image.get_size() != target_size:
		image.resize(target_size.x, target_size.y, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(image)

func _first_line(text: String) -> String:
	var parts = text.split("\n", false)
	return parts[0] if parts.size() > 0 else text

func _second_line(text: String) -> String:
	var parts = text.split("\n", false)
	return parts[1] if parts.size() > 1 else ""

func _on_play_pressed(scene_path: String):
	SoundManager.play_card_click()
	get_tree().change_scene_to_file(scene_path)

func _on_help_pressed():
	SoundManager.play_card_click()
	var help = HelpScreenScene.new()
	add_child(help)

func _on_settings_pressed():
	SoundManager.play_card_click()
	var settings = SettingsScreenScene.new()
	settings.closed.connect(_build)
	add_child(settings)

func _on_language_changed(_language: String):
	if get_children().any(func(child): return child is SettingsScreen):
		return
	_load_lobby_fonts()
	_build()

func _on_quit_pressed():
	SoundManager.play_card_click()
	get_tree().quit()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()

func get_target_window_size() -> Vector2i:
	var screen = DisplayServer.window_get_current_screen()
	var usable_rect = DisplayServer.screen_get_usable_rect(screen)
	return Vector2i(
		max(1280, int(float(usable_rect.size.x) * 0.8)),
		max(720, int(float(usable_rect.size.y) * 0.8))
	)

func center_window(window_size: Vector2i):
	var screen = DisplayServer.window_get_current_screen()
	var usable_rect = DisplayServer.screen_get_usable_rect(screen)
	get_window().position = usable_rect.position + (usable_rect.size - window_size) / 2

func is_web_build() -> bool:
	return OS.has_feature("web")
