/datum/action/cooldown/necro/dodge
	name = "Dodge"
	cooldown_time = 5 SECONDS
	shared_cooldown = "necro_charge"
	var/movement_delay = 1.25

/datum/action/cooldown/necro/dodge/New(Target, cooldown, range, move_delay)
	if(movement_delay)
		movement_delay = move_delay
	.=..()

/datum/action/cooldown/necro/dodge/Activate()
	.=..()
	var/list/possible_turfs = RANGE_TURFS(1, owner)
	possible_turfs -= get_turf(owner)
	possible_turfs -= get_step(owner, owner.dir)
	possible_turfs -= get_step(owner, DIRFLIP(owner.dir))

	var/turf/target
	while(possible_turfs.len) //Using while() instead of for() to ensure target turf is randomised
		target = pick(possible_turfs)
		if(!target.is_blocked_turf())
			break
		possible_turfs -= target
		target = null
	if(target)
		owner.set_dir_on_move = FALSE
		step_towards(owner, target, movement_delay)
		owner.set_dir_on_move = TRUE
		//Randomly selected sound
		var/sound_type = pickweight(list(SOUND_SPEECH = 6, SOUND_ATTACK  = 2, SOUND_PAIN = 1.5, SOUND_SHOUT = 1))
		owner.play_species_audio(owner, sound_type, VOLUME_QUIET, 1, -1)
	else
		owner.balloon_alert(owner, "Couldn't find valid dodge location!")
