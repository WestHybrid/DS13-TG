#define COLOR_BIOMASS_GREEN "#82bf26"

//One unit (10ml) of purified liquid biomass can be multiplied by this value to create one kilogram of solid biomass
#define REAGENT_TO_BIOMASS	0.01

#define BIOMASS_TO_REAGENT	100

#define STEMCELLS_ORGAN 5
#define STEMCELLS_BODYPART 10

#define STEMCELL_REAGENT_PATH /datum/reagent/consumable/nutriment/stemcells
#define BIOMASS_REAGENT_PATH /datum/reagent/consumable/nutriment/biomass

GLOBAL_LIST_INIT(bpl_organs, list(
"heart" = /obj/item/organ/heart,
"eyes" = /obj/item/organ/eyes,
"ears" = /obj/item/organ/ears,
"tongue" = /obj/item/organ/tongue,
"lungs" = /obj/item/organ/lungs,
"liver" = /obj/item/organ/liver,
"stomach" = /obj/item/organ/stomach,
"appendix" = /obj/item/organ/appendix,
"left_arm" = /obj/item/bodypart/l_arm,
"right_arm" = /obj/item/bodypart/r_arm,
"left_leg" = /obj/item/bodypart/l_leg,
"right_leg" = /obj/item/bodypart/r_leg,
"stem_cells" = /obj/item/organ/fetus,
))
