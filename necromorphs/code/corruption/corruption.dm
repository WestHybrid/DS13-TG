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
	var/list/non_corrupted_dirs = list()

/obj/structure/corruption/Initialize(mapload)
	.=..()
	//We start from 1
	atom_integrity = 1
	for(var/direction in GLOB.cardinals)
		if(!(locate(/obj/structure/corruption) in get_step(src, direction)))
			non_corrupted_dirs += direction

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

	//I hate that you can't just override update_integrity()
	RegisterSignal(src, COMSIG_ATOM_INTEGRITY_CHANGED, .proc/on_integrity_change)

/obj/structure/corruption/Destroy()
	SScorruption.growing -= src
	SScorruption.spreading -= src
	SScorruption.decaying -= src
	.=..()

/obj/structure/corruption/proc/on_master_delete(datum/source)
	UnregisterSignal(master, COMSIG_PARENT_QDELETING)
	master = null
	for(var/obj/structure/corruption/node/node as anything in SScorruption.nodes[z])
		if(node.remaining_weed_amount && IN_GIVEN_RANGE(src, node, node.control_range))
			master = node
			master.remaining_weed_amount--
			RegisterSignal(master, COMSIG_PARENT_QDELETING, .proc/on_master_delete)
			break

/obj/structure/corruption/proc/spread()
	var/turf/T
	for(var/direction in non_corrupted_dirs)
		T = get_step(src, direction)
		//In case we are in null space/near the map border
		if(T?.Enter(src))
			new /obj/structure/corruption(T)
	non_corrupted_dirs.Cut()

/obj/structure/corruption/proc/on_integrity_change(datum/source, old_integrity, new_integrity)
	if(master)
		if(old_integrity > new_integrity)
			SScorruption.spreading -= src
			SScorruption.growing |= src
		else if(new_integrity >= max_integrity)
			SScorruption.growing -= src
			if(length(non_corrupted_dirs))
				SScorruption.spreading |= src
	alpha = clamp(255*new_integrity/max_integrity, 20, 215)

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
