
ABSTRACT_TYPE(/obj/mapping_helper/machine_output)
/obj/mapping_helper/machine_output

	var/output_dir = null

	initialize()
		var/turf/T = get_turf(src)
		var/turf/target = get_step(src, src.output_dir)
		for (var/obj/machinery/M in T)
			if (istype(M, /obj/machinery/manufacturer))
				var/obj/machinery/manufacturer/manf = M
				manf.output_target = target
			if (istype(M, /obj/machinery/material_processor))
				var/obj/machinery/material_processor/mate = M
				mate.output_location = target
			if (istype(M, /obj/machinery/conveyor/loader))
				var/obj/machinery/conveyor/loader/load = M
				load.load_dir = src.output_dir
				load.get_load_target()
				load.UpdateIcon()
		..()

	north
		output_dir = NORTH
		icon_state = "output_north"

	east
		output_dir = EAST
		icon_state = "output_east"

	south
		output_dir = SOUTH
		icon_state = "output_south"

	west
		output_dir = WEST
		icon_state = "output_west"
