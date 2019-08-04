extends KinematicBody2D

const MAX_SPEED = 600
const ACCELERATION = 1000
const DECELERATION = 2000
const JUMP_FORCE = 800
const GRAVITY = 2000
const MAX_FALL_SPEED = 1400
const MAX_JUMP_COUNT = 2

var character_sprite
#player input direction
var input_direction = 0
#game player current direction
var direction = 1
#game player current speed
var speed_x = 0
var speed_y = 0
#current jump count
var jump_count = 0
#game player current velocity
var velocity = Vector2()


func _ready():
	character_sprite = $Sprite
	
func _input(event):
	if event.is_action_pressed("Jump") and jump_count < MAX_JUMP_COUNT:
		speed_y = -JUMP_FORCE
		jump_count += 1

func _process(delta):
	
	if input_direction:
		direction = input_direction
	
	#set input direction	
	if Input.is_action_pressed("move_left"):
		input_direction = -1
		character_sprite.set_flip_h(true)
	elif Input.is_action_pressed("move_right"):
		input_direction = 1
		character_sprite.set_flip_h(false)
	else:
		input_direction = 0
	
	#if input diection is oppsite of player direction slow down speed	
	if input_direction == -direction:
		speed_x /= 10
	
	#handle horizontal speed
	if input_direction:
		speed_x += ACCELERATION * delta
	else:
		speed_x -= DECELERATION * delta
	
	#constraint speed
	speed_x = clamp(speed_x, 0, MAX_SPEED)
	
	speed_y += GRAVITY * delta
	if speed_y > MAX_FALL_SPEED:
		speed_y = MAX_FALL_SPEED
	
	#velocity
	velocity.x = speed_x * delta * direction
	velocity.y = speed_y * delta
	
	#move player
	var collision = move_and_collide(velocity)
	
	#on ground
	if collision:
		var normal = collision.get_normal()
		var final_movement = collision.remainder.slide(normal)
		speed_y = Vector2(0, speed_y).slide(normal).y
		move_and_collide(final_movement)
		
		#make sure collide with ground not wall, which normal can be (1,0) or (-1,0)
		if not normal.x:
			jump_count=0
