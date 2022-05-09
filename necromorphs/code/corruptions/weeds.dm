//Color variant defines
#define SPEED_COLOR ""
#define RESTING_COLOR "white"
#define STICKY_COLOR "green"

// base weed type
/obj/structure/necromorph/weeds
	name = "weeds"
	desc = "A layer of oozy slime, it feels slick, but not as slick for you to slip."
	icon_state = "coruption-1"
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	max_integrity = 25
	ignore_weed_destruction = TRUE

	var/obj/structure/necromorph/weeds/node/parent_node
	///The color variant of the sprite
	var/color_variant = SPEED_COLOR
	///The healing buff when resting on this weed
	var/resting_buff = 1
	///If these weeds are not destroyed but just swapped
	var/swapped = FALSE

/obj/structure/necromorph/weeds/deconstruct(disassembled = TRUE)
	GLOB.round_statistics.weeds_destroyed++
	return ..()

/obj/structure/necromorph/weeds/Initialize(mapload, obj/structure/necromorph/weeds/node/node, swapped = FALSE)
	. = ..()

	if(!isnull(node))
		if(!istype(node))
			CRASH("Created weed without weed node. Type: [node.type]")
		set_parent_node(node)
	update_icon()
	AddElement(/datum/element/accelerate_on_crossed)
	if(!swapped)
		update_neighbours()
	for(var/mob/living/living_mob in loc.contents)
		SEND_SIGNAL(living_mob, COMSIG_LIVING_WEEDS_AT_LOC_CREATED, src)

/obj/structure/necromorph/weeds/Destroy()
	parent_node = null
	if(swapped)
		return ..()
	for(var/mob/living/L in range(1, src))
		SEND_SIGNAL(L, COMSIG_LIVING_WEEDS_ADJACENT_REMOVED)
	SEND_SIGNAL(loc, COMSIG_TURF_WEED_REMOVED)
	INVOKE_NEXT_TICK(src, .proc/update_neighbours, loc)
	return ..()

/obj/structure/necromorph/weeds/proc/update_neighbours(turf/U)
	if(!U)
		U = loc
	if(istype(U))
		for (var/dirn in GLOB.cardinals)
			var/turf/T = get_step(U, dirn)

			if (!istype(T))
				continue

			var/obj/structure/necromorph/weeds/W = locate() in T
			if(W)
				W.update_icon()

///Check if we have a parent node, if not, qdel ourselve
/obj/structure/necromorph/weeds/proc/check_for_parent_node()
	if(parent_node)
		return
	qdel(src)

/obj/structure/necromorph/weeds/update_icon_state()
	. = ..()
	icon_state = "corruption-[rand(1,3)]"

	var/matrix/M = matrix()
	M = M.Scale(1.1)	//We scale up the sprite so it slightly overlaps neighboring corruption tiles
	var/rotation = pick(list(0,90,180,270))	//Randomly rotate it
	transform = turn(M, rotation)

///Set the parent_node to node
/obj/structure/necromorph/weeds/proc/set_parent_node(atom/node)
	if(parent_node)
		UnregisterSignal(parent_node, COMSIG_PARENT_QDELETING)
	parent_node = node
	RegisterSignal(parent_node, COMSIG_PARENT_QDELETING, .proc/clean_parent_node)

///Clean the parent node var
/obj/structure/necromorph/weeds/proc/clean_parent_node()
	SIGNAL_HANDLER
	if(!parent_node.swapped)
		SSweeds_decay.decaying_list += src
	parent_node = null
