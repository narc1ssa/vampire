extends CanvasLayer

@onready var hp_label = $HPLabel
@onready var xp_label = $XPLabel
@onready var level_label = $LevelLabel
@onready var time_label = $TimeLabel
@onready var kill_label = $KillLabel

var elapsed_time: float = 0.0

func _process(delta):
    elapsed_time += delta
    var m = int(elapsed_time) / 60
    var s = int(elapsed_time) % 60
    time_label.text = "%d:%02d" % [m, s]

func update_hp(current: float, maximum: float):
    hp_label.text = "HP: %d/%d" % [int(current), int(maximum)]

func update_xp(current: float, to_next: float):
    xp_label.text = "XP: %d/%d" % [int(current), int(to_next)]

func update_level(lvl: int):
    level_label.text = "Level: %d" % lvl

func update_kills(count: int):
    kill_label.text = "Kills: %d" % count
