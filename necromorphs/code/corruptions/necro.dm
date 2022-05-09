
/*
* structure/necromorph
*/
/obj/structure/necromorph
	name = "necromorph thing"
	desc = "theres something necromorph about this"
	icon = 'necromorphs/icons/effects/corruption.dmi'
	anchored = TRUE
	max_integrity = 1
	resistance_flags = UNACIDABLE
	obj_flags = CAN_BE_HIT
	var/on_fire = FALSE
	///Set this to true if this object isn't destroyed when the weeds under it is.
	var/ignore_weed_destruction = FALSE

/obj/structure/necromorph/Initialize()
	. = ..()
	if(!ignore_weed_destruction)
		RegisterSignal(loc, COMSIG_TURF_WEED_REMOVED, .proc/weed_removed)
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_cross,
	)
	AddElement(/datum/element/connect_loc, connections)

/// Destroy the necromorph effect when the weed it was on is destroyed
/obj/structure/necromorph/proc/weed_removed()
	SIGNAL_HANDLER
	atom_destruction(MELEE)

/obj/structure/necromorph/proc/on_cross(datum/source, atom/movable/O, oldloc, oldlocs)
	SIGNAL_HANDLER

/obj/structure/necromorph/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			if(damage_amount)
				playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/necromorph/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE)
		switch(damage_type)
			if(BRUTE)
				damage_amount *= 0.25
			if(BURN)
				damage_amount *= 2
	. = ..()
