# main.gd - Shengji main scene
extends Node2D

var game_manager: Node
var ui_manager: CanvasLayer
var background: ColorRect
var felt_texture_layer: Node2D

const LOBBY_ASSET_DIR = "res://assets/ui/lobby/"
const TEX_SUIT_SPADE = LOBBY_ASSET_DIR + "suit_shadow_spade.png"
const TEX_SUIT_CLUB = LOBBY_ASSET_DIR + "suit_shadow_club.png"
const TEX_SUIT_DIAMOND = LOBBY_ASSET_DIR + "suit_shadow_diamond.png"

func _ready():
	get_window().title = GameConfig.text("shengji_title")
	if not GameConfig.language_changed.is_connected(_on_language_changed):
		GameConfig.language_changed.connect(_on_language_changed)
	var initial_size = get_viewport().get_visible_rect().size
	if not is_web_build():
		var window_size = get_target_window_size()
		get_window().size = window_size
		get_window().min_size = window_size
		center_window(window_size)
		initial_size = Vector2(window_size)
	
	background = ColorRect.new()
	background.color = Color(0.027, 0.114, 0.090)
	background.position = Vector2.ZERO
	background.size = initial_size
	background.z_index = -10
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	felt_texture_layer = Node2D.new()
	felt_texture_layer.z_index = -9
	add_child(felt_texture_layer)
	build_felt_texture(initial_size)
	if not get_viewport().size_changed.is_connected(apply_layout):
		get_viewport().size_changed.connect(apply_layout)

	ui_manager = CanvasLayer.new()
	ui_manager.name = "UIManager"
	var ui_script = load("res://scripts/games/shengji/ui/ui_manager.gd")
	ui_manager.set_script(ui_script)
	add_child(ui_manager)
	await get_tree().process_frame

	game_manager = Node.new()
	game_manager.name = "GameManager"
	var game_script = load("res://scripts/games/shengji/flow/game_manager.gd")
	game_manager.set_script(game_script)
	game_manager.ui_manager = ui_manager
	
	ui_manager.play_cards_pressed.connect(game_manager._on_play_cards_pressed)
	ui_manager.bury_cards_pressed.connect(game_manager._on_bury_cards_pressed)

	if ui_manager.has_node("BiddingUI"):
		var bidding_ui = ui_manager.get_node("BiddingUI")
		bidding_ui.bid_made.connect(game_manager._on_player_bid_made)
		bidding_ui.bid_passed.connect(game_manager._on_player_bid_passed)
		bidding_ui.bid_suit_skipped.connect(game_manager._on_player_bid_suit_skipped)
		bidding_ui.bid_skipped_auto.connect(game_manager._on_player_bid_skipped_auto)

	if ui_manager.has_node("GameOverUI"):
		var game_over_ui = ui_manager.get_node("GameOverUI")
		game_over_ui.restart_game.connect(game_manager.restart_game)
		game_over_ui.quit_game.connect(_on_quit_game)

	add_child(game_manager)

	await get_tree().process_frame
	if game_manager.players.size() > 0:
		var player1 = game_manager.players[0]
		if player1.has_signal("selection_changed"):
			player1.selection_changed.connect(_on_player_selection_changed)

func _on_player_selection_changed(count: int):
	"""Handle selection count changes."""
	if game_manager and game_manager.has_method("on_human_selection_changed"):
		game_manager.on_human_selection_changed(count)
	elif ui_manager:
		ui_manager.update_selected_count(count, GameConfig.get_shengji_bottom_card_count())

func _on_quit_game():
	"""Exit the game."""
	get_tree().quit()

func _on_language_changed(_language: String):
	get_window().title = GameConfig.text("shengji_title")

func apply_layout():
	var viewport_size = get_viewport().get_visible_rect().size
	if background:
		background.size = viewport_size
	if felt_texture_layer:
		build_felt_texture(viewport_size)

func build_felt_texture(viewport_size: Vector2):
	for child in felt_texture_layer.get_children():
		child.queue_free()

	for x in range(0, int(viewport_size.x), 22):
		var line = ColorRect.new()
		line.position = Vector2(x, 0)
		line.size = Vector2(1, viewport_size.y)
		line.color = Color(1, 1, 1, 0.010)
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		felt_texture_layer.add_child(line)

	for y in range(0, int(viewport_size.y), 22):
		var line = ColorRect.new()
		line.position = Vector2(0, y)
		line.size = Vector2(viewport_size.x, 1)
		line.color = Color(0, 0, 0, 0.045)
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		felt_texture_layer.add_child(line)

	var border_color = Color(0.945, 0.768, 0.353, 0.16)
	var borders = [
		[Vector2(0, 0), Vector2(viewport_size.x, 2)],
		[Vector2(0, viewport_size.y - 2), Vector2(viewport_size.x, 2)],
		[Vector2(0, 0), Vector2(2, viewport_size.y)],
		[Vector2(viewport_size.x - 2, 0), Vector2(2, viewport_size.y)],
	]
	for item in borders:
		var rect = ColorRect.new()
		rect.position = item[0]
		rect.size = item[1]
		rect.color = border_color
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		felt_texture_layer.add_child(rect)

	for item in [
		[Vector2(viewport_size.x * 0.045, viewport_size.y * 0.84), TEX_SUIT_SPADE],
		[Vector2(viewport_size.x * 0.92, viewport_size.y * 0.08), TEX_SUIT_CLUB],
		[Vector2(viewport_size.x * 0.90, viewport_size.y * 0.82), TEX_SUIT_DIAMOND],
	]:
		var mark = TextureRect.new()
		mark.texture = load(item[1])
		mark.position = item[0]
		mark.size = Vector2(76, 76)
		mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		mark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		mark.modulate = Color(1, 1, 1, 0.10)
		mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		felt_texture_layer.add_child(mark)

func get_target_window_size() -> Vector2i:
	var screen = DisplayServer.window_get_current_screen()
	var usable_rect = DisplayServer.screen_get_usable_rect(screen)
	var target = Vector2i(
		max(1280, int(float(usable_rect.size.x) * 0.8)),
		max(720, int(float(usable_rect.size.y) * 0.8))
	)
	return target

func center_window(window_size: Vector2i):
	var screen = DisplayServer.window_get_current_screen()
	var usable_rect = DisplayServer.screen_get_usable_rect(screen)
	get_window().position = usable_rect.position + (usable_rect.size - window_size) / 2

func is_web_build() -> bool:
	return OS.has_feature("web")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
