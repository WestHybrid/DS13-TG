/obj/structure/corruption
	name = ""
	desc = "There is something scary in it."
	icon = 'necromorphs/icons/effects/corruption.dmi'
	icon_state = "corruption-1"
	//smoothing_flags = SMOOTH_BITMASK
	anchored = TRUE
	max_integrity = 15
	//Smallest alpha we can get in on_integrity_change()
	alpha = 20
	resistance_flags = UNACIDABLE
	obj_flags = CAN_BE_HIT
	interaction_flags_atom = NONE
	/// Node that keeps us alive
	var/obj/structure/corruption/node/master
	/// A list of cardinal dirs that don't have corruption
	var/list/turfs_to_spread = list()

/obj/structure/corruption/Initialize(mapload)
	.=..()
	ADD_TRAIT(loc, TRAIT_TURF_NECRO_CORRUPTED, src)
	//We start from 1
	atom_integrity = 1
	for(var/direction in GLOB.cardinals)
		var/turf/T = get_step(src, direction)
		if(T)
			RegisterSignal(T, COMSIG_TURF_CHANGE, .proc/on_turf_change)
			if(!HAS_TRAIT(T, TRAIT_TURF_NECRO_CORRUPTED))
				RegisterSignal(T, SIGNAL_ADDTRAIT(TRAIT_TURF_NECRO_CORRUPTED), .proc/on_nearby_turf_corrupted)
				turfs_to_spread += T
			else
				RegisterSignal(T, SIGNAL_REMOVETRAIT(TRAIT_TURF_NECRO_CORRUPTED), .proc/on_nearby_turf_uncorrupted)

	//I hate that you can't just override update_integrity()
	RegisterSignal(src, COMSIG_ATOM_INTEGRITY_CHANGED, .proc/on_integrity_change)

	//Nodes set master to themself before
	if(!master)
		for(var/obj/structure/corruption/node/node as anything in SScorruption.nodes)
			if(node.remaining_weed_amount && IN_GIVEN_RANGE(src, node, node.control_range))
				master = node
				master.remaining_weed_amount--
				RegisterSignal(master, COMSIG_PARENT_QDELETING, .proc/on_master_delete)
				break

		if(!master)
			SScorruption.decaying += src
			return
	SScorruption.growing += src

/obj/structure/corruption/Destroy()
	SScorruption.growing -= src
	SScorruption.spreading -= src
	SScorruption.decaying -= src
	.=..()

/obj/structure/corruption/proc/on_master_delete(datum/source)
	UnregisterSignal(master, COMSIG_PARENT_QDELETING)
	master = null
	for(var/obj/structure/corruption/node/node as anything in SScorruption.nodes)
		if(node.remaining_weed_amount && IN_GIVEN_RANGE(src, node, node.control_range))
			master = node
			master.remaining_weed_amount--
			RegisterSignal(master, COMSIG_PARENT_QDELETING, .proc/on_master_delete)
			return
	SScorruption.decaying += src

/obj/structure/corruption/proc/spread()
	for(var/turf/T as anything in turfs_to_spread)
		//In case we are in null space/near the map border
		if(T?.Enter(src))
			new /obj/structure/corruption(T)
			turfs_to_spread -= T

/obj/structure/corruption/proc/on_integrity_change(datum/source, old_integrity, new_integrity)
	SIGNAL_HANDLER
	if(master)
		if(old_integrity > new_integrity)
			SScorruption.spreading -= src
			SScorruption.growing |= src
		else if(new_integrity >= max_integrity)
			SScorruption.growing -= src
			if(length(turfs_to_spread))
				SScorruption.spreading |= src
	alpha = clamp(255*new_integrity/max_integrity, 20, 215)

/obj/structure/corruption/proc/on_turf_change(turf/source)
	SIGNAL_HANDLER
	var/direction = get_dir(src, source)
	turfs_to_spread -= source
	UnregisterSignal(source, list(COMSIG_TURF_CHANGE, SIGNAL_ADDTRAIT(TRAIT_TURF_NECRO_CORRUPTED), SIGNAL_REMOVETRAIT(TRAIT_TURF_NECRO_CORRUPTED)))
	source = null
	//Wait for the proc to actually replace the turf
	spawn(0)
		source = get_step(src, direction)
		RegisterSignal(source, COMSIG_TURF_CHANGE, .proc/on_turf_change)
		if(!HAS_TRAIT(source, TRAIT_TURF_NECRO_CORRUPTED))
			RegisterSignal(source, SIGNAL_ADDTRAIT(TRAIT_TURF_NECRO_CORRUPTED), .proc/on_nearby_turf_corrupted)
			turfs_to_spread += source
		else
			RegisterSignal(source, SIGNAL_REMOVETRAIT(TRAIT_TURF_NECRO_CORRUPTED), .proc/on_nearby_turf_uncorrupted)

/obj/structure/corruption/proc/on_nearby_turf_corrupted(turf/source)
	SIGNAL_HANDLER
	turfs_to_spread -= source
	if(!length(turfs_to_spread))
		SScorruption.spreading -= src

/obj/structure/corruption/proc/on_nearby_turf_uncorrupted(turf/source)
	SIGNAL_HANDLER
	turfs_to_spread += source
	if(!length(turfs_to_spread))
		SScorruption.spreading -= src

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
