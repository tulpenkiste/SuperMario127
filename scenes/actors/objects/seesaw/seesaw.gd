extends GameObject


#-------------------------------- GameObject logic -----------------------

var parts := 1
var last_parts := 1

func _set_properties():
	savable_properties = ["parts"]
	editable_properties = ["parts"]
	
func _set_property_values():
	set_property("parts", parts, 1)

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and hovered:
		if event.button_index == 5: # Mouse wheel down
			parts -= 1
			if parts < 1:
				parts = 1
			set_property("parts", parts, true)
		elif event.button_index == 4: # Mouse wheel up
			parts += 1
			set_property("parts", parts, true)

func _process(_delta):
	if parts != last_parts:
		update_parts()
	last_parts = parts






#-------------------------------- platform logic -----------------------

onready var body = $KinematicBody2D
onready var sprite = $Sprite
onready var screw = $Screw
onready var area = $FloorTouchArea

onready var platform_area_collision_shape = $KinematicBody2D/Area2D/CollisionShape2D
onready var area_collision_shape = $FloorTouchArea/CollisionShape2D
onready var collision_shape = $KinematicBody2D/CollisionShape2D

var buffer := -5

var tilt := 0.0

var rotation_speed := 0.0

const HALF_PI = PI/2

onready var left_width = sprite.patch_margin_left
onready var right_width = sprite.patch_margin_right
onready var part_width = sprite.texture.get_width() - left_width - right_width

func _ready():
	platform_area_collision_shape.shape = platform_area_collision_shape.shape.duplicate(true)
	area_collision_shape.shape = area_collision_shape.shape.duplicate(true)
	collision_shape.shape = collision_shape.shape.duplicate(true)
	
	if !enabled:
		collision_shape.disabled = true
		
	update_parts()
		
func update_parts():
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts

	platform_area_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2 + 20
	area_collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2
	collision_shape.shape.extents.x = (left_width + (part_width * parts) + right_width) / 2

func _physics_process(delta):
	if(mode==1):
		return
	
	var scale_x = scale.x * (left_width + right_width + part_width * parts) / 64
	
	var delta_rotation := 0
	for _body in area.get_overlapping_bodies():
		var bottom_pos = _body.get("bottom_pos")
		if(bottom_pos):
			var diff : float = _body.global_position.x-body.global_position.x
			
			var distance = (tan(tilt)*diff+body.global_position.y) - bottom_pos.global_position.y - 5 * scale.y
			
			var factor = max(0,1-distance/10) / scale_x
			
			var weight := 1.0
			if _body.has_method("get_weight"):
				weight = _body.get_weight()
			
			delta_rotation += (diff * factor) * weight if distance>0 else 0.0


	tilt += clamp(delta_rotation,-70,70) * delta * 0.05

	rotation_speed -= tilt*delta*0.25

	rotation_speed *= pow(0.92,delta*60)
	tilt = clamp(tilt + rotation_speed, -HALF_PI, HALF_PI)
	
	rotation = tilt
	body.rotation = 0 #necessary because godot
	screw.global_rotation = 0
