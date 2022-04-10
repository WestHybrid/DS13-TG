/obj/item/marker_shard

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

/mob/living/silicon/marker/Initialize(mapload)
	. = ..()

	ADD_TRAIT(src, TRAIT_NO_TELEPORT, AI_ANCHOR_TRAIT)
	status_flags &= ~CANPUSH //AI starts anchored, so dont push it

	create_eye()

	GLOB.markernet.cameras += src
	GLOB.markernet.addCamera(src)

	ADD_TRAIT(src, TRAIT_PULL_BLOCKED, ROUNDSTART_TRAIT)
	ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, ROUNDSTART_TRAIT)

/mob/living/silicon/marker/Destroy()
	. = ..()
	GLOB.markernet.cameras -= src
	GLOB.markernet.removeCamera(src)

/mob/living/silicon/marker/proc/camera_visibility(mob/camera/marker/moved_eye)
	GLOB.markernet.visibility(moved_eye, client, all_eyes, TRUE)

/mob/living/silicon/marker/forceMove(atom/destination)
	. = ..()
	if(.)
		//end_multicam()
