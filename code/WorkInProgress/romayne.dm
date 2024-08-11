var/static/list/valid_gases = list(
	"oxygen" = "O2",
	"nitrogen" = "N2",
	"carbon_dioxide" = "CO2",
	"toxins" = "Plasma",
	"farts" = "Farts",
	"radgas" = "Fallout",
	"nitrous_oxide" = "N20",
	"oxygen_agent_b" = "Oxygen Agent B"
)

#define MOLES_TO_KPA(particles_moles, temperature_kelvin, volume_liters) (((particles_moles) * (R_IDEAL_GAS_EQUATION) * (temperature_kelvin))/(volume_liters))
#define KPA_TO_MOLES(pressure_kpa, temperature_kelvin, volume_liters) (((pressure_kpa) * (volume_liters))/((R_IDEAL_GAS_EQUATION) * (temperature_kelvin)))

#define LITRE *1
#define LITRES LITRE

// specific strings to identify the kind of unit to use
#define UNIT_PASCALS "pascals"
#define UNIT_MOLES "moles"
#define UNIT_KELVIN "kelvin"
#define UNIT_CELSIUS "celsius"
#define UNIT_FARENHEIT "farenheit"

// specific flags to pick either pressure or matter as the chosen unit for 'stuff inside of tank'
#define USE_PRESSURE "pressure"
#define USE_MATTER "matter"

/obj/item/tanktest
	name = "Developer Tank Testing"
	icon = 'icons/obj/items/tank.dmi'
	icon_state = "oxygen"

	var/advanced_mode = FALSE

	var/use_temperature_unit = UNIT_KELVIN
	var/use_pressure_unit = UNIT_PASCALS
	var/use_matter_unit = UNIT_MOLES

	var/si_unit_used_contents = USE_PRESSURE

	var/temperature = T20C
	var/volume = 70 LITRES
	var/list/gas_moles = list()
	var/list/log_data = list()
	var/datum/gas_mixture/mix

	/// Return information about the pseudo-mixture as a keyed list.
	proc/mixture_info()
		var/list/info = list(
			"total_pressure" = 0,
			"total_moles" = 0,
			"temperature" = src.temperature,
			"volume" = src.volume,
			"data_each_gas" = list(),
		)
		for (var/gas in valid_gases)
			info["total_moles"] += src.gas_moles[gas]
			info["data_each_gas"] += list(list(
				id = gas,
				name = valid_gases[gas],
				UNIT_MOLES = src.gas_moles[gas],
				UNIT_PASCALS = MOLES_TO_KPA(src.gas_moles[gas], src.temperature, src.volume),
			))

		info["total_pressure"] = MOLES_TO_KPA(info["total_moles"], src.temperature, src.volume)

		return info

	New()
		..()
		src.mix = new /datum/gas_mixture
		for (var/gas in valid_gases)
			src.gas_moles[gas] = 0

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "DevBombSim", "DevBombSim")
			ui.open()

	ui_data(mob/user)
		. = list(
			"gas_data" = src.mixture_info(),
			"advanced_mode" = src.advanced_mode,
			"use_temperature_unit" = src.use_temperature_unit,
			"use_pressure_unit" = src.use_pressure_unit,
			"use_matter_unit" = src.use_matter_unit,
			"si_unit_used_contents" = src.si_unit_used_contents,
			"max_moles" = KPA_TO_MOLES(PORTABLE_ATMOS_MAX_RELEASE_PRESSURE, src.temperature, src.volume),
			"log_data" = src.log_data
		)

	ui_static_data(mob/user)
		. = list(
			"max_pressure" = PORTABLE_ATMOS_MAX_RELEASE_PRESSURE,
		)

	/// Update the gas mixture with our current parameters.
	proc/update_gas_mixture()
		src.mix.volume = src.volume
		src.mix.temperature = src.temperature
		for (var/gas in valid_gases)
			src.mix.vars[gas] = src.gas_moles[gas]

	/// Update the local simulacrum 'mixture' with the gas mixture.
	proc/load_from_gas_mixture()
		for (var/gas in valid_gases)
			src.gas_moles[gas] = src.mix.vars[gas]
		src.temperature = src.mix.temperature
		src.volume = src.mix.volume

	proc/mixture_as_dict(datum/gas_mixture/mix)
		var/out = list()
		for (var/gas in valid_gases)
			out[gas] = mix.vars[gas]
		out["temperature"] = mix.temperature
		out["volume"] = mix.volume
		out["heat_capacity"] = HEAT_CAPACITY(mix)
		out["thermal_energy"] = THERMAL_ENERGY(mix)
		return out

	//! Calculate delta using mix2 - mix1 (final - initial)
	proc/calculate_mixture_delta(datum/gas_mixture/mix1, datum/gas_mixture/mix2)
		// fuck it, im just doing it manually because idrc
		var/list/vars_get_delta_of = list(
			"oxygen", "nitrogen", "carbon_dioxide", "toxins", "farts", "radgas", "nitrous_oxide", "oxygen_agent_b", "temperature"
		)
		var/list/delta_output = list()
		for(var/todo in vars_get_delta_of) {
			delta_output[todo] = mix2.vars[todo] - mix1.vars[todo]
		}
		// a few special vars too to cement this as a different fucking thing because I GUESS.
		delta_output["heat_capacity"] = HEAT_CAPACITY(mix2) - HEAT_CAPACITY(mix1)
		delta_output["thermal_energy"] = THERMAL_ENERGY(mix2) - THERMAL_ENERGY(mix1)

	proc/format_log_data(list/unformatted_log_data)
		var/formatted_log_data = list()
		var/current = "pre"
		for (var/element in unformatted_log_data)
			if (istype(element, /datum/gas_mixture))
				formatted_log_data[current] = src.mixture_as_dict(element)
				current = "post"
			else if (unformatted_log_data[element])
				formatted_log_data[element] = unformatted_log_data[element]
		return formatted_log_data

	ui_act(action, list/params)

		switch(action)

			if ("console_log")
				boutput(world, "TGUI CONSOLE LOG: [params["data"]]")

			if ("clear_logs")
				src.log_data = list()
				return TRUE

			if ("copy_into_tank")
				var/obj/item/tank/empty/new_tank = new /obj/item/tank/empty
				src.update_gas_mixture()
				new_tank.air_contents.merge(src.mix)

				if (params["set_loc"])
					new_tank.set_loc(get_turf(src))
				return TRUE

			if ("do_reaction_step")
				// load src into mix
				src.update_gas_mixture()
				// react
				var/unformatted_log_data = list()
				src.mix.react(null, null, unformatted_log_data)
				src.log_data += list(src.format_log_data(unformatted_log_data))
				// load mix into src
				src.load_from_gas_mixture()
				return TRUE

			if ("toggle_advanced_mode")
				src.advanced_mode = !src.advanced_mode
				return TRUE

			if ("set_temperature")
				// this assumes kelvin. convert it to that if you pass in anything else
				switch (params["unit"])
					if (UNIT_KELVIN)
						src.temperature = params["value"]
					if (UNIT_CELSIUS)
						src.temperature = FROM_CELSIUS(params["value"])
					if (UNIT_FARENHEIT)
						src.temperature = FROM_FAHRENHEIT(params["value"])
				return TRUE

			if ("set_volume")
				// this assumes liters. convert it to that if you pass in anything else
				src.volume = params["volume"]
				return TRUE

			if ("set_matter")
				// you will need to handle each unit here if you choose to add something like grams. i dont know why you would. but i made it easy.
				src.gas_moles[params["name"]] = params["matter"]
				return TRUE

			if ("set_pressure")
				// this assumes pascals. add special params and whatnot if you want other things (any mmHg enjoyers?)
				src.gas_moles[params["name"]] = KPA_TO_MOLES(params["pressure"], src.temperature, src.volume)
				return TRUE

			if ("change_used_si_unit_contents")
				switch (params["unit"])
					if (USE_MATTER)
						src.si_unit_used_contents = USE_MATTER
					if (USE_PRESSURE)
						src.si_unit_used_contents = USE_PRESSURE
				return TRUE

			if ("set_unit")
				switch (params["unit"])
					if (UNIT_MOLES)
						src.use_matter_unit = UNIT_MOLES
					if (UNIT_PASCALS)
						src.use_pressure_unit = UNIT_PASCALS
					if (UNIT_KELVIN)
						src.use_temperature_unit = UNIT_KELVIN
					if (UNIT_CELSIUS)
						src.use_temperature_unit = UNIT_CELSIUS
					if (UNIT_FARENHEIT)
						src.use_temperature_unit = UNIT_FARENHEIT
				return TRUE

		// Post-Handling for pressure/moles change when advanced mode is off
		// TL;DR, don't go above 1013.25 kPa
		if (src.advanced_mode)
			return TRUE

		if ((action == "set_moles") || (action == "set_pressure"))
			var/total_pressure = src.mixture_info()["total_pressure"]
			if (total_pressure > PORTABLE_ATMOS_MAX_RELEASE_PRESSURE)
				var/moles_to_remove = KPA_TO_MOLES(total_pressure - PORTABLE_ATMOS_MAX_RELEASE_PRESSURE, src.temperature, src.volume)
				src.gas_moles[params["name"]] -= moles_to_remove
			src.gas_moles[params["name"]] = max(0, src.gas_moles[params["name"]])
			return TRUE

	attack_self(mob/user)
		ui_interact(user)
		. = ..()
