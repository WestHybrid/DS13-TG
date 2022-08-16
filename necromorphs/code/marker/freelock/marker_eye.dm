/mob/camera/marker
	name = "Marker"
	hud_possible = list(ANTAG_HUD, AI_DETECT_HUD = HUD_LIST_LIST)
	invisibility = INVISIBILITY_MAXIMUM

	var/list/visibleCameraChunks = list()
	var/mob/living/silicon/marker/marker = null
	var/use_static = TRUE
	var/static_visibility_range = 16
	var/marker_detector_visible = TRUE
	var/marker_detector_color = COLOR_RED
	interaction_range = null

/mob/camera/marker/Initialize(mapload)
	. = ..()
	update_marker_detect_hud()
	setLoc(loc, TRUE)

/mob/camera/marker/examine(mob/user) //Displays a silicon's laws to ghosts
	. = ..()

/mob/camera/marker/proc/update_marker_detect_hud()
	var/datum/atom_hud/ai_detector/hud = GLOB.huds[DATA_HUD_AI_DETECT]
	var/list/old_images = hud_list[AI_DETECT_HUD]
	if(!marker_detector_visible)
		hud.remove_atom_from_hud(src)
		QDEL_LIST(old_images)
		return

	if(!length(hud.hud_users))
		return //no one is watching, do not bother updating anything

	hud.remove_atom_from_hud(src)

	var/static/list/vis_contents_opaque = list()
	var/obj/effect/overlay/ai_detect_hud/hud_obj = vis_contents_opaque[marker_detector_color]
	if(!hud_obj)
		hud_obj = new /obj/effect/overlay/ai_detect_hud()
		hud_obj.color = marker_detector_color
		vis_contents_opaque[marker_detector_color] = hud_obj

	var/list/new_images = list()
	var/list/turfs = get_visible_turfs()
	for(var/T in turfs)
		var/image/I = (old_images.len > new_images.len) ? old_images[new_images.len + 1] : image(null, T)
		I.loc = T
		I.vis_contents += hud_obj
		new_images += I
	for(var/i in (new_images.len + 1) to old_images.len)
		qdel(old_images[i])
	hud_list[AI_DETECT_HUD] = new_images
	hud.add_atom_to_hud(src)

/mob/camera/marker/proc/get_visible_turfs()
	if(!isturf(loc))
		return list()
	var/client/C = GetViewerClient()
	var/view = C ? getviewsize(C.view) : getviewsize(world.view)
	var/turf/lowerleft = locate(max(1, x - (view[1] - 1)/2), max(1, y - (view[2] - 1)/2), z)
	var/turf/upperright = locate(min(world.maxx, lowerleft.x + (view[1] - 1)), min(world.maxy, lowerleft.y + (view[2] - 1)), lowerleft.z)
	return block(lowerleft, upperright)

// Use this when setting the aiEye's location.
// It will also stream the chunk that the new loc is in.

/mob/camera/marker/proc/setLoc(destination, force_update = FALSE)
	if(marker)
		if(!isturf(marker.loc))
			return
		destination = get_turf(destination)
		if(!force_update && (destination == get_turf(src)) )
			return //we are already here!
		if (destination)
			abstract_move(destination)
		else
			moveToNullspace()
		if(use_static)
			marker.camera_visibility(src)
		if(marker.client)
			marker.client.eye = src
		update_marker_detect_hud()
		update_parallax_contents()
		//Holopad
		if(istype(marker.current, /obj/machinery/holopad))
			var/obj/machinery/holopad/H = marker.current
			H.move_hologram(marker, destination)

/mob/camera/marker/zMove(dir, turf/target, z_move_flags = NONE, recursions_left = 1, list/falling_movs)
	. = ..()
	if(.)
		setLoc(loc, force_update = TRUE)

/mob/camera/marker/Move()
	return

/mob/camera/marker/proc/GetViewerClient()
	if(marker)
		return marker.client
	return null

/mob/camera/marker/Destroy()
	if(marker)
		marker.all_eyes -= src
		marker = null
	for(var/V in visibleCameraChunks)
		var/datum/markerchunk/c = V
		c.remove(src)
	GLOB.aiEyes -= src
	if(marker_detector_visible)
		var/datum/atom_hud/ai_detector/hud = GLOB.huds[DATA_HUD_AI_DETECT]
		hud.remove_atom_from_hud(src)
		var/list/L = hud_list[AI_DETECT_HUD]
		QDEL_LIST(L)
	return ..()

// This will move the AIEye. It will also cause lights near the eye to light up, if toggled.
// This is handled in the proc below this one.

/client/proc/MarkerMove(n, direct, mob/living/silicon/marker/user)

	var/initial = initial(user.sprint)
	var/max_sprint = 50

	if(user.cooldown && user.cooldown < world.timeofday) // 3 seconds
		user.sprint = initial

	for(var/i = 0; i < max(user.sprint, initial); i += 20)
		var/turf/step = get_turf(get_step(user.eyeobj, direct))
		if(step)
			user.eyeobj.setLoc(step)

	user.cooldown = world.timeofday + 5
	if(user.acceleration)
		user.sprint = min(user.sprint + 0.5, max_sprint)
	else
		user.sprint = initial

	if(!user.tracking)
		user.cameraFollow = null

// Return to the Core.
/mob/living/silicon/marker/proc/jump_to_marker()
	if(istype(current,/obj/machinery/holopad))
		var/obj/machinery/holopad/H = current
		H.clear_holo(src)
	else
		current = null
	cameraFollow = null
	unset_machine()

	if(isturf(loc) && (QDELETED(eyeobj) || !eyeobj.loc))
		to_chat(src, "ERROR: Eyeobj not found. Creating new eye...")
		stack_trace("MARKER eye object wasn't found! Location: [loc] / Eyeobj: [eyeobj] / QDELETED: [QDELETED(eyeobj)] / Eye loc: [eyeobj?.loc]")
		QDEL_NULL(eyeobj)
		create_eye()

	eyeobj?.setLoc(loc)

/mob/living/silicon/marker/proc/create_eye()
	if(eyeobj)
		return
	eyeobj = new /mob/camera/marker()
	all_eyes += eyeobj
	eyeobj.marker = src
	eyeobj.setLoc(loc)
	eyeobj.name = "Marker"
	eyeobj.real_name = eyeobj.name
	set_eyeobj_visible(TRUE)

/mob/living/silicon/marker/proc/set_eyeobj_visible(state = TRUE)
	if(!eyeobj)
		return
	eyeobj.mouse_opacity = state ? MOUSE_OPACITY_ICON : initial(eyeobj.mouse_opacity)
	eyeobj.invisibility = state ? INVISIBILITY_OBSERVER : initial(eyeobj.invisibility)
