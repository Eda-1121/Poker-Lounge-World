# settings_screen.gd - 設定オーバーレイ
extends Control
class_name SettingsScreen

signal closed

var _sound_btn_on: Button
var _sound_btn_off: Button
var _hint_btn_on: Button
var _hint_btn_off: Button
var _title_label: Label
var _sound_label: Label
var _hint_label: Label
var _language_label: Label
var _lang_btn_ja: Button
var _lang_btn_en: Button
var _lang_btn_zh: Button
var _close_btn: Button

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()

func _build_ui():
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.70)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var vp = get_viewport_rect().size
	var panel = Panel.new()
	panel.position = Vector2(int((vp.x - 500) / 2), int((vp.y - 450) / 2))
	panel.size = Vector2(500, 450)

	var ps = StyleBoxFlat.new()
	ps.bg_color = Color(0.051, 0.106, 0.165)
	ps.border_color = Color(0.941, 0.788, 0.416, 0.45)
	ps.set_border_width_all(1)
	ps.set_corner_radius_all(12)
	panel.add_theme_stylebox_override("panel", ps)
	add_child(panel)

	_title_label = Label.new()
	_title_label.position = Vector2(0, 16)
	_title_label.size = Vector2(500, 48)
	_title_label.add_theme_font_size_override("font_size", 34)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.38))
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(_title_label)

	_add_separator(panel, 70)

	_sound_label = _add_row_label(panel, "", 84)
	_sound_btn_on  = _make_button("ON",  Vector2(100, 118))
	_sound_btn_off = _make_button("OFF", Vector2(260, 118))
	_sound_btn_on.pressed.connect(_on_sound_on)
	_sound_btn_off.pressed.connect(_on_sound_off)
	panel.add_child(_sound_btn_on)
	panel.add_child(_sound_btn_off)

	_add_separator(panel, 178)

	_hint_label = _add_row_label(panel, "", 192)
	_hint_btn_on  = _make_button("ON",  Vector2(100, 226))
	_hint_btn_off = _make_button("OFF", Vector2(260, 226))
	_hint_btn_on.pressed.connect(_on_hint_on)
	_hint_btn_off.pressed.connect(_on_hint_off)
	panel.add_child(_hint_btn_on)
	panel.add_child(_hint_btn_off)

	_add_separator(panel, 286)

	_language_label = _add_row_label(panel, "", 300)
	_lang_btn_en = _make_button("", Vector2(50, 334))
	_lang_btn_ja = _make_button("", Vector2(190, 334))
	_lang_btn_zh = _make_button("", Vector2(330, 334))
	_lang_btn_ja.pressed.connect(_on_lang_ja)
	_lang_btn_en.pressed.connect(_on_lang_en)
	_lang_btn_zh.pressed.connect(_on_lang_zh)
	panel.add_child(_lang_btn_en)
	panel.add_child(_lang_btn_ja)
	panel.add_child(_lang_btn_zh)

	_add_separator(panel, 390)

	_close_btn = _make_button("", Vector2(170, 398))
	_close_btn.size = Vector2(160, 40)
	_close_btn.pressed.connect(_on_close)
	panel.add_child(_close_btn)

	_update_texts()
	_update_sound_buttons()
	_update_hint_buttons()
	_update_lang_buttons()

func _add_separator(parent: Control, y: int):
	var sep = ColorRect.new()
	sep.position = Vector2(50, y)
	sep.size = Vector2(400, 1)
	sep.color = Color(0.941, 0.788, 0.416, 0.25)
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(sep)

func _add_row_label(parent: Control, text: String, y: int):
	var lbl = Label.new()
	lbl.text = text
	lbl.position = Vector2(50, y)
	lbl.size = Vector2(400, 30)
	lbl.add_theme_font_size_override("font_size", 20)
	lbl.add_theme_color_override("font_color", Color(0.75, 0.87, 1.00))
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(lbl)
	return lbl

func _make_button(text: String, pos: Vector2) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.position = pos
	btn.size = Vector2(120, 48)
	btn.add_theme_font_size_override("font_size", 18)
	return btn

func _set_button_active(btn: Button, active: bool):
	var acc = Color(0.941, 0.788, 0.416)
	var mk = func(bg: Color, border_a: float) -> StyleBoxFlat:
		var s = StyleBoxFlat.new()
		s.bg_color = bg
		s.border_color = Color(acc.r, acc.g, acc.b, border_a)
		s.set_border_width_all(1)
		s.set_corner_radius_all(8)
		s.content_margin_left  = 8
		s.content_margin_right = 8
		return s

	if active:
		btn.add_theme_stylebox_override("normal",  mk.call(acc, 1.0))
		btn.add_theme_stylebox_override("hover",   mk.call(acc.lightened(0.15), 1.0))
		btn.add_theme_stylebox_override("pressed", mk.call(acc.darkened(0.12), 1.0))
		btn.add_theme_color_override("font_color", Color(0.08, 0.06, 0.02))
	else:
		btn.add_theme_stylebox_override("normal",  mk.call(Color(0.06, 0.10, 0.16), 0.35))
		btn.add_theme_stylebox_override("hover",   mk.call(Color(0.09, 0.14, 0.22), 0.50))
		btn.add_theme_stylebox_override("pressed", mk.call(Color(0.04, 0.07, 0.11), 0.25))
		btn.add_theme_color_override("font_color", Color(0.941, 0.788, 0.416, 0.70))

func _update_sound_buttons():
	_set_button_active(_sound_btn_on,  GameConfig.sound_enabled)
	_set_button_active(_sound_btn_off, not GameConfig.sound_enabled)

func _update_hint_buttons():
	_set_button_active(_hint_btn_on,  GameConfig.play_hints_enabled)
	_set_button_active(_hint_btn_off, not GameConfig.play_hints_enabled)

func _update_lang_buttons():
	_set_button_active(_lang_btn_en, GameConfig.language == "en")
	_set_button_active(_lang_btn_ja, GameConfig.language == "ja")
	_set_button_active(_lang_btn_zh, GameConfig.language == "zh")

func _update_texts():
	_title_label.text = GameConfig.text("settings")
	_sound_label.text = GameConfig.text("sound")
	_hint_label.text = GameConfig.text("hints")
	_language_label.text = GameConfig.text("language")
	_lang_btn_en.text = GameConfig.text("english")
	_lang_btn_ja.text = GameConfig.text("japanese")
	_lang_btn_zh.text = GameConfig.text("chinese")
	_close_btn.text = GameConfig.text("close")

func _on_lang_ja():
	SoundManager.play_card_click()
	GameConfig.set_language("ja")
	_update_texts()
	_update_lang_buttons()

func _on_lang_en():
	SoundManager.play_card_click()
	GameConfig.set_language("en")
	_update_texts()
	_update_lang_buttons()

func _on_lang_zh():
	SoundManager.play_card_click()
	GameConfig.set_language("zh")
	_update_texts()
	_update_lang_buttons()

func _on_sound_on():
	GameConfig.sound_enabled = true
	SoundManager.play_card_click()
	_update_sound_buttons()

func _on_sound_off():
	GameConfig.sound_enabled = false
	_update_sound_buttons()

func _on_hint_on():
	SoundManager.play_card_click()
	GameConfig.set_play_hints_enabled(true)
	_update_hint_buttons()

func _on_hint_off():
	SoundManager.play_card_click()
	GameConfig.set_play_hints_enabled(false)
	_update_hint_buttons()

func _on_close():
	SoundManager.play_card_click()
	closed.emit()
	queue_free()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_on_close()
