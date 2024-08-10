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
		)

	ui_static_data(mob/user)
		. = list(
			"max_pressure" = PORTABLE_ATMOS_MAX_RELEASE_PRESSURE,
		)

	ui_act(action, list/params)

		switch(action)

			if ("toggle_advanced_mode")
				src.advanced_mode = !src.advanced_mode
				return TRUE

			if ("set_temperature")
				src.temperature = params["temperature"]
				return TRUE

			if ("set_volume")
				src.volume = params["volume"]
				return TRUE

			if ("set_moles")
				src.gas_moles[params["name"]] = params["matter"]
				return TRUE

			if ("set_pressure")
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
