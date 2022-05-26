/obj/item/marker_shard

/mob/living/silicon/marker/Initialize(mapload)
	. = ..()

	SSnecromorph.marker = src

	ADD_TRAIT(src, TRAIT_NO_TELEPORT, AI_ANCHOR_TRAIT)
	status_flags &= ~CANPUSH //Marker starts anchored, so dont push it

	create_eye()
	marker_status_ui = new(src)
	marker_status_ui.update_marker_location()

	GLOB.markernet.cameras += src
	GLOB.markernet.addCamera(src)

	ADD_TRAIT(src, TRAIT_PULL_BLOCKED, ROUNDSTART_TRAIT)
	ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, ROUNDSTART_TRAIT)

	for(var/datum/necro_class/class as anything in subtypesof(/datum/necro_class))
		necro_classes[class] = new class()

/mob/living/silicon/marker/Destroy()
	. = ..()

	qdel(marker_status_ui)
	marker_status_ui = null
	GLOB.markernet.cameras -= src
	GLOB.markernet.removeCamera(src)

/mob/living/silicon/marker/proc/camera_visibility(mob/camera/marker/moved_eye)
	GLOB.markernet.visibility(moved_eye, client, all_eyes, TRUE)

/mob/living/silicon/marker/forceMove(atom/destination)
	. = ..()
//	if(.)
//		end_multicam()
