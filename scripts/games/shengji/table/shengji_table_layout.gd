# shengji_table_layout.gd - Table positions for Shengji gameplay
extends RefCounted
class_name ShengjiTableLayout

static func get_player_positions(table_size: Vector2) -> Array[Vector2]:
	return [
		Vector2(table_size.x * 0.50, table_size.y * 0.79),
		Vector2(table_size.x * 0.08, table_size.y * 0.46),
		Vector2(table_size.x * 0.50, table_size.y * 0.12),
		Vector2(table_size.x * 0.88, table_size.y * 0.46)
	]

static func get_play_area_positions(table_size: Vector2) -> Array[Vector2]:
	return [
		Vector2(table_size.x * 0.5, table_size.y * 0.64),
		Vector2(table_size.x * 0.28, table_size.y * 0.48),
		Vector2(table_size.x * 0.5, table_size.y * 0.30),
		Vector2(table_size.x * 0.72, table_size.y * 0.48)
	]
