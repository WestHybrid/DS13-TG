/mob/living/carbon/necromorph
	name = "Necromorph"
	desc = "What the hell is THAT?"
	icon = 'necromorphs/icons/necromorphs/slasher/fleshy.dmi'
	icon_state = "Drone Walking"
	verb_say = "roars"
	verb_ask = "roars"
	verb_exclaim = "roars"
	verb_whisper = "roars"
	verb_sing = "roars"
	verb_yell = "roars"
	melee_damage_lower = 5
	melee_damage_upper = 5
	health = 5
	maxHealth = 5
	rotate_on_lying = FALSE
	mob_size = MOB_SIZE_HUMAN
	see_in_dark = 8
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE|LONG_GLIDE
	see_infrared = TRUE
	hud_type = /datum/hud/alien
	hud_possible = list(HEALTH_HUD,STATUS_HUD,ANTAG_HUD,GLAND_HUD)
	faction = FACTION_NECROMORPH
	initial_language_holder = /datum/language_holder/necro_talk
	light_system = MOVABLE_LIGHT
	type_of_meat = /obj/item/food/meat/slab/human/mutant/necro
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	bodyparts = list(
		/obj/item/bodypart/chest/necromorph,
		/obj/item/bodypart/head/necromorph,
		/obj/item/bodypart/l_arm/necromorph,
		/obj/item/bodypart/r_arm/necromorph,
		/obj/item/bodypart/l_leg/necromorph,
		/obj/item/bodypart/r_leg/necromorph,
		)
	pixel_x = -8
	var/armour_penetration = 0
	var/nicknumber = 0
	var/caste_type = "Slasher"
	var/tier = 0
	var/mob/living/silicon/marker/marker
	var/list/species_audio = list()	//An associative list of lists, in the format SOUND_TYPE = list(sound_1, sound_2)
	var/list/species_audio_volume = list()		//An associative list, in the format SOUND_TYPE = VOLUME_XXX. Values set here will override the volume of species audio files
	var/list/datum/action/necro_abilities = list()

	var/datum/xeno_caste/xeno_caste
	var/caste_base_type

	///"Frenzy", "Warding", "Recovery". Defined in __DEFINES/xeno.dm
	var/current_aura = null
	///Passive plasma cost per tick for enabled personal (not leadership) pheromones.
	var/pheromone_cost = 5
	var/frenzy_aura = 0 //Strength of aura we are affected by. NOT THE ONE WE ARE EMITTING
	var/warding_aura = 0
	var/recovery_aura = 0

	var/regen_power = 0 //Resets to -xeno_caste.regen_delay when you take damage.
	//Negative values act as a delay while values greater than 0 act as a multiplier.
	//Will increase by 10 every decisecond if under 0. Increases by xeno_caste.regen_ramp_amount every decisecond.
	//If you want to balance this, look at the xeno_caste defines mentioned above.

	var/list/datum/action/xeno_abilities = list()
	var/datum/action/xeno_action/activable/selected_ability

	//This list of inherent verbs lets us take any proc basically anywhere and add them.
	//If they're not a xeno subtype it might crash or do weird things, like using human verb procs
	//It should add them properly on New() and should reset/readd them on evolves
	var/list/inherent_verbs = list()

	//Lord forgive me for this horror, but Life code is awful
	//These are tally vars, yep. Because resetting the aura value directly leads to fuckups
	var/frenzy_new = 0
	var/warding_new = 0
	var/recovery_new = 0

	///The necromorph that this source is currently overwatching
	var/mob/living/carbon/necromorph/observed_xeno

	///Multiplicative melee damage modifier; referenced by attack_alien.dm, most notably attack_alien_harm
	var/xeno_melee_damage_modifier = 1

	var/xeno_mobhud = FALSE //whether the xeno mobhud is activated or not.

	var/queen_chosen_lead //whether the xeno has been selected by the queen as a leader.

	//Notification spam controls
	var/recent_notice = 0
	var/notice_delay = 20 //2 second between notices

	var/fire_luminosity = 0 //Luminosity of the current fire while burning

	///The xenos/silo/nuke currently tracked by the xeno_tracker arrow
	var/atom/tracked

	COOLDOWN_DECLARE(xeno_health_alert_cooldown)


/obj/item/food/meat/slab/human/mutant/necro
//	icon_state = "necromeat"
	desc = "Eating it doesn't sound like a good idea."
	food_reagents = list(/datum/reagent/toxin/carpotoxin = 5)
	tastes = list("rotten" = 1)
	foodtypes = MEAT|JUNKFOOD|RAW|TOXIC
	venue_value = FOOD_MEAT_MUTANT

/datum/language_holder/necro_talk
	understood_languages = list(/datum/language/necro = list(LANGUAGE_MIND))
	spoken_languages = list(/datum/language/necro = list(LANGUAGE_MIND))

/datum/language/necro
	name = "Necromorph"
	desc = "Blurbing sounds necromorph use to communicate."
	flags = NO_STUTTER|TONGUELESS_SPEECH|LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD
	key = "x"
	syllables = list("Hrr", "rHr", "rrr")
	default_priority = 50

	icon_state = "xeno"
