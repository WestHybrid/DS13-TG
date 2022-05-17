/mob/living/carbon/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof)
	. = dna?.species?.handle_say(src, message, bubble_type, spans, sanitize, language, ignore_spam, forced, filterproof)
	if(!.)
		.=..()

/mob/living/carbon/proc/handle_tongueless_speech(mob/living/carbon/speaker, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	var/static/regex/tongueless_lower = new("\[gdntke]+", "g")
	var/static/regex/tongueless_upper = new("\[GDNTKE]+", "g")
	if(message[1] != "*")
		message = tongueless_lower.Replace(message, pick("aa","oo","'"))
		message = tongueless_upper.Replace(message, pick("AA","OO","'"))
		speech_args[SPEECH_MESSAGE] = message

/mob/living/carbon/can_speak_vocal(message)
	if(silent)
		if(HAS_TRAIT(src, TRAIT_SIGN_LANG))
			return ..()
		else
			return FALSE
	return ..()

/mob/living/carbon/could_speak_language(datum/language/language)
	var/obj/item/organ/tongue/T = getorganslot(ORGAN_SLOT_TONGUE)
	if(T)
		return T.could_speak_language(language)
	else
		return initial(language.flags) & TONGUELESS_SPEECH
