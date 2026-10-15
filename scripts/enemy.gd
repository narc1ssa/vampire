extends CharacterBody2D

@export var speed: float = 80.0
@export var max_hp: float = 30.0
@export var damage: float = 10.0
@export var xp_value: float = 10.0

var hp: float
var player: CharacterBody2D = null
var attack_cooldown: float = 0.0

var xp_gem_scene: PackedScene = preload("res://scenes/xp_gem.tscn")

func _ready():
    hp = max_hp
    add_to_group("enemies")

func _physics_process(delta):
    if not player or not is_instance_valid(player):
        return
    var dir = (player.global_position - global_position).normalized()
    velocity = dir * speed
    move_and_slide()

    attack_cooldown -= delta
    if global_position.distance_to(player.global_position) < 28 and attack_cooldown <= 0:
        player.take_damage(damage)
        attack_cooldown = 0.5

func take_damage(amount: float):
    hp -= amount
    if hp <= 0:
        _die()

func _die():
    var gem = xp_gem_scene.instantiate()
    gem.global_position = global_position
    gem.xp_value = xp_value
    get_parent().add_child(gem)
    if player and is_instance_valid(player):
        player.register_kill()
    queue_free()
