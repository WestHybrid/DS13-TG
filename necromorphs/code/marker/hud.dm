/atom/movable/screen/marker
	icon = 'icons/hud/screen_ai.dmi'

/atom/movable/screen/marker/Click()
	if(isobserver(usr) || usr.incapacitated())
		return TRUE

/atom/movable/screen/marker/jump_to_marker
	name = "Marker"
	icon_state = "ai_core"

/atom/movable/screen/marker/jump_to_marker/Click()
	if(..())
		return
	var/mob/living/silicon/marker/M = usr
	M.jump_to_marker()

/atom/movable/screen/marker/marker_status
	name = "Marker Status"
	icon_state = "manifest"

/atom/movable/screen/marker/marker_status/Click()
	if(..())
		return
	var/mob/living/silicon/marker/M = usr
	M.marker_status_ui.ui_interact(M)

/atom/movable/screen/marker/announcement
	name = "Make Vox Announcement"
	icon_state = "announcement"

/atom/movable/screen/marker/announcement/Click()
	if(..())
		return

/datum/hud/ai
	ui_style = 'icons/hud/screen_ai.dmi'

/datum/hud/marker/New(mob/owner)
	..()
	var/atom/movable/screen/using

//Marker core
	using = new /atom/movable/screen/marker/jump_to_marker()
	using.screen_loc = ui_ai_core
	using.hud = src
	static_inventory += using

//Marker Status
	using = new /atom/movable/screen/marker/marker_status()
	using.screen_loc = ui_ai_crew_manifest
	using.hud = src
	static_inventory += using

//Announcement
	using = new /atom/movable/screen/marker/announcement()
	using.screen_loc = ui_ai_announcement
	using.hud = src
	static_inventory += using

