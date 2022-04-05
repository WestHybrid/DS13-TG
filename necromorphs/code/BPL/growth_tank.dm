/atom/movable
	//Biomass is also measured in kilograms, its the organic mass in the atom. Is often zero
	var/biomass = 0



/*
	The growth tank is where organs are created

	Fetuses can be grown using only biomass
	Limbs and organs require stem cells, which are harvested from fetuses (as well as more biomass)
*/
/obj/machinery/growth_tank
	name = "growth tank"
	desc = "A vat for growing organic components."
	icon = 'necromorphs/icons/obj/machines/ds13/bpl.dmi'
	icon_state = "base"
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND

	density = TRUE
	anchored = TRUE
	drag_slowdown = 1.5

	var/max_biomass = 150 //1.5 Litre
	var/current_biomass = 0

	var/growing_organ
	var/organ_biomass = 0
	var/target_biomass = 0
	var/max_health = 0
	var/decay_factor = 0
	var/damage = 0
	var/decaying = FALSE
	var/idle = FALSE

	var/obj/machinery/computer/bpl/connected_console

	var/growth_rate = 1.2 //This many units of refined biomass are added to the forming organ each tick

	var/efficiency = 0.9 //Some of the biomass is wasted

	//Two tanks can be stacked vertically
	var/obj/machinery/growth_tank/up
	var/obj/machinery/growth_tank/below

/obj/machinery/growth_tank/Initialize()
	.=..()
	create_reagents(max_biomass)
	//If we find another tank in our turf, put ourselves ontop of it
	for(var/obj/machinery/growth_tank/tank in loc)
		if(tank != src && !tank.up && !tank.below)
			pixel_y = 24
			below = tank
			drag_slowdown = 3
			tank.drag_slowdown = 3
			tank.up = src
			tank.update_icon(UPDATE_ICON_STATE)
			break
	RegisterSignal(reagents, list(COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_REM_REAGENT), .proc/reagent_change)

/obj/machinery/growth_tank/MouseDrop_T(atom/A, mob/living/user)
	if(!istype(user) || user.stat || !Adjacent(user) || !Adjacent(A) || !isliving(A) || up || below || !istype(A, /obj/machinery/growth_tank))
		return
	if(do_after(user, 3 SECONDS, A))
		var/obj/machinery/growth_tank/tank = A
		up = tank
		drag_slowdown = 3
		tank.below = src
		tank.drag_slowdown = 3
		tank.pixel_y = 24
		tank.forceMove(loc)

/obj/machinery/growth_tank/examine(mob/user)
	.=..()
	if(growing_organ)
		if(!idle)
			var/obj/item/organ/organ = GLOB.bpl_organs[growing_organ]
			. += "It is currently growing [initial(organ.name)]"
			var/growth_progress = growth_progress()
			. += "Growth progress is [round(growth_progress*100,0.1)]%"
			var/total_time = (target_biomass / (growth_rate * REAGENT_TO_BIOMASS)) * SSmachines.wait
			var/remaining_time = total_time * (1 - growth_progress)
			. += "Estimated time remaining is [time2text(remaining_time, "mm:ss")]"

		var/biomass_percent = biomass / max_biomass
		if(biomass_percent <= 0.6)
			if(biomass_percent > 0.3)
				. += span_warning("The yellow warning light indicates biomass is below 60% and should be replenished.")
			else if(biomass_percent > 0)
				. += span_warning("The orange warning light indicates biomass is below 30% and must be replenished urgently.")
			else
				//The blinking red light appears when biomass has completely run out. At this point, the contained atom takes damage until it starves to death
				. += span_danger("The red warning light indicates there is no biomass remaining, the organ inside is starving to death and will lose viability soon.")
		else
			//If biomass is fine, then lets show some other lights
			if(!idle)
				//If the current growth thing is not done growing, then lets display a non-attention-grabbing still green light
				. += "The green light indicates it is functioning normally, no action needed."
			else
				//Its finished growing, lets have a flashy light to attract attention
				. += span_notice("The flashing green light indicates that growth is complete, the organ within is ready for harvesting or implantation")
	else
		. += "The light is off, it is not currently operating."

/obj/machinery/growth_tank/is_open_container()
	return TRUE

/obj/machinery/growth_tank/attack_hand(mob/living/carbon/human/user)
	.=..()
	if(.)
		return
	if(growing_organ && idle)
		remove_product(user)

/obj/machinery/growth_tank/process(delta_time)
	//If we have no biomass we do nothing
	if(!current_biomass || !growing_organ)
		turn_off()
		return

	//If we're growing something, try to consume some biomass and add it to the growing attom
	if(!idle && !decaying)
		var/change = reagents.get_reagent_amount(BIOMASS_REAGENT_PATH)
		change = clamp(growth_rate, 0, change)
		reagents.remove_reagent(BIOMASS_REAGENT_PATH, change)

		organ_biomass += change

		update_icon(UPDATE_OVERLAYS)

		if(growth_progress() >= 1.0)
			finish_growing()
	else if(decaying)
		damage = min(max_health, damage + (decay_factor * delta_time * max_health))

/obj/machinery/growth_tank/proc/reagent_change(datum/reagent/reagent, amount, reagtemp, data, no_react)
	SIGNAL_HANDLER
	if(istype(reagent, BIOMASS_REAGENT_PATH))
		current_biomass += amount
		if(current_biomass <= 0)
			set_is_operational(FALSE)
			if(growing_organ)
				decaying = TRUE
		else
			set_is_operational(TRUE)
			if(growing_organ)
				decaying = FALSE
		playsound(src, "bubble_small", VOLUME_MID)

/obj/machinery/growth_tank/proc/turn_on()
	if(!is_operational || !growing_organ || use_power > NO_POWER_USE)
		return FALSE

	if(!idle)
		update_use_power(ACTIVE_POWER_USE)
	else
		update_use_power(IDLE_POWER_USE)

	START_PROCESSING(SSmachines, src)

	update_icon(UPDATE_OVERLAYS)
	return TRUE

/obj/machinery/growth_tank/proc/turn_off()
	//We're already turned off
	if(use_power == NO_POWER_USE || growing_organ)
		return

	STOP_PROCESSING(SSmachines, src)
	update_use_power(NO_POWER_USE)

	update_icon(UPDATE_OVERLAYS)

/obj/machinery/growth_tank/proc/growth_progress()
	if(!growing_organ)
		return 0

	if(!idle)
		return (organ_biomass / target_biomass)
	else
		return 1
/obj/machinery/growth_tank/update_icon_state()
	.=..()
	if(up)
		icon_state = "base_up"
	else
		icon_state = "base"

/obj/machinery/growth_tank/update_overlays()
	.=..()
	var/biomass_percent = current_biomass / max_biomass
	var/liquid_color = BlendRGB("#e5ffb2", COLOR_BIOMASS_GREEN, biomass_percent)
	var/mutable_appearance/appearance

	if(growing_organ)
		//TODO here: Atom for the thing growing in the tank
		appearance = mutable_appearance(icon, growing_organ, alpha = 220)

		//Partially grown things are smaller
		if(!idle && growing_organ)
			appearance.transform.Scale(max(0.3, organ_biomass / target_biomass))
		appearance.transform.Turn(rand(-10, 10))	//Slight random rotation
		appearance.pixel_x += rand(-3, 3)
		appearance.pixel_y += rand(-3, 3)
		. += appearance

		//First of all, biomass warning lights
		if(biomass_percent <= 0.6)
			if(biomass_percent > 0.3)
				. += "light_yellow"
			else if(biomass_percent > 0)
				. += "light_orange"
			else
				//The blinking red light appears when biomass has completely run out. At this point, the contained atom takes damage until it starves to death
				.+="light_red"
				playsound(src, 'necromorphs/sound/machines/tankdanger.ogg', VOLUME_MID)
		else
			//If biomass is fine, then lets show some other lights
			if(growing_organ && !idle)
				//If the current growth thing is not done growing, then lets display a non-attention-grabbing still green light
				. += "light_green"
			else
				//Its finished growing, lets have a flashy light to attract attention
				. += "light_green_flashing"
	else
		//Nothing currently growing, the light turns off
		. += "light_off"

	//The liquid becomes more sickly pale as biomass depletes
	appearance = mutable_appearance(icon, "pod_liquid_grayscale")
	appearance.color = liquid_color
	. += appearance

	appearance = mutable_appearance(icon, "gradient_grayscale", alpha = 190)
	appearance.color = liquid_color
	. += appearance

	appearance = mutable_appearance(icon, pick("bubbles1", "bubbles2", "bubbles3"))
	appearance.color = liquid_color
	. += appearance

	appearance = mutable_appearance(icon, "shine", alpha = 220)
	appearance.color = liquid_color
	. += appearance

/obj/machinery/growth_tank/proc/remove_product(mob/living/carbon/human/user)
	if(!growing_organ)
		return

	idle = FALSE
	var/obj/item/organ/organ = new GLOB.bpl_organs[growing_organ]
	organ.biomass = organ_biomass
	organ.applyOrganDamage(damage)

	target_biomass = initial(target_biomass)
	organ_biomass = initial(organ_biomass)
	damage = initial(damage)
	max_health = initial(max_health)
	growing_organ = initial(growing_organ)

	if(user)
		//organ.forceMove(user.loc)
		user.put_in_hands(organ)
	else
		organ.forceMove(loc)

	turn_off()

/obj/machinery/growth_tank/proc/finish_growing()
	idle = TRUE
	playsound(src, 'necromorphs/sound/machines/tankconfirm.ogg', VOLUME_MID)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/growth_tank/proc/dump_organ()
	if(!idle)
		var/obj/item/organ/forming/organ = new /obj/item/organ/forming
		var/obj/item/organ/organ_type = GLOB.bpl_organs[growing_organ]
		organ.organ_flags &= ORGAN_FROZEN
		organ.name = initial(organ_type.name)
		organ.icon = initial(organ_type.icon)
		organ.icon_state = initial(organ_type.icon_state)
		organ.biomass = organ_biomass
		organ.applyOrganDamage(damage)

		target_biomass = initial(target_biomass)
		organ_biomass = initial(organ_biomass)
		damage = initial(damage)
		max_health = initial(max_health)
		growing_organ = initial(growing_organ)

		organ.forceMove(loc)
		turn_off()


/*
	Console
*/


/obj/machinery/computer/bpl
	name = "bioprotestic console"
	desc = "Used to control bioprotestic growth tanks."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	light_color = COLOR_DARK_MODERATE_LIME_GREEN
	var/obj/machinery/growth_tank/selected_tank
	var/list/obj/machinery/growth_tank/connected_tanks = list()
	COOLDOWN_DECLARE(resync)

/obj/machinery/computer/bpl/Initialize(mapload, obj/item/circuitboard/C)
	.=..()
	connect_nearby_tanks()

/obj/machinery/computer/bpl/proc/connect_nearby_tanks()
	//Disconnect all tanks first to prevent duplicate names
	disconnect_tanks()
	for(var/obj/machinery/growth_tank/tank in range(6, src))
		if(tank.connected_console)
			continue
		connected_tanks += tank
		tank.name = "[tank.name] [connected_tanks.len]"
		tank.connected_console = src

/obj/machinery/computer/bpl/proc/disconnect_tanks()
	for(var/obj/machinery/growth_tank/tank as anything in connected_tanks)
		tank.name = initial(tank.name)
		tank.connected_console = null
	connected_tanks.Cut()

/obj/machinery/computer/bpl/Destroy()
	disconnect_tanks()
	.=..()

/obj/machinery/computer/bpl/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BioprotesticConsole", "Bioprotestic Console")
		ui.open()

/obj/machinery/computer/bpl/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/bpl_organs))

/obj/machinery/computer/bpl/ui_data(mob/user)
	var/list/data = list()
	if(selected_tank)
		data["selected_tank"] = REF(selected_tank)
		data["max_biomass"] = selected_tank.max_biomass
		data["current_biomass"] = selected_tank.current_biomass
		if(selected_tank.growing_organ)
			data["growing_organ"] = selected_tank.growing_organ
			data["organ_biomass"] = selected_tank.organ_biomass
			data["target_biomass"] = selected_tank.target_biomass
			data["damage"] = selected_tank.damage
			data["decaying"] = selected_tank.decaying
			data["idle"] = selected_tank.idle
	return data

/obj/machinery/computer/bpl/ui_static_data(mob/user)
	var/list/data = list()
	data["organs"] = list()
	for(var/organ_name in GLOB.bpl_organs)
		var/obj/item/organ/organ = GLOB.bpl_organs[organ_name]
		data["organs"] += list(list(
			"name" = initial(organ.name),
			"icon_name" = organ_name,
			"biomass_required" = initial(organ.biomass),
			"stemcells_required" = ispath(organ, /obj/item/organ) ? STEMCELLS_ORGAN : STEMCELLS_BODYPART
		))

	data["tanks"] = list()
	for(var/obj/machinery/growth_tank/tank as anything in connected_tanks)
		data["tanks"] += list(list(
			"name" = tank.name,
			"id" = REF(tank),
		))
	return data

/obj/machinery/computer/bpl/ui_act(action, list/params)
	.=..()
	if(.)
		return
	switch(action)
		if("select_tank")
			selected_tank = locate(params["id"]) in connected_tanks
			.=TRUE
		if("start_growing")
			if(!selected_tank?.growing_organ)
				return
			var/obj/item/organ/organ = GLOB.bpl_organs[params["organ_name"]]
			var/stemcell_cost = ispath(organ, /obj/item/organ) ? STEMCELLS_ORGAN : STEMCELLS_BODYPART
			if(selected_tank.reagents.get_reagent_amount(STEMCELL_REAGENT_PATH) < stemcell_cost)
				return
			selected_tank.reagents.remove_reagent(STEMCELL_REAGENT_PATH, stemcell_cost)
			selected_tank.growing_organ = params["organ_name"]
			selected_tank.target_biomass = initial(organ.biomass)
			playsound(selected_tank, "bubble", VOLUME_MID)
			selected_tank.turn_on()
			.=TRUE
		if("dump_organ")
			if(!selected_tank?.growing_organ)
				return
			selected_tank.dump_organ()
			.=TRUE
		if("dump_useless_reagents")
			for(var/datum/reagent/reagent as anything in reagents.reagent_list)
				if(istype(reagent, BIOMASS_REAGENT_PATH) || istype(reagent, STEMCELL_REAGENT_PATH))
					continue
				reagents.del_reagent(reagent.type)
			.=TRUE
		if("resync_tanks")
			if(!COOLDOWN_FINISHED(src, resync))
				return
			//Making sure people won't spam with range(6, src)
			COOLDOWN_START(src, resync, 3 SECONDS)
			connect_nearby_tanks()
			.=TRUE
