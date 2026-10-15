extends Area2D

@export var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT
var damage: float = 20.0
var lifetime: float = 2.0

func _ready():
    body_entered.connect(_on_body_entered)

func _physics_process(delta):
    global_position += direction * speed * delta
    lifetime -= delta
    if lifetime <= 0:
        queue_free()

func _on_body_entered(body):
    if body.is_in_group("enemies"):
        body.take_damage(damage)
        queue_free()
