/datum/component/wallrun
	dupe_type = /datum/component/wallrun
	var/mount_time = 0.7 SECONDS
	var/atom/mount_atom
	var/atom/next_mountpoint
	var/current_angle
	var/list/valid_types = list(/turf/closed/wall,
		/obj/structure/grille,
		/obj/structure/window,
		/obj/machinery/door,
		/mob/living)
	var/cached_alpha
	var/passflag_delta
	var/block_movement

/datum/component/wallrun/Initialize()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOVABLE_BUMP, .proc/attempt_connect)

/datum/component/wallrun/proc/attempt_connect(datum/source, atom/obstacle)
	if(!mount_atom)
		return attempt_mount(obstacle)
	else
		return attempt_transition(obstacle)

/datum/component/wallrun/proc/cache_data()
	var/atom/movable/holder = parent
	cached_alpha = holder.alpha
	if(!(holder.pass_flags & PASSTABLE))
		passflag_delta &= PASSTABLE

	if(!(holder.pass_flags & PASSMACHINE))
		passflag_delta &= PASSMACHINE

/datum/component/wallrun/proc/attempt_mount(atom/target)
	if(is_valid_mount_target(target))
		cache_data()
		mount_to_atom(target)
		mount_animation(TRUE)
		var/atom/movable/holder = parent
		holder.visible_message("[holder] climbs onto the [target]")
		return TRUE

/datum/component/wallrun/proc/is_valid_mount_target(atom/target, ignore_selfcheck)
	if(!ignore_selfcheck && (target == parent || target == mount_atom))
		return FALSE

	if(!target.density)
		return FALSE

	var/typematch = FALSE
	for(var/typepath in valid_types)
		if(istype(target, typepath))
			typematch = TRUE
			break
	if(!typematch)
		return FALSE

	var/target_turf = get_mount_target_turf(parent, target)
	if(!(target_turf in orange(1, parent)))
		return FALSE

	if(isliving(target))
		var/mob/living/LT = target
		if(LT.mob_size < MOB_SIZE_LARGE)
			return FALSE
	return TRUE

/datum/component/wallrun/proc/get_mount_target_turf(atom/origin, atom/target)
	var/turf/T = get_turf(target)
	if(target.flags_1 & ON_BORDER_1)
		var/dir_to_us = get_dir(T, origin)
		if(dir_to_us & target.dir)
			return T
		return get_step(T, target.dir)

	if(get_turf(origin) != T)
		return T
	else
		return null

/datum/component/wallrun/proc/is_valid_transition_target(var/atom/target)
	var/target_turf = get_mount_target_turf(parent, target)
	if(!(target_turf in orange(mount_atom, 1)))
		return FALSE
	return TRUE

/datum/component/wallrun/proc/mount_to_atom(atom/target)
	mount_atom = target
	var/atom/movable/holder = parent
	if(ismovable(mount_atom))
		RegisterSignal(mount_atom, COMSIG_MOVABLE_MOVED, .proc/on_mount_atom_move)
		RegisterSignal(mount_atom, COMSIG_ATOM_DIR_CHANGE, .proc/on_mount_dir_change)
		RegisterSignal(mount_atom, COMSIG_LIVING_DEATH, .proc/unmount)
		RegisterSignal(mount_atom, COMSIG_PARENT_QDELETING, .proc/unmount_silent)
	RegisterSignal(holder, COMSIG_MOVABLE_PRE_MOVE, .proc/on_parent_premove)
	RegisterSignal(holder, COMSIG_MOVABLE_MOVED, .proc/on_parent_move)
	RegisterSignal(holder, COMSIG_LIVING_DEATH, .proc/unmount)
	holder.pass_flags &= passflag_delta

/datum/component/wallrun/proc/find_mountpoint(origin)
	for(var/atom/target in orange(origin, 1))
		// Can't hook to grille if there is a window in our way
		if(istype(target, /obj/structure/grille))
			for(var/obj/structure/window/test in target.loc)
				. = TRUE
				break
			if(.)
				. = null
				continue
		if(is_valid_mount_target(target) && is_valid_transition_target(target))
			return target
	return null

/datum/component/wallrun/proc/on_parent_premove(atom/mover, newloc)
	if(!mount_atom)
		return

	var/atom/next = find_mountpoint(newloc)
	if(!next)
		if(get_dist(mount_atom, newloc) <= 1)
			next = mount_atom
	if(next)
		next_mountpoint = next
		if(block_movement)
			return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	else
		unmount()

/datum/component/wallrun/proc/on_parent_move(atom/mover, oldloc, newloc)
	var/mounted = FALSE
	if(next_mountpoint)
		if(next_mountpoint == mount_atom)
			mounted = is_valid_mount_target(mount_atom, TRUE)
			mount_animation()
		else if(mount_atom)
			mounted = attempt_connect(parent, next_mountpoint)
		next_mountpoint = null
	if(!mounted)
		var/atom/next = find_mountpoint(newloc)
		if(next && attempt_connect(parent, next))
			mounted = TRUE
		else if(mount_atom && is_valid_mount_target(mount_atom, TRUE))
			mounted = TRUE
		else
			unmount()

/datum/component/wallrun/proc/mount_animation(mounting)
	var/atom/movable/holder = parent
	var/new_angle = DIR2ANGLE(DIRFLIP(get_dir(holder, mount_atom)))
	var/temp_angle
	if(current_angle != null)
		temp_angle = new_angle - current_angle
	else
		temp_angle = new_angle
	current_angle = new_angle
	if(temp_angle || mounting)
		animate(holder, transform = holder.transform.Turn(temp_angle), alpha = min(cached_alpha * 0.5, 100), time = mount_time, easing = BACK_EASING)

/datum/component/wallrun/proc/unmount_animation()
	var/atom/movable/holder = parent
	animate(holder, transform = holder.transform.Turn(-current_angle), alpha = cached_alpha, time = mount_time, easing = BACK_EASING)
	current_angle = null
	cached_alpha = null

/datum/component/wallrun/proc/attempt_transition(atom/target)
	if(is_valid_mount_target(target) && is_valid_transition_target(target))
		return transition_to_atom(target)

/datum/component/wallrun/proc/transition_to_atom(atom/target)
	var/target_turf = get_mount_target_turf(parent, target)
	if(!target_turf)
		return
	var/angle_to_target = DIR2ANGLE(DIRFLIP(get_dir(parent, target)))
	var/do_animate = FALSE
	if(current_angle != angle_to_target)
		do_animate = TRUE
	handle_unmount()
	mount_to_atom(target)
	if(do_animate)
		mount_animation()
	return TRUE

/datum/component/wallrun/proc/handle_unmount()
	var/atom/movable/holder = parent
	if(mount_atom)
		UnregisterSignal(mount_atom, COMSIG_MOVABLE_MOVED, .proc/on_mount_atom_move)
		UnregisterSignal(mount_atom, COMSIG_ATOM_DIR_CHANGE, .proc/on_mount_dir_change)
		UnregisterSignal(mount_atom, COMSIG_LIVING_DEATH, .proc/unmount)
		UnregisterSignal(mount_atom, COMSIG_PARENT_QDELETING, .proc/unmount_silent)
	UnregisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, .proc/on_parent_premove)
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/on_parent_move)
	UnregisterSignal(holder, COMSIG_LIVING_DEATH, .proc/unmount)
	mount_atom = null
	holder.pass_flags &= ~passflag_delta

/datum/component/wallrun/proc/unmount(atom/target)
	var/atom/movable/holder = parent
	holder.visible_message("[holder] climbs down from \the [mount_atom]")
	unmount_animation()
	handle_unmount()

/datum/component/wallrun/proc/unmount_silent(atom/target)
	unmount_animation()
	handle_unmount()

/datum/component/wallrun/proc/find_mount_atom(origin)
	for(var/atom/target in orange(origin, 1))
		if(is_valid_mount_target(target) && is_valid_transition_target(target))
			return target
	return null

/datum/component/wallrun/proc/on_mount_atom_move(atom/movable/target, atom/origin, direction, forced)
	var/atom/movable/holder = parent
	var/turf/new_loc = get_step(holder, direction)
	if(new_loc.Enter(holder))
		holder.forceMove(new_loc)
	else
		unmount()

/*
/datum/component/wallrun/proc/on_density_set()
	if(!mount_atom.density)
		unmount()
*/

/datum/component/wallrun/proc/on_mount_dir_change(atom/mover, old_dir, new_dir)
	if(mount_atom)
		var/atom/movable/holder = parent
		var/turf/new_loc = get_step(mover, DIRFLIP(new_dir))
		if(new_loc.Enter(holder))
			holder.forceMove(new_loc)
		else
			unmount()
