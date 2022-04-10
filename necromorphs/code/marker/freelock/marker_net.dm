// CAMERA NET
//
// The datum containing all the chunks.

#define CHUNK_SIZE 16 // Only chunk sizes that are to the power of 2. E.g: 2, 4, 8, 16, etc..

GLOBAL_DATUM_INIT(markernet, /datum/markernet, new)

/datum/markernet
	/// Name to show for VV and stat()
	var/name = "Marker Net"

	/// The cameras on the map, no matter if they work or not. Updated in obj/machinery/camera.dm by New() and Del().
	var/list/cameras = list()
	/// The chunks of the map, mapping the areas that the cameras can see.
	var/list/chunks = list()
	var/ready = 0

	///The image cloned by all chunk static images put onto turfs cameras cant see
	var/image/obscured

/datum/markernet/New()

	obscured = new('icons/effects/cameravis.dmi')
	obscured.plane = CAMERA_STATIC_PLANE
	obscured.appearance_flags = RESET_TRANSFORM | RESET_ALPHA | RESET_COLOR | KEEP_APART
	obscured.override = TRUE

/// Checks if a chunk has been Generated in x, y, z.
/datum/markernet/proc/chunkGenerated(x, y, z)
	x &= ~(CHUNK_SIZE - 1)
	y &= ~(CHUNK_SIZE - 1)
	return chunks["[x],[y],[z]"]

// Returns the chunk in the x, y, z.
// If there is no chunk, it creates a new chunk and returns that.
/datum/markernet/proc/getCameraChunk(x, y, z)
	x &= ~(CHUNK_SIZE - 1)
	y &= ~(CHUNK_SIZE - 1)
	var/key = "[x],[y],[z]"
	. = chunks[key]
	if(!.)
		chunks[key] = . = new /datum/markerchunk(x, y, z)

/// Updates what the aiEye can see. It is recommended you use this when the aiEye moves or it's location is set.
/datum/markernet/proc/visibility(list/moved_eyes, client/C, list/other_eyes, use_static = TRUE)
	if(!islist(moved_eyes))
		moved_eyes = moved_eyes ? list(moved_eyes) : list()
	if(islist(other_eyes))
		other_eyes = (other_eyes - moved_eyes)
	else
		other_eyes = list()

	for(var/mob/camera/marker/eye as anything in moved_eyes)
		var/list/visibleChunks = list()
		if(eye.loc)
			// 0xf = 15
			var/static_range = eye.static_visibility_range
			var/x1 = max(0, eye.x - static_range) & ~(CHUNK_SIZE - 1)
			var/y1 = max(0, eye.y - static_range) & ~(CHUNK_SIZE - 1)
			var/x2 = min(world.maxx, eye.x + static_range) & ~(CHUNK_SIZE - 1)
			var/y2 = min(world.maxy, eye.y + static_range) & ~(CHUNK_SIZE - 1)


			for(var/x = x1; x <= x2; x += CHUNK_SIZE)
				for(var/y = y1; y <= y2; y += CHUNK_SIZE)
					visibleChunks |= getCameraChunk(x, y, eye.z)

		var/list/remove = eye.visibleCameraChunks - visibleChunks
		var/list/add = visibleChunks - eye.visibleCameraChunks

		for(var/datum/markerchunk/chunk as anything in remove)
			chunk.remove(eye, FALSE)

		for(var/datum/markerchunk/chunk as anything in add)
			chunk.add(eye)

/// Updates the chunks that the turf is located in. Use this when obstacles are destroyed or when doors open.
/datum/markernet/proc/updateVisibility(atom/A, opacity_check = 1)
	if(!SSticker || (opacity_check && !A.opacity))
		return
	majorChunkChange(A, 2)

/datum/markernet/proc/updateChunk(x, y, z)
	var/datum/markerchunk/chunk = chunkGenerated(x, y, z)
	if (!chunk)
		return
	chunk.hasChanged()

/// Removes a camera from a chunk.
/datum/markernet/proc/removeCamera(atom/c)
	majorChunkChange(c, 0)

/// Add a camera to a chunk.
/datum/markernet/proc/addCamera(atom/c)
	if(c.can_use_marker())
		majorChunkChange(c, 1)

/// Used for Cyborg cameras. Since portable cameras can be in ANY chunk.
/datum/markernet/proc/updatePortableCamera(atom/c)
	if(c.can_use_marker())
		majorChunkChange(c, 1)

/**
 * Never access this proc directly!!!!
 * This will update the chunk and all the surrounding chunks.
 * It will also add the atom to the cameras list if you set the choice to 1.
 * Setting the choice to 0 will remove the camera from the chunks.
 * If you want to update the chunks around an object, without adding/removing a camera, use choice 2.
 */
/datum/markernet/proc/majorChunkChange(atom/c, choice)
	if(!c)
		return

	var/turf/T = get_turf(c)
	if(T)
		var/x1 = max(0, T.x - (CHUNK_SIZE / 2)) & ~(CHUNK_SIZE - 1)
		var/y1 = max(0, T.y - (CHUNK_SIZE / 2)) & ~(CHUNK_SIZE - 1)
		var/x2 = min(world.maxx, T.x + (CHUNK_SIZE / 2)) & ~(CHUNK_SIZE - 1)
		var/y2 = min(world.maxy, T.y + (CHUNK_SIZE / 2)) & ~(CHUNK_SIZE - 1)
		for(var/x = x1; x <= x2; x += CHUNK_SIZE)
			for(var/y = y1; y <= y2; y += CHUNK_SIZE)
				var/datum/markerchunk/chunk = chunkGenerated(x, y, T.z)
				if(chunk)
					if(choice == 0)
						// Remove the camera.
						chunk.cameras -= c
					else if(choice == 1)
						// You can't have the same camera in the list twice.
						chunk.cameras |= c
					chunk.hasChanged()

/// Will check if a mob is on a viewable turf. Returns 1 if it is, otherwise returns 0.
/datum/markernet/proc/checkCameraVis(mob/living/target)
	var/turf/position = get_turf(target)
	return checkTurfVis(position)


/datum/markernet/proc/checkTurfVis(turf/position)
	var/datum/markerchunk/chunk = getCameraChunk(position.x, position.y, position.z)
	if(chunk)
		if(chunk.changed)
			chunk.hasChanged(1) // Update now, no matter if it's visible or not.
		if(chunk.visibleTurfs[position])
			return TRUE
	return FALSE
