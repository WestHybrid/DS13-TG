
/*
	The growth tank is where organs are created

	Fetuses can be grown using only biomass
	Limbs and organs require stem cells, which are harvested from fetuses (as well as more biomass)
*/

/obj/machinery/growth_tank
	name = "growth tank"
	desc = "A vat for growing organic components."
	icon = 'necromorphs/icons/obj/machines/bpl.dmi'
	icon_state = "base"
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	density = TRUE
	anchored = TRUE
	drag_slowdown = 1.5
	move_resist = MOVE_RESIST_DEFAULT
	/// Storage for our reagents holder in case we are on top of something
	var/datum/reagents/temp_holder
	/// The console we are connected to.
	var/obj/machinery/computer/bpl/connected_console
	/// Two tanks can be stacked vertically.
	var/obj/machinery/growth_tank/up
	var/obj/machinery/growth_tank/below
	/// The design we're printing currently.
	var/datum/design/being_built
	/// If we're currently printing something.
	var/busy = FALSE
	/// How efficient our machine is. Better parts = less chemicals used and less power used. Range of 1 to 0.25.
	/// Lower is better.
	var/production_coefficient = 1
	/// How long it takes for us to print a limb. Affected by production_coefficient.
	var/production_speed = 5 MINUTES

/obj/machinery/growth_tank/Initialize()
	create_reagents(100, OPENCONTAINER)
	temp_holder = reagents
	.=..()

/obj/machinery/growth_tank/LateInitialize()
	.=..()
	//If we find another tank in our turf, put it ontop of us
	if(!below)
		AddComponent(/datum/component/plumbing/simple_demand)
		for(var/obj/machinery/growth_tank/tank in loc.contents-src)
			if(put_tank_above(tank))
				tank.anchored = TRUE
				tank.reagents = reagents
				break

/obj/machinery/growth_tank/Destroy()
	if(up)
		up.below = null
		up.pixel_y = 0
	else if(below)
		below.up = null
		below.update_icon(UPDATE_ICON_STATE)
	.=..()

/obj/machinery/growth_tank/update_icon_state()
	.=..()
	icon_state = "base"
	if(being_built)
		icon_state = "[icon_state]_growing"
	if(up)
		icon_state = "[icon_state]_up"

/obj/machinery/growth_tank/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/our_beaker in component_parts)
		reagents.maximum_volume += our_beaker.volume
		our_beaker.reagents.trans_to(src, our_beaker.reagents.total_volume)
	production_coefficient = 1.25
	for(var/obj/item/stock_parts/manipulator/our_manipulator in component_parts)
		production_coefficient -= our_manipulator.rating * 0.25
	production_coefficient = clamp(production_coefficient, 0, 1)

/obj/machinery/growth_tank/can_be_pulled(user, grab_state, force)
	.=..()
	if(up || below)
		. = FALSE

/obj/machinery/growth_tank/on_deconstruction()
	for(var/obj/item/reagent_containers/glass/our_beaker in component_parts)
		reagents.trans_to(our_beaker, our_beaker.reagents.maximum_volume)
	.=..()

/obj/machinery/growth_tank/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	.=..()
	if(!istype(usr) || usr.stat || !Adjacent(usr) || !usr.Adjacent(over) || up)
		return
	if(istype(over, /obj/machinery/growth_tank))
		var/obj/machinery/growth_tank/tank = over
		if((!tank.below && !tank.up) && tank.anchored && do_after(usr, 3 SECONDS, src))
			tank.put_tank_above(src)
	else if(below && !anchored && do_after(usr, 3 SECONDS, src))
		below.up = null
		below.update_icon(UPDATE_ICON_STATE)
		below.move_resist = MOVE_RESIST_DEFAULT
		move_resist = MOVE_RESIST_DEFAULT
		below = null
		pixel_y = 0
		forceMove(get_turf(over))
		if(!length(GetComponents(/datum/component/plumbing/simple_demand)))
			AddComponent(/datum/component/plumbing/simple_demand)

/obj/machinery/growth_tank/proc/put_tank_above(obj/machinery/growth_tank/tank)
	.=FALSE
	if(istype(tank, /obj/machinery/growth_tank) || tank != src && !tank.up && !tank.below && !up && !below)
		tank.pixel_y = 24
		up = tank
		tank.below = src
		//Prevent any kind of pulling
		move_resist = INFINITY
		tank.move_resist = INFINITY
		update_icon(UPDATE_ICON_STATE)
		var/list/components = GetComponents(/datum/component/plumbing/simple_demand)
		QDEL_LIST(components)
		tank.forceMove(loc)
		.=TRUE

/obj/machinery/growth_tank/wrench_act(mob/living/user, obj/item/tool)
	if(!up && default_unfasten_wrench(user, tool) == SUCCESSFUL_UNFASTEN)
		.=TRUE
	if(anchored && below)
		//Lets share the same reagent storage to prevent plumbing fuckery
		reagents = below.reagents
	else
		reagents = temp_holder

/obj/machinery/growth_tank/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	if(!up || !below)
		.=..()

/obj/machinery/growth_tank/on_deconstruction()
	for(var/obj/item/reagent_containers/glass/our_beaker in component_parts)
		reagents.trans_to(our_beaker, our_beaker.reagents.maximum_volume)
	.=..()

/obj/machinery/growth_tank/is_open_container()
	return TRUE

/obj/machinery/growth_tank/proc/build_item(list/modified_consumed_reagents_list)
	var/built_typepath = being_built.build_path
	// If we have a bodypart, we need to initialize the limb on its own. Otherwise we can build it here.
	if(ispath(built_typepath, /obj/item/bodypart))
		build_limb(built_typepath)
	else
		new built_typepath(loc)

	busy = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/growth_tank/proc/build_limb(buildpath, building_category)
	/// The limb we're making with our buildpath, so we can edit it.
	var/obj/item/bodypart/limb = new buildpath(loc)
	/// Species with greyscale limbs.
	var/list/greyscale_species = list(SPECIES_HUMAN, SPECIES_LIZARD, SPECIES_ETHEREAL)
	if(building_category in greyscale_species) //Species with greyscale parts should be included here
		if(building_category == SPECIES_HUMAN) //humans don't use the full colour spectrum, they use random_skin_tone
			limb.skin_tone = random_skin_tone()
		else
			limb.species_color = "#[random_color()]"
		limb.icon = 'icons/mob/human_parts_greyscale.dmi'
		limb.should_draw_greyscale = TRUE
	else
		limb.icon = 'icons/mob/human_parts.dmi'

	// Set this limb up using the species name and body zone
	limb.icon_state = "[building_category]_[limb.body_zone]"
	limb.name = "\improper biosynthetic [building_category] [parse_zone(limb.body_zone)]"
	limb.desc = "A synthetically produced [building_category] limb, grown in a tube. This one is for the [parse_zone(limb.body_zone)]."
	limb.species_id = building_category
	limb.update_icon_dropped()
	limb.original_owner = WEAKREF(src)  //prevents updating the icon, so a lizard arm on a human stays a lizard arm etc.

/*
	BPL Console
*/

/obj/machinery/computer/bpl
	name = "bioprotestic console"
	desc = "Used to control bioprotestic growth tanks."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	light_color = COLOR_DARK_MODERATE_LIME_GREEN
	/// The growth tank we selected.
	var/obj/machinery/growth_tank/selected_tank
	/// List of connected tanks.
	var/list/obj/machinery/growth_tank/connected_tanks = list()
	/// The category of limbs we're browing in our UI.
	var/selected_category = SPECIES_HUMAN
	/// Our internal techweb for growth tank designs.
	var/datum/techweb/stored_research
	/// All the categories of organs we can print.
	var/list/categories = list(SPECIES_HUMAN, SPECIES_LIZARD, SPECIES_MOTH, SPECIES_PLASMAMAN, SPECIES_ETHEREAL, "other")

/obj/machinery/computer/bpl/Initialize(mapload, obj/item/circuitboard/C)
	stored_research = new /datum/techweb/specialized/autounlocking/limbgrower
	.=..()

/obj/machinery/computer/bpl/attackby(obj/item/user_item, mob/living/user, params)
	if(istype(user_item, /obj/item/disk/design_disk/limbs))
		user.visible_message(span_notice("[user] begins to load \the [user_item] in \the [src]..."),
			span_notice("You begin to load designs from \the [user_item]..."),
			span_hear("You hear the clatter of a floppy drive."))
		var/obj/item/disk/design_disk/limbs/limb_design_disk = user_item
		if(do_after(user, 2 SECONDS, target = src))
			for(var/datum/design/found_design in limb_design_disk.blueprints)
				stored_research.add_design(found_design)
			update_static_data(user)
		return
	.=..()

/// Emagging a limbgrower allows you to build synthetic armblades.
/obj/machinery/computer/bpl/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	for(var/design_id in SSresearch.techweb_designs)
		var/datum/design/found_design = SSresearch.techweb_design_by_id(design_id)
		if((found_design.build_type & LIMBGROWER) && ("emagged" in found_design.category))
			stored_research.add_design(found_design)
	to_chat(user, span_warning("Safety overrides have been deactivated!"))
	obj_flags |= EMAGGED
	update_static_data(user)

/obj/machinery/limbgrower/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BioprotesticConsole", "Bioprotestic Console")
		ui.open()

/obj/machinery/computer/bpl/ui_data(mob/user)
	var/list/data = list()

	if(selected_tank)
		data["selected_tank"] = REF(selected_tank)

		for(var/datum/reagent/reagent_id in selected_tank.reagents.reagent_list)
			var/list/reagent_data = list(
				reagent_name = reagent_id.name,
				reagent_amount = reagent_id.volume,
				reagent_type = reagent_id.type
			)
			data["reagents"] += list(reagent_data)

		data["total_reagents"] = selected_tank.reagents.total_volume
		data["max_reagents"] = selected_tank.reagents.maximum_volume
		data["busy"] = selected_tank.busy
		data["production_coefficient"] = selected_tank.production_coefficient
	return data

/obj/machinery/computer/bpl/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = list()

	var/species_categories = categories.Copy()
	for(var/species in species_categories)
		species_categories[species] = list()
	for(var/design_id in stored_research.researched_designs)
		var/datum/design/limb_design = SSresearch.techweb_design_by_id(design_id)
		for(var/found_category in species_categories)
			if(found_category in limb_design.category)
				species_categories[found_category] += limb_design

	for(var/category in species_categories)
		var/list/category_data = list(
			name = category,
			designs = list(),
		)
		for(var/datum/design/found_design in species_categories[category])
			var/list/all_reagents = list()
			for(var/reagent_typepath in found_design.reagents_list)
				var/datum/reagent/reagent_id = find_reagent_object_from_type(reagent_typepath)
				var/list/reagent_data = list(
					name = reagent_id.name,
					amount = found_design.reagents_list[reagent_typepath],
				)
				all_reagents += list(reagent_data)

			category_data["designs"] += list(list(
				parent_category = category,
				name = found_design.name,
				id = found_design.id,
				needed_reagents = all_reagents,
			))

		data["categories"] += list(category_data)

	data["connected_tanks"] = list()
	for(var/obj/machinery/growth_tank/tank as anything in connected_tanks)
		data["connected_tanks"] += list(list(
			name = tank.name,
			ref = REF(tank),
		))

	return data

/obj/machinery/computer/bpl/ui_act(action, list/params)
	.=..()
	if(.)
		return

	if(selected_tank.busy)
		to_chat(usr, span_warning("The growth tank is busy. Please wait for completion of previous operation."))
		return

	switch(action)
		if("resync_tanks")
			connect_nearby_tanks()

		if("select_tank")
			var/obj/machinery/growth_tank/tank = locate(params["tank"]) in connected_tanks
			if(tank)
				selected_tank = tank

		if("make_limb")
			if(!selected_tank || selected_tank.being_built)
				return
			var/datum/design/design = stored_research.isDesignResearchedID(params["design_id"])
			if(!design)
				CRASH("[src] was passed an invalid design id!")

			/// All the reagents we're using to make our organ.
			var/list/consumed_reagents_list = design.reagents_list.Copy()
			/// The amount of power we're going to use, based on how much reagent we use.
			var/power = 0
			if(ispath(design.build_path, /obj/item/bodypart))
				consumed_reagents_list[STEMCELL_REAGENT_PATH] = STEMCELLS_BODYPART
			else
				consumed_reagents_list[STEMCELL_REAGENT_PATH] = STEMCELLS_ORGAN

			for(var/reagent_id in consumed_reagents_list)
				consumed_reagents_list[reagent_id] *= selected_tank.production_coefficient
				//You can replace synthflesh with biomass
				if(ispath(reagent_id, /datum/reagent/medicine/c2/synthflesh))
					var/synthflesh = selected_tank.reagents.has_reagent(reagent_id)
					var/biomass = selected_tank.reagents.has_reagent(BIOMASS_REAGENT_PATH)
					if(synthflesh < consumed_reagents_list[reagent_id])
						if(biomass < (consumed_reagents_list[reagent_id]-synthflesh)*2)
							audible_message(span_notice("The [src] buzzes."))
							playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
							return
						consumed_reagents_list[BIOMASS_REAGENT_PATH] = (consumed_reagents_list[reagent_id]-synthflesh)*2
						consumed_reagents_list[reagent_id] = synthflesh

				else if(!selected_tank.reagents.has_reagent(reagent_id, consumed_reagents_list[reagent_id]))
					audible_message(span_notice("The [src] buzzes."))
					playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
					return

				power = max(2000, (power + consumed_reagents_list[reagent_id]))

			for(var/reagent_id in consumed_reagents_list)
				selected_tank.reagents.remove_reagent(reagent_id, consumed_reagents_list[reagent_id])

			selected_tank.busy = TRUE
			use_power(power)
			selected_tank.being_built = design
			selected_tank.update_icon(UPDATE_ICON_STATE)
			addtimer(CALLBACK(selected_tank, /obj/machinery/growth_tank/proc/build_item, consumed_reagents_list, params["sel_cat"]), selected_tank.production_speed * selected_tank.production_coefficient)
			. = TRUE

/obj/machinery/computer/bpl/proc/connect_nearby_tanks()
	for(var/obj/machinery/growth_tank/tank in connected_tanks)
		tank.connected_console = null
	connected_tanks.Cut()
	for(var/obj/machinery/growth_tank/tank in hearers(5, src))
		if(!tank.connected_console)
			connected_tanks += tank
			tank.connected_console = src
