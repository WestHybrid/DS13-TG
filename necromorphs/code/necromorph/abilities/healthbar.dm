#define HEALTHBAR_PIXEL_WIDTH 181
#define HEALTHBAR_PIXEL_HEIGHT 24

/datum/component/health_meter
	var/atom/movable/screen/health_meter/master
	var/mutable_appearance/health
	var/dm_filter/alpha_mask
	var/mutable_appearance/foreground

/datum/component/health_meter/Initialize()
	if(!istype(parent, /mob/living))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/holder = parent

	master = new

	health = mutable_appearance('necromorphs/icons/hud/healthbar.dmi', "health_grayscale")
	health.color = COLOR_CULT_RED
	alpha_mask = filter(type = "alpha", icon = icon('necromorphs/icons/hud/healthbar.dmi', "alpha_mask"), x = clamp(HEALTHBAR_PIXEL_WIDTH*(holder.health/holder.maxHealth), 0, HEALTHBAR_PIXEL_WIDTH), flags = MASK_INVERSE)
	health.filters += alpha_mask

	foreground = mutable_appearance('necromorphs/icons/hud/healthbar.dmi', "graphic")
	foreground.maptext_x = 73
	foreground.maptext_y = 8
	foreground.maptext_width = HEALTHBAR_PIXEL_WIDTH
	foreground.maptext = MAPTEXT("[max(0, holder.health)]/[holder.maxHealth]")

	master.overlays += health
	master.overlays += foreground

	if(holder.hud_used)
		holder.hud_used.infodisplay += master
		if(holder.client)
			holder.client.screen += master
	else
		RegisterSignal(holder, COMSIG_MOB_HUD_CREATED, .proc/on_hud_created)

	RegisterSignal(holder, COMSIG_CARBON_HEALTH_UPDATE, .proc/on_health_update)

/datum/component/health_meter/Destroy(force, silent)
	var/mob/living/holder = parent
	if(holder.hud_used)
		holder.hud_used.infodisplay -= master
		if(holder.client)
			holder.client.screen -= master
	QDEL_NULL(master)
	.=..()

/datum/component/health_meter/proc/on_hud_created(mob/living/source)
	source.hud_used.infodisplay += master
	if(source.client)
		source.client.screen += master
	UnregisterSignal(source, COMSIG_MOB_HUD_CREATED)

/datum/component/health_meter/proc/on_health_update(mob/living/source)
	SIGNAL_HANDLER
	alpha_mask.x = clamp(HEALTHBAR_PIXEL_WIDTH*(source.health/source.maxHealth), 0, HEALTHBAR_PIXEL_WIDTH)
	health.filters.Cut()
	health.filters += alpha_mask
	foreground.maptext = MAPTEXT("[max(0, source.health)]/[source.maxHealth]")
	master.overlays.Cut()
	master.overlays += health
	master.overlays += foreground

//Screen objects
/atom/movable/screen/health_meter
	icon = 'necromorphs/icons/hud/healthbar.dmi'
	icon_state = "backdrop"
	screen_loc = "TOP,CENTER-2:-8"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

#undef HEALTHBAR_PIXEL_WIDTH
#undef HEALTHBAR_PIXEL_HEIGHT
