//Generic proc to see if a thing is aligned with the necromorph faction
/datum/proc/is_necromorph()
	return FALSE

//We'll check the species on the brain first, before the rest of the body
/mob/living/carbon/is_necromorph()
	return dna.species.is_necromorph()

/datum/species/necromorph/is_necromorph()
	return TRUE

/proc/jumplink_public(var/mob/user, var/atom/target)
	if(QDELETED(target))
		return ""
	var/turf/T = get_turf(target)
	var/area/A = get_area(target)
	var/where = "[A? A.name : "Unknown Location"] | [T.x], [T.y], [T.z]"
	var/whereLink = "<A HREF='?src=\ref[user];jump_to=1;X=[T.x];Y=[T.y];Z=[T.z]'>[where]</a>"
	return whereLink

/proc/link_necromorphs_to(message, target)
	for(var/mob/M as anything in SSnecromorph.necromorph_players)
		if(M && M.client)
			var/personal_message = replacetext(message, "LINK", jumplink_public(M, target))
			to_chat(M, personal_message)

