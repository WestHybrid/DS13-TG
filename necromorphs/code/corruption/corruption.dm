//TODO: Do some refactoring
/obj/structure/corruption
	name = ""
	desc = "There is something scary in it."
	icon = 'necromorphs/icons/effects/corruption.dmi'
	icon_state = "corruption-1"
	//smoothing_flags = SMOOTH_BITMASK
	anchored = TRUE
	max_integrity = 25
	integrity_failure = 5
	//Smallest alpha we can get in on_integrity_change()
	alpha = 20
	resistance_flags = UNACIDABLE
	obj_flags = CAN_BE_HIT
	interaction_flags_atom = NONE
	pass_flags = PASSTABLE|PASSMOB|PASSMACHINE|PASSSTRUCTURE|PASSVEHICLE|PASSITEM
	/// Node that keeps us alive
	var/datum/corruption_node/master
	/// A list of cardinal dirs that don't have corruption
	var/list/turfs_to_spread = list()

/obj/structure/corruption/Initialize(mapload, datum/corruption_node/new_master)
	.=..()

	if(new_master)
		set_master(new_master)
	else
		for(var/datum/corruption_node/node as anything in SScorruption.nodes)
			if(node.remaining_weed_amount && IN_GIVEN_RANGE(src, node.parent, node.control_range))
				set_master(node)
				break
		if(!master)
			return INITIALIZE_HINT_QDEL

	SScorruption.growing += src

	atom_integrity = 3
	RegisterSignal(loc, COMSIG_TURF_CHANGE, .proc/on_source_turf_change)
	ADD_TRAIT(loc, TRAIT_TURF_NECRO_CORRUPTED, src)
	for(var/direction in GLOB.cardinals)
		var/turf/T = get_step(src, direction)
		//In case we are in null space/near the map border
		if(T)
			RegisterSignal(T, COMSIG_TURF_CHANGE, .proc/on_turf_change)
			if(isspaceturf(T) || istype(T, /turf/open/openspace))
				continue
			RegisterSignal(T, COMSIG_ATOM_SET_DENSITY, .proc/on_turf_set_density)
			if(!T.density)
				if(!HAS_TRAIT(T, TRAIT_TURF_NECRO_CORRUPTED))
					RegisterSignal(T, SIGNAL_ADDTRAIT(TRAIT_TURF_NECRO_CORRUPTED), .proc/on_nearby_turf_corrupted)
					turfs_to_spread += T
				else
					RegisterSignal(T, SIGNAL_REMOVETRAIT(TRAIT_TURF_NECRO_CORRUPTED), .proc/on_nearby_turf_uncorrupted)

	//I hate that you can't just override update_integrity()
	RegisterSignal(src, COMSIG_ATOM_INTEGRITY_CHANGED, .proc/on_integrity_change)

/obj/structure/corruption/Destroy()
	REMOVE_TRAIT(loc, TRAIT_TURF_NECRO_CORRUPTED, src)
	if(master)
		master.remaining_weed_amount++
	master = null
	SScorruption.growing -= src
	SScorruption.spreading -= src
	SScorruption.decaying -= src
	.=..()

/obj/structure/corruption/proc/on_master_delete(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(master, COMSIG_PARENT_QDELETING)
	master = null
	for(var/datum/corruption_node/node as anything in SScorruption.nodes)
		if(node.remaining_weed_amount && IN_GIVEN_RANGE(src, node.parent, node.control_range))
			set_master(node)
			return
	SScorruption.decaying += src

/obj/structure/corruption/proc/spread()
	for(var/turf/T as anything in turfs_to_spread)
		if(T.Enter(src))
			for(var/datum/corruption_node/node as anything in SScorruption.nodes)
				if(node.remaining_weed_amount && IN_GIVEN_RANGE(T, node.parent, node.control_range))
					node.remaining_weed_amount--
					new /obj/structure/corruption(T, node)
					turfs_to_spread -= T

/obj/structure/corruption/proc/on_integrity_change(datum/source, old_integrity, new_integrity)
	SIGNAL_HANDLER
	if(master)
		if(old_integrity > new_integrity)
			SScorruption.spreading -= src
			SScorruption.growing |= src
		else if(new_integrity >= max_integrity)
			SScorruption.growing -= src
			SScorruption.spreading |= src
	alpha = clamp(255*new_integrity/max_integrity, 20, 215)

/obj/structure/corruption/proc/on_turf_change(turf/source)
	SIGNAL_HANDLER
	var/direction = get_dir(src, source)
	turfs_to_spread -= source
	source = null
	//Wait for the proc to actually replace the turf
	spawn(0)
		source = get_step(src, direction)
		if(isspaceturf(source) || !istype(source, /turf/open/openspace))
			return
		if(source.density || HAS_TRAIT(source, TRAIT_TURF_NECRO_CORRUPTED))
			return
		turfs_to_spread += source
		if(atom_integrity >= max_integrity)
			SScorruption.spreading |= src

/obj/structure/corruption/proc/on_source_turf_change(turf/source)
	SIGNAL_HANDLER
	source = null
	//Wait for the proc to actually replace the turf
	spawn(0)
		ADD_TRAIT(loc, TRAIT_TURF_NECRO_CORRUPTED, src)

/obj/structure/corruption/proc/on_turf_set_density(turf/source, old_density, new_density)
	SIGNAL_HANDLER
	if(old_density)
		if(!HAS_TRAIT(source, TRAIT_TURF_NECRO_CORRUPTED))
			RegisterSignal(source, SIGNAL_ADDTRAIT(TRAIT_TURF_NECRO_CORRUPTED), .proc/on_nearby_turf_corrupted)
			turfs_to_spread += source
			SScorruption.spreading |= src
		else
			RegisterSignal(source, SIGNAL_REMOVETRAIT(TRAIT_TURF_NECRO_CORRUPTED), .proc/on_nearby_turf_uncorrupted)
	else
		turfs_to_spread -= source
		if(!length(turfs_to_spread))
			SScorruption.spreading -= src
		UnregisterSignal(source, list(SIGNAL_ADDTRAIT(TRAIT_TURF_NECRO_CORRUPTED), SIGNAL_REMOVETRAIT(TRAIT_TURF_NECRO_CORRUPTED)))

/obj/structure/corruption/proc/on_nearby_turf_corrupted(turf/source)
	SIGNAL_HANDLER
	turfs_to_spread -= source
	if(!length(turfs_to_spread))
		SScorruption.spreading -= src

/obj/structure/corruption/proc/on_nearby_turf_uncorrupted(turf/source)
	SIGNAL_HANDLER
	SScorruption.spreading |= src
	turfs_to_spread += source

// Doesn't do any safety checks, make sure to do them first
/obj/structure/corruption/proc/set_master(datum/corruption_node/new_master)
	if(master)
		master.remaining_weed_amount++
		UnregisterSignal(master, COMSIG_PARENT_QDELETING)
	master = new_master
	new_master.remaining_weed_amount++
	RegisterSignal(new_master, COMSIG_PARENT_QDELETING, .proc/on_master_delete)
	SScorruption.decaying -= src

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
