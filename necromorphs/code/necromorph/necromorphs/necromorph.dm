/mob/living/carbon/necromorph/Initialize(mapload, marker_master)
	create_bodyparts()
	prepare_huds() //Prevents a nasty runtime on necro init
	create_internal_organs()
	.=..()
	GLOB.markernet.cameras += src
	GLOB.markernet.addCamera(src)
	GLOB.living_necro_list += src
	GLOB.necro_mob_list += src

	//marker = marker_master
	marker = SSnecromorph.marker // FOR TESTS

	generate_name()

	if(marker)
		marker.add_necro(src)

		if(marker.marker_status_ui)
			marker.marker_status_ui.update_all_necro_data()

	ADD_TRAIT(src, TRAIT_DEFIB_BLACKLISTED, NECROMORPH_TRAIT)
	ADD_TRAIT(src, TRAIT_BADDNA, NECROMORPH_TRAIT)
	ADD_TRAIT(src, TRAIT_GENELESS, NECROMORPH_TRAIT)
	ADD_TRAIT(src, TRAIT_VIRUSIMMUNE, NECROMORPH_TRAIT)
	ADD_TRAIT(src, TRAIT_NOMETABOLISM, NECROMORPH_TRAIT)
	ADD_TRAIT(src, TRAIT_TOXIMMUNE, NECROMORPH_TRAIT)
	ADD_TRAIT(src, TRAIT_EASYDISMEMBER, NECROMORPH_TRAIT)
	ADD_TRAIT(src, TRAIT_NOBREATH, NECROMORPH_TRAIT)
	ADD_TRAIT(src, TRAIT_NOCRITDAMAGE, NECROMORPH_TRAIT)
	ADD_TRAIT(src, TRAIT_FEARLESS, NECROMORPH_TRAIT)
	ADD_TRAIT(src, TRAIT_NO_SOUL, NECROMORPH_TRAIT)
	ADD_TRAIT(src, TRAIT_CANT_RIDE, NECROMORPH_TRAIT)
	ADD_TRAIT(src, TRAIT_CAN_STRIP, NECROMORPH_TRAIT)
	ADD_TRAIT(src, TRAIT_RESISTLOWPRESSURE, NECROMORPH_TRAIT)
	ADD_TRAIT(src, TRAIT_RESISTCOLD, NECROMORPH_TRAIT)

	AddComponent(src, /datum/component/necro_health_meter)

	for(var/datum/action/action_datum as anything in necro_abilities)
		necro_abilities -= action_datum
		necro_abilities += new action_datum(src)
		action_datum.Grant(src)

	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/update_visibility)

/mob/living/carbon/necromorph/create_internal_organs()
	internal_organs += new /obj/item/organ/eyes
	internal_organs += new /obj/item/organ/ears
	internal_organs += new /obj/item/organ/tongue
	.=..()

/mob/living/carbon/necromorph/revive(full_heal = FALSE, admin_revive = FALSE, excess_healing = 0)
	.=..(full_heal, admin_revive, excess_healing)
	marker.add_necro(src)

/mob/living/carbon/necromorph/death()
	if(stat == DEAD)
		return

	.=..()

	GLOB.living_necro_list -= src
	marker.remove_necro(src)

/mob/living/carbon/necromorph/Destroy()
	.=..()
	GLOB.markernet.cameras -= src
	GLOB.markernet.removeCamera(src)
	GLOB.living_necro_list -= src
	GLOB.necro_mob_list -= src

	marker.remove_necro(src)

	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

/mob/living/carbon/necromorph/proc/generate_name()
	//We don't have a nicknumber yet, assign one to stick with us
	if(!nicknumber)
		var/tempnumber = rand(1, 999)
		var/list/numberlist = list()
		for(var/mob/living/carbon/necromorph/N in GLOB.necro_mob_list)
			numberlist += N.nicknumber

		while(tempnumber in numberlist)
			tempnumber = rand(1, 999)

		nicknumber = tempnumber

	name = "[caste_type] ([nicknumber])"
	real_name = name
	update_name()

	marker?.marker_status_ui.update_necro_info()

/mob/living/carbon/necromorph/proc/update_visibility()
	GLOB.markernet.updateVisibility(src, 0)

/mob/living/carbon/necromorph/can_use_marker()
	if(stat & DEAD)
		return FALSE
	return TRUE

/atom/proc/can_use_marker()
	return FALSE

/atom/proc/can_see_marker()
	var/list/see = null
	var/turf/pos = get_turf(src)
	var/view_range = get_view_range()
	see = get_hear(view_range, pos)
	return see

/atom/proc/get_view_range()
	return 7

/mob/living/carbon/necromorph/is_necromorph()
	return TRUE
