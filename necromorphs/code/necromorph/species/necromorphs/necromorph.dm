/datum/species/necromorph
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "Necromorph"
	plural_form = "Necromorphs"
	id = SPECIES_NECROMORPH
	sexes = 0
	bodytype = BODYTYPE_NECROMORPH|BODYTYPE_ORGANIC
	exotic_bloodtype = "X"
	attack_verb = "slash"
	meat = /obj/item/food/meat/slab/human/mutant/necro
	species_traits = list(
		NOBLOOD,
		NOTRANSSTING,
		NOZOMBIE,
		NO_UNDERWEAR,
		NOSTOMACH,
		NO_DNA_COPY,
		NOEYESPRITES,
		HAS_FLESH,
		HAS_BONE,
		NOBLOODOVERLAY,
		NOAUGMENTS,
		)
	inherent_traits = list(
		TRAIT_DEFIB_BLACKLISTED,
		TRAIT_BADDNA,
		TRAIT_GENELESS,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NOMETABOLISM,
		TRAIT_TOXIMMUNE,
		TRAIT_EASYDISMEMBER,
		TRAIT_NOBREATH,
		TRAIT_NOCRITDAMAGE,
		TRAIT_FEARLESS,
		TRAIT_NO_SOUL,
		TRAIT_CANT_RIDE,
		TRAIT_CAN_STRIP,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTCOLD,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	inherent_factions = list("necromorphs")
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/l_arm/necromorph,\
		BODY_ZONE_R_ARM = /obj/item/bodypart/r_arm/necromorph,\
		BODY_ZONE_HEAD = /obj/item/bodypart/head/necromorph,\
		BODY_ZONE_L_LEG = /obj/item/bodypart/l_leg/necromorph,\
		BODY_ZONE_R_LEG = /obj/item/bodypart/r_leg/necromorph,\
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/necromorph)
	mutanteyes = /obj/item/organ/eyes/night_vision
	changesource_flags = MIRROR_BADMIN|WABBAJACK
	damage_overlay_type = ""
	species_language_holder = /datum/language_holder/necro_talk
	var/health = 100
	var/list/abilities = list()

// We don't remove those abilities manually because all of them should register
// COMSIG_SPECIES_LOSS signal and remove themselfs once they recieve it
/datum/species/necromorph/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	.=..()
	for(var/path in abilities)
		if(ispath(path, /datum/action))
			var/datum/action/button = new path(C, src)
			button.Grant(C)
		else if(ispath(path, /datum/element))
			C.AddElement(path, src)
		else if(ispath(path, /datum/component))
			C.AddComponent(path, src)
	C.hud_used.infodisplay

/datum/species/necromorph/random_name(gender,unique,lastname)
	return "[name] [rand(1, 999)]"

/datum/species/necromorph/handle_say(mob/living/carbon/owner, message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null)
	.=TRUE
	if(!message)
		return

	if(owner.client)
		if(owner.client.prefs.muted & MUTE_IC)
			to_chat(owner, span_boldwarning("You cannot send IC messages (muted)."))
			return
		if (!(ignore_spam || forced) && owner.client.handle_spam_prevention(message,MUTE_IC))
			return

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	owner.log_talk(message, LOG_SAY)

	var/message_a = owner.say_quote(message)
	var/rendered = "<font color=\"#AA00FF\"><b>[owner.name]</b> [message_a]</font>"

	for(var/mob/M in GLOB.mob_list)
		if(issignal(M))
			var/link = FOLLOW_LINK(M, owner)
			to_chat(M, "[link] [rendered]")
		else if(M.is_necromorph())
			to_chat(M, rendered)

/datum/species/shadow/get_species_description()
	return "Placeholder description"

/datum/species/shadow/get_species_lore()
	return list(
		"Placeholder description1",

		"Placeholder description2",

		"Placeholder description3",
	)

/obj/item/food/meat/slab/human/mutant/necro
//	icon_state = "necromeat"
	desc = "Eating it doesn't sound like a good idea."
	food_reagents = list(/datum/reagent/toxin/carpotoxin = 5)
	tastes = list("rotten" = 1)
	foodtypes = MEAT|JUNKFOOD|RAW|TOXIC
	venue_value = FOOD_MEAT_MUTANT

/datum/language_holder/necro_talk
	understood_languages = list()
	spoken_languages = list()
