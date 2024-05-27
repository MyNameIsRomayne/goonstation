#define MAX_ORES_PER_TICK 100

/obj/machinery/quarry
	name = "quarry"
	desc = "description whenever you yell at 1-800-IMCODER"
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "hedron-MtoW"

	/// List of resources this quarry will output. Should be generated from planet composition, but doesnt exist yet
	/// TODO: Quarries generate mats from some factors based off seed/planet
	var/output_resources = list(/obj/item/raw_material/mauxite)

	/// How many resources we will output after process(). Used with mult to have resource output be predictible
	var/resources_to_output = 0

	/// How fast the quarry outputs ores.
	var/ores_per_second = 1

	/// The direction to output ores in.
	var/output_dir = EAST
	/// The turf to spawn ores on. Chosen from original loc and output_dir
	var/turf/output_turf

	New()
		. = ..()
		output_turf = get_step(src, output_dir)
		if (!output_turf)
			CRASH("could not get output turf for [src]")

	process(var/mult)
		src.resources_to_output = (src.ores_per_second * mult)
		if (src.resources_to_output > 0)
			src.output_resources()

	proc/can_output()
		if (isnull(src.output_turf))
			return FALSE
		for (var/atom/A in src.output_turf)
			if (!ismob(A) && (A.density == TRUE))
				return FALSE
		return TRUE

	proc/output_resources()
		if (!src.can_output())
			return FALSE
		var/integer_output = floor(src.resources_to_output)
		integer_output = min(integer_output, MAX_ORES_PER_TICK)
		if (integer_output < 0)
			CRASH("Somehow, the ores to output this tick for [src] is [integer_output]. bad!")
		for (var/i in 1 to integer_output)
			/// TODO: replace with weighted pick, or deterministic one-ore output system
			var/obj/item/raw_mat = new pick(src.output_resources)
			set_loc(raw_mat, src.output_turf)

#undef MAX_ORES_PER_TICK
