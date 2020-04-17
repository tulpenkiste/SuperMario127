extends Nozzle

class_name HoverNozzle

export var boost_power := 40
export var depletion := 0.35
var last_activated = false

var accel = 15
var rotation_interpolation_speed = 35

func _init():
	blacklisted_states = ["WallSlideState", "GroundPoundStartState", "GroundPoundState", "GroundPoundEndState", "GetupState", "BonkedState", "SpinningState"]

func _activate_check(_delta):
	return true
	
func is_state(state):
	return character.state == character.get_state_node(state)
	
func _activated_update(delta):
	if !is_state("DiveState") and !is_state("SlideState"):
		if character.facing_direction == 1:
			character.sprite.animation = "jumpRight"
		else:
			character.sprite.animation = "jumpLeft"

	if (character.state == null or !character.state.override_rotation) and !character.rotating_jump:
		override_rotation = true
		var sprite = character.sprite
		var sprite_rotation = (character.velocity.x / character.move_speed) * 8
		sprite.rotation_degrees = lerp(sprite.rotation_degrees, sprite_rotation, delta * rotation_interpolation_speed)
	else:
		override_rotation = false
			
	var normal = character.sprite.transform.y.normalized()
	character.jump_animation = 0
	
	var power = -boost_power * (character.stamina / 100)
	if abs(character.velocity.x) < abs(power * normal.x) * 8:
		character.velocity.x -= accel * normal.x
		
	if (character.velocity.y > power * normal.y and normal.y > 0) or (character.velocity.y < power * normal.y and normal.y < 0):
		character.velocity.y -= accel * normal.y
	character.stamina -= depletion
	character.attacking = true
	
func _update(_delta):
	if character.is_grounded():
		character.stamina = 100
		
	if !activated:
		override_rotation = false

func _process(delta):
	if character.nozzle == self:
		if character.water_sprite.flip_h:
			character.water_sprite.flip_h = false
		else:
			character.water_sprite.flip_h = true

func _general_update(_delta):
	if activated and !last_activated:
		character.water_sprite.animation = "out"
		character.water_sprite.frame = 0
		character.fludd_sound.play(((100 - character.stamina) / 100) * 2.79)
	elif !activated and last_activated:
		character.water_sprite.animation = "in"
		character.water_sprite.frame = 0
		character.attacking = false
		character.fludd_sound.stop()

	last_activated = activated
