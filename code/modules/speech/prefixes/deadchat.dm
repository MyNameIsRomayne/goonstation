/datum/say_prefix/deadchat
	id = ":d"

/datum/say_prefix/deadchat/is_compatible_with(datum/say_message/message, datum/speech_module_tree/say_tree)
	return ismob(message.speaker) && inafterlife(message.speaker)

/datum/say_prefix/deadchat/process(datum/say_message/message, datum/speech_module_tree/say_tree)
	. = message

	if (!src.is_compatible_with(message, say_tree))
		return

	say_tree.GetOutputByID(SPEECH_OUTPUT_DEADCHAT)?.process(message.Copy())
