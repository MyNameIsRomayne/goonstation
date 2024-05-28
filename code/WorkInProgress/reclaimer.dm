/obj/machinery/material_processor
	name = "material processor"
	desc = "A sophisticated piece of machinery can process raw materials, scrap, and material sheets into bars."
	icon = 'icons/obj/scrap.dmi'
	icon_state = "reclaimer"
	anchored = ANCHORED
	density = 1
	event_handler_flags = NO_MOUSEDROP_QOL
	var/active = FALSE
	var/smelt_interval = 5 DECI SECONDS
	var/sound/sound_load = sound('sound/items/Deconstruct.ogg')
	var/sound/sound_process = sound('sound/effects/pop.ogg')
	var/sound/sound_grump = sound('sound/machines/buzz-two.ogg')
	var/atom/output_location = null
	var/list/atom/leftovers = list()

	New()
		src.create_storage(/datum/storage/no_hud, can_hold = list(/obj/item))
		..()

	attack_hand(var/mob/user)
		if (active)
			boutput(user, SPAN_ALERT("It's already working! Give it a moment!"))
			return
		if (length(src.contents) < 1)
			boutput(user, SPAN_ALERT("There's nothing inside to reclaim."))
			return
		user.visible_message("<b>[user.name]</b> switches on [src].")
		anchored = ANCHORED
		icon_state = "reclaimer-on"

		src.smelt_contents()

		active = 0
		anchored = UNANCHORED
		icon_state = "reclaimer"
		src.visible_message("<b>[src]</b> finishes working and shuts down.")

	process(var/mult)
		if (length(src.storage.get_contents()) > 0)
			src.smelt_contents()

	proc/smelt_contents()
		if (src.active)
			return
		src.active = TRUE
		var/reject = FALSE
		var/list/C = src.storage.get_contents()
		for (var/obj/item/I in C)
			if (istype(I, /obj/item/wizard_crystal))
				var/obj/item/wizard_crystal/wizard_crystal = I
				wizard_crystal.setMaterial(getMaterial(wizard_crystal.assoc_material), 0, 0, 1, 0)

			if (!istype(I.material))
				src.storage.transfer_stored_item(I, src.loc)
				reject = TRUE
				continue

			else if (istype(I, /obj/item/cable_coil))
				var/obj/item/cable_coil/coil = I
				src.output_bar_from_item(I, 1 / I.material_amt, coil.conductor.getID())
				qdel(coil)

			else
				src.output_bar_from_item(I, 1 / I.material_amt)
				qdel(I)

		src.active = FALSE
		if (reject)
			src.visible_message("<b>[src]</b> emits an angry buzz and rejects some unsuitable materials!")
			playsound(src.loc, sound_grump, 40, 1)

	proc/output_bar_from_item(obj/item/O, var/amount_per_bar = 1, var/extra_mat)
		if (!O || !O.material)
			return

		var/output_amount = O.amount

		if (amount_per_bar)
			var/bonus = leftovers[O.material.getID()]
			var/num_bars = O.amount / amount_per_bar + bonus

			output_amount = round(num_bars)
			if (output_amount != num_bars)
				leftovers[O.material.getID()] = num_bars - output_amount

		output_bar(O.material, output_amount, O.quality)

		if (extra_mat) // i hate this
			output_amount = O.amount

			if (amount_per_bar)
				var/bonus = leftovers[extra_mat]
				var/num_bars = O.amount / amount_per_bar + bonus

				output_amount = round(num_bars)
				if (output_amount != num_bars)
					leftovers[extra_mat] = num_bars - output_amount

			output_bar(extra_mat, output_amount, O.quality)

	proc/output_bar(material, amount, quality)

		if(amount <= 0)
			return

		var/datum/material/MAT = material
		if (!istype(MAT))
			MAT = getMaterial(material)
			if (!MAT)
				return

		var/atom/output_location = src.get_output_location()

		var/bar_type = getProcessedMaterialForm(MAT)
		var/obj/item/material_piece/BAR = new bar_type
		BAR.quality = quality
		BAR.name += getQualityName(quality)
		BAR.setMaterial(MAT)
		BAR.change_stack_amount(amount - 1)

		if (istype(output_location, /obj/machinery/manufacturer))
			var/obj/machinery/manufacturer/M = output_location
			M.change_contents(mat_piece = BAR)
		else
			BAR.set_loc(output_location)
			for (var/obj/item/material_piece/other_bar in output_location.contents)
				if (other_bar == BAR)
					continue
				if (BAR.material.isSameMaterial(other_bar.material))
					if (other_bar.stack_item(BAR))
						break

		playsound(src.loc, sound_process, 40, 1)

	proc/load_reclaim(obj/item/W as obj, mob/user as mob)
		. = FALSE
		if (src.is_valid(W) && brain_check(W, user, TRUE))
			if (W.stored)
				W.stored.transfer_stored_item(W, src, add_to_storage = TRUE, user = user)
			else
				if (user)
					user.u_equip(W)
				src.storage.add_contents(W, visible = FALSE)
			W.dropped(user)
			. = TRUE

	attackby(obj/item/W, mob/user)

		if (istype(W, /obj/item/ore_scoop))
			var/obj/item/ore_scoop/scoop = W
			W = scoop.satchel
		if (W.storage || istype(W, /obj/item/satchel))
			var/items = W
			if (W.storage)
				items = W.storage.get_contents()
			for(var/obj/item/O in items)
				if (load_reclaim(O))
					. = TRUE
			if (istype(W, /obj/item/satchel) && .)
				W.UpdateIcon()
			//Users loading individual items would make an annoying amount of messages
			//But loading a container is more noticable and there should be less
			if (.)
				user.visible_message("<b>[user.name]</b> loads [W] into [src].")
				playsound(src, sound_load, 40, TRUE)
				logTheThing(LOG_STATION, user, "loads [W] into \the [src] at [log_loc(src)].")
		else if (W?.cant_drop)
			boutput(user, SPAN_ALERT("You can't put that in [src] when it's attached to you!"))
			return ..()
		else if (load_reclaim(W, user))
			boutput(user, "You load [W] into [src].")
			playsound(src, sound_load, 40, TRUE)
			logTheThing(LOG_STATION, user, "loads [W] into \the [src] at [log_loc(src)].")
		else
			. = ..()

	mouse_drop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, SPAN_ALERT("Get your filthy dead fingers off that!"))
			return

		if(over_object == src)
			output_location = null
			boutput(usr, SPAN_NOTICE("You reset the processor's output target."))
			return

		if(BOUNDS_DIST(over_object, src) > 0)
			boutput(usr, SPAN_ALERT("The processor is too far away from the target!"))
			return

		if(BOUNDS_DIST(over_object, usr) > 0)
			boutput(usr, SPAN_ALERT("You are too far away from the target!"))
			return

		if (istype(over_object,/obj/storage/crate/))
			var/obj/storage/crate/C = over_object
			if (C.locked || C.welded)
				boutput(usr, SPAN_ALERT("You can't use a currently unopenable crate as an output target."))
			else
				src.output_location = over_object
				boutput(usr, SPAN_NOTICE("You set the processor to output to [over_object]!"))

		else if (istype(over_object,/obj/storage/cart/))
			var/obj/storage/cart/C = over_object
			if (C.locked || C.welded)
				boutput(usr, SPAN_ALERT("You can't use a currently unopenable cart as an output target."))
			else
				src.output_location = over_object
				boutput(usr, SPAN_NOTICE("You set the processor to output to [over_object]!"))

		else if (istype(over_object,/obj/machinery/manufacturer/))
			var/obj/machinery/manufacturer/M = over_object
			if (M.status & BROKEN || M.status & NOPOWER || M.dismantle_stage > 0)
				boutput(usr, SPAN_ALERT("You can't use a non-functioning manufacturer as an output target."))
			else
				src.output_location = M
				boutput(usr, SPAN_NOTICE("You set the processor to output to [over_object]!"))

		else if (istype(over_object,/obj/table/) && istype(over_object,/obj/rack/))
			var/obj/O = over_object
			src.output_location = O.loc
			boutput(usr, SPAN_NOTICE("You set the processor to output on top of [O]!"))

		else if (istype(over_object,/turf/simulated/floor/))
			src.output_location = over_object
			boutput(usr, SPAN_NOTICE("You set the processor to output to [over_object]!"))

		else
			boutput(usr, SPAN_ALERT("You can't use that as an output target."))
		return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!O || !user)
			return

		if(!isliving(user))
			boutput(user, SPAN_ALERT("Only living mobs are able to use the processor's quick-load feature."))
			return

		if (!isobj(O))
			boutput(user, SPAN_ALERT("You can't quick-load that."))
			return

		if(BOUNDS_DIST(O, user) > 0)
			boutput(user, SPAN_ALERT("You are too far away!"))
			return

		if (istype(O, /obj/storage/crate/) || istype(O, /obj/storage/cart/))
			user.visible_message(SPAN_NOTICE("[user] uses [src]'s automatic loader on [O]!"), SPAN_NOTICE("You use [src]'s automatic loader on [O]."))
			var/amtload = 0
			for (var/obj/item/raw_material/M in O.contents)
				M.set_loc(src)
				amtload++
			if (amtload) boutput(user, SPAN_NOTICE("[amtload] materials loaded from [O]!"))
			else boutput(user, SPAN_ALERT("No material loaded!"))

		else if (is_valid(O))
			quickload(user,O)
		else
			..()

	proc/quickload(var/mob/living/user,var/obj/item/O)
		if (!user || !O)
			return
		user.visible_message(SPAN_NOTICE("[user] begins quickly stuffing [O] into [src]!"))
		var/staystill = user.loc
		for(var/obj/item/M in view(1,user))
			if (!M || M.loc == user)
				continue
			if (M.name != O.name)
				continue
			if(!(src.is_valid(M) && brain_check(M, user, FALSE)))
				continue
			src.storage.add_contents(M, user, visible = FALSE)
			playsound(src, sound_load, 40, TRUE)
			sleep(0.5)
			if (user.loc != staystill) break
		boutput(user, SPAN_NOTICE("You finish stuffing [O] into [src]!"))
		return

	proc/get_output_location()
		if (!output_location)
			return src.loc

		if (!(BOUNDS_DIST(src.output_location, src) == 0))
			output_location = null
			return src.loc

		if (istype(output_location,/obj/machinery/manufacturer))
			var/obj/machinery/manufacturer/M = output_location
			if (M.status & NOPOWER || M.status & BROKEN | M.dismantle_stage > 0)
				return M.loc
			return M

		if (istype(output_location,/obj/storage))
			var/obj/storage/S = output_location
			if (S.locked || S.welded || S.open)
				return S.loc
			return S

		return output_location

	proc/is_valid(var/obj/item/I)
		if (!istype(I))
			return
		return (I.material && !istype(I,/obj/item/material_piece) && !istype(I,/obj/item/nuclear_waste)) || istype(I,/obj/item/wizard_crystal)

	proc/brain_check(var/obj/item/I, var/mob/user, var/ask)
		if (!istype(I))
			return
		var/obj/item/organ/brain/brain = null
		if (istype(I, /obj/item/parts/robot_parts/head))
			var/obj/item/parts/robot_parts/head/head = I
			brain = head.brain
		else if (istype(I, /obj/item/organ/brain))
			brain = I

		if (brain)
			if (!ask)
				boutput(user, SPAN_ALERT("[I] turned the intelligence detection light on! You decide to not load it for now."))
				return FALSE
			var/accept = tgui_alert(user, "Possible intelligence detected. Are you sure you want to reclaim [I]?", "Incinerate brain?", list("Yes", "No")) == "Yes" && can_reach(user, src) && user.equipped() == I
			if (accept)
				logTheThing(LOG_COMBAT, user, "loads [brain] (owner's ckey [brain.owner ? brain.owner.ckey : null]) into a material processor.")
			return accept
		return TRUE
