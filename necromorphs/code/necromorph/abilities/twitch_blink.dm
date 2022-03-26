//TODO: Implement animation support
/datum/element/twitch
	element_flags = ELEMENT_DETACH|ELEMENT_BESPOKE
	var/movement_blink_chance = 4
	var/damage_blink_chance = 6
	var/blink_delay_min = 3 SECONDS
	var/blink_delay_max = 15 SECONDS
	var/next_blink = 0

/datum/element/twitch/Attach(datum/target, _movement_blink_chance, _damage_blink_chance, delay_min, delay_max)
	.=..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

	if(!isnull(_movement_blink_chance))
		movement_blink_chance = _movement_blink_chance
	if(!isnull(_damage_blink_chance))
		damage_blink_chance = _damage_blink_chance
	if(!isnull(delay_min))
		blink_delay_min = delay_min
	if(delay_max && delay_max > 0)
		blink_delay_max = delay_max

	RegisterSignal(target, COMSIG_MOB_APPLY_DAMAGE, .proc/on_damage)
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/on_moved)

/datum/element/twitch/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_MOB_APPLY_DAMAGE, COMSIG_MOVABLE_MOVED))
	.=..()

/datum/element/twitch/proc/on_damage(datum/target, damage, damagetype, def_zone)
	SIGNAL_HANDLER
	if(damage && world.time > next_blink && prob(damage_blink_chance))
		blink(target)

/datum/element/twitch/proc/on_moved(atom/movable/target, atom/origin, direction, forced)
	SIGNAL_HANDLER
	if(world.time > next_blink && prob(movement_blink_chance))
		blink(target)

//Code from dodge.dm
/datum/element/twitch/proc/blink(mob/holder)
	var/list/possible_turfs = RANGE_TURFS(1, holder)
	possible_turfs -= get_turf(holder)
	possible_turfs -= get_step(holder, holder.dir)
	possible_turfs -= get_step(holder, DIRFLIP(holder.dir))

	var/turf/target
	while(possible_turfs.len) //Using while() instead of for() to ensure target turf is randomised
		target = pick(possible_turfs)
		if(!target.is_blocked_turf())
			break
		possible_turfs -= target
		target = null

	next_blink = world.time + rand(blink_delay_min, blink_delay_max)
	holder.set_dir_on_move = FALSE
	holder.Move(target, get_dir(holder, target))
	holder.set_dir_on_move = TRUE
