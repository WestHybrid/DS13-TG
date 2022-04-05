/datum/reagent/consumable/nutriment/biomass
	name = "Purified Biomass"
	description = "A pasteurised organic soup for providing nutrition to growth tanks in clinical settings. \
	Technically safe for human consumption, but the taste is horrible."
	nutriment_factor = 15 * REAGENTS_METABOLISM
	taste_mult = 10
	reagent_state = LIQUID
	metabolization_rate = REM * 4
	color = COLOR_BIOMASS_GREEN

/datum/reagent/consumable/nutriment/stemcells
	name = "Stem Cells"
	description = "Partially differentiated cells that can be used as a baseline to grow various limbs and organs"
	taste_mult = 10
	nutriment_factor = 15 * REAGENTS_METABOLISM
	reagent_state = LIQUID
	metabolization_rate = REM * 4
	color = COLOR_PINK

/obj/item/reagent_containers/glass/bottle/stemcells
	name = "Stem Cell Clinical Sample"
	desc = "The essence of life"
	icon_state = "bottle-4"

/obj/item/reagent_containers/glass/bottle/stemcells/Initialize()
	.=..()
	reagents.add_reagent(STEMCELL_REAGENT_PATH, 10)
