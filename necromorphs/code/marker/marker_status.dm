/datum/marker_status
	var/name = "Marker Status"

	// Data to pass when rendering the UI (not static)
	var/total_necros
	var/list/necro_counts
	var/list/necro_vitals
	var/list/necro_keys
	var/list/necro_info
	var/marker_location

	var/data_initialized = FALSE

	var/mob/living/silicon/marker/assoc_marker = null

/datum/marker_status/New(mob/living/silicon/marker/M)
	assoc_marker = M
	update_all_data()
	START_PROCESSING(SSprocessing, src)

/datum/marker_status/process()
	update_necro_vitals()
	update_necro_info(FALSE)
	SStgui.update_uis(src)

// Updates the list tracking how many necros there are in each tier, and how many there are in total
/datum/marker_status/proc/update_necro_counts(send_update = TRUE)
	necro_counts = assoc_marker.get_necro_counts()

	total_necros = 0
	for(var/counts in necro_counts)
		for(var/caste in counts)
			total_necros += counts[caste]

	if(send_update)
		SStgui.update_uis(src)


// Updates the marker location using the area name of the defined marker location turf
/datum/marker_status/proc/update_marker_location(send_update = TRUE)
	if(!assoc_marker)
		return

	marker_location = get_area_name(assoc_marker)

	if(send_update)
		SStgui.update_uis(src)

// Updates the sorted list of all necros that we use as a key for all other information
/datum/marker_status/proc/update_necro_keys(send_update = TRUE)
	necro_keys = assoc_marker.get_necro_keys()

	if(send_update)
		SStgui.update_uis(src)

// Mildly related to the above, but only for when necros are removed from the marker
// If a necro dies, we don't have to regenerate all necro info and sort it again, just remove them from the data list
/datum/marker_status/proc/necro_removed(mob/living/carbon/necromorph/N)
	if(!necro_keys)
		return

	for(var/index in 1 to length(necro_keys))
		var/list/info = necro_keys[index]
		if(info["nicknumber"] == N.nicknumber)

			// tried Remove(), didn't work. *shrug*
			necro_keys[index] = null
			necro_keys -= null
			return

	SStgui.update_uis(src)

// Updates the list of necro names, strains and references
/datum/marker_status/proc/update_necro_info(send_update = TRUE)
	necro_info = assoc_marker.get_necro_info()

	if(send_update)
		SStgui.update_uis(src)

// Updates vital information about necros such as health and location. Only info that should be updated regularly
/datum/marker_status/proc/update_necro_vitals()
	necro_vitals = assoc_marker.get_necro_vitals()

// Updates all data except pooled larva
/datum/marker_status/proc/update_all_necro_data(send_update = TRUE)
	update_necro_counts(FALSE)
	update_necro_vitals()
	update_necro_keys(FALSE)
	update_necro_info(FALSE)

	if(send_update)
		SStgui.update_uis(src)

// Updates all data
/datum/marker_status/proc/update_all_data()
	data_initialized = TRUE
	update_all_necro_data(FALSE)
	SStgui.update_uis(src)

/datum/marker_status/ui_state(mob/user)
	return GLOB.always_state

/datum/marker_status/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(isobserver(user))
		return UI_INTERACTIVE

/datum/marker_status/ui_data(mob/user)
	. = list()
	.["total_necros"] = total_necros
	.["necro_counts"] = necro_counts
	.["necro_keys"] = necro_keys
	.["necro_info"] = necro_info
	.["necro_vitals"] = necro_vitals
	.["marker_location"] = marker_location

/datum/marker_status/ui_static_data(mob/user)
	. = list()
	.["user_ref"] = REF(user)
	.["marker_color"] = assoc_marker.ui_color
	.["marker_name"] = assoc_marker.name

/datum/marker_status/proc/open_marker_status(var/mob/user)
	if(!user)
		return

	// Update absolutely all data
	if(!data_initialized)
		update_all_data()

	ui_interact(user)

/datum/marker_status/ui_interact(mob/user, datum/tgui/ui)
	if(!assoc_marker)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "MarkerStatus", "[assoc_marker.name] Status")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/marker_status/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("reconstruct")
			var/mob/living/carbon/necromorph/necroTarget = locate(params["target_ref"]) in GLOB.living_necro_list
			var/mob/living/carbon/necromorph/necroSrc = ui.user

			if(QDELETED(necroTarget) || necroTarget.stat == DEAD)
				return

			if(necroSrc.stat == DEAD)
				return

			//TO DO

		if("rebuild")
			var/mob/living/carbon/necromorph/necroTarget = locate(params["target_ref"]) in GLOB.living_necro_list
			var/mob/living/carbon/necromorph/necroSrc = ui.user

			if(QDELETED(necroTarget) || necroTarget.stat == DEAD)
				return

			if(necroSrc.stat == DEAD)
				return

			//TO DO

		if("watch")
			var/mob/living/carbon/necromorph/necroTarget = locate(params["target_ref"]) in GLOB.living_necro_list
			var/mob/living/carbon/necromorph/necroSrc = ui.user

			if(QDELETED(necroTarget) || necroTarget.stat == DEAD)
				return

			if(necroSrc.stat == DEAD)
				if(isobserver(necroSrc))
					var/mob/dead/observer/O = necroSrc
					O.ManualFollow(necroTarget)
				return
