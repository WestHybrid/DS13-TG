/datum/action/cooldown/necro/active/gallop
	name = "Gallop"
	cooldown_time = 1 SECONDS
	duration_time = 1 SECONDS
	var/datum/movespeed_modifier/modifier

/datum/action/cooldown/necro/active/gallop/New(Target, cooldown, duration, power)
	modifier = new()
	modifier.multiplicative_slowdown = -power
	.=..()

/datum/action/cooldown/necro/active/gallop/Destroy()
	if(active)
		owner.remove_movespeed_modifier(modifier)
	QDEL_NULL(modifier)
	.=..()

/datum/action/cooldown/necro/active/gallop/Activate(atom/target)
	.=..()
	owner.add_movespeed_modifier(modifier)
	RegisterSignal(owner, COMSIG_ATOM_BULLET_ACT, .proc/on_hit)
	RegisterSignal(owner, COMSIG_MOVABLE_BUMP, .proc/on_bump)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/on_moved)

/datum/action/cooldown/necro/active/gallop/CooldownEnd()
	.=..()
	if(.)
		owner.remove_movespeed_modifier(modifier)
		UnregisterSignal(owner, list(COMSIG_ATOM_BULLET_ACT, COMSIG_MOVABLE_BUMP, COMSIG_MOVABLE_MOVED))

/datum/action/cooldown/necro/active/gallop/proc/on_hit(datum/source, obj/projectile/proj)
	SIGNAL_HANDLER
	owner.visible_message(span_danger("[owner] crumples under the impact [isobj(proj.fired_from) ? "of":"from"] [proj.fired_from]"))
	stop_crash()

/datum/action/cooldown/necro/active/gallop/proc/on_bump(datum/source, atom/obstacle)
	SIGNAL_HANDLER
	owner.visible_message(span_danger("[owner] crashes into [obstacle]"))
	stop_crash()

//Play extra footstep sounds as the leaper clatters along the floor
/datum/action/cooldown/necro/active/gallop/proc/on_moved(atom/movable/target, atom/origin, direction, forced)
	SIGNAL_HANDLER
	shake_camera(owner, 3,0.5)
	owner.play_species_audio(owner, SOUND_FOOTSTEP, VOLUME_QUIET)

/datum/action/cooldown/necro/active/gallop/proc/stop_crash()
	var/mob/living/holder = owner
	shake_camera(owner, 20,4)
	holder.Stun(3 SECONDS)
	holder.take_overall_damage(20)
	CooldownEnd()
