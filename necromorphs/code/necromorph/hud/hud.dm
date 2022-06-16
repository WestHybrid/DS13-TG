//Health meter
/atom/movable/screen/health_meter
	icon = 'necromorphs/icons/hud/health.dmi'
	screen_loc = "CENTER,TOP"
	mouse_opacity = MOUSE_OPACITY_OPAQUE

/atom/movable/screen/health_meter/background
	icon_state = "background"

/atom/movable/screen/health_meter/foreground
	icon_state = "foreground"

/atom/movable/screen/health_meter/lost
	icon_state = "lost"

/atom/movable/screen/health_meter/text_holder
	icon_state = "text"

//An actual HUD
/atom/movable/screen/necromorph
	icon = 'icons/hud/screen_midnight.dmi'

/datum/hud/necromorph
	ui_style = 'icons/hud/screen_midnight.dmi'

/datum/hud/necromorph/New(mob/living/carbon/necromorph/owner)
	..()

	var/atom/movable/screen/using

//equippable shit

//hands
	build_hand_slots()

//begin buttons

	using = new /atom/movable/screen/swap_hand()
	using.icon = ui_style
	using.icon_state = "swap_1"
	using.screen_loc = ui_swaphand_position(owner,1)
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/swap_hand()
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand_position(owner,2)
	using.hud = src
	static_inventory += using

	action_intent = new /atom/movable/screen/combattoggle/flashy()
	action_intent.hud = src
	action_intent.icon = ui_style
	action_intent.screen_loc = ui_combat_toggle
	static_inventory += action_intent

	using = new/atom/movable/screen/language_menu
	using.icon = ui_style
	using.screen_loc = ui_alien_language_menu
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/navigate
	using.icon = ui_style
	using.screen_loc = ui_alien_navigate_menu
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/drop()
	using.icon = ui_style
	using.screen_loc = ui_drop_throw
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/resist()
	using.icon = ui_style
	using.screen_loc = ui_above_movement
	using.hud = src
	hotkeybuttons += using

	throw_icon = new /atom/movable/screen/throw_catch()
	throw_icon.icon = ui_style
	throw_icon.screen_loc = ui_drop_throw
	throw_icon.hud = src
	hotkeybuttons += throw_icon

	pull_icon = new /atom/movable/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_above_movement
	pull_icon.hud = src
	static_inventory += pull_icon

	zone_select = new /atom/movable/screen/zone_sel()
	using.icon = ui_style
	zone_select.hud = src
	zone_select.update_appearance()
	static_inventory += zone_select

	for(var/atom/movable/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[TOBITSHIFT(inv.slot_id) + 1] = inv
			inv.update_appearance()

/datum/hud/necromorph/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/necromorph/H = mymob
	if(hud_version != HUD_STYLE_NOHUD)
		for(var/obj/item/I in H.held_items)
			I.screen_loc = ui_hand_position(H.get_held_index_of_item(I))
			H.client.screen += I
	else
		for(var/obj/item/I in H.held_items)
			I.screen_loc = null
			H.client.screen -= I
