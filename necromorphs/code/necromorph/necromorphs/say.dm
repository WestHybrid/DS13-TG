/datum/saymode/necromorph
	key = ";"
	mode = MODE_NECROMORPH

/datum/saymode/necromorph/handle_message(mob/living/user, message, datum/language/language)
	if(user.is_necromorph())
		var/mob/living/carbon/necromorph/necro = user
		if(necro.hivemind_talk(message))
			return FALSE
	return TRUE
