/datum/say_prefix/deadchat
	id = ":d"

/// Say prefix for """living""" beings in the afterlife bar/etc. This should not work anywhere else!
/datum/say_prefix/deadchat/process(datum/say_message/message, datum/speech_module_tree/say_tree)
	. = message

	var/mob/mob_speaker = message.speaker
	if (!inafterlife(mob_speaker))
		return
	var/datum/say_message/deadchat_message = message.Copy()
	say_tree.GetOutputByID(SPEECH_OUTPUT_DEADCHAT)?.process(deadchat_message)
