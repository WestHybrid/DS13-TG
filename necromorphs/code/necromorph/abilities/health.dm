#define HEALTHBAR_PIXEL_WIDTH 220
#define HEALTHBAR_PIXEL_HEIGHT 25

/datum/component/necro_health_meter
	var/atom/movable/screen/health_meter/background/background
	var/atom/movable/screen/health_meter/lost/lost
	var/atom/movable/screen/health_meter/foreground/foreground
	var/atom/movable/screen/health_meter/text_holder

/datum/component/necro_health_meter/Initialize()
	if(!istype(parent, /mob/living/carbon))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/carbon/holder = parent

	if(!holder?.dna?.species)
		return COMPONENT_INCOMPATIBLE

	background = new
	lost = new
	foreground = new
	text_holder = new



	text_holder.maptext_y = 14
	text_holder.maptext_width = HEALTHBAR_PIXEL_WIDTH
	text_holder.maptext = MAPTEXT("[holder.health]/[holder.maxHealth]")

	if(holder.hud_used)
		holder.hud_used.infodisplay += background
		holder.hud_used.infodisplay += lost
		holder.hud_used.infodisplay += foreground
		holder.hud_used.infodisplay += text_holder
		if(holder.client)
			holder.client.screen += background
			holder.client.screen += lost
			holder.client.screen += foreground
			holder.client.screen += text_holder
	else
		RegisterSignal(holder, COMSIG_MOB_HUD_CREATED, .proc/on_hud_created)

	if(holder.health < 0 || (holder.stat == DEAD && !HAS_TRAIT(holder, TRAIT_FAKEDEATH)))
		holder.death()
	else
		RegisterSignal(holder, COMSIG_CARBON_HEALTH_UPDATE, .proc/on_health_update)

/datum/component/necro_health_meter/Destroy(force, silent)
	QDEL_NULL(background)
	QDEL_NULL(foreground)
	QDEL_NULL(lost)
	.=..()

/datum/component/necro_health_meter/proc/on_hud_created(mob/living/carbon/source)
	source.hud_used.infodisplay += background
	source.hud_used.infodisplay += lost
	source.hud_used.infodisplay += foreground
	source.hud_used.infodisplay += text_holder
	if(source.client)
		source.client.screen += background
		source.client.screen += lost
		source.client.screen += foreground
		source.client.screen += text_holder

/datum/component/necro_health_meter/proc/on_health_update(mob/living/carbon/source)
	SIGNAL_HANDLER
	text_holder.maptext = MAPTEXT("[source.health]/[source.maxHealth]")

	if(source.health < 0)
		// If necromorph is dead - kill it
		source.death()
		UnregisterSignal(source, COMSIG_CARBON_HEALTH_UPDATE)



#undef HEALTHBAR_PIXEL_WIDTH
#undef HEALTHBAR_PIXEL_HEIGHT
