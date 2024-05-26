/obj/machinery/loader
	name = "Loader"
	desc = "A machine which loads items into the recipticale of other machines. Reciptical. Recieptible? fuck."
	icon = 'icons/obj/factory.dmi'
	icon_state = "loader"

	/// How many objects to try and load each process tick
	var/objects_per_tick = 1

	// Sounds
	var/sound_grump = 'sound/machines/buzz-two.ogg'
	var/sound_catastrophic_failure = 'sound/machines/pod_alarm.ogg'

	/// Which direction are we loading into?
	var/load_dir = NORTH
	/// What machine have we decided to load into?
	var/obj/machinery/target = null

	New()
		src.create_storage(/datum/storage/no_hud/internal, can_hold = list(/obj/item))
		..()

	disposing()
		src.remove_storage()
		..()

	Crossed(atom/movable/AM)
		if (QDELETED(AM))
			return
		if (AM.anchored)
			return
		if (!isitem(AM))
			return
		if (src.storage.check_can_hold(AM))
			src.storage.add_contents(AM, visible = FALSE)
		..()

	/// Every tick, check if we have an item to try and load. If we can't load it, throw it somewhere random
	process(var/mult)
		var/list/contents = src.storage.get_contents()
		if (length(contents) == 0)
			return
		var/obj/item/I = contents[1]
		var/loaded = src.try_load_item(I)
		if (!loaded)
			src.grump("The loader was unable to insert [I]!")
			src.fling_item_from_storage(I)
		..()

	/// Try to load the passed item into the current target machine, and return whether we did or not.
	proc/try_load_item(obj/item/I)
		if (isnull(I))
			return FALSE
		if (isnull(src.target))
			if (!src.get_load_target())
				return FALSE
		if (!target.storage.check_can_hold(I))
			return FALSE
		src.storage.transfer_stored_item(I, target, TRUE)
		return TRUE

	/// Gets the machinery we should be trying to load into.
	proc/get_load_target()
		var/turf/T = get_step(src, src.load_dir)
		for (var/obj/machinery/M in T.contents)
			if (!isnull(M.storage))
				src.target = M
				return TRUE
		return FALSE

	proc/grump(var/message)
		playsound(src, src.sound_grump, 50, 1)
		src.visible_message(SPAN_ALERT(message))

	proc/fling_item_from_storage(obj/item/I)
		if (isnull(I))
			return
		// Generate an associative list of turf=dir to throw this from, in some given direction, as throwing from src.loc reinserts it immediately
		// if we can't find a non-dense turf to throw this at, explode because fuck you for doing that >:(
		var/list/safe_turfs = list()
		for (var/dir in alldirs)
			var/safe = TRUE
			var/turf/T = get_step(src, dir)
			for (var/atom/A in T)
				if (A.density)
					safe = FALSE
					break
			if (safe)
				safe_turfs[T] = dir

		if (length(safe_turfs) == 0)
			src.catastrophic_fail()
			return

		var/turf/T = pick(safe_turfs)
		var/dir = safe_turfs[T]

		src.storage.transfer_stored_item(I, T)
		var/atom/target = get_edge_cheap(src, dir)
		I.throw_at(target, 5, 2)

	proc/catastrophic_fail()
		src.visible_message(SPAN_ALERT("[src] is overloading!!! RUN!!!"))
		playsound(src, src.sound_catastrophic_failure, 75, 1)
		SPAWN(3 SECONDS)
			blowthefuckup(1, TRUE)

/// For things which are meant to be a part of a machine. No rustling, no interacting with by hand, etc. DONT!!!
/datum/storage/no_hud/internal
	sneaky = TRUE
	move_triggered = FALSE

	storage_item_attack_by()
		return FALSE // bad

	storage_item_mouse_drop()
		return FALSE // no

	storage_item_attack_hand()
		return FALSE // i said no

	storage_item_after_attack()
		return FALSE // please no


