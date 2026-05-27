# sound_manager.gd - Shared audio manager
extends Node

const POOL_SIZE = 8
const COMMON_SFX_DIR = "res://assets/common/audio/sfx"

const SFX_PATHS = {
	"card_click": "%s/card_click.ogg" % COMMON_SFX_DIR,
	"card_play": "%s/card_play.ogg" % COMMON_SFX_DIR,
	"deal": "%s/card_deal.ogg" % COMMON_SFX_DIR,
	"bid": "%s/bid.ogg" % COMMON_SFX_DIR,
	"trick_win": "%s/trick_win.ogg" % COMMON_SFX_DIR,
	"level_up": "%s/level_up.ogg" % COMMON_SFX_DIR,
	"game_over": "%s/game_over.ogg" % COMMON_SFX_DIR,
}

var _players: Array[AudioStreamPlayer] = []
var _pool_index: int = 0
var _stream_cache: Dictionary = {}

func _ready():
	for i in POOL_SIZE:
		var p = AudioStreamPlayer.new()
		p.volume_db = -6.0
		add_child(p)
		_players.append(p)

func play_card_click():
	_play_sfx("card_click", _beep(850.0, 0.07, 0.35))

func play_card_play():
	_play_sfx("card_play", _beep(520.0, 0.13, 0.45))

func play_deal():
	_play_sfx("deal", _beep(360.0, 0.05, 0.22))

func play_bid():
	_play_sfx("bid", _beep(680.0, 0.12, 0.40))

func play_trick_win():
	_play_sfx("trick_win", _sweep(420.0, 720.0, 0.32, 0.50))

func play_level_up():
	_play_sfx("level_up", _sweep(320.0, 960.0, 0.55, 0.58))

func play_game_over():
	_play_sfx("game_over", _sweep(680.0, 280.0, 0.70, 0.50))

func _play_sfx(key: String, fallback_stream: AudioStream):
	_play(_get_stream(key, fallback_stream))

func _get_stream(key: String, fallback_stream: AudioStream) -> AudioStream:
	if _stream_cache.has(key):
		return _stream_cache[key]
	if SFX_PATHS.has(key) and ResourceLoader.exists(SFX_PATHS[key]):
		var loaded = load(SFX_PATHS[key])
		if loaded is AudioStream:
			_stream_cache[key] = loaded
			return loaded
	_stream_cache[key] = fallback_stream
	return fallback_stream

func _play(stream: AudioStream):
	if not GameConfig.sound_enabled:
		return
	var p = _players[_pool_index]
	_pool_index = (_pool_index + 1) % POOL_SIZE
	p.stream = stream
	p.play()

func _beep(freq: float, dur: float, vol: float) -> AudioStreamWAV:
	var sr = 22050
	var n = int(dur * sr)
	var data = PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t = float(i) / sr
		var env = pow(1.0 - float(i) / n, 0.55)
		var s = sin(TAU * freq * t) * vol * env
		data.encode_s16(i * 2, int(clamp(s, -1.0, 1.0) * 32767))
	return _make_wav(data, sr)

func _sweep(f0: float, f1: float, dur: float, vol: float) -> AudioStreamWAV:
	var sr = 22050
	var n = int(dur * sr)
	var data = PackedByteArray()
	data.resize(n * 2)
	var phase = 0.0
	for i in n:
		var t = float(i) / n
		var freq = lerp(f0, f1, t)
		phase += TAU * freq / sr
		var env = sin(PI * t) * vol
		var s = sin(phase) * env
		data.encode_s16(i * 2, int(clamp(s, -1.0, 1.0) * 32767))
	return _make_wav(data, sr)

func _make_wav(data: PackedByteArray, sr: int) -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sr
	stream.stereo = false
	return stream
