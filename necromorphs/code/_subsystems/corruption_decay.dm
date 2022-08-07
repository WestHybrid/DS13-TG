SUBSYSTEM_DEF(corruption_decay)
	name = "Corruption Decay"
	init_order = INIT_ORDER_DECAY
	priority = FIRE_PRIORITY_DECAY
	flags = SS_NO_INIT
	wait = 2 SECONDS
	var/list/decaying = list()

/datum/controller/subsystem/corruption_decay/fire(resumed)
	for(var/obj/structure/corruption/decay as anything in decaying)

		if(MC_TICK_CHECK)
			return
