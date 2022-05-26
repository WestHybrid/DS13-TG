
/mob/living/silicon/marker/proc/get_necro_info()
	var/list/necros = list()

	for(var/mob/living/carbon/necromorph/necro in total_necros)
		necros["[necro.nicknumber]"] = list(
			"name" = necro.name,
			"strain" = "", // TO DO BUFFS
			"ref" = "\ref[necro]"
		)

	return necros

/mob/living/silicon/marker/proc/get_necro_vitals()
	var/list/necros = list()

	for(var/mob/living/carbon/necromorph/necro in total_necros)

		if(!(necro in GLOB.living_necro_list))
			continue

		var/area/A = get_area(necro)
		var/area_name = A ? A.name : "Unknown"

		necros["[necro.nicknumber]"] = list(
			"health" = round((necro.health / necro.maxHealth) * 100, 1),
			"area" = area_name,
			"is_ssd" = (!necro.client)
		)

	return necros

/mob/living/silicon/marker/proc/get_necro_counts()
	var/list/necro_counts = list(
		list("Slasher" = 0, "Spitter" = 0, "Lurker" = 0, "Leaper" = 0, "Exploder" = 0),
		list("Puker" = 0, "Divider" = 0, "Twitcher" = 0, "Enhanced Slasher" = 0),
		list("Brute" = 0, "Hunter" = 0, "Tripod" = 0),
		list("Ubermorph" = 0),
	)

	for(var/mob/living/carbon/necromorph/necro in total_necros)
		necro_counts[necro.tier+1][initial(necro.class.display_name)]++

	return necro_counts

/mob/living/silicon/marker/proc/get_necro_keys()
	var/list/necros[total_necros.len]

	var/index = 1
	var/useless_slots = 0
	for(var/mob/living/carbon/necromorph/necro in total_necros)
		// Insert without doing list merging
		necros[index++] = list(
			"nicknumber" = necro.nicknumber,
			"tier" = necro.tier, // This one is only important for sorting
			"is_leader" = "",//(IS_NECRO_LEADER(X)), // TO DO
			"caste_type" = necro.class,
		)

	// Clear nulls from the necros list
	necros.len -= useless_slots

	// Make it all nice and fancy by sorting the list before returning it
	var/list/sorted_keys = sort_necro_keys(necros)
	if(length(sorted_keys))
		return sorted_keys
	return necros

/mob/living/silicon/marker/proc/add_necro(mob/living/carbon/necromorph/necro)
	if(!istype(necro))
		return

	// If the necro is part of another hive, they should be removed from that one first
	if(necro.marker != src)
		necro.marker.remove_necro(necro, TRUE)

	// Already in the hive
	if(necro in total_necros)
		return

	necro.marker = src

	total_necros += necro

/mob/living/silicon/marker/proc/remove_necro(mob/living/carbon/necromorph/necro, hard=FALSE, light_mode = FALSE)
	if(!istype(necro))
		return

	// Make sure the necro was in the marker hive in the first place
	if(!(necro in total_necros))
		return

	// We allow "soft" removals from the hive (the necro still retains information about the hive)
	// This is so that necros can add themselves back to the hive if they should die or otherwise go "on leave" from the hive
	if(hard)
		necro.marker = null

	total_necros -= necro

	if(!light_mode)
		marker_status_ui.update_necro_counts()
		marker_status_ui.necro_removed(necro)

// This sorts the necro info list by multiple criteria. Prioritized in order:
// 1. Leaders
// 2. Tier
// It uses a slightly modified insertion sort to accomplish this
/mob/living/silicon/marker/proc/sort_necro_keys(list/necros)
	if(!length(necros))
		return

	var/list/sorted_list = necros.Copy()

	if(!length(sorted_list))
		return

	for(var/index in 2 to length(sorted_list))
		var/j = index

		while(j > 1)
			var/current = sorted_list[j]
			var/prev = sorted_list[j-1]

			// Leaders before normal necros
			if(!prev["is_leader"] && current["is_leader"])
				sorted_list.Swap(j-1, j)
				j--
				continue

			// Make sure we're only comparing leaders to leaders and non-leaders to non-leaders when sorting
			// This means we get leaders sorted first, then non-leaders sorted
			// Sort by tier first, higher tiers over lower tiers, and then by name alphabetically

			// Could not think of an elegant way to write this
			if(!(current["is_leader"]^prev["is_leader"])\
				&& (prev["tier"] < current["tier"]\
				|| prev["tier"] == current["tier"] && prev["caste_type"] > current["caste_type"]\
			))
				sorted_list.Swap(j-1, j)

			j--

	return sorted_list

/mob/living/silicon/marker/proc/hive_mind_message(mob/living/carbon/necromorph/sender, message)
	for(var/mob/dead/observer/observer as anything in GLOB.current_observers_list)
		if(!observer?.client?.prefs || !(observer.client.prefs.chat_toggles & CHAT_NECROMORPH))
			continue
		observer.show_message("[FOLLOW_LINK(observer, sender)] [message]", 2)

	for(var/mob/living/carbon/necromorph/necro as anything in total_necros)
		necro.show_message(message, 2)

//	for(var/signal/sig as anything in signal_list)
//		sig.show_message("[FOLLOW_LINK(sig, sender)] [message]", 2)
