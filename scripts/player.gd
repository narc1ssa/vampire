extends CharacterBody2D

@export var speed: float = 200.0
@export var max_hp: float = 100.0
@export var fire_rate: float = 0.5
@export var projectile_damage: float = 20.0

var hp: float
var xp: float = 0.0
var level: int = 1
var xp_to_next_level: float = 50.0
var fire_timer: float = 0.0
var invincible_timer: float = 0.0
var kills: int = 0

var projectile_scene: PackedScene = preload("res://scenes/projectile.tscn")

signal hp_changed(current_hp, maximum_hp)
signal xp_changed(current_xp, xp_to_next)
signal level_up(new_level)
signal player_died
signal kill_count_changed(count)

func _ready():
    hp = max_hp
    hp_changed.emit(hp, max_hp)
    xp_changed.emit(xp, xp_to_next_level)

func _physics_process(delta):
    var input_dir = Vector2.ZERO
    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
        input_dir.y -= 1
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
        input_dir.y += 1
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        input_dir.x -= 1
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        input_dir.x += 1
    if input_dir != Vector2.ZERO:
        input_dir = input_dir.normalized()

    velocity = input_dir * speed
    move_and_slide()

    fire_timer -= delta
    if fire_timer <= 0:
        _try_fire()
        fire_timer = fire_rate

    if invincible_timer > 0:
        invincible_timer -= delta
        $Visual.modulate.a = 0.4 if fmod(invincible_timer, 0.1) > 0.05 else 1.0
    else:
        $Visual.modulate.a = 1.0

func _try_fire():
    var enemies = get_tree().get_nodes_in_group("enemies")
    if enemies.is_empty():
        return
    var closest = null
    var closest_dist = INF
    for e in enemies:
        var d = global_position.distance_to(e.global_position)
        if d < closest_dist:
            closest_dist = d
            closest = e
    if closest and closest_dist < 500:
        var proj = projectile_scene.instantiate()
        proj.global_position = global_position
        proj.direction = (closest.global_position - global_position).normalized()
        proj.damage = projectile_damage
        get_parent().add_child(proj)

func take_damage(amount: float):
    if invincible_timer > 0:
        return
    hp -= amount
    invincible_timer = 0.5
    hp_changed.emit(hp, max_hp)
    if hp <= 0:
        hp = 0
        player_died.emit()

func collect_xp(amount: float):
    xp += amount
    while xp >= xp_to_next_level:
        xp -= xp_to_next_level
        level += 1
        xp_to_next_level *= 1.3
        speed *= 1.05
        projectile_damage *= 1.10
        fire_rate = max(0.1, fire_rate * 0.95)
        level_up.emit(level)
    xp_changed.emit(xp, xp_to_next_level)

func register_kill():
    kills += 1
    kill_count_changed.emit(kills)
