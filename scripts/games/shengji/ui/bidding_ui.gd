# bidding_ui.gd - Bidding UI component
extends Control
class_name BiddingUI

signal bid_made(suit: Card.Suit, count: int)
signal bid_passed
signal bid_suit_skipped(suit: Card.Suit)
signal bid_skipped_auto

var bid_panel: Panel
var button_container: HBoxContainer
var current_bid_label: Label
var title_label: Label

const C_GOLD = Color(0.941, 0.788, 0.416)
const C_PAPER = Color(0.945, 0.905, 0.796)
const C_INK = Color(0.165, 0.141, 0.098)
const C_GREEN_DARK = Color(0.035, 0.110, 0.086, 0.96)

func _ready():
	create_bidding_panel()
	apply_layout()
	if not get_viewport().size_changed.is_connected(apply_layout):
		get_viewport().size_changed.connect(apply_layout)
	if not GameConfig.language_changed.is_connected(_on_language_changed):
		GameConfig.language_changed.connect(_on_language_changed)
	visible = false

func create_bidding_panel():
	bid_panel = Panel.new()
	bid_panel.size = Vector2(720, 190)

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = C_GREEN_DARK
	panel_style.border_color = Color(C_GOLD, 0.78)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(4)
	panel_style.shadow_color = Color(0, 0, 0, 0.44)
	panel_style.shadow_size = 10
	bid_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(bid_panel)

	title_label = Label.new()
	title_label.position = Vector2(20, 10)
	title_label.size = Vector2(680, 30)
	title_label.text = GameConfig.text("bidding_phase")
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.add_theme_color_override("font_color", Color(C_GOLD, 0.95))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bid_panel.add_child(title_label)

	current_bid_label = Label.new()
	current_bid_label.position = Vector2(20, 50)
	current_bid_label.size = Vector2(680, 25)
	current_bid_label.text = GameConfig.text("no_bid_yet")
	current_bid_label.add_theme_font_size_override("font_size", 18)
	current_bid_label.add_theme_color_override("font_color", Color(C_PAPER, 0.92))
	current_bid_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bid_panel.add_child(current_bid_label)

	button_container = HBoxContainer.new()
	button_container.position = Vector2(30, 105)
	button_container.size = Vector2(660, 50)
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_theme_constant_override("separation", 10)
	bid_panel.add_child(button_container)

func apply_layout():
	if bid_panel == null:
		return
	var viewport_size = get_viewport().get_visible_rect().size
	var panel_width = clamp(viewport_size.x * 0.46, 620.0, 780.0)
	bid_panel.size = Vector2(panel_width, 190)
	bid_panel.position = Vector2(
		(viewport_size.x - bid_panel.size.x) * 0.5,
		(viewport_size.y - bid_panel.size.y) * 0.5
	)

	if title_label:
		title_label.size = Vector2(panel_width - 40, 30)
	if current_bid_label:
		current_bid_label.size = Vector2(panel_width - 40, 25)
	if button_container:
		button_container.size = Vector2(panel_width - 60, 50)
		button_container.position = Vector2(30, 105)

func _make_bid_btn_style(active: bool) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color     = C_GOLD if active else Color(0.055, 0.150, 0.112, 0.95)
	s.border_color = Color(C_GOLD, 0.80 if active else 0.40)
	s.set_border_width_all(2 if active else 1)
	s.set_corner_radius_all(3)
	return s

func show_bidding_options(available_suits: Array, suit_counts: Dictionary = {}, show_skip_prompt: bool = true):
	for child in button_container.get_children():
		child.queue_free()

	visible = true
	apply_layout()

	for suit in available_suits:
		var btn = Button.new()
		var suit_name = get_suit_name(suit)
		if suit_counts.has(suit):
			var count = suit_counts[suit]
			btn.text = GameConfig.text("bid_card_count") % [suit_name, count]
		else:
			btn.text = suit_name
		btn.custom_minimum_size = Vector2(130, 44)
		btn.add_theme_font_size_override("font_size", 16)
		btn.add_theme_stylebox_override("normal",  _make_bid_btn_style(false))
		btn.add_theme_stylebox_override("hover",   _make_bid_btn_style(true))
		btn.add_theme_color_override("font_color", Color(C_GOLD, 0.92))

		var suit_to_bid  = suit
		var count_to_bid = suit_counts.get(suit, 1)
		btn.pressed.connect(func(): _on_suit_button_pressed(suit_to_bid, count_to_bid))
		button_container.add_child(btn)

	var pass_button = Button.new()
	pass_button.text = GameConfig.text("pass")
	pass_button.custom_minimum_size = Vector2(100, 44)
	pass_button.add_theme_font_size_override("font_size", 18)
	var ps = StyleBoxFlat.new()
	ps.bg_color     = Color(0.035, 0.080, 0.065, 0.90)
	ps.border_color = Color(0.60, 0.74, 0.90, 0.40)
	ps.set_border_width_all(1)
	ps.set_corner_radius_all(3)
	pass_button.add_theme_stylebox_override("normal", ps)
	var psh = ps.duplicate()
	psh.bg_color = Color(0.09, 0.14, 0.22)
	pass_button.add_theme_stylebox_override("hover", psh)
	pass_button.add_theme_color_override("font_color", Color(0.75, 0.87, 1.00))
	pass_button.pressed.connect(_on_pass_button_pressed)
	button_container.add_child(pass_button)

	if show_skip_prompt:
		var skip_suit_button = Button.new()
		skip_suit_button.text = GameConfig.text("skip_bid_suit")
		skip_suit_button.custom_minimum_size = Vector2(145, 44)
		skip_suit_button.add_theme_font_size_override("font_size", 15)
		var ss = StyleBoxFlat.new()
		ss.bg_color = Color(0.030, 0.065, 0.055, 0.90)
		ss.border_color = Color(C_GOLD, 0.34)
		ss.set_border_width_all(1)
		ss.set_corner_radius_all(3)
		skip_suit_button.add_theme_stylebox_override("normal", ss)
		var ssh = ss.duplicate()
		ssh.bg_color = Color(0.08, 0.12, 0.10)
		ssh.border_color = Color(C_GOLD, 0.58)
		skip_suit_button.add_theme_stylebox_override("hover", ssh)
		skip_suit_button.add_theme_color_override("font_color", Color(C_PAPER, 0.88))
		var suit_to_skip = available_suits[0] if not available_suits.is_empty() else Card.Suit.NO_TRUMP
		skip_suit_button.pressed.connect(func(): _on_skip_suit_button_pressed(suit_to_skip))
		button_container.add_child(skip_suit_button)

		var skip_all_button = Button.new()
		skip_all_button.text = GameConfig.text("skip_all_bidding_prompts")
		skip_all_button.custom_minimum_size = Vector2(155, 44)
		skip_all_button.add_theme_font_size_override("font_size", 15)
		skip_all_button.add_theme_stylebox_override("normal", ss.duplicate())
		skip_all_button.add_theme_stylebox_override("hover", ssh.duplicate())
		skip_all_button.add_theme_color_override("font_color", Color(C_PAPER, 0.88))
		skip_all_button.pressed.connect(_on_skip_auto_button_pressed)
		button_container.add_child(skip_all_button)

func hide_bidding_ui():
	visible = false
	for child in button_container.get_children():
		child.queue_free()

func update_current_bid(message: String):
	current_bid_label.text = message

func get_suit_name(suit: Card.Suit) -> String:
	match suit:
		Card.Suit.NO_TRUMP: return GameConfig.text("suit_no_trump")
		Card.Suit.SPADE: return GameConfig.text("suit_spade")
		Card.Suit.HEART: return GameConfig.text("suit_heart")
		Card.Suit.CLUB: return GameConfig.text("suit_club")
		Card.Suit.DIAMOND: return GameConfig.text("suit_diamond")
		Card.Suit.JOKER: return GameConfig.text("suit_no_trump")
		_: return "?"

func _on_language_changed(_language: String):
	if title_label:
		title_label.text = GameConfig.text("bidding_phase")

func _on_suit_button_pressed(suit: Card.Suit, count: int = 1):
	bid_made.emit(suit, count)
	hide_bidding_ui()

func _on_pass_button_pressed():
	bid_passed.emit()
	hide_bidding_ui()

func _on_skip_suit_button_pressed(suit: Card.Suit):
	bid_suit_skipped.emit(suit)
	hide_bidding_ui()

func _on_skip_auto_button_pressed():
	bid_skipped_auto.emit()
	hide_bidding_ui()

func show_bidding_ui(can_bid: bool = true):
	visible = can_bid
	if visible:
		apply_layout()

func enable_buttons(enabled: bool):
	for btn in button_container.get_children():
		if btn is Button:
			btn.disabled = not enabled
