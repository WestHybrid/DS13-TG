
/mob/living/carbon/human/necromorph/New(marker)
	. = ..()
	M = marker

/mob/living/carbon/human/necromorph/Initialize(mapload)
	. = ..()
	GLOB.markernet.cameras += src
	GLOB.markernet.addCamera(src)
	GLOB.living_necro_list += src
	GLOB.necro_mob_list += src

	M = SSnecromorph.marker // FOR TESTS

	generate_name()

	if(M)
		M.add_necro(src)

		if(M.marker_status_ui)
			M.marker_status_ui.update_all_necro_data()


	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/update_visibility)

/mob/living/carbon/human/necromorph/revive(full_heal = FALSE, admin_revive = FALSE, excess_healing = 0)
	. = ..(full_heal, admin_revive, excess_healing)
	M.add_necro(src)

/mob/living/carbon/human/necromorph/death()
	if(stat == DEAD)
		return

	. = ..()

	GLOB.living_necro_list -= src
	M.remove_necro(src)

/mob/living/carbon/human/necromorph/Destroy()
	. = ..()
	GLOB.markernet.cameras -= src
	GLOB.markernet.removeCamera(src)
	GLOB.living_necro_list -= src
	GLOB.necro_mob_list -= src

	M.remove_necro(src)

	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

/mob/living/carbon/human/necromorph/proc/generate_name()
	//We don't have a nicknumber yet, assign one to stick with us
	if(!nicknumber)
		var/tempnumber = rand(1, 999)
		var/list/numberlist = list()
		for(var/mob/living/carbon/human/necromorph/N in GLOB.necro_mob_list)
			numberlist += N.nicknumber

		while(tempnumber in numberlist)
			tempnumber = rand(1, 999)

		nicknumber = tempnumber

	name = "[caste_type] ([nicknumber])"
	real_name = name
	update_name()

	M.marker_status_ui.update_necro_info()

/mob/living/carbon/human/necromorph/proc/update_visibility()
	GLOB.markernet.updateVisibility(src, 0)

/mob/living/carbon/human/necromorph/can_use_marker()
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
