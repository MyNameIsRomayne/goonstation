/obj/machinery/conveyor/loader
	name = "Conveyor Loader"
	desc = "A conveyor with a machine which loads items into the recipticale of other machines. Reciptical. Recieptible? fuck."

	var/base_loader_icon = 'icons/obj/factory.dmi'
	var/base_loader_iconstate = "loader-"

	/// How many objects to try and load each process tick
	var/objects_per_tick = 1

	/// Direction the loader on top will face
	var/load_dir = null

	// Sounds
	var/sound_grump = 'sound/machines/buzz-two.ogg'
	var/sound_catastrophic_failure = 'sound/machines/pod_alarm.ogg'

	/// What machine have we decided to load into?
	var/obj/machinery/target = null

	New()
		src.create_storage(/datum/storage/no_hud/loader, can_hold = list(/obj/item), slots = 1)
		src.UpdateIcon()
		src.get_load_target()
		if (isnull(load_dir))
			src.load_dir = src.dir_out
		..()

	disposing()
		src.remove_storage()
		..()

	update_icon()
		src.overlays = list()
		var/overlay_iconstate = null
		switch(src.dir)
			if (NORTH)
				overlay_iconstate = "[base_loader_iconstate]north"
			if (EAST)
				overlay_iconstate = "[base_loader_iconstate]east"
			if (SOUTH)
				overlay_iconstate = "[base_loader_iconstate]south"
			if (WEST)
				overlay_iconstate = "[base_loader_iconstate]west"
		var/image/overlay = image(src.base_loader_icon, src, overlay_iconstate)
		src.overlays += overlay
		..()

	attackby(obj/item/W, mob/user)
		if (ispryingtool(W))
			src.rotate()
		..()

	proc/rotate()
		switch (src.dir)
			if (NORTH)
				src.dir = EAST
			if (EAST)
				src.dir = SOUTH
			if (SOUTH)
				src.dir = WEST
			if (WEST)
				src.dir = NORTH
		src.UpdateIcon()
		src.get_load_target()

	Crossed(atom/movable/AM)
		if (QDELETED(AM))
			return
		if (AM.anchored)
			return
		if (!isitem(AM))
			return
		if (src.storage.check_can_hold(AM) && !src.storage.is_full())
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
		if (!target.storage.check_can_hold(I) || target.storage.is_full())
			return FALSE
		src.storage.transfer_stored_item(I, target, TRUE)
		return TRUE

	/// Gets the machinery we should be trying to load into.
	proc/get_load_target()
		var/turf/T = get_step(src, src.dir)
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
/datum/storage/no_hud/loader
	sneaky = TRUE
	move_triggered = FALSE
	/// How many items in a stack we transfer to others
	var/max_amount_to_others = 1
	/// How many items in a stack we transfer to ourselves
	var/max_amount_to_self = 1
	/// Maximum amount of items this can hold at once
	var/max_amount = 100

	storage_item_attack_by()
		return FALSE // bad

	storage_item_mouse_drop()
		return FALSE // no

	storage_item_attack_hand()
		return FALSE // i said no

	storage_item_after_attack()
		return FALSE // please no

	is_full()
		var/total_amount = 0
		for(var/obj/item/I in src.stored_items)
			total_amount += I.amount
			if (total_amount > src.max_amount)
				return FALSE
		return TRUE

	/// Goes through items in our storage, stacks it with something if possible, otherwise tries to add it to an empty slot.
	/// Fails that if we are at the slot limit
	add_contents(obj/item/I, mob/user = null, visible = TRUE)
		if (I in user?.equipped_list())
			user.u_equip(I)
		var/amt_stacked = 0
		for (var/obj/item/stored_item in src.stored_items)
			var/amt_stacked = stored_item.stack_item(I)
			if (amt_stacked > 0)
				I = stored_item
				break
		if (amt_stacked < I.amount)
			src.stored_items += I
		I.set_loc(src.linked_item, FALSE)
		src.hud.add_item(I, user)
		I.stored = src

		src.add_contents_extra(I, user, visible)
