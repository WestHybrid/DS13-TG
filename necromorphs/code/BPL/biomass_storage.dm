/obj/structure/reagent_dispensers/biomass
	name = "biomass storage"
	desc = "It is every citizen's final duty to go into the tanks, and to become one with all the people."
	icon = 'necromorphs/icons/obj/machines/ds13/bpl.dmi'
	icon_state = "tank"
	tank_volume = 10000	//Approximately 100 litres capacity, based on 1u = 10ml = 0.01 litre
	//reagent_id = BIOMASS_REAGENT_PATH
	density = TRUE
	anchored = TRUE
	can_be_tanked = FALSE

/obj/structure/reagent_dispensers/biomass/ComponentInitialize()
	AddComponent(/datum/component/plumbing, anchored)

/obj/structure/reagent_dispensers/biomass/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I)
	return TRUE

