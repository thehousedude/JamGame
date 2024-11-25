# Spike.gd
extends Area2D

func _ready():
	# 将尖刺添加到 "hazards" 组
	add_to_group("hazards")
