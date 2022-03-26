#define MOB_ANY_STATE 0
#define MOB_CONTROLLED 1
#define MOB_NOT_CONTROLLED 2

/datum/element/auto_sound
	element_flags = ELEMENT_DETACH|ELEMENT_BESPOKE
	var/volume = VOLUME_MID
	var/extrarange = 2
	//A list of SOUND_X defines indicating what type of sound to play
	//Use subtypes to change this value
	var/list/valid_sounds = list(SOUND_SHOUT)
	//If true, only play sounds when a client is controlling the mob
	//If false, only play when not controlled
	//If null, play in both states
	var/play_when = MOB_ANY_STATE
	//How often to try to play sounds
	var/interval = 20 SECONDS
	//Random variation either side of interval
	var/variation = 15
	//Chance on each attempt, to actually play a sound
	var/probability = 50
	//Assoc list, holder = timer id
	var/list/timer_ids = list()

/datum/element/auto_sound/Attach(datum/holder ,_volume, _extrarange, _play_when, _interval, _variation, _probability, _playing)
	.=..()
	if(!ismob(holder))
		return ELEMENT_INCOMPATIBLE

	if(_volume)
		volume = _volume
	if(!isnull(_extrarange))
		extrarange = _extrarange
	if(!isnull(_play_when))
		play_when = _play_when
	if(_interval && _interval > 0) // Interval shouldn't be 0 or lower
		interval = _interval
	if(_variation)
		variation = _variation
	if(_probability)
		probability = _probability

	if(variation >= interval)
		stack_trace("Tried adding auto_sound element with variation bigger then interval. Setting variation to interval-1.")
		variation = interval - 1

	timer_ids[holder] = addtimer(CALLBACK(src, .proc/try_play_sound, holder), (interval+rand(-variation, variation)), TIMER_STOPPABLE|TIMER_DELETE_ME)

/datum/element/auto_sound/Detach(datum/target)
	deltimer(timer_ids[target])
	timer_ids -= target
	.=..()

/datum/element/auto_sound/proc/can_play_sound(mob/holder)
	if(holder.stat == DEAD)
		return FALSE

	if(play_when)
		if(play_when == MOB_CONTROLLED)
			if(holder.client)
				return TRUE
			return FALSE
		else
			if(!holder.client)
				return TRUE
			return FALSE
	return TRUE

/datum/element/auto_sound/proc/try_play_sound(mob/holder)
	if(can_play_sound(holder))
		if(prob(probability))
			holder.play_species_audio(holder, pick(valid_sounds), volume, TRUE, extrarange)

	timer_ids[holder] = addtimer(CALLBACK(src, .proc/try_play_sound, holder), (interval+rand(-variation, variation)), TIMER_STOPPABLE|TIMER_DELETE_ME)

#undef MOB_ANY_STATE
#undef MOB_CONTROLLED
#undef MOB_NOT_CONTROLLED
