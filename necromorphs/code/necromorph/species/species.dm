/datum/species
	var/list/species_audio = list()	//An associative list of lists, in the format SOUND_TYPE = list(sound_1, sound_2)
	var/list/species_audio_volume = list()		//An associative list, in the format SOUND_TYPE = VOLUME_XXX. Values set here will override the volume of species audio files

//Species level audio wrappers
//--------------------------------
/datum/species/proc/get_species_audio(audio_type)
	var/list/L = species_audio[audio_type]
	if (L)
		return pick_weight(L)
	return null

/datum/species/proc/play_species_audio(atom/source, audio_type, vol as num, vary, extrarange as num, falloff, is_global, frequency, is_ambiance = 0)
	var/soundin = get_species_audio(audio_type)
	if(soundin)
		playsound(source, soundin, vol, vary, extrarange, falloff, is_global, frequency, is_ambiance)
		return TRUE
	return FALSE


/mob/proc/play_species_audio()
	return

/mob/living/carbon/human/play_species_audio(atom/source, audio_type, volume = VOLUME_MID, vary = TRUE, extrarange as num, falloff, is_global, frequency, is_ambiance = 0)
	if(dna.species.species_audio_volume[audio_type])
		volume = dna.species.species_audio_volume[audio_type]
	return dna.species.play_species_audio(arglist(args.Copy()))

/mob/proc/get_species_audio()
	return

/mob/living/carbon/human/get_species_audio(var/audio_type)
	return dna.species.get_species_audio(arglist(args.Copy()))
