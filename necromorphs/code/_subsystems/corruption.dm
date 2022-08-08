SUBSYSTEM_DEF(corruption)
	name = "Corruption"
	init_order = INIT_ORDER_CORRUPTION
	priority = FIRE_PRIORITY_CORRUPTION
	wait = 1 SECONDS
	flags = SS_NO_INIT
	/// A list of corruption nodes
	var/list/nodes = list()
	/// A list of corruption that is still growing and not ready to spread
	var/list/growing = list()
	/// A list of grown corruption that is ready to spread
	var/list/spreading = list()

	var/list/decaying = list()

/datum/controller/subsystem/corruption/fire(resumed)
	for(var/obj/structure/corruption/corruption as anything in growing)
		corruption.repair_damage(3)
		if(MC_TICK_CHECK)
			return

	for(var/obj/structure/corruption/corruption as anything in spreading)
		corruption.spread()
		spreading -= corruption
		if(MC_TICK_CHECK)
			return

	for(var/obj/structure/corruption/corruption as anything in decaying)
		corruption.take_damage(3)
		if(MC_TICK_CHECK)
			return
