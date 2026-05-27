# player.gd - Shengji player
extends Node2D
class_name Player

const ShengjiCardLogic = preload("res://scripts/games/shengji/rules/shengji_card_logic.gd")

signal cards_played(cards: Array[Card])
signal card_selected(card: Card)
signal selection_changed(count: int)

enum PlayerType { HUMAN, AI }

var player_id: int = 0
var player_name: String = "Player "
var player_type: PlayerType = PlayerType.HUMAN
var team: int = 0
var current_rank: int = 2

var hand: Array[Card] = []
var is_dealer: bool = false

# UI state
var hand_container: Node2D
var card_spacing: float = 43.0
var selected_cards: Array[Card] = []

const MIN_CARD_SPACING = 18.0
const HAND_SIDE_MARGIN = 14.0

func _ready():
	hand_container = Node2D.new()
	hand_container.name = "HandContainer"
	add_child(hand_container)

func receive_cards(cards: Array[Card], update_display_after_receive: bool = true):
	for card in cards:
		hand.append(card)

		if card.get_parent():
			card.get_parent().remove_child(card)
		hand_container.add_child(card)

		# card.visible = true

		if player_type == PlayerType.HUMAN:
			card.set_face_up(true, true)
			if not card.card_clicked.is_connected(_on_card_clicked):
				card.card_clicked.connect(_on_card_clicked)

	if update_display_after_receive:
		update_hand_display()

func sort_hand(trump_last: bool = false, trump_suit: Card.Suit = Card.Suit.SPADE, current_rank: int = 2):
	"""Sort the hand for bidding or play."""
	for card in hand:
		ShengjiCardLogic.apply_trump(card, trump_suit, current_rank)

	hand.sort_custom(func(a, b):
		if trump_last:
			if a.is_trump != b.is_trump:
				return not a.is_trump

			if not a.is_trump:
				if a.suit != b.suit:
					return a.suit < b.suit
				return a.rank < b.rank

			var a_type = _get_trump_type(a, trump_suit, current_rank)
			var b_type = _get_trump_type(b, trump_suit, current_rank)

			if a_type != b_type:
				return a_type < b_type

			if a_type == 0:
				return a.rank < b.rank
			elif a_type == 1:
				return a.suit < b.suit
			# Other types are already ordered by type.
			return a.rank < b.rank
		else:
			if a.is_trump != b.is_trump:
				return a.is_trump
			if a.suit != b.suit:
				return a.suit < b.suit
			return a.rank < b.rank
	)

func _get_trump_type(card: Card, trump_suit: Card.Suit, current_rank: int) -> int:
	"""
	3: Small Joker
	4: Big Joker
	"""
	if card.suit == Card.Suit.JOKER:
		if card.rank == Card.Rank.SMALL_JOKER:
			return 3  # Small Joker
		else:
			return 4  # Big Joker

	if card.rank == current_rank:
		if card.suit == trump_suit:
			return 2
		else:
			return 1

	if card.suit == trump_suit:
		return 0

	return 5

func update_hand_display(animate: bool = true):
	"""Update the hand display so it matches the hand array."""
	print("=== update_hand_display Start ===")
	print("hand array size: ", hand.size())
	print("hand_container child count: ", hand_container.get_child_count())

	var to_remove = []
	for child in hand_container.get_children():
		if child is Card:
			if not hand.has(child):
				to_remove.append(child)

	for card in to_remove:
		print("Remove card no longer in hand: ", card)
		hand_container.remove_child(card)
		card.visible = false

	for card in hand:
		if card.get_parent() != hand_container:
			print("Add card to hand_container: ", card)
			if card.get_parent():
				card.get_parent().remove_child(card)
			hand_container.add_child(card)

		card.visible = true
		card.is_selectable = true

		if card.sprite and not card.is_selected:
			card.sprite.modulate = Color.WHITE

	print("After cleanup - hand_container child count: ", hand_container.get_child_count())

	var layout = get_hand_layout()
	for i in range(hand.size()):
		var card = hand[i]
		card.visible = true
		card.set_hand_overlap_spacing(layout["spacing"], i == hand.size() - 1)
		var target_pos = layout["positions"][i]

		var was_selected = card.is_selected

		if animate:
			if was_selected:
				var offset_pos = Vector2(target_pos.x, target_pos.y - Card.SELECTED_HEIGHT)
				card.move_to_with_base(target_pos, offset_pos, 0.3)
			else:
				card.move_to(target_pos, 0.3)
		else:
			card.original_position = target_pos
			if was_selected:
				card.position = Vector2(target_pos.x, target_pos.y - Card.SELECTED_HEIGHT)
			else:
				card.position = target_pos

		card.z_index = 1000 + selected_cards.find(card) if card.is_selected else i

	print("=== update_hand_display Complete ===") 

func refresh_hand_z_order():
	for i in range(hand.size()):
		var card = hand[i]
		card.z_index = 1000 + selected_cards.find(card) if card.is_selected else i

func get_effective_card_spacing() -> float:
	return get_effective_card_spacing_for_count(hand.size())

func get_effective_card_spacing_for_count(card_count: int) -> float:
	if card_count <= 1:
		return card_spacing

	var viewport_width = 1280.0
	if is_inside_tree():
		viewport_width = get_viewport_rect().size.x

	var card_half_width = Card.CARD_WIDTH * Card.CARD_SCALE * 0.5
	var available_span = viewport_width - (card_half_width + HAND_SIDE_MARGIN) * 2.0
	if available_span <= 0:
		return MIN_CARD_SPACING

	var max_spacing = available_span / float(card_count - 1)
	return min(card_spacing, max(MIN_CARD_SPACING, max_spacing))

func get_hand_layout() -> Dictionary:
	var positions: Array[Vector2] = []
	var spacing = get_effective_card_spacing()
	var row_width = spacing * float(max(hand.size() - 1, 0))
	var start_x = -row_width * 0.5
	for i in range(hand.size()):
		positions.append(Vector2(start_x + i * spacing, 0))

	return {"positions": positions, "spacing": spacing}

func _on_card_clicked(card: Card):
	if player_type != PlayerType.HUMAN:
		return

	if not hand.has(card):
		print("Warning: tried to select a card not in hand ", card)
		return

	if card.is_selected:
		card.set_selected(false)
		selected_cards.erase(card)
	else:
		card.set_selected(true)
		selected_cards.append(card)
	refresh_hand_z_order()

	selection_changed.emit(selected_cards.size())
	card_selected.emit(card)

func play_selected_cards() -> bool:
	if selected_cards.is_empty():
		return false

	var cards_to_play = selected_cards.duplicate()
	return play_cards(cards_to_play)

func play_cards(cards: Array[Card]) -> bool:
	"""Play cards and update the hand display."""
	if not can_play_cards(cards):
		print("Error: cannot play because some cards are not in hand")
		return false

	print("=== StartPlay cards ===")
	print("Before play - hand.size() = ", hand.size())
	print("Cards to play: ", cards.size())

	for card in cards:
		print("Play cards：", card.get_card_name())

	for card in cards:
		if card.is_selected:
			card.is_selected = false
			if card.sprite:
				card.sprite.modulate = Color.WHITE  # immediatelyrestorecolor

		card.is_selectable = false

		if card.card_clicked.is_connected(_on_card_clicked):
			card.card_clicked.disconnect(_on_card_clicked)

		hand.erase(card)

		if card.get_parent() == hand_container:
			hand_container.remove_child(card)
			print("Remove card from hand_container: ", card.get_card_name())

		if selected_cards.has(card):
			selected_cards.erase(card)

	selected_cards.clear()

	print("After play - hand.size() = ", hand.size())

	update_hand_display(false)

	verify_hand_sync()

	cards_played.emit(cards)
	print("=== Play cardsComplete ===")
	return true

func verify_hand_sync():
	"""Verify the hand array and UI display are synchronized."""
	var ui_card_count = 0
	for child in hand_container.get_children():
		if child is Card:
			ui_card_count += 1

	if ui_card_count != hand.size():
		print("Warning: hand is out of sync. hand array: ", hand.size(), " UI cards: ", ui_card_count)
		print("Forcing hand display sync...")
		update_hand_display(false)
	else:
		print("Verification passed: hand is synchronized. Count: ", hand.size())

func can_play_cards(cards: Array[Card]) -> bool:
	for card in cards:
		if not hand.has(card):
			return false
	return true

func get_valid_plays(lead_cards: Array[Card], _trump_suit: Card.Suit) -> Array:
	var valid_plays = []
	
	if lead_cards.is_empty():
		for card in hand:
			valid_plays.append([card])
	else:
		if hand.size() > 0:
			valid_plays.append([hand[0]])
	
	return valid_plays

func ai_play_turn(lead_cards: Array[Card], trump_suit: Card.Suit) -> Array[Card]:
	if player_type != PlayerType.AI:
		return []
	
	var valid_plays = get_valid_plays(lead_cards, trump_suit)
	if valid_plays.is_empty():
		return [hand[0]] if hand.size() > 0 else []
	
	return valid_plays[randi() % valid_plays.size()]

func get_hand_size() -> int:
	return hand.size()

func show_cards(face_up: bool = true):
	for card in hand:
		card.set_face_up(face_up)

func set_card_selectable(selectable: bool):
	for card in hand:
		card.is_selectable = selectable

func clear_selection():
	"""Clear all selected cards."""
	for card in selected_cards:
		card.set_selected(false)
	selected_cards.clear()
	refresh_hand_z_order()
	selection_changed.emit(0)

func pre_select_cards(cards: Array[Card]):
	"""Select multiple cards at once for the burying phase."""
	for card in cards:
		if hand.has(card) and not card.is_selected:
			card.set_selected(true)
			selected_cards.append(card)
			card.z_index = 1000 + selected_cards.size()
	selection_changed.emit(selected_cards.size())
