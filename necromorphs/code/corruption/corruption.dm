/obj/structure/corruption
	name = "necromorph sturcture"
	desc = "There is something scary in it."
	icon = 'necromorphs/icons/effects/corruption.dmi'
	smoothing_flags = SMOOTH_CORNERS|SMOOTH_BITMASK
	anchored = TRUE
	max_integrity = 1
	resistance_flags = UNACIDABLE
	obj_flags = CAN_BE_HIT
	/// Node that keeps us alive
	var/obj/structure/corruption/node/master
	/// List of corruption near us
	var/list/nearby_corruption = list()

/obj/structure/corruption/Initialize(mapload)
	.=..()
	for(var/direction in GLOB.cardinals)
		nearby_corruption |= locate(/obj/structure/corruption) in get_step(src, direction)

	//Nodes set master to themself before
	if(!master)
		for(var/obj/structure/corruption/corruption as anything in nearby_corruption)
			if(corruption.master?.remaining_weed_amount && IN_GIVEN_RANGE(src, corruption.master, corruption.master.control_range))
				//Perhaps I should register for COMSIG_PARENT_QDELETING
				//For now we assume update() will clean it up the same tick
				master = corruption.master
				master.remaining_weed_amount--
			corruption.nearby_corruption |= src

		if(!master)
			SScorruption_decay.decaying += src

/obj/structure/corruption/proc/update(update_nearby = TRUE)

/obj/structure/corruption/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			if(damage_amount)
				playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/corruption/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE)
		switch(damage_type)
			if(BRUTE)
				damage_amount *= 0.25
			if(BURN)
				damage_amount *= 2
	. = ..()
