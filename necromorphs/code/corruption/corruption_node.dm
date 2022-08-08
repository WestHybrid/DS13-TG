/obj/structure/corruption/node
	name = ""
	desc = "There is something scary in it."
	icon = 'necromorphs/icons/effects/corruption.dmi'
	icon_state = "corruption-node"
	//smoothing_flags = SMOOTH_BITMASK
	anchored = TRUE
	max_integrity = 15
	resistance_flags = UNACIDABLE
	obj_flags = CAN_BE_HIT
	interaction_flags_atom = NONE
	var/remaining_weed_amount = 25
	var/control_range = 5

/obj/structure/corruption/node/Initialize(mapload)
	SScorruption.nodes += src
	master = src
	.=..()
	UnregisterSignal(src, COMSIG_PARENT_QDELETING)

/obj/structure/corruption/node/Destroy()
	LAZYREMOVE(SScorruption.nodes[z], src)
	.=..()
