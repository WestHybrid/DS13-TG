/obj/structure/reagent_dispensers/biomass
	name = "biomass storage"
	desc = "It is every citizen's final duty to go into the tanks, and to become one with all the people."
	icon = 'necromorphs/icons/obj/machines/bpl.dmi'
	icon_state = "tank"
	tank_volume = 10000	//Approximately 100 litres capacity, based on 1u = 10ml = 0.01 litre
	density = TRUE
	anchored = TRUE
	can_be_tanked = FALSE

/obj/structure/reagent_dispensers/biomass/ComponentInitialize()
	AddComponent(/datum/component/plumbing/tank, anchored)

/obj/structure/reagent_dispensers/biomass/wrench_act(mob/living/user, obj/item/I)
	if(default_unfasten_wrench(user, I) == SUCCESSFUL_UNFASTEN)
		return TRUE

