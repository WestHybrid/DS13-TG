/mob/living/carbon/necromorph/proc/hivemind_talk(message)
	if(!message || stat)
		return
	if(!marker)
		to_chat(src, span_warning("There is no connection between you and the Marker!"))
		return

	message = "<span class='necromorph'>[name] roars, '[message]'</span>"

	log_talk(message, LOG_NECRO)

	marker.hive_mind_message(src, message)

	return TRUE

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

	name = "[initial(class.display_name)] ([nicknumber])"
	real_name = name
	update_name()

	marker?.marker_status_ui.update_necro_info()

/mob/living/carbon/necromorph/proc/update_visibility()
	GLOB.markernet.updateVisibility(src, 0)
