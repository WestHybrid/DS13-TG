/mob/living/silicon/marker
	name = "Marker"
	real_name = "Marker"
	icon = 'necromorphs/icons/obj/marker_giant.dmi'
	icon_state = "marker_giant_dormant"
	pixel_x = -33

	move_resist = MOVE_FORCE_OVERPOWERING
	density = TRUE
	status_flags = CANSTUN|CANPUSH
	combat_mode = TRUE //so we always get pushed instead of trying to swap
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS
	see_in_dark = 8
	can_buckle_to = FALSE
	native_fov = null

	hud_type = /datum/hud/marker

	var/obj/machinery/camera/current
	var/tracking = FALSE //this is 1 if the marker is currently tracking somebody, but the track has not yet been completed.

	var/mob/living/silicon/marker/parent
	var/list/obj/machinery/camera/lit_cameras = list()

	var/mob/camera/marker/eyeobj
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1

	var/list/all_eyes = list()
	var/display_icon_override

	var/invested_biomass
	var/unavailable_biomass

	var/datum/marker_status/marker_status_ui
	var/ui_color = null
	var/static/markernumber = 0
	var/list/total_necros = list()
