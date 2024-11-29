# OptionButton.gd
extends MarginContainer

var is_click_usable=true
var is_pressed = false

var text:String="":
	set(value):
		text=value
		call_deferred("_set_string")

func _set_string():
	$MarginContainer/Label.text=text
	pivot_offset=size/2


@export var start_state="normal"

signal _be_pressed(_slot)
signal _be_dispressed(_slot)
signal _be_hovered(_slot)


func _ready() -> void:
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://Card/card_shader.gdshader")
	material = shader_material
	connect("mouse_entered", onmouse_entered)
	connect("mouse_exited", onmouse_exited)

func onmouse_entered():
	if !material:return
	emit_signal("_be_hovered",self)
	if is_click_usable and not is_pressed:
		material.set_shader_parameter("hover", true)
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1).set_ease(Tween.EASE_OUT)

func onmouse_exited():
	if !material:return
	if is_click_usable and not is_pressed:
		material.set_shader_parameter("hover", false)
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1, 1), 0.1).set_ease(Tween.EASE_OUT)

func ongui_input(event):
	if !material:return
	if !is_click_usable: return
	if is_click_usable and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			toggle_pressed_state()
		

func toggle_pressed_state():
	is_pressed = !is_pressed
	material.set_shader_parameter("pressed", is_pressed)
	
	if is_pressed:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.1).set_ease(Tween.EASE_OUT)
		emit_signal("_be_pressed")
	else:
		emit_signal("_be_dispressed",self)
		_release()

func _release():
	is_pressed=false
	material.set_shader_parameter("pressed", is_pressed)
	var target_scale = Vector2(1, 1)
	if get_global_rect().has_point(get_global_mouse_position()):
		material.set_shader_parameter("hover", true)
		target_scale = Vector2(1.1, 1.1)
	else:
		material.set_shader_parameter("hover", false)
	var tween = create_tween()
	tween.tween_property(self, "scale", target_scale, 0.1).set_ease(Tween.EASE_OUT)

func update_usability_state():
	if is_click_usable:
		modulate = Color.WHITE
	else:
		modulate = Color(0.5, 0.5, 0.5, 1)
	
	material.set_shader_parameter("disabled", !is_click_usable)

func reset_state():
	if is_pressed:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1, 1), 0.1).set_ease(Tween.EASE_OUT)
	
	is_pressed = false
	material.set_shader_parameter("hover", false)
	material.set_shader_parameter("pressed", false)
