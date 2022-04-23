/datum/reagent
	var/biomass = 0	//How much biomass one unit of this reagent is worth.

/*
	Recycling tanks recieve objects and chemicals which are organic in nature.
	These are gradually broken down into a chemical called Purified Biomass

	PB is used as food for the growth tank
*/
/obj/machinery/recycling_tank
	name = "recycling tank"
	desc = "A organic-breakdown machine that takes organic matter and turns it into a substance known simply as 'biomass' which it then automatically feeds into the storage tank next to it."
	icon = 'necromorphs/icons/obj/machines/bpl.dmi'
	icon_state = "biogen-empty"
	density = TRUE
	anchored = TRUE

	var/enabled = FALSE
	var/list/recycling_atoms = list()
	var/breakdown_rate = 0.002	//Remove this many units of biomass per tick, and convert it into purified biomass
	var/reagent_breakdown_rate = 0.065	//Remove this many units of reagents per tick and convert to biomass

/obj/machinery/recycling_tank/Initialize()
	.=..()
	create_reagents(1000)
	AddComponent(/datum/component/plumbing/simple_supply, anchored)

/obj/machinery/recycling_tank/LateInitialize()
	.=..()
	RegisterSignal(reagents, list(COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_REM_REAGENT), .proc/storage_reagent_change)

/obj/machinery/recycling_tank/wrench_act(mob/living/user, obj/item/I)
	if(default_unfasten_wrench(user, I) == SUCCESSFUL_UNFASTEN)
		return TRUE

/obj/machinery/recycling_tank/update_icon_state()
	if(enabled)
		icon_state = "biogen-work"
	else
		icon_state = "biogen-empty"
	.=..()

/obj/machinery/recycling_tank/is_open_container()
	return TRUE

/obj/machinery/recycling_tank/attackby(obj/item/I, mob/living/user, params)
	if(I.GetComponent(/datum/component/storage))
		var/cache = recycling_atoms.len
		for(var/obj/item/item in I.contents)
			insert_atom(I, user)
		if(cache != recycling_atoms.len)
			turn_on()
		else
			//Placed here instead of insert_atom() to prevent spam
			balloon_alert(user, "[I] doesn't contain organic items, or those items doesn't have recoverable biomasss")
		return

	//With containers, you pour in the contents, assuming the container itself is non-organic
	//Requires there to be some organic component in the contents
	if(insert_atom(I, user))
		turn_on()
	else
		if(!user.combat_mode)
			balloon_alert(user, "[I] is not organic, or doesn't contain recoverable biomass")
		else
			.=..()

/obj/machinery/recycling_tank/proc/storage_reagent_change(datum/reagent/reagent, amount, reagtemp, data, no_react)
	if(reagents.holder_full())
		turn_off()
	else if(!enabled)
		turn_on()

//This one doesnt do safety checks, and assumes the atom is on a turf or already in us
/obj/machinery/recycling_tank/proc/insert_atom(atom/movable/A, mob/user)
	if(!A.biomass)
		return

	if(!user.transferItemToLoc(A, src))
		return

	recycling_atoms |= A
	playsound(src, 'necromorphs/sound/machines/tankbiorecycle.ogg', VOLUME_LOW)
	user.visible_message("[user] places \the [A] into \the [src].", "You place \the [A] into \the [src].")

	return TRUE

/obj/machinery/recycling_tank/proc/turn_on()
	//We can't operate if our storage tank is full
	if(enabled || !is_operational || reagents.holder_full())
		return

	enabled = TRUE
	update_use_power(ACTIVE_POWER_USE)
	START_PROCESSING(SSmachines, src)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/recycling_tank/proc/turn_off()
	enabled = FALSE
	update_use_power(NO_POWER_USE)
	STOP_PROCESSING(SSmachines, src)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/recycling_tank/process()
	if(!is_operational)
		turn_off()
		return

	for(var/atom/movable/A as anything in recycling_atoms)
		if(A.biomass > breakdown_rate)
			A.biomass -= breakdown_rate
			reagents.add_reagent(BIOMASS_REAGENT_PATH, breakdown_rate*BIOMASS_TO_REAGENT)
		else
			biomass = 0
			reagents.add_reagent(BIOMASS_REAGENT_PATH, A.biomass*BIOMASS_TO_REAGENT)
			recycling_atoms -= A
			qdel(A)

	for(var/datum/reagent/R as anything in reagents.reagent_list)
		if(istype(R, /datum/reagent/consumable/nutriment/biomass))
			continue
		var/change = clamp(reagent_breakdown_rate, 0, R.volume)
		reagents.remove_reagent(R.type, reagent_breakdown_rate)
		if(R.biomass)
			reagents.add_reagent(BIOMASS_REAGENT_PATH, change*R.biomass*BIOMASS_TO_REAGENT)

	//If we've run out of things to breakdown, lets turn off
	if(!recycling_atoms.len && (reagents.total_volume <= reagents.get_reagent_amount(BIOMASS_REAGENT_PATH)))
		turn_off()
