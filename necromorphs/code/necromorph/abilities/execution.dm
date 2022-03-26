//Global assoc list wiith all execution stages
GLOBAL_LIST_INIT_TYPED(execution_stages, /datum/execution_stage, list(); for(var/type in subtypesof(/datum/execution_stage)) execution_stages[type] = new type;)
#define span_execution(str) ("<span class='execution'>" + str + "</span>")



#define EXECUTION_CANCEL	-1	//The whole move has gone wrong, abort
#define EXECUTION_RETRY		0	//Its not right yet but will probably fix itself, delay and keep trying
#define EXECUTION_CONTINUE	1	//Its fine, keep going
#define EXECUTION_SUCCESS 2	//We have achieved victory conditions. Try to skip to the end
#define EXECUTION_SAFETY	if(safety_check() == EXECUTION_CANCEL && can_interrupt){\
	interrupt();\
	return}

#define STATUS_NOT_STARTED	0
#define STATUS_STARTING		1
#define STATUS_PRE_FINISH	2
#define STATUS_POST_FINISH	3
#define STATUS_ENDED		4

/datum/execution_stage
	//How long to remain in this stage before moving to the next one
	var/duration = 1 SECONDS

	//In the case that we fail to advance when our duration ends
	var/retry_time = 1 SECONDS

	var/max_retries = 10

	//If not null, this overrides the range of the execution while active
	var/range = null

/datum/execution_stage/New()
	.=..()

/datum/execution_stage/proc/enter()
	return TRUE

//Here, do safety checks to see if everything is in order for being able to advance to the next stage. Return true/false appropriately
/datum/execution_stage/proc/can_advance()
	return EXECUTION_CONTINUE

//Here, do safety checks to see if its okay to continue the execution move
/datum/execution_stage/proc/safety()
	return EXECUTION_CONTINUE

//Called when we finish this stage and move to the next one
/datum/execution_stage/proc/exit()
	return TRUE

//Called on this stage when the execution is interrupted. Use this to add consequences of failure
/datum/execution_stage/proc/interrupt()
	return TRUE

//Called on this stage when the execution is completed. NOT when this specific stage finishes, that's exit()
/datum/execution_stage/proc/complete()
	return TRUE

//Called when the execution finishes, by both interrupt and complete. Use this to clean up assets and effects
/datum/execution_stage/proc/stop()
	return TRUE

//Called to make a stage advance early, before its duration is up
/datum/execution_stage/proc/advance(datum/action/cooldown/necro/execute/host)
	host.try_advance_stage()







/datum/action/cooldown/necro/execute
	name = "Execute"
	cooldown_time = 20 SECONDS
	var/button_added = FALSE

	var/status = STATUS_NOT_STARTED
	var/mob/living/victim

	//Weapon vars: Indicates a tool, implement, bodypart, etc, which we are using to do this execution.
	//Optional, not always used
	var/atom/movable/weapon

	//Reward Handling
	//-------------------
	//Used to make sure finish only runs once
	var/success = FALSE //If true, we have already finished the success condition. Check this to skip things in other stages
	var/finished = FALSE

	var/reward_biomass = 0
	var/reward_energy = 0
	var/reward_heal = 0


	//Aquisition vars
	//-----------------------
	//If true, this execution requires the victim to be grabbed at the start, and held in a grab throughout the move
	//Can also be set to a number, in which case it only requires a grab from that step onwards
	//In either case, grab is no longer required after the finisher
	var/require_grab = TRUE

	//If true this cannot be performed on corpses, victim must be alive at the start
	var/require_alive = TRUE

	//The victim must remain with this distance of the attacker, or the move fails
	var/range = 1

	//Before the first stage, we can commence the execution within this range
	var/start_range = 1

	//A delay before acquisition happens
	var/windup_time = 0

	//If the user of this is a necromorph, send a message on necromorph channel telling everyone to come watch
	var/notify_necromorphs = TRUE

	//Stage handling
	//----------------------
	//All the stages that we will eventually execute
	//This should be a list of typepaths
	var/list/datum/execution_stage/all_stages = list()

	//What entry in the all stages list we're currently working on
	var/current_stage_index = 0

	//How many times we have retried the current stage when it failed to advance
	//If we hit the stage's max retries, we abort the whole execution
	//Reset to 0 upon entering a new stage
	var/retries = 0

	//Interrupt Handling
	//--------------------
	var/interrupt_damage_threshold = 40 //If the user takes this much total damage from hits while performing the attack, it is cancelled
	var/hit_damage_taken = 0

	//Is the execution currently in a state where it could be interrupted?
	//This is set true on the start of stages, and set false after a finisher stage
	var/can_interrupt = FALSE


/datum/action/cooldown/necro/execute/New(Target, cooldown)
	.=..()

/datum/action/cooldown/necro/execute/Destroy()
	.=..()

/datum/action/cooldown/necro/execute/Grant(mob/M)
	if(M)
		if(owner)
			if(owner == M)
				return
			Remove(owner)
		owner = M
		RegisterSignal(owner, COMSIG_PARENT_QDELETING, .proc/clear_ref, override = TRUE)
		RegisterSignal(owner, COMSIG_ATOM_START_PULL, .proc/on_grab)
		UpdateButtonIcon()
		if(next_use_time > world.time)
			AddButton()
			START_PROCESSING(SSfastprocess, src)
	else
		Remove(owner)

/datum/action/cooldown/necro/execute/StartCooldown(override_cooldown_time)
	AddButton()
	.=..()

/datum/action/cooldown/necro/execute/CooldownEnd()
	if(!owner.pulling || !(owner.grab_state < GRAB_NECK))
		RemoveButton()

/datum/action/cooldown/necro/execute/proc/AddButton()
	if(!button_added)
		//button id generation
		var/counter = 0
		var/bitfield = 0
		for(var/datum/action/A in owner.actions)
			if(A.name == name && A.button.id)
				counter += 1
				bitfield |= A.button.id
		bitfield = ~bitfield
		var/bitflag = 1
		for(var/i in 1 to (counter + 1))
			if(bitfield & bitflag)
				button.id = bitflag
				break
			bitflag *= 2

		LAZYADD(owner.actions, src)
		if(owner.client)
			owner.client.screen += button
			button.locked = owner.client.prefs.read_preference(/datum/preference/toggle/buttons_locked) || button.id ? owner.client.prefs.action_buttons_screen_locs["[name]_[button.id]"] : FALSE //even if it's not defaultly locked we should remember we locked it before
			button.moved = button.id ? owner.client.prefs.action_buttons_screen_locs["[name]_[button.id]"] : FALSE
		owner.update_action_buttons()

/datum/action/cooldown/necro/execute/proc/RemoveButton()
	if(button_added)
		if(owner)
			if(owner.client)
				owner.client.screen -= button
			LAZYREMOVE(owner.actions, src)
			owner.update_action_buttons()
		button.moved = FALSE //so the button appears in its normal position when given to another owner.
		button.locked = FALSE
		button.id = null

/datum/action/cooldown/necro/execute/proc/on_grab(datum/source, pulled_atom, state, force)
	if(state >= GRAB_NECK)
		AddButton()
	else
		RemoveButton()
		interrupt()

/datum/action/cooldown/necro/execute/Activate(mob/living/target)
	var/mob/living/carbon/holder = owner
	if(!isliving(target) || status > STATUS_NOT_STARTED || (require_alive && target.stat == DEAD))
		return
	.=..()
	victim = target

	status = STATUS_STARTING
	//First of all, we do windup
	holder.Stun(windup_time, TRUE)
	sleep(windup_time)


	holder.face_atom(victim)

	//If we failed to aquire a target, just stop immediately
	if(safety_check() != EXECUTION_CONTINUE)
		return


	status = STATUS_PRE_FINISH

	//Alright we're clear to proceed
	if(holder.is_necromorph() && notify_necromorphs)
		link_necromorphs_to(span_execution("[holder] is performing [name] at LINK"), victim)

	//Lets setup handling for future interruption
	can_interrupt = TRUE

	RegisterSignal(holder, COMSIG_MOB_APPLY_DAMAGE, .proc/on_owner_damage)

	try_advance_stage()

/datum/action/cooldown/necro/execute/proc/safety_check()
	.=EXECUTION_CONTINUE

	//If we needed a grab, check that we have it and its valid
	if(require_grab && require_grab <= current_stage_index)
		if(!owner.pulling || owner.grab_state < GRAB_NECK)
			return EXECUTION_CANCEL

	//Gotta be close enough
	if(get_dist(owner, victim) > get_range())
		return EXECUTION_CANCEL

	for(var/i in 1 to current_stage_index)
		var/result = GLOB.execution_stages[all_stages[i]].safety(src)
		if(result != EXECUTION_CONTINUE)
			return result

/datum/action/cooldown/necro/execute/proc/on_owner_damage(attacker, damage, damagetype, def_zone)
	hit_damage_taken += damage
	if(can_interrupt && (hit_damage_taken >= interrupt_damage_threshold))
		owner.balloon_alert(owner, span_warning("You took too much damage, execution interrupted!"))
		interrupt()

/datum/action/cooldown/necro/execute/proc/interrupt()

/datum/action/cooldown/necro/execute/proc/try_advance_stage()

/datum/action/cooldown/necro/execute/proc/get_range()
	if(current_stage_index)
		if(!isnull(all_stages[current_stage_index].range))
			return all_stages[current_stage_index].range
	else
		//If no current stage, we havent started yet
		return start_range
	return range


#undef STATUS_NOT_STARTED
#undef STATUS_STARTING
#undef STATUS_PRE_FINISH
#undef STATUS_POST_FINISH
#undef STATUS_ENDED

#undef EXECUTION_CANCEL
#undef EXECUTION_RETRY
#undef EXECUTION_CONTINUE
#undef EXECUTION_SUCCESS
#undef EXECUTION_SAFETY
