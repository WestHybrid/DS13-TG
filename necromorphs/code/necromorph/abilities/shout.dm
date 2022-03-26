/datum/action/cooldown/necro/shout
	name = "Shout"
	desc = "Lay a cluster of eggs, which will soon grow into a normal spider."
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_demon"
	button_icon_state = "lay_eggs"
	cooldown_time = 8 SECONDS
	shared_cooldown = "necro_shout"
	var/sound_type = SOUND_SHOUT
	var/shake_strength = 5
	var/shake_strength_multiplier = 0.3
	var/shake_duration = 7
	var/shake_duration_multiplier = 0.5
	var/do_stun = FALSE
	var/block_movement = FALSE

/datum/action/cooldown/necro/shout/Activate()
	.=..()
	var/mob/living/holder = owner
	if(holder.play_species_audio(holder, sound_type, VOLUME_HIGH, 1, 2))
		if(do_stun)
			block_movement = TRUE
			RegisterSignal(holder, COMSIG_MOVABLE_PRE_MOVE, .proc/pre_move)
			addtimer(CALLBACK(src, .proc/EndStun), shake_duration*0.35 SECONDS)
		holder.shake_animation(40)
		new /obj/effect/temp_visual/expanding_circle(holder.loc, 3 SECONDS, 2)	//Visual effect
		for(var/mob/mob in range(8, holder))
			var/distance = get_dist(holder, mob)
			var/strength = shake_strength - (distance * shake_strength_multiplier)
			var/duration = (shake_duration - (distance * shake_duration_multiplier)) SECONDS
			if(holder.is_necromorph()) //Less camera shake for necromorphs
				strength *= 0.35
				duration *= 0.35
			shake_camera(mob, duration, strength)
			//TODO in future: Add psychosis damage here for non-necros who hear the scream

/datum/action/cooldown/necro/shout/proc/pre_move()
	SIGNAL_HANDLER
	if(block_movement)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/action/cooldown/necro/shout/proc/EndStun()
	block_movement = FALSE
	UnregisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE)

/datum/action/cooldown/necro/shout/CooldownEnd()
	EndStun() //Ensure we remove movement block

/datum/action/cooldown/necro/shout/long
	name = "Scream"
	desc = "Lay a cluster of eggs, which will soon grow into a normal spider."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "lay_eggs"
	sound_type = SOUND_SHOUT_LONG
	cooldown_time = 11 SECONDS
	do_stun = TRUE
