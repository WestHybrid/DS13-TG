//TODO:
// - Add stun and damage in case you bump in something that isn't your target and you don't have destroy_objects = TRUE
// - Add mob autotargeting
/datum/action/cooldown/mob_cooldown/charge/necro
	background_icon_state = "bg_demon"
	shared_cooldown = "necro_charge"
	var/shake_power = 8

/datum/action/cooldown/mob_cooldown/charge/necro/New(Target, delay, past, distance, speed, damage, destroy, shake, cooldown)
	if(!isnull(shake))
		shake_power = shake
	if(cooldown)
		cooldown_time = cooldown
	.=..()

/datum/action/cooldown/mob_cooldown/charge/necro/do_charge_indicator(atom/charger, atom/charge_target)
	var/mob/living/carbon/necromorph = charger
	if(ismob(charge_target))
		necromorph.dna.species.play_species_audio(necromorph, SOUND_SHOUT_LONG, VOLUME_HIGH, 1, 3)
	else
		necromorph.dna.species.play_species_audio(necromorph, SOUND_SHOUT, VOLUME_HIGH, 1, 3)
	necromorph.shake_animation(shake_power)

/datum/action/cooldown/mob_cooldown/charge/necro/on_moved(atom/source)
	INVOKE_ASYNC(src, .proc/DestroySurroundings, source)

/datum/action/cooldown/mob_cooldown/charge/necro/on_bump(atom/movable/source, atom/target)
	if(owner == target)
		return
	if(destroy_objects)
		if(isturf(target))
			SSexplosions.medturf += target
		if(isobj(target) && target.density)
			SSexplosions.med_mov_atom += target

		INVOKE_ASYNC(src, .proc/DestroySurroundings, source)
	hit_target(source, target, charge_damage)

/datum/action/cooldown/mob_cooldown/charge/necro/on_move(atom/source, atom/new_loc)
	if(!actively_moving)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	new /obj/effect/temp_visual/decoy/fading/duration_set(source.loc, source, charge_speed*2)
	INVOKE_ASYNC(src, .proc/DestroySurroundings, source)

/obj/effect/temp_visual/decoy/fading/duration_set/Initialize(mapload, atom/mimiced_atom, new_duration)
	if(new_duration)
		duration = new_duration
	.=..()
