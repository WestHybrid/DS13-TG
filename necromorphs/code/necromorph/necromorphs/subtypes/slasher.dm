/datum/necro_class/slasher
	display_name = "Slasher"
	desc = "The frontline soldier of the necromorph horde. Slow when not charging, but its blade arms make for powerful melee attacks"
	necromorph_type_path = /mob/living/carbon/necromorph/slasher
	melee_damage_lower = 10
	melee_damage_upper = 16
	max_health = 100
	actions = list(
		/datum/action/cooldown/necro/charge/slasher
	)
	minimap_icon = "slasher"

/mob/living/carbon/necromorph/slasher
	class = /datum/necro_class/slasher

/mob/living/carbon/necromorph/slasher/Shout(audio_type, volume, vary, extra_range)
	playsound(src, pick(GLOB.slasher_sounds[audio_type]), volume, vary, extra_range)
