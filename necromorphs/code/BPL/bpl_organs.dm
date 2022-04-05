/*
	A generic organ used to represent something in the growth tank which hasn't finished growing yet
*/

/obj/item/organ/forming
	icon = 'necromorphs/icons/obj/machines/ds13/bpl.dmi'

/obj/item/organ/fetus
	name = "fetus"
	desc = "a bundle of cells, probably nonsentient. You can use a syringe to extract stem cells from the spinal fluid"
	icon = 'necromorphs/icons/obj/machines/ds13/bpl.dmi'
	icon_state = "stem_cells_still"

/obj/item/organ/fetus/Initialize()
	.=..()
	create_reagents(15)
	reagents.add_reagent(STEMCELL_REAGENT_PATH, 15)

