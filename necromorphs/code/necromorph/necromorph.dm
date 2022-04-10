/mob/living/human/necromorph/can_use_marker()
	if(stat & DEAD)
		return FALSE
	return TRUE

/mob/living/human/necromorph/Initialize(mapload)
	. = ..()
	GLOB.markernet.cameras += src
	GLOB.markernet.addCamera(src)

	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/update_visibility)

/mob/living/human/necromorph/Destroy()
	. = ..()
	GLOB.markernet.cameras -= src
	GLOB.markernet.removeCamera(src)

	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

/mob/living/human/necromorph/proc/update_visibility()
	GLOB.markernet.updateVisibility(src, 0)

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
