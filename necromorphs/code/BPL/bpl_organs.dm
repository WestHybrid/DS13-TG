/*
	A generic organ used to represent something in the growth tank which hasn't finished growing yet
*/
/obj/item/organ/fetus
	name = "fetus"
	desc = "a bundle of cells, probably nonsentient. You can use a syringe to extract stem cells from the spinal fluid"
	icon = 'necromorphs/icons/obj/machines/bpl.dmi'
	icon_state = "stem_cells_still"

/obj/item/organ/fetus/Initialize()
	.=..()
	create_reagents(15)
	reagents.add_reagent(STEMCELL_REAGENT_PATH, 15)

/atom/movable
	//Biomass is also measured in kilograms, its the organic mass in the atom. Is often zero
	var/biomass = 0
