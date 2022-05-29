/mob/living/carbon/necromorph/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(SEND_SIGNAL(src, COMSIG_LIVING_UNARMED_ATTACK, attack_target, proximity_flag, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return
	attack_target.attack_necromorph(src, modifiers)

/atom/proc/attack_necromorph(mob/living/carbon/necromorph/user, list/modifiers)
	attack_paw(user, modifiers)
	return

/mob/living/attack_necromorph(mob/living/carbon/necromorph/user, list/modifiers)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		user.do_attack_animation(src, ATTACK_EFFECT_DISARM)
		return TRUE
	if(user.combat_mode)
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, span_warning("You don't want to hurt anyone!"))
			return FALSE
		user.do_attack_animation(src)
		return TRUE
	else
		visible_message(span_notice("[user] caresses [src] with its scythe-like arm."), \
						span_notice("[user] caresses you with its scythe-like arm."), null, null, user)
		to_chat(user, span_notice("You caress [src] with your scythe-like arm."))
		return FALSE

/mob/living/carbon/necromorph/get_eye_protection()
	return ..() + 2 //potential cyber implants + natural eye protection

/mob/living/carbon/necromorph/get_ear_protection()
	return 2 //no ears

/mob/living/carbon/necromorph/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	..(AM, skipcatch = TRUE, hitpush = FALSE)

/mob/living/carbon/necromorph/attack_necromorph(mob/living/carbon/necromorph/user, list/modifiers)
	if(user.combat_mode)
		user.do_attack_animation(src, ATTACK_EFFECT_SLASH)
		playsound(loc, 'sound/weapons/slash.ogg', 50, TRUE, -1)
		visible_message(span_danger("[user.name] slashes [src]!"), \
						span_userdanger("[user.name] slashes you!"), span_hear("You hear a cutting of the flesh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("You slash [src]!"))
		adjustBruteLoss(1)
		log_combat(user, src, "attacked")
		updatehealth()

/mob/living/carbon/necromorph/attack_hand(mob/living/carbon/human/user, list/modifiers)
	.=..()
	if(.) //to allow surgery to return properly.
		return FALSE

	var/martial_result = user.apply_martial_art(src, modifiers)
	if (martial_result != MARTIAL_ATTACK_INVALID)
		return martial_result

	if(user.combat_mode)
		if(LAZYACCESS(modifiers, RIGHT_CLICK))
			user.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			return TRUE
		user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		return TRUE
	else
		help_shake_act(user)

/mob/living/carbon/necromorph/attack_paw(mob/living/carbon/human/user, list/modifiers)
	if(..())
		if (stat != DEAD)
			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(user.zone_selected))
			apply_damage(rand(1, 3), BRUTE, affecting)

/mob/living/carbon/necromorph/attack_animal(mob/living/simple_animal/user, list/modifiers)
	.=..()
	if(.)
		var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
		switch(user.melee_damage_type)
			if(BRUTE)
				adjustBruteLoss(damage)
			if(BURN)
				adjustFireLoss(damage)
			if(TOX)
				adjustToxLoss(damage)
			if(OXY)
				adjustOxyLoss(damage)
			if(CLONE)
				adjustCloneLoss(damage)
			if(STAMINA)
				adjustStaminaLoss(damage)

/mob/living/carbon/necromorph/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return FALSE

	.=..()
	if(QDELETED(src))
		return

	var/obj/item/organ/ears/ears = getorganslot(ORGAN_SLOT_EARS)
	switch (severity)
		if (EXPLODE_DEVASTATE)
			gib()
			return

		if (EXPLODE_HEAVY)
			take_overall_damage(60, 60)
			if(ears)
				ears.adjustEarDamage(30,120)

		if(EXPLODE_LIGHT)
			take_overall_damage(30,0)
			if(prob(50))
				Unconscious(20)
			if(ears)
				ears.adjustEarDamage(15,60)

/mob/living/carbon/necromorph/soundbang_act(intensity = 1, stun_pwr = 20, damage_pwr = 5, deafen_pwr = 15)
	return 0
