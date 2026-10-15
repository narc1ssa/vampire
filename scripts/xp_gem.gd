extends Area2D

var xp_value: float = 10.0
var attract_speed: float = 300.0
var attract_range: float = 100.0
var is_attracted: bool = false
var player: Node2D = null

func _ready():
    body_entered.connect(_on_body_entered)

func _physics_process(delta):
    if not player or not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player")
        if not player:
            return
    var dist = global_position.distance_to(player.global_position)
    if dist < attract_range:
        is_attracted = true
    if is_attracted:
        var dir = (player.global_position - global_position).normalized()
        global_position += dir * attract_speed * delta
        attract_speed += 500 * delta

func _on_body_entered(body):
    if body.is_in_group("player"):
        body.collect_xp(xp_value)
        queue_free()
