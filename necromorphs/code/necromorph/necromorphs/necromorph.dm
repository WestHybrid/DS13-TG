/mob/living/carbon/necromorph/Initialize(mapload, marker_master)
	create_bodyparts()
	prepare_huds() //Prevents a nasty runtime on necro init
	create_internal_organs()
	ADD_TRAIT(src, TRAIT_IS_NECROMORPH, NECROMORPH_TRAIT)
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

		for(var/trait in marker.necro_classes[class].traits)
			ADD_TRAIT(src, trait, NECROMORPH_TRAIT)

		for(var/datum/action/action_datum as anything in marker.necro_classes[class].actions)
			action_datum = new action_datum(src)
			action_datum.Grant(src)

		melee_damage_upper = marker.necro_classes[class].melee_damage_upper

		melee_damage_lower = marker.necro_classes[class].melee_damage_lower

		maxHealth = marker.necro_classes[class].max_health

		conscious_see_in_dark = marker.necro_classes[class].conscious_see_in_dark

		unconscious_see_in_dark = marker.necro_classes[class].unconscious_see_in_dark

		necro_flags = marker.necro_classes[class].necro_flags

		fire_resist =  marker.necro_classes[class].fire_resist

		vent_enter_speed = marker.necro_classes[class].vent_enter_speed

		vent_exit_speed = marker.necro_classes[class].vent_exit_speed

		silent_vent_crawl = marker.necro_classes[class].silent_vent_crawl

	else
		// initial() doesn't work with lists so we create a temp datum to get them
		var/datum/necro_class/temp = new class()
		for(var/trait in temp.traits)
			ADD_TRAIT(src, trait, NECROMORPH_TRAIT)

		for(var/datum/action/action_datum as anything in temp.actions)
			action_datum = new action_datum(src)
			action_datum.Grant(src)

		QDEL_NULL(temp)
		// initial() is faster so lets use it for everything else

		melee_damage_upper = initial(class.melee_damage_upper)

		melee_damage_lower = initial(class.melee_damage_lower)

		maxHealth = initial(class.max_health)

		conscious_see_in_dark = initial(class.conscious_see_in_dark)

		unconscious_see_in_dark = initial(class.unconscious_see_in_dark)

		necro_flags = initial(class.necro_flags)

		fire_resist = initial(class.fire_resist)

		vent_enter_speed = initial(class.vent_enter_speed)

		vent_exit_speed = initial(class.vent_exit_speed)

		silent_vent_crawl = initial(class.silent_vent_crawl)

	AddComponent(src, /datum/component/necro_health_meter)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/update_visibility)

/mob/living/carbon/necromorph/create_internal_organs()
	internal_organs += new /obj/item/organ/eyes
	internal_organs += new /obj/item/organ/ears
	internal_organs += new /obj/item/organ/tongue
	.=..()

/mob/living/carbon/necromorph/revive(full_heal = FALSE, admin_revive = FALSE, excess_healing = 0)
	.=..(full_heal, admin_revive, excess_healing)
	marker.add_necro(src)

/mob/living/carbon/necromorph/update_stat()
	. = ..()
	if(.)
		return

	if(status_flags & GODMODE)
		return

	if(stat == DEAD)
		return

	if(health <= 0)
		death()
		return

	if(HAS_TRAIT(src, TRAIT_KNOCKEDOUT))
		if(stat == UNCONSCIOUS)
			return
		set_stat(UNCONSCIOUS)
	else if(stat == UNCONSCIOUS)
		set_stat(CONSCIOUS)

/mob/living/carbon/necromorph/set_stat(new_stat)
	.=..()
	if(stat < UNCONSCIOUS)
		see_in_dark = conscious_see_in_dark
	else
		see_in_dark = unconscious_see_in_dark

/mob/living/carbon/necromorph/death()
	if(stat == DEAD)
		return

	.=..()

	GLOB.living_necro_list -= src
	marker?.remove_necro(src)

/mob/living/carbon/necromorph/Destroy()
	.=..()
	GLOB.markernet.cameras -= src
	GLOB.markernet.removeCamera(src)
	GLOB.living_necro_list -= src
	GLOB.necro_mob_list -= src

	if(marker)
		marker.remove_necro(src)

	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

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

// VENTCRAWLING
// Handles the entrance and exit on ventcrawling
// Copy paste of the /mob/living/proc/handle_ventcrawl()
// I've changed do_after() time and remove var/required_nudity
/mob/living/carbon/necromorph/handle_ventcrawl(obj/machinery/atmospherics/components/ventcrawl_target)
	// Cache the vent_movement bitflag var from atmos machineries
	var/vent_movement = ventcrawl_target.vent_movement

	if(!Adjacent(ventcrawl_target))
		return
	if(!HAS_TRAIT(src, TRAIT_VENTCRAWLER_NUDE) && !HAS_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS))
		return
	if(stat)
		to_chat(src, span_warning("You must be conscious to do this!"))
		return
	if(HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		to_chat(src, span_warning("You currently can't move into the vent!"))
		return
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		to_chat(src, span_warning("You need to be able to use your hands to ventcrawl!"))
		return
	if(has_buckled_mobs())
		to_chat(src, span_warning("You can't vent crawl with other creatures on you!"))
		return
	if(buckled)
		to_chat(src, span_warning("You can't vent crawl while buckled!"))
		return
	if(ventcrawl_target.welded)
		to_chat(src, span_warning("You can't crawl around a welded vent!"))
		return

	if(vent_movement & VENTCRAWL_ENTRANCE_ALLOWED)
		//Handle the exit here
		if(HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING) && istype(loc, /obj/machinery/atmospherics) && movement_type & VENTCRAWLING)
			visible_message(span_notice("[src] begins climbing out from the ventilation system...") ,span_notice("You begin climbing out from the ventilation system..."))
			if(!client)
				return
			if(!do_after(src, vent_exit_speed, target = ventcrawl_target.loc))
				return
			visible_message(span_notice("[src] scrambles out from the ventilation ducts!"),span_notice("You scramble out from the ventilation ducts."))
			forceMove(ventcrawl_target.loc)
			REMOVE_TRAIT(src, TRAIT_MOVE_VENTCRAWLING, VENTCRAWLING_TRAIT)
			update_pipe_vision()

		//Entrance here
		else
			var/datum/pipeline/vent_parent = ventcrawl_target.parents[1]
			if(vent_parent && (vent_parent.members.len || vent_parent.other_atmos_machines))
				flick_overlay_static(image('icons/effects/vent_indicator.dmi', "arrow", ABOVE_MOB_LAYER, dir = get_dir(src.loc, ventcrawl_target.loc)), ventcrawl_target, 2 SECONDS)
				visible_message(span_notice("[src] begins climbing into the ventilation system...") ,span_notice("You begin climbing into the ventilation system..."))
				if(!client)
					return
				if(!do_after(src, vent_enter_speed, target = ventcrawl_target))
					return
				flick_overlay_static(image('icons/effects/vent_indicator.dmi', "insert", ABOVE_MOB_LAYER), ventcrawl_target, 1 SECONDS)
				visible_message(span_notice("[src] scrambles into the ventilation ducts!"),span_notice("You climb into the ventilation ducts."))
				move_into_vent(ventcrawl_target)
			else
				to_chat(src, span_warning("This ventilation duct is not connected to anything!"))
