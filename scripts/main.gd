extends Node2D

@onready var player = $Player
@onready var hud = $HUD
@onready var spawn_timer = $SpawnTimer
@onready var enemy_container = $EnemyContainer

var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
var game_over: bool = false
var spawn_interval: float = 1.5
var difficulty_timer: float = 0.0

func _ready():
    player.add_to_group("player")
    player.hp_changed.connect(hud.update_hp)
    player.xp_changed.connect(hud.update_xp)
    player.level_up.connect(hud.update_level)
    player.kill_count_changed.connect(hud.update_kills)
    player.player_died.connect(_on_player_died)
    spawn_timer.timeout.connect(_on_spawn_timer)

func _process(delta):
    if game_over:
        return
    queue_redraw()
    difficulty_timer += delta
    if difficulty_timer > 10.0:
        difficulty_timer = 0.0
        spawn_interval = max(0.3, spawn_interval - 0.1)
        spawn_timer.wait_time = spawn_interval

func _draw():
    var grid = 64
    var c = player.global_position
    var sx = int((c.x - 700) / grid) * grid
    var sy = int((c.y - 400) / grid) * grid
    var col = Color(0.18, 0.18, 0.22)
    for x in range(sx, int(c.x + 700), grid):
        draw_line(Vector2(x, c.y - 400), Vector2(x, c.y + 400), col)
    for y in range(sy, int(c.y + 400), grid):
        draw_line(Vector2(c.x - 700, y), Vector2(c.x + 700, y), col)

func _on_spawn_timer():
    if game_over:
        return
    _spawn_enemy()

func _spawn_enemy():
    var enemy = enemy_scene.instantiate()
    var screen = get_viewport_rect().size
    var c = player.global_position
    var margin = 100.0
    var pos = Vector2.ZERO
    match randi() % 4:
        0: pos = c + Vector2(randf_range(-screen.x / 2, screen.x / 2), -screen.y / 2 - margin)
        1: pos = c + Vector2(randf_range(-screen.x / 2, screen.x / 2), screen.y / 2 + margin)
        2: pos = c + Vector2(-screen.x / 2 - margin, randf_range(-screen.y / 2, screen.y / 2))
        3: pos = c + Vector2(screen.x / 2 + margin, randf_range(-screen.y / 2, screen.y / 2))
    enemy.global_position = pos
    enemy.player = player
    var t = 1.0 + hud.elapsed_time / 60.0
    enemy.max_hp = 30.0 * t
    enemy.hp = enemy.max_hp
    enemy.speed = 80.0 + hud.elapsed_time * 0.5
    enemy.damage = 10.0 * t
    enemy_container.add_child(enemy)

func _on_player_died():
    game_over = true
    spawn_timer.stop()
    var go = load("res://scenes/game_over_screen.tscn").instantiate()
    go.get_node("Panel/VBoxContainer/StatsLabel").text = "Level: %d\nKills: %d\nTime: %s" % [
        player.level, player.kills, hud.time_label.text
    ]
    go.get_node("Panel/VBoxContainer/RestartButton").pressed.connect(_restart)
    add_child(go)

func _restart():
    get_tree().reload_current_scene()
