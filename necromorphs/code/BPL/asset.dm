/datum/asset/spritesheet/bpl_organs
	name = "bpl_organs"

/datum/asset/spritesheet/bpl_organs/create_spritesheets()
	for(var/organ_name in GLOB.bpl_organs)
		Insert(organ_name, icon('necromorphs/icons/obj/machines/ds13/bpl.dmi', organ_name))
