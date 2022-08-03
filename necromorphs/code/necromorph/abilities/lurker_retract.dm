// Lurker Add- Lurker Tentacle bodyparts to the mob,

/datum/action/cooldown/necro/lurker_retract
	name = "Retract"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Allows you to charge at a chosen position."
	cooldown_time = 1.5 SECONDS
	click_to_activate = TRUE

	// Deploy Tentacles and Enable Attacks
	var/deploy

	//A list of organ tags to retract when we close the cover
	var/list/retract_limbs

	cooldown_time = 5 SECONDS
	shared_cooldown = MOB_SHARED_COOLDOWN_2
	/// The max possible cooldown, cooldown is random between the default cooldown time and this
	var/max_cooldown_time = 10 SECONDS

/datum/action/cooldown/necro/lurker_retract/Activate(atom/target_atom)
	StartCooldown(100)
	do_transform(target_atom)
	StartCooldown(rand(cooldown_time, max_cooldown_time))


