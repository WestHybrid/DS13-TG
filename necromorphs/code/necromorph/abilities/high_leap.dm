/datum/action/cooldown/necro/high_leap
	name = "High Leap"
	click_to_activate = TRUE
	cooldown_time = 1 SECONDS
	var/datum/move_loop/loop
	var/turf/started_at
	var/block_movement = FALSE
	var/tiles_moved = 0
	//Must travel at least this far
	var/min_range = 3
	//Metres per second, while in the air. Note that this speed is not guaranteed, short-ranged jumps may go slower than this to make the animation look right
	var/travel_speed = 1.25
	//Time between giving command and actually taking off
	var/windup_time = 1 SECONDS
	//Recovery time after landing
	var/winddown_time = 1 SECONDS
	//How long does the launching animation take? We'll start travel during this animation, so this is a minimum rather than an addition
	var/launch_time = 4
	//Like above, at the landing end
	var/land_time = 4
	//Temporary vars stored while travelling
	var/cached_density
	var/cached_alpha
	var/cached_passflags

/datum/action/cooldown/necro/high_leap/New(Target, cooldown, windup_time, winddown_time, min_range, travel_speed)
	if(windup_time)
		src.windup_time = windup_time
	if(winddown_time)
		src.winddown_time = winddown_time
	if(min_range)
		src.min_range = min_range
	if(travel_speed)
		src.travel_speed = travel_speed
	.=..()

/datum/action/cooldown/necro/high_leap/Destroy()
	if(!QDELETED(loop))
		QDEL_NULL(loop)
	.=..()

/datum/action/cooldown/necro/high_leap/Activate(atom/target)
	var/distance = get_dist(owner, target)
	if(distance < min_range)
		return
	target = get_turf(target)
	owner.setDir(get_dir(owner, target))

	var/travel_time = distance * travel_speed
	StartCooldown(winddown_time+winddown_time+travel_time+launch_time+land_time+1)
	block_movement = TRUE
	RegisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE, .proc/owner_move)

	windup_animation()

	cached_density = owner.density
	cached_passflags = owner.pass_flags
	owner.density = FALSE
	//The only things we should really care about are walls and windows
	owner.pass_flags |= (PASSTABLE|PASSBLOB|PASSMOB|PASSMACHINE|PASSSTRUCTURE|PASSVEHICLE|PASSITEM)

	launch_animation()
	sleep(launch_time)

	started_at = get_turf(owner)
	tiles_moved = 0
	loop = SSmove_manager.home_onto(owner, target, delay = travel_speed, timeout = travel_time, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, .proc/pre_move)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, .proc/post_move)
	RegisterSignal(loop, COMSIG_PARENT_QDELETING, .proc/land)
	RegisterSignal(owner, COMSIG_MOVABLE_BUMP, .proc/on_bump)

/datum/action/cooldown/necro/high_leap/proc/owner_move()
	SIGNAL_HANDLER
	if(block_movement)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/action/cooldown/necro/high_leap/proc/pre_move()
	SIGNAL_HANDLER
	block_movement = FALSE

/datum/action/cooldown/necro/high_leap/proc/post_move()
	SIGNAL_HANDLER
	block_movement = TRUE
	tiles_moved += 1

/datum/action/cooldown/necro/high_leap/proc/on_bump(datum/source, atom/obstacle)
	SIGNAL_HANDLER
	obstacle.shake_animation(8)
	var/mob/living/holder = owner
	var/selfdamage = 15 + 2*tiles_moved
	selfdamage = min(holder.maxHealth*0.15, selfdamage)
	holder.take_overall_damage(selfdamage)
	//We just smashed into a wall, window or something like that, perhaps stun should be even longer
	holder.Stun(5 SECONDS)
	qdel(loop)

/datum/action/cooldown/necro/high_leap/proc/windup_animation()
	var/matrix/M = matrix()
	M = M.Scale(1, 0.8)	//Squish vertically
	animate(owner, transform = M, time = windup_time * 0.667, pixel_y = owner.pixel_y-16, easing = QUAD_EASING)
	sleep(windup_time*0.667)
	M = matrix()
	animate(owner, transform = M, pixel_y = owner.pixel_y+16, time = windup_time * 0.333)
	sleep(windup_time*0.333)

/datum/action/cooldown/necro/high_leap/proc/launch_animation()
	var/matrix/M = matrix()
	M = M.Scale(1.5)
	cached_alpha = owner.alpha
	animate(owner, transform = M,  pixel_y = owner.pixel_y+128, alpha = 0, time = launch_time)

/datum/action/cooldown/necro/high_leap/proc/land()
	loop = null
	land_animation()
	sleep(land_time)

	owner.density = cached_density
	owner.pass_flags = cached_passflags

	winddown()
	//We play a sound!
	var/sound_file = pick(list(
	'modular_skyrat/modules/necromorphs/sound/effects/impacts/hard_impact_1.ogg',
	'modular_skyrat/modules/necromorphs/sound/effects/impacts/hard_impact_2.ogg',
	'modular_skyrat/modules/necromorphs/sound/effects/impacts/low_impact_1.ogg',
	'modular_skyrat/modules/necromorphs/sound/effects/impacts/low_impact_2.ogg'))
	playsound(owner, sound_file, VOLUME_MID, TRUE)

	//The leap impact deals two burst of damage.

	//Firstly, to mobs within 1 tile of us
	new /obj/effect/temp_visual/expanding_circle(owner.loc, 0.5 SECONDS, -0.65)
	for(var/mob/living/L in range(1, owner)-owner)
		shake_camera(L,8,2)

		L.take_overall_damage(10)

	//TODO: Try to get rid of this vector
	var/vector2/direction = Vector2.DirectionBetween(started_at, get_turf(owner))

	new /obj/effect/temp_visual/forceblast(owner.loc, 0.65 SECONDS, direction.Angle(), 4, "#EE0000")
	spawn(1.5)
		new /obj/effect/temp_visual/forceblast(owner.loc, 0.65 SECONDS, direction.Angle(), 4, "#EE0000")
	spawn(3)
		new /obj/effect/temp_visual/forceblast(owner.loc, 0.65 SECONDS, direction.Angle(), 4, "#EE0000")

	for(var/turf/T as anything in get_cone(owner.loc, direction, 3, 80))
		for(var/mob/living/L in T)
			if(L == owner)
				continue

			L.take_overall_damage(15)
//TODO: implement this:
//			L.Weaken(LEAP_CONE_WEAKEN)
//			set_extension(owner, /datum/extension/tripod_leap_defense)
			shake_camera(L,10,3)

	release_vector(direction)

/datum/action/cooldown/necro/high_leap/proc/land_animation()
	var/matrix/M = matrix()
	animate(owner, transform = M, pixel_y = -128, alpha = cached_alpha, time = land_time, flags = ANIMATION_RELATIVE)

/datum/action/cooldown/necro/high_leap/proc/winddown()
	winddown_animation()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_BUMP))
	StartCooldown()

/datum/action/cooldown/necro/high_leap/proc/winddown_animation()
	var/matrix/M = matrix()
	M = M.Scale(1, 0.8)	//Squish vertically
	animate(owner, transform = M, pixel_y = owner.pixel_y-16, time = winddown_time * 0.333, easing = QUAD_EASING)
	sleep(winddown_time * 0.333)
	M = matrix()
	animate(owner, transform = M, pixel_y = owner.pixel_y+16, time = winddown_time * 0.667)
