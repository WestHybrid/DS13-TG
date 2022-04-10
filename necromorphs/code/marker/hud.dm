/atom/movable/screen/marker
	icon = 'icons/hud/screen_ai.dmi'

/atom/movable/screen/marker/Click()
	if(isobserver(usr) || usr.incapacitated())
		return TRUE

/atom/movable/screen/marker/aicore
	name = "Marker"
	icon_state = "ai_core"

/atom/movable/screen/marker/aicore/Click()
	if(..())
		return
	var/mob/living/silicon/marker/M = usr
	M.view_core()

/atom/movable/screen/marker/crew_manifest
	name = "Crew Manifest"
	icon_state = "manifest"

/atom/movable/screen/marker/crew_manifest/Click()
	if(..())
		return

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
	using = new /atom/movable/screen/marker/aicore()
	using.screen_loc = ui_ai_core
	using.hud = src
	static_inventory += using

//Crew Manifest
	using = new /atom/movable/screen/marker/crew_manifest()
	using.screen_loc = ui_ai_crew_manifest
	using.hud = src
	static_inventory += using

//Announcement
	using = new /atom/movable/screen/marker/announcement()
	using.screen_loc = ui_ai_announcement
	using.hud = src
	static_inventory += using

